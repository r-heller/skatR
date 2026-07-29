# skatR 0.1.0

## Initial release

### Cards and ordering
* `sk_full_deck()`, `sk_card()`, `sk_points()`: the 32-card Skat deck and card points.
* `sk_suit_of()`, `sk_rank_of()`: split a card code into its parts.
* `sk_card_order()`, `sk_strength()`, `sk_is_trump()`, `sk_effective_suit()`: game-type-aware trick ordering, including the rule that jacks are trumps in suit and grand games but plain cards in null games.
* `format()`, `print()`, and `[` methods for `sk_card`, so hands render with suit symbols and stay `sk_card` objects when subset.

### Bidding
* `sk_base_value()`, `sk_matadors()`, `sk_game_value()`: game-value (Reizwert) computation, with the four fixed null values.

### Play and scoring
* `sk_legal_moves()`, `sk_trick_winner()`, `sk_count_points()`: trick mechanics.
* `sk_score_game()`: win/loss, schneider, and schwarz resolution.

### Players
* `sk_player()`, `sk_choose()`: random, heuristic, and Monte Carlo strategies.
* `sk_mcts_move()`: determinized Monte Carlo move selection.

### Solver
* `sk_solve_dd()`: exact double-dummy endgame solver (Rcpp alpha-beta). Returns the card points the declarer can guarantee against perfect defence, counting the points on the declarer's own cards.
* The search carries a transposition table and move ordering. The table is keyed on the three hand masks plus the trick in progress and stores what the declarer collects from that position onward, which is independent of the points already banked; every slot holds its full key, so a hash collision misses rather than answering for a different position. Move ordering tries cards that take the trick first, highest first. Both are optimisations only: the values returned are unchanged, and `tests/testthat/test-solver.R` pins the hand-traced positions, a set of five- and six-trick values recorded from the previous solver, and agreement with an independent minimax written against the R rules engine.
* Measured on this machine (R 4.6.1, x86_64 Linux, g++ 13.3, `-O2`), solving the last *n* cards of each hand from `sk_deal(seed = s)` with the declarer on lead:

  | position | before | after | speedup |
  |----------|-------:|------:|--------:|
  | grand, 7 cards each, `seed = 7` | 2.72 s | 0.016 s | 170x |
  | clubs, 7 cards each, `seed = 7` | 1.17 s | 0.014 s | 84x |
  | grand, 8 cards each, `seed = 1` | 2.29 s | 0.016 s | 143x |
  | clubs, 8 cards each, `seed = 1` | 1.04 s | 0.005 s | 208x |
  | grand, 8 cards each, `seed = 7` | 63.96 s | 0.033 s | 1938x |
  | clubs, 8 cards each, `seed = 7` | 92.68 s | 0.119 s | 779x |

  Over the whole twenty-position sweep (four to eight cards per hand, grand and clubs, two deals each) the total falls from 164.3 s to 0.23 s, with every one of the twenty values unchanged. Small positions are no slower: the four-card ones come in at 0.4-0.6 ms either way. Whole ten-trick deals were never benchmarked on the old solver because they did not finish in reasonable time; twenty sampled deals now solve in 0.06-12.8 s, median 0.33 s.
* `sk_solve_dd()` gains `max_tricks` (default 8), which rejects a position deeper than the given number of cards per hand instead of starting a search that may not finish. The error suggests slicing the endgame, and the guard can be raised to 10 to solve a whole deal.

### Simulation and visualisation
* `sk_deal()`, `sk_play_game()`: deal and play out a single game.
* `sk_simulate()`: Monte Carlo over many deals, returning a tidy tibble.
* `sk_plot_points()`, `sk_plot_winrate()`: outcome visualisations.

### Rulesets and demo
* `sk_ruleset()`, `is_sk_ruleset()`: configurable tournament and casual variants.
* `sk_run_app()`: an interactive Shiny demo of the simulation engine.
