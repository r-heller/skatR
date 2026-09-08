# The effective suit a card follows

In suit and grand games every jack counts as a trump, not as its printed
suit, so leading a jack forces trumps rather than that suit. This
function returns the suit a card must be followed under, using the
sentinel `"T"` for trump.

## Usage

``` r
sk_effective_suit(x, game_type, call = rlang::caller_env())
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

A character vector the same length as `x`: one of the suit codes (`"C"`,
`"S"`, `"H"`, `"D"`), or `"T"` for trump.

## See also

[`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md),
which applies this rule.

Other game-type functions:
[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md),
[`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md),
[`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md),
[`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)

## Examples

``` r
# In a hearts game the jack of clubs is a trump, not a club.
sk_effective_suit(c("CJ", "HA", "D10"), "hearts")
#> [1] "T" "T" "D"
# In a null game it is simply a club.
sk_effective_suit(c("CJ", "HA", "D10"), "null")
#> [1] "C" "H" "D"
```
