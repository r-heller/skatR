# Game value (Reizwert)

Computes the value of a declared game: for suit and grand games, the
base value times the multiplier (matadors + one for game, plus levels
for hand, achieved/announced schneider and schwarz, and ouvert). Null
games use fixed values.

## Usage

``` r
sk_game_value(
  hand,
  game_type,
  hand_game = FALSE,
  schneider = FALSE,
  schwarz = FALSE,
  ouvert = FALSE,
  call = rlang::caller_env(),
  schneider_announced = FALSE,
  schwarz_announced = FALSE
)
```

## Arguments

- hand:

  An `sk_card` object or character vector: the declarer's cards used for
  matador counting.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- hand_game:

  Logical; `TRUE` if played as a hand game (skat not picked up).
  Defaults to `FALSE`.

- schneider:

  Logical; either party achieved schneider. Defaults to `FALSE`.

- schwarz:

  Logical; either party achieved schwarz (also implies schneider).
  Defaults to `FALSE`.

- ouvert:

  Logical; open (ouvert) game. For suit/grand, implies hand, schneider
  announced and schwarz announced. Defaults to `FALSE`.

- call:

  The calling environment, used for error reporting.

- schneider_announced, schwarz_announced:

  Logical; additional announced levels in a hand game. Schwarz announced
  implies schneider announced. Announcements include their required
  achieved levels in the scoring value.

## Value

A single integer game value. Null games return one of the four fixed
values 23, 35, 46, or 59.

## See also

[`sk_matadors()`](https://r-heller.github.io/skatR/reference/sk_matadors.md)
for the multiplier and
[`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md)
for what a game value is worth once played.

Other bidding functions:
[`sk_base_value()`](https://r-heller.github.io/skatR/reference/sk_base_value.md),
[`sk_matadors()`](https://r-heller.github.io/skatR/reference/sk_matadors.md)

## Examples

``` r
sk_game_value(c("CJ", "SJ", "HA", "HK", "H10", "H9"), "hearts")
#> [1] 30
sk_game_value(character(0), "null")
#> [1] 23
sk_game_value(character(0), "null", hand_game = TRUE, ouvert = TRUE)
#> [1] 59
```
