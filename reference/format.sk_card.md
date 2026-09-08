# Format and print Skat cards

Renders card codes with their suit symbols, so `"CA"` prints as the ace
of clubs rather than as a bare string.

## Usage

``` r
# S3 method for class 'sk_card'
format(x, ...)

# S3 method for class 'sk_card'
print(x, ...)

# S3 method for class 'sk_card'
x[i, ...]
```

## Arguments

- x:

  An `sk_card` object.

- ...:

  Ignored; present for consistency with the S3 generics.

- i:

  An index, passed on to the default `[` method.

## Value

[`format()`](https://rdrr.io/r/base/format.html) returns a character
vector of pretty card labels, the same length as `x`.
[`print()`](https://rdrr.io/r/base/print.html) returns `x` invisibly and
is called for the side effect of printing. `[` returns an `sk_card`
object, so subsetting a hand stays a hand.

## See also

Other card functions:
[`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md),
[`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md),
[`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md),
[`sk_rank_of()`](https://r-heller.github.io/skatR/reference/sk_rank_of.md),
[`sk_suit_of()`](https://r-heller.github.io/skatR/reference/sk_suit_of.md)

## Examples

``` r
format(sk_full_deck()[1:4])
#> [1] "♣7" "♣8" "♣9" "♣J"
print(sk_card("C", "A"))
#> 1 Skat card: ♣A
sk_full_deck()[1:4]
#> 4 Skat cards: ♣J ♣9 ♣8 ♣7
```
