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

struct Position {
  // Each of three seats holds a bitmask of remaining cards (bit i = card i).
  std::uint32_t hand[3];
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

static inline int popcount32(std::uint32_t x) {
  int c = 0;
  while (x) { x &= (x - 1); ++c; }
  return c;
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

// Legal moves for a seat given the led effective suit (-1 if leading).
static std::vector<int> legal_moves(std::uint32_t hand, int led_suit) {
  std::vector<int> all, follow;
  for (int c = 0; c < 32; ++c) {
    if (hand & (1u << c)) {
      all.push_back(c);
      if (led_suit >= 0 && g_eff_suit[c] == led_suit) follow.push_back(c);
    }
  }
  if (led_suit >= 0 && !follow.empty()) return follow;
  return all;
}

// Recursive alpha-beta. Returns max card points the DECLARER can collect from
// this position onward. `declarer_points` accumulates completed-trick points.
static int search(Position& pos, int declarer_points, int alpha, int beta) {
  if (++g_nodes % kInterruptEvery == 0) Rcpp::checkUserInterrupt();

  int total_cards = popcount32(pos.hand[0]) + popcount32(pos.hand[1]) +
                    popcount32(pos.hand[2]);
  if (total_cards == 0 && pos.n_in_trick == 0) {
    return declarer_points;
  }

  int seat = pos.leader;
  int led_suit = pos.n_in_trick > 0 ? g_eff_suit[pos.trick_cards[0]] : -1;
  std::vector<int> moves = legal_moves(pos.hand[seat], led_suit);

  bool maximizing = (seat == pos.declarer);
  int best = maximizing ? -1 : 1000;

  for (int card : moves) {
    Position next = pos;
    next.hand[seat] &= ~(1u << card);
    next.trick_cards[next.n_in_trick] = card;
    next.trick_seats[next.n_in_trick] = seat;
    next.n_in_trick += 1;

    int gain = declarer_points;
    if (next.n_in_trick == 3) {
      int wp = trick_winner(next.trick_cards);
      int winner_seat = next.trick_seats[wp];
      int tp = 0;
      for (int i = 0; i < 3; ++i) tp += g_points[next.trick_cards[i]];
      if (winner_seat == pos.declarer) gain += tp;
      next.leader = winner_seat;
      next.n_in_trick = 0;
      next.trick_cards[0] = next.trick_cards[1] = next.trick_cards[2] = -1;
    } else {
      next.leader = (seat + 1) % 3;
    }

    int val = search(next, gain, alpha, beta);

    if (maximizing) {
      if (val > best) best = val;
      if (best > alpha) alpha = best;
    } else {
      if (val < best) best = val;
      if (best < beta) beta = best;
    }
    if (alpha >= beta) break;  // prune
  }
  return best;
}

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
  const IntegerVector* seats[3] = {&hand0, &hand1, &hand2};
  for (int s = 0; s < 3; ++s) {
    for (int c : *seats[s]) {
      if (c < 0 || c > 31) Rcpp::stop("Card ids must lie in 0:31.");
      pos.hand[s] |= (1u << c);
    }
  }
  pos.leader = leader;
  pos.declarer = declarer;
  pos.n_in_trick = 0;
  pos.trick_cards[0] = pos.trick_cards[1] = pos.trick_cards[2] = -1;

  return search(pos, 0, -1, 1000);
}
