#include <Rcpp.h>
#include <cstdint>
#include <vector>
using namespace Rcpp;

// Double-dummy Skat solver: perfect-information alpha-beta search returning the
// maximum card points the declarer can guarantee from a given position.
//
// Cards are passed in as integer codes 0..31. Encoding and ordering are set up
// on the R side and passed in via lookup vectors so the C++ core stays purely
// numeric.
//
// search() returns the points the declarer collects *from this position
// onward*, not a running total. That makes the value a function of the
// position alone, which is what lets the transposition table below memoise it:
// the same distribution of remaining cards is worth the same regardless of how
// many points either side has already banked.

struct Position {
  // Each of three seats holds a bitmask of remaining cards (bit i = card i).
  std::uint32_t hand[3];
  int n_cards;         // cards still held across all three hands
  int leader;          // seat to lead / next to play within the trick
  int trick_cards[3];  // cards played so far this trick (-1 if empty)
  int trick_seats[3];  // seats that played them
  int n_in_trick;      // how many cards are in the current trick
  int declarer;        // which seat is the declarer
};

// Globals for the current solve, set by sk_solve_dd_cpp().
static std::vector<int> g_points;    // card -> card points
static std::vector<int> g_strength;  // card -> trick strength (higher wins)
static std::vector<int> g_eff_suit;  // card -> effective suit id (trump = 4)

// Nodes visited since the last interrupt poll. Checking on every node is far
// too expensive; every few hundred thousand keeps Ctrl-C responsive.
static long g_nodes = 0;
static const long kInterruptEvery = 262144L;

// --- transposition table ----------------------------------------------------
//
// A fixed-size, always-replace table. Each slot stores the full position key,
// so a hash collision is detected on probe and simply misses; the table can
// never return the value of a different position. Sizing is derived from the
// position, so a two-trick endgame allocates a few kilobytes and only a deep
// solve pays for a large table.

static const std::int8_t kFlagEmpty = 0;
static const std::int8_t kFlagExact = 1;
static const std::int8_t kFlagLower = 2;
static const std::int8_t kFlagUpper = 3;

struct TTEntry {
  std::uint32_t h0, h1, h2, meta;
  std::int16_t value;
  std::int8_t flag;
};

static std::vector<TTEntry> g_tt;
static std::size_t g_tt_mask = 0;

// Positions with fewer than this many cards left are cheaper to re-search than
// to store: the last trick is a handful of nodes.
static const int kTTMinCards = 6;

// The seats that played into the current trick follow the seat to move, so the
// key needs only the leader, how many cards are down, and which they were.
static inline std::uint32_t tt_meta(const Position& pos) {
  std::uint32_t m = static_cast<std::uint32_t>(pos.leader) |
                    (static_cast<std::uint32_t>(pos.n_in_trick) << 2);
  if (pos.n_in_trick > 0) {
    m |= static_cast<std::uint32_t>(pos.trick_cards[0] + 1) << 4;
  }
  if (pos.n_in_trick > 1) {
    m |= static_cast<std::uint32_t>(pos.trick_cards[1] + 1) << 10;
  }
  return m;
}

static inline std::uint64_t tt_mix(std::uint64_t x) {
  x ^= x >> 33;
  x *= 0xff51afd7ed558ccdULL;
  x ^= x >> 33;
  x *= 0xc4ceb9fe1a85ec53ULL;
  x ^= x >> 33;
  return x;
}

static inline std::size_t tt_index(std::uint32_t h0, std::uint32_t h1,
                                   std::uint32_t h2, std::uint32_t meta) {
  std::uint64_t a = (static_cast<std::uint64_t>(h0) << 32) ^ h1;
  std::uint64_t b = (static_cast<std::uint64_t>(h2) << 32) ^ meta;
  return static_cast<std::size_t>(tt_mix(a ^ tt_mix(b)) & g_tt_mask);
}

// Determine winning position (0..2) within a completed 3-card trick.
static int trick_winner(const int cards[3]) {
  int led = g_eff_suit[cards[0]];
  bool any_trump = false;
  for (int i = 0; i < 3; ++i) if (g_eff_suit[cards[i]] == 4) any_trump = true;
  int best = -1, best_str = -1;
  for (int i = 0; i < 3; ++i) {
    int es = g_eff_suit[cards[i]];
    bool eligible = any_trump ? (es == 4) : (es == 4 || es == led);
    if (eligible && g_strength[cards[i]] > best_str) {
      best_str = g_strength[cards[i]];
      best = i;
    }
  }
  return best;
}

