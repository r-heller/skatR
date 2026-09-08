# Extract the rank of a card

Extract the rank of a card

## Usage

``` r
sk_rank_of(x)
```

## Arguments

- x:

  An `sk_card` object or a character vector of card codes.

## Value

A character vector of rank codes, the same length as `x`. The ten is two
characters wide (`"10"`); every other rank is one.

## See also

[`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)
for the other half of a card code.

Other card functions:
[`format.sk_card()`](https://r-heller.github.io/skatR/reference/format.sk_card.md),
[`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md),
[`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md),
[`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md),
[`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)

## Examples

``` r
sk_rank_of(sk_card("H", "K"))
#> [1] "K"
sk_rank_of(c("CA", "D10"))
#> [1] "A"  "10"
```
