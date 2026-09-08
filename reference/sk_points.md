# Card-point value of one or more cards

Returns the Skat card-point value (jack 2, queen 3, king 4, ten 10, ace
11, others 0). The card points of all 32 cards sum to 120.

## Usage

``` r
sk_points(x, call = rlang::caller_env())
```

## Arguments

- x:

  An `sk_card` object or character vector of card codes.

- call:

  The calling environment, used for error reporting.

## Value

An integer vector of card-point values, the same length as `x`.

## See also

[`sk_count_points()`](https://r-heller.github.io/skatR/reference/sk_count_points.md)
to total the points of a set of cards.

Other card functions:
[`format.sk_card()`](https://r-heller.github.io/skatR/reference/format.sk_card.md),
[`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md),
[`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md),
[`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md),
[`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)

## Examples

``` r
sk_points(c("CA", "D10", "H7"))
#> [1] 11 10  0
sum(sk_points(sk_full_deck()))
#> [1] 120
```
