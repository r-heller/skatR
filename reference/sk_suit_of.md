# Extract the suit of a card

Extract the suit of a card

## Usage

``` r
sk_suit_of(x)
```

## Arguments

- x:

  An `sk_card` object or a character vector of card codes.

## Value

A character vector of suit codes (`"C"`, `"S"`, `"H"`, or `"D"`), the
same length as `x`.

## See also

[`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md)
for the other half of a card code.

Other card functions:
[`format.sk_card()`](https://r-heller.github.io/skatR/reference/format.sk_card.md),
[`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md),
[`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md),
[`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md),
[`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md)

## Examples

``` r
sk_suit_of(sk_card("H", "K"))
#> [1] "H"
sk_suit_of(c("CA", "D10"))
#> [1] "C" "D"
```
