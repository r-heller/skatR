# A full 32-card Skat deck

A full 32-card Skat deck

## Usage

``` r
sk_full_deck()
```

## Value

An `sk_card` object of length 32 containing every suit-rank combination,
ordered by suit and then by rank.

## See also

[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md)
for trick-taking order under a given game type.

Other card functions:
[`format.sk_card()`](https://r-heller.github.io/skatR/reference/format.sk_card.md),
[`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md),
[`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md),
[`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md),
[`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)

## Examples

``` r
sk_full_deck()
#> 32 Skat cards: ♣A ♣10 ♣K ♣Q ♣J ♣9 ♣8 ♣7 · ♠A ♠10 ♠K ♠Q ♠J ♠9 ♠8 ♠7 · ♥A ♥10 ♥K
#> ♥Q ♥J ♥9 ♥8 ♥7 · ♦A ♦10 ♦K ♦Q ♦J ♦9 ♦8 ♦7
length(sk_full_deck())
#> [1] 32
```
