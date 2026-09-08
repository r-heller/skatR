# Base value of a game type

The multiplier base used in Skat game-value computation: diamonds 9,
hearts 10, spades 11, clubs 12, grand 24. Null games use fixed values
instead and return `NA` here.

## Usage

``` r
sk_base_value(game_type, call = rlang::caller_env())
```

## Arguments

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- call:

  The calling environment, used for error reporting.

## Value

A single integer base value, or `NA_integer_` for `"null"`.

## See also

[`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md),
which multiplies this by the matador multiplier.

Other bidding functions:
[`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md),
[`sk_matadors()`](https://r-heller.github.io/skatR/reference/sk_matadors.md)

## Examples

``` r
sk_base_value("clubs")
#> [1] 12
sk_base_value("grand")
#> [1] 24
sk_base_value("null")
#> [1] NA
```
