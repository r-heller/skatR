# Construct a Skat card

Creates a single card, represented as an S3 object of class `sk_card`. A
card is stored as a length-one character code of the form
`"<suit><rank>"`, e.g. `"CA"` for the ace of clubs or `"D10"` for the
ten of diamonds.

## Usage

``` r
sk_card(suit, rank, call = rlang::caller_env())
```

## Arguments

- suit:

  A single suit code, one of `sk_suits` (`"C"`, `"S"`, `"H"`, `"D"`).

- rank:

  A single rank code, one of `sk_ranks`.

- call:

  The calling environment, used for error reporting.

## Value

An `sk_card` object (a length-one character vector with class
`sk_card`).

## See also

Other card functions:
[`format.sk_card()`](https://r-heller.github.io/skatR/reference/format.sk_card.md),
[`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md),
[`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md),
[`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md),
[`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)

## Examples

``` r
sk_card("C", "A")
#> 1 Skat card: ♣A
sk_card("D", "10")
#> 1 Skat card: ♦10
```
