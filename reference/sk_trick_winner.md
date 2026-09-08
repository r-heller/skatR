# Determine the winner of a completed trick

A trump beats any non-trump; among cards of the same effective suit the
stronger one wins; a card that neither follows the led suit nor trumps
cannot win at all.

## Usage

``` r
sk_trick_winner(cards, game_type, call = rlang::caller_env())
```

## Arguments

- cards:

  A length-3 `sk_card` object or character vector: the cards played in
  play order (first element led).

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- call:

  The calling environment, used for error reporting.

## Value

An integer in `1:3`: the position within `cards` that won the trick.

## See also

[`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)
for the ordering this uses.

Other play functions:
[`sk_count_points()`](https://r-heller.github.io/skatR/reference/sk_count_points.md),
[`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md)

## Examples

``` r
sk_trick_winner(c("H7", "HK", "HA"), "spades")
#> [1] 3
sk_trick_winner(c("H7", "SJ", "HA"), "spades")  # a jack trumps
#> [1] 2
sk_trick_winner(c("H10", "HJ", "H9"), "null")   # no trumps, jack over ten
#> [1] 2
```