// Would `card` take the lead in a trick whose best card so far is `best_card`
// and whose led effective suit is `led`? Mirrors trick_winner()'s rule.
static inline bool beats(int card, int best_card, int led) {
  int es = g_eff_suit[card];
  int bs = g_eff_suit[best_card];
  if (es == 4) return bs != 4 || g_strength[card] > g_strength[best_card];
  if (bs == 4) return false;
  return es == led && g_strength[card] > g_strength[best_card];
}

// Legal moves for a seat given the led effective suit (-1 if leading). Fills
// `out` and returns the count; a plain array avoids allocating at every node.
static int legal_moves(std::uint32_t hand, int led_suit, int* out) {
  int n_all = 0, n_follow = 0;
  int all[32], follow[32];
  for (int c = 0; c < 32; ++c) {
    if (hand & (1u << c)) {
      all[n_all++] = c;
      if (led_suit >= 0 && g_eff_suit[c] == led_suit) follow[n_follow++] = c;
    }
  }
  if (led_suit >= 0 && n_follow > 0) {
    for (int i = 0; i < n_follow; ++i) out[i] = follow[i];
    return n_follow;
  }
  for (int i = 0; i < n_all; ++i) out[i] = all[i];
  return n_all;
}

// Move ordering. Alpha-beta prunes hardest when the strongest reply is tried
// first, so cards that take the trick go first (both sides want the trick:
// the declarer to bank its points, the defenders to deny them), and within
// each group the higher card leads. Ordering can never change the value of a
// full-window search -- only how many nodes it takes to find it.
static void order_moves(const Position& pos, int* moves, int n) {
  if (n < 2) return;

  int led = pos.n_in_trick > 0 ? g_eff_suit[pos.trick_cards[0]] : -1;
  int best_card = -1;
  if (pos.n_in_trick > 0) {
    best_card = pos.trick_cards[0];
    for (int i = 1; i < pos.n_in_trick; ++i) {
      if (beats(pos.trick_cards[i], best_card, led)) {
        best_card = pos.trick_cards[i];
      }
    }
  }

  int score[32];
  for (int i = 0; i < n; ++i) {
    bool takes = best_card < 0 || beats(moves[i], best_card, led);
    score[i] = g_strength[moves[i]] + (takes ? 1000 : 0);
  }

  // Insertion sort, descending: n is at most ten.
  for (int i = 1; i < n; ++i) {
    int m = moves[i], s = score[i], j = i - 1;
    while (j >= 0 && score[j] < s) {
      moves[j + 1] = moves[j];
      score[j + 1] = score[j];
      --j;
    }
    moves[j + 1] = m;
    score[j + 1] = s;
  }
}

// Recursive alpha-beta. Returns the card points the DECLARER collects from this
// position onward, exactly (fail-soft bounds outside the window, as usual).
static int search(Position& pos, int alpha, int beta) {
  if (++g_nodes % kInterruptEvery == 0) Rcpp::checkUserInterrupt();

  if (pos.n_cards == 0 && pos.n_in_trick == 0) return 0;

  const int alpha_orig = alpha, beta_orig = beta;

  const bool use_tt = pos.n_cards >= kTTMinCards;
  std::size_t slot = 0;
  std::uint32_t meta = 0;
  if (use_tt) {
    meta = tt_meta(pos);
    slot = tt_index(pos.hand[0], pos.hand[1], pos.hand[2], meta);
    const TTEntry& e = g_tt[slot];
    if (e.flag != kFlagEmpty && e.h0 == pos.hand[0] && e.h1 == pos.hand[1] &&
        e.h2 == pos.hand[2] && e.meta == meta) {
      int v = e.value;
      if (e.flag == kFlagExact) return v;
      if (e.flag == kFlagLower) {
        if (v > alpha) alpha = v;
      } else {
        if (v < beta) beta = v;
      }
      if (alpha >= beta) return v;
    }
  }

  int seat = pos.leader;
  int led_suit = pos.n_in_trick > 0 ? g_eff_suit[pos.trick_cards[0]] : -1;
  int moves[32];
  int n_moves = legal_moves(pos.hand[seat], led_suit, moves);
  order_moves(pos, moves, n_moves);

  bool maximizing = (seat == pos.declarer);
  int best = maximizing ? -1 : 1000;

  for (int i = 0; i < n_moves; ++i) {
    const int card = moves[i];
    Position next = pos;
    next.hand[seat] &= ~(1u << card);
    next.n_cards -= 1;
    next.trick_cards[next.n_in_trick] = card;
    next.trick_seats[next.n_in_trick] = seat;
    next.n_in_trick += 1;

    int gain = 0;
    if (next.n_in_trick == 3) {
      int wp = trick_winner(next.trick_cards);
      int winner_seat = next.trick_seats[wp];
      int tp = 0;
      for (int k = 0; k < 3; ++k) tp += g_points[next.trick_cards[k]];
      if (winner_seat == pos.declarer) gain = tp;
      next.leader = winner_seat;
      next.n_in_trick = 0;
      next.trick_cards[0] = next.trick_cards[1] = next.trick_cards[2] = -1;
    } else {
      next.leader = (seat + 1) % 3;
    }

    // The window shifts by the points banked on the way into the child, since
    // the child reports only what is still to come.
    int val = gain + search(next, alpha - gain, beta - gain);

    if (maximizing) {
      if (val > best) best = val;
      if (best > alpha) alpha = best;
    } else {
      if (val < best) best = val;
      if (best < beta) beta = best;
    }
    if (alpha >= beta) break;  // prune
  }

  if (use_tt) {
    TTEntry& e = g_tt[slot];
    e.h0 = pos.hand[0];
    e.h1 = pos.hand[1];
    e.h2 = pos.hand[2];
    e.meta = meta;
    e.value = static_cast<std::int16_t>(best);
    // Fail-soft bounds: at or below the incoming alpha the value is an upper
    // bound on the truth, at or above beta a lower bound, in between exact.
    e.flag = best <= alpha_orig ? kFlagUpper
                                : (best >= beta_orig ? kFlagLower : kFlagExact);
  }

  return best;
}

