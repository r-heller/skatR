# Changelog

## skatR 0.2.0

### Rule corrections

- Hand games include the skat in the declarer’s card points and matador
  count, and automatically computed values include an achieved Schneider
  or Schwarz.
- Announced levels (Schneider, Schwarz, ouvert) follow the official hand
  and announcement levels with their implied requirements; Schneider
  needs 90 points and Schwarz all tricks. Null keeps its fixed values
  23/35/46/59. Corrected scores can therefore differ from 0.1.0.
- Deals are validated as 32 unique cards before any player runs;
  fractional and non-finite inputs and score overflow are rejected.

### CRAN preparation

- The package help page uses the vector logo, which is now shipped in
  the source package; the build no longer leaves an empty `tools/`
  directory.
- GitHub Actions check the package on R devel, release and oldrel-1.
- Added spelling `WORDLIST` entries and updated `cran-comments.md`.

## skatR 0.1.0

### Initial release

#### Cards and ordering

- [`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md),
  [`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md),
  [`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md):
  the 32-card Skat deck and card points.
- [`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md),
  [`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md):
  split a card code into its parts.
- [`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md),
  [`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md),
  [`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md),
  [`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md):
  game-type-aware trick ordering, including the rule that jacks are
  trumps in suit and grand games but plain cards in null games.
- [`format()`](https://rdrr.io/r/base/format.html),
  [`print()`](https://rdrr.io/r/base/print.html), and `[` methods for
  `sk_card`, so hands render with suit symbols and stay `sk_card`
  objects when subset.

#### Bidding

- [`sk_base_value()`](https://r-heller.github.io/skatR/reference/sk_base_value.md),
  [`sk_matadors()`](https://r-heller.github.io/skatR/reference/sk_matadors.md),
  [`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md):
  game-value (Reizwert) computation, with the four fixed null values.

#### Play and scoring

- [`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md),
  [`sk_trick_winner()`](https://r-heller.github.io/skatR/reference/sk_trick_winner.md),
  [`sk_count_points()`](https://r-heller.github.io/skatR/reference/sk_count_points.md):
  trick mechanics.
- [`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md):
  win/loss, schneider, and schwarz resolution.

#### Players

- [`sk_player()`](https://r-heller.github.io/skatR/reference/sk_player.md),
  [`sk_choose()`](https://r-heller.github.io/skatR/reference/sk_choose.md):
  random, heuristic, and Monte Carlo strategies.
- [`sk_mcts_move()`](https://r-heller.github.io/skatR/reference/sk_mcts_move.md):
  determinized Monte Carlo move selection.

#### Solver

- [`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md):
  exact double-dummy endgame solver (Rcpp alpha-beta). Returns the card
  points the declarer can guarantee against perfect defence, counting
  the points on the declarer’s own cards.

- The search carries a transposition table and move ordering. The table
  is keyed on the three hand masks plus the trick in progress and stores
  what the declarer collects from that position onward, which is
  independent of the points already banked; every slot holds its full
  key, so a hash collision misses rather than answering for a different
  position. Move ordering tries cards that take the trick first, highest
  first. Both are optimisations only: the values returned are unchanged,
  and `tests/testthat/test-solver.R` pins the hand-traced positions, a
  set of five- and six-trick values recorded from the previous solver,
  and agreement with an independent minimax written against the R rules
  engine.

- Measured on this machine (R 4.6.1, x86_64 Linux, g++ 13.3, `-O2`),
  solving the last *n* cards of each hand from `sk_deal(seed = s)` with
  the declarer on lead:

  | position                        |  before |   after | speedup |
  |---------------------------------|--------:|--------:|--------:|
  | grand, 7 cards each, `seed = 7` |  2.72 s | 0.016 s |    170x |
  | clubs, 7 cards each, `seed = 7` |  1.17 s | 0.014 s |     84x |
  | grand, 8 cards each, `seed = 1` |  2.29 s | 0.016 s |    143x |
  | clubs, 8 cards each, `seed = 1` |  1.04 s | 0.005 s |    208x |
  | grand, 8 cards each, `seed = 7` | 63.96 s | 0.033 s |   1938x |
  | clubs, 8 cards each, `seed = 7` | 92.68 s | 0.119 s |    779x |

  Over the whole twenty-position sweep (four to eight cards per hand,
  grand and clubs, two deals each) the total falls from 164.3 s to 0.23
  s, with every one of the twenty values unchanged. Small positions are
  no slower: the four-card ones come in at 0.4-0.6 ms either way. Whole
  ten-trick deals were never benchmarked on the old solver because they
  did not finish in reasonable time; twenty sampled deals now solve in
  0.06-12.8 s, median 0.33 s.

- [`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md)
  gains `max_tricks` (default 8), which rejects a position deeper than
  the given number of cards per hand instead of starting a search that
  may not finish. The error suggests slicing the endgame, and the guard
  can be raised to 10 to solve a whole deal.

#### Simulation and visualisation

- [`sk_deal()`](https://r-heller.github.io/skatR/reference/sk_deal.md),
  [`sk_play_game()`](https://r-heller.github.io/skatR/reference/sk_play_game.md):
  deal and play out a single game.
- [`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md):
  Monte Carlo over many deals, returning a tidy tibble.
- [`sk_plot_points()`](https://r-heller.github.io/skatR/reference/sk_plot_points.md),
  [`sk_plot_winrate()`](https://r-heller.github.io/skatR/reference/sk_plot_winrate.md):
  outcome visualisations.

#### Rulesets and demo

- [`sk_ruleset()`](https://r-heller.github.io/skatR/reference/sk_ruleset.md),
  [`is_sk_ruleset()`](https://r-heller.github.io/skatR/reference/is_sk_ruleset.md):
  configurable tournament and casual variants.
- [`sk_run_app()`](https://r-heller.github.io/skatR/reference/sk_run_app.md):
  an interactive Shiny demo of the simulation engine.
