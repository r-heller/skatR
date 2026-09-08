# Score a completed Skat game

Determines whether the declarer won and by how much, given the
declarer's card points, whether they took every trick, the announced
game value, and the game type.

## Usage

``` r
sk_score_game(
  declarer_points,
  game_type,
  game_value,
  declarer_won_all = FALSE,
  declarer_lost_all = FALSE,
  call = rlang::caller_env()
)
```

## Arguments

- declarer_points:

  Card points (0-120) the declarer collected in tricks, including any
  points in the skat for a non-hand game.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- game_value:

  The announced/bid game value (see
  [`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md)).

- declarer_won_all:

  Logical; `TRUE` if the declarer took every trick (relevant for
  schwarz). Defaults to `FALSE`.

- declarer_lost_all:

  Logical; `TRUE` if the declarer took no trick at all. Defaults to
  `FALSE`. For null games this determines the outcome directly.

- call:

  The calling environment, used for error reporting.

## Value

A list of class `sk_result` with elements:

- `won`: logical, did the declarer win;

- `schneider`: logical, was schneider reached (declarer to 90 or defence
  held to 30);

- `schwarz`: logical, was schwarz reached (one side took every trick);

- `game_value`: integer, the announced value;

- `score`: integer, points credited to the declarer – the game value if
  won, twice the negated game value if lost.

## Details

The declarer needs 61 of the 120 card points to win a suit or grand
game. Reaching 90 (or holding the defence to 30) is schneider; taking
every trick is schwarz. Null games invert the goal: the declarer wins
only by taking no trick at all, and neither schneider nor schwarz
applies. A lost game costs twice the game value.

## See also

[`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md)
computes the announced value;
[`sk_play_game()`](https://r-heller.github.io/skatR/reference/sk_play_game.md)
calls this on a played-out deal.

## Examples

``` r
sk_score_game(72, "hearts", game_value = 20)
#> <sk_result>: declarer won
#> • Game value: 20
#> • Score: 20
#> • Schneider: no
#> • Schwarz: no
sk_score_game(59, "hearts", game_value = 20)  # lost, did not reach 61
#> <sk_result>: declarer lost
#> • Game value: 20
#> • Score: -40
#> • Schneider: no
#> • Schwarz: no
sk_score_game(0, "null", game_value = 23, declarer_lost_all = TRUE)
#> <sk_result>: declarer won
#> • Game value: 23
#> • Score: 23
#> • Schneider: no
#> • Schwarz: no
```