// Releases the table however the solve ends, including on a user interrupt.
struct TTGuard {
  ~TTGuard() {
    std::vector<TTEntry>().swap(g_tt);
    g_tt_mask = 0;
  }
};

//' Solve a double-dummy Skat endgame (C++ core)
//'
//' @param hand0,hand1,hand2 Integer vectors of card codes (0-31) held by seats
//'   0, 1, and 2.
//' @param leader Integer seat (0-2) to lead the next trick.
//' @param declarer Integer seat (0-2) that is the declarer.
//' @param points Integer vector of length 32: card -> card points.
//' @param strength Integer vector of length 32: card -> trick strength.
//' @param eff_suit Integer vector of length 32: card -> effective suit id
//'   (0-3 for suits, 4 for trump).
//' @return Integer: the maximum card points the declarer can guarantee.
//' @keywords internal
// [[Rcpp::export]]
int sk_solve_dd_cpp(IntegerVector hand0, IntegerVector hand1,
                    IntegerVector hand2, int leader, int declarer,
                    IntegerVector points, IntegerVector strength,
                    IntegerVector eff_suit) {
  if (points.size() != 32 || strength.size() != 32 || eff_suit.size() != 32) {
    Rcpp::stop("points, strength and eff_suit must each have length 32.");
  }
  g_points.assign(points.begin(), points.end());
  g_strength.assign(strength.begin(), strength.end());
  g_eff_suit.assign(eff_suit.begin(), eff_suit.end());
  g_nodes = 0;

  Position pos;
  pos.hand[0] = pos.hand[1] = pos.hand[2] = 0u;
  pos.n_cards = 0;
  const IntegerVector* seats[3] = {&hand0, &hand1, &hand2};
  for (int s = 0; s < 3; ++s) {
    for (int c : *seats[s]) {
      if (c < 0 || c > 31) Rcpp::stop("Card ids must lie in 0:31.");
      pos.hand[s] |= (1u << c);
      pos.n_cards += 1;
    }
  }
  pos.leader = leader;
  pos.declarer = declarer;
  pos.n_in_trick = 0;
  pos.trick_cards[0] = pos.trick_cards[1] = pos.trick_cards[2] = -1;

  // A two-card endgame wants a few kilobytes and a ten-trick solve millions of
  // slots, so size the table from the position: roughly one slot per four
  // distinct positions the search is expected to reach, floored at 1024 slots
  // and capped at about 20 MB.
  int bits = pos.n_cards - 2;
  if (bits < 10) bits = 10;
  if (bits > 20) bits = 20;
  TTGuard guard;
  g_tt.assign(static_cast<std::size_t>(1) << bits, TTEntry());
  g_tt_mask = g_tt.size() - 1;

  return search(pos, -1, 1000);
}
