# Deal a Skat game

Shuffles a full deck and deals ten cards to each of the three players
plus a two-card skat, following the standard 3-4-3 deal pattern (the
pattern does not affect play but is preserved for realism).

## Usage

``` r
sk_deal(seed = NULL, call = rlang::caller_env())
```

## Arguments

- seed:

  Optional whole-number seed for reproducible shuffles. If `NULL` (the
  default) the current random state is used. When a seed is supplied the
  previous random state is restored on exit, by any path.

- call:

  The calling environment, used for error reporting.

## Value

An object of class `sk_deal`: a list with elements

- `hands`: a length-3 list of `sk_card` vectors, ten cards each (players
  1, 2, 3),

- `skat`: an `sk_card` vector of length 2.

## See also

[`sk_play_game()`](https://r-heller.github.io/skatR/reference/sk_play_game.md)
to play the deal out.

## Examples

``` r
d <- sk_deal(seed = 1)
d$hands[[1]]
#> 10 Skat cards: ♣A ♣10 ♣J · ♠8 · ♥A ♥Q ♥J · ♦A ♦J ♦7
d$skat
#> 2 Skat cards: ♥9 · ♦Q
```
