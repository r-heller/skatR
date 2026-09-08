# Trick-taking order for a game type

Returns every card in strict ascending trick-taking strength for the
given game type. The last element is the strongest card.

## Usage

``` r
sk_card_order(game_type, call = rlang::caller_env())
```

## Arguments

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- call:

  The calling environment, used for error reporting.

## Value

A character vector of all 32 card codes ordered from weakest to
strongest for the given game type.

## See also

[`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)
to look a card up in this order.

Other game-type functions:
[`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md),
[`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md),
[`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md),
[`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)

## Examples

``` r
# The jack of clubs is the strongest card of every suit and grand game.
tail(sk_card_order("grand"), 4)
#> [1] "DJ" "HJ" "SJ" "CJ"
tail(sk_card_order("hearts"), 4)
#> [1] "DJ" "HJ" "SJ" "CJ"
# Null games have no trumps at all.
head(sk_card_order("null"), 8)
#> [1] "C7"  "C8"  "C9"  "C10" "CJ"  "CQ"  "CK"  "CA" 
```
