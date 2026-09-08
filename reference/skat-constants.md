# Skat card constants

The four suits and eight ranks of a 32-card Skat deck, together with the
card-point values used for scoring.

## Usage

``` r
sk_suits

sk_ranks

sk_card_points
```

## Format

Character and integer vectors.

## Details

Suits are ordered by their bidding rank: clubs (highest), spades,
hearts, diamonds (lowest). Ranks run seven, eight, nine, jack, queen,
king, ten, ace in card-point order, though trick-taking order depends on
the game type (see
[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md)).

`sk_suits` uses the single letters `C`, `S`, `H`, `D`. `sk_ranks` uses
`7`, `8`, `9`, `J`, `Q`, `K`, `10`, `A`.
