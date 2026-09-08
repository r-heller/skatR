# Total card points in a set of cards

Total card points in a set of cards

## Usage

``` r
sk_count_points(cards, call = rlang::caller_env())
```

## Arguments

- cards:

  An `sk_card` object or character vector.

- call:

  The calling environment, used for error reporting.

## Value

A single integer: the sum of the card points. Zero for no cards.

## See also

[`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md)
for the per-card values.

Other play functions:
[`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md),
[`sk_trick_winner()`](https://r-heller.github.io/skatR/reference/sk_trick_winner.md)

## Examples

``` r
sk_count_points(c("CA", "D10", "HK"))
#> [1] 25
sk_count_points(sk_full_deck())
#> [1] 120
```
