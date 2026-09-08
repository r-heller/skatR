# Determinized Monte Carlo move selection

Chooses a card by sampling many random completions of the hidden cards
("determinizations"): for each legal move the rest of the trick is
filled in at random from the unseen cards, and the move with the best
average card-point outcome is returned. Points the move captures count
in its favour; points it hands to the opponents count half against it,
so a cheap loss is preferred to an expensive one.

## Usage

``` r
sk_mcts_move(
  hand,
  led,
  game_type,
  trick = character(0),
  unseen = NULL,
  n_sims = 200,
  call = rlang::caller_env()
)
```

## Arguments

- hand:

  The deciding player's hand (`sk_card` or character vector).

- led:

  The led card, or `NULL` if this player leads.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- trick:

  Cards already played to the current trick, in play order and including
  the led card. Defaults to `character(0)`.

- unseen:

  Optional character vector of cards not visible to the player
  (opponents' cards plus skat). If `NULL`, inferred as the full deck
  minus the player's hand and the visible trick.

- n_sims:

  Number of determinized rollouts per legal move. Defaults to 200.

- call:

  The calling environment, used for error reporting.

## Value

A single card code: a character scalar drawn from the legal moves.

## Details

This is a light-weight imperfect-information heuristic, not a full
information-set MCTS. It plays reasonably and costs little; for exact
play use
[`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md)
on an endgame.

## See also

[`sk_player()`](https://r-heller.github.io/skatR/reference/sk_player.md)
wraps this as a strategy;
[`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md)
plays exactly when every hand is known.

Other player functions:
[`sk_choose()`](https://r-heller.github.io/skatR/reference/sk_choose.md),
[`sk_player()`](https://r-heller.github.io/skatR/reference/sk_player.md)

## Examples

``` r
set.seed(1)
sk_mcts_move(c("HA", "H7", "CJ", "DA"), led = "HK",
             game_type = "spades", n_sims = 50)
#> [1] "HA"
```
