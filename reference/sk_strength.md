# Numeric strength of cards under a game type

Positions each card in the trick-taking order returned by
[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md),
so strengths can be compared directly: higher beats lower.

## Usage

``` r
sk_strength(x, game_type, call = rlang::caller_env())
```

## Arguments

- x:

  An `sk_card` object or character vector of card codes.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- call:

  The calling environment, used for error reporting.

## Value

An integer vector of strengths in `1:32` (higher beats lower), the same
length as `x`.

## See also

[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md)
for the underlying order.

Other game-type functions:
[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md),
[`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md),
[`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md),
[`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md)

## Examples

``` r
sk_strength(c("CJ", "DA", "H7"), "grand")
#> [1] 32 28 15
```
