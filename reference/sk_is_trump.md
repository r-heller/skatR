# Test whether a card is a trump

Test whether a card is a trump

## Usage

``` r
sk_is_trump(x, game_type, call = rlang::caller_env())
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

A logical vector, the same length as `x`. In `"null"` games this is
always `FALSE`, because null games have no trumps.

## See also

[`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md),
which folds this into the follow-suit rule.

Other game-type functions:
[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md),
[`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md),
[`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md),
[`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)

## Examples

``` r
sk_is_trump(c("CJ", "DA", "HK"), "hearts")
#> [1]  TRUE FALSE  TRUE
sk_is_trump(c("CJ", "DA", "HK"), "null")
#> [1] FALSE FALSE FALSE
```
