# Game types

The valid Skat game types recognised throughout the package.

## Usage

``` r
sk_game_types()
```

## Value

A character vector of the six valid game-type strings.

## Details

- Suit games: `"diamonds"`, `"hearts"`, `"spades"`, `"clubs"` (the named
  suit plus all four jacks are trumps).

- `"grand"`: only the four jacks are trumps.

- `"null"`: no trumps; ranks run 7-8-9-10-J-Q-K-A low to high.

## See also

[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md)
for the ordering each type implies.

Other game-type functions:
[`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md),
[`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md),
[`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md),
[`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md)

## Examples

``` r
sk_game_types()
#> [1] "diamonds" "hearts"   "spades"   "clubs"    "grand"    "null"    
```
