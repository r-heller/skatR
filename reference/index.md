# Package index

## Cards and ordering

The 32-card deck, and how its cards rank under each game type.

- [`sk_suits`](https://r-heller.github.io/skatR/reference/skat-constants.md)
  [`sk_ranks`](https://r-heller.github.io/skatR/reference/skat-constants.md)
  [`sk_card_points`](https://r-heller.github.io/skatR/reference/skat-constants.md)
  : Skat card constants
- [`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md)
  : A full 32-card Skat deck
- [`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md) :
  Construct a Skat card
- [`format(`*`<sk_card>`*`)`](https://r-heller.github.io/skatR/reference/format.sk_card.md)
  [`print(`*`<sk_card>`*`)`](https://r-heller.github.io/skatR/reference/format.sk_card.md)
  [`` `[`( ``*`<sk_card>`*`)`](https://r-heller.github.io/skatR/reference/format.sk_card.md)
  : Format and print Skat cards
- [`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)
  : Extract the suit of a card
- [`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md)
  : Extract the rank of a card
- [`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md)
  : Card-point value of one or more cards
- [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md)
  : Game types
- [`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md)
  : Trick-taking order for a game type
- [`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)
  : Numeric strength of cards under a game type
- [`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md)
  : Test whether a card is a trump
- [`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md)
  : The effective suit a card follows

## Bidding

Game values (Reizwerte) and the matador multiplier.

- [`sk_base_value()`](https://r-heller.github.io/skatR/reference/sk_base_value.md)
  : Base value of a game type
- [`sk_matadors()`](https://r-heller.github.io/skatR/reference/sk_matadors.md)
  : Count matadors (Spitzen)
- [`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md)
  : Game value (Reizwert)

## Play and scoring

Trick mechanics and the outcome of a completed game.

- [`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md)
  : Legal cards to play
- [`sk_trick_winner()`](https://r-heller.github.io/skatR/reference/sk_trick_winner.md)
  : Determine the winner of a completed trick
- [`sk_count_points()`](https://r-heller.github.io/skatR/reference/sk_count_points.md)
  : Total card points in a set of cards
- [`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md)
  : Score a completed Skat game

## Players

Strategies that pick a card to play.

- [`sk_player()`](https://r-heller.github.io/skatR/reference/sk_player.md)
  : Create a Skat player
- [`sk_choose()`](https://r-heller.github.io/skatR/reference/sk_choose.md)
  : Ask a player to choose a card
- [`sk_mcts_move()`](https://r-heller.github.io/skatR/reference/sk_mcts_move.md)
  : Determinized Monte Carlo move selection

## Solver

Exact double-dummy endgame analysis.

- [`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md)
  : Solve a double-dummy Skat endgame

## Simulation and visualisation

Deal, play, repeat, and look at the results.

- [`sk_deal()`](https://r-heller.github.io/skatR/reference/sk_deal.md) :
  Deal a Skat game
- [`sk_play_game()`](https://r-heller.github.io/skatR/reference/sk_play_game.md)
  : Play out a full Skat game
- [`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md)
  : Simulate many Skat games
- [`sk_plot_points()`](https://r-heller.github.io/skatR/reference/sk_plot_points.md)
  : Plot the distribution of declarer card points
- [`sk_plot_winrate()`](https://r-heller.github.io/skatR/reference/sk_plot_winrate.md)
  : Plot win rate by game type

## Rulesets and app

Rule variants and the interactive demo.

- [`sk_ruleset()`](https://r-heller.github.io/skatR/reference/sk_ruleset.md)
  : Define a Skat ruleset
- [`is_sk_ruleset()`](https://r-heller.github.io/skatR/reference/is_sk_ruleset.md)
  : Test whether an object is a ruleset
- [`sk_run_app()`](https://r-heller.github.io/skatR/reference/sk_run_app.md)
  : Launch the skatR demo Shiny app
