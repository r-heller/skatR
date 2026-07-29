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

### Simulation and visualisation
* `sk_deal()`, `sk_play_game()`: deal and play out a single game.
* `sk_simulate()`: Monte Carlo over many deals, returning a tidy tibble.
* `sk_plot_points()`, `sk_plot_winrate()`: outcome visualisations.

### Rulesets and demo
* `sk_ruleset()`, `is_sk_ruleset()`: configurable tournament and casual variants.
* `sk_run_app()`: an interactive Shiny demo of the simulation engine.
