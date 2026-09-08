# Ask a player to choose a card

Dispatches to the player's strategy and returns a single legal card.

## Usage

``` r
sk_choose(
  player,
  hand,
  led,
  game_type,
  trick = character(0),
  call = rlang::caller_env()
)
```

## Arguments

- player:

  An `sk_player` object.

- hand:

  The player's current hand (`sk_card` or character vector).

- led:

  The led card, or `NULL` if this player leads.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- trick:

  Cards already played to the current trick, in play order and including
  the led card. Defaults to `character(0)`; when it is empty but `led`
  is supplied, `led` is taken as the whole trick so far.

- call:

  The calling environment, used for error reporting.

## Value

A single card code: a character scalar drawn from
`sk_legal_moves(hand, led, game_type)`.

## See also

[`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md)
for the set a choice is drawn from.

Other player functions:
[`sk_mcts_move()`](https://r-heller.github.io/skatR/reference/sk_mcts_move.md),
[`sk_player()`](https://r-heller.github.io/skatR/reference/sk_player.md)

## Examples

``` r
p <- sk_player("heuristic")
sk_choose(p, hand = c("HA", "H7", "CJ"), led = "HK", game_type = "spades")
#> [1] "HA"

# Leading, the heuristic sheds its cheapest card.
sk_choose(p, hand = c("HA", "H7", "CJ"), led = NULL, game_type = "spades")
#> [1] "H7"
```
