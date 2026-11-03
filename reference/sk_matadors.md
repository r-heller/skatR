# Count matadors (Spitzen)

Counts the length of the unbroken run of top trumps a hand holds
("with") or lacks ("without"), starting from the jack of clubs. The
count is the number of matadors; the multiplier game contributes this
count plus one.

## Usage

``` r
sk_matadors(hand, game_type, call = rlang::caller_env())
```

## Arguments

- hand:

  An `sk_card` object or character vector: the declarer's cards. For an
  authentic count this should include the two skat cards the declarer
  owns (12 cards), including the unseen skat in a completed hand game. A
  count from only the ten known cards is a bidding estimate, not final
  scoring.

- game_type:

  A single suit or grand game type (not `"null"`).

- call:

  The calling environment, used for error reporting.

## Value

A list with elements `with` (logical; `TRUE` if the run starts with the
jack of clubs) and `count` (integer number of matadors).

## See also

[`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md)
turns the count into a game value.

Other bidding functions:
[`sk_base_value()`](https://r-heller.github.io/skatR/reference/sk_base_value.md),
[`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md)

## Examples

``` r
# With two top jacks:
sk_matadors(c("CJ", "SJ", "HA", "HK", "H9"), "hearts")
#> $with
#> [1] TRUE
#> 
#> $count
#> [1] 2
#> 
# Without the jack of clubs:
sk_matadors(c("HJ", "HA", "HK"), "hearts")
#> $with
#> [1] FALSE
#> 
#> $count
#> [1] 2
#> 
```
