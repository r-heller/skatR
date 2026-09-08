# Solve a double-dummy Skat endgame

Computes, by exhaustive alpha-beta search, the maximum card points the
declarer can guarantee from a fully specified position where every hand
is known (a "double-dummy" analysis). This is exact perfect-information
play: it assumes both defenders cooperate optimally against the
declarer.

## Usage

``` r
sk_solve_dd(
  hands,
  game_type,
  declarer,
  leader = declarer,
  max_tricks = 8,
  call = rlang::caller_env()
)
```

## Arguments

- hands:

  A length-3 list of `sk_card` vectors (or character vectors of card
  codes): the remaining cards of seats 1, 2, and 3. Every seat must hold
  the same number of cards, and no card may be held twice.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- declarer:

  Integer in `1:3`: the declaring seat.

- leader:

  Integer in `1:3`: the seat to lead the next trick. Defaults to
  `declarer`.

- max_tricks:

  Maximum number of cards per hand the solver will accept, as a guard
  against accidentally launching an intractable search. Deeper positions
  raise an error rather than running. At the default of `8` a solve
  stays well under a second on ordinary hardware; each further trick
  multiplies the work several times over, and a whole ten-trick deal
  (`max_tricks = 10`) can take tens of seconds.

- call:

  The calling environment, used for error reporting.

## Value

A single integer: the maximum card points (0-120) the declarer can
guarantee against best defence.

## Details

The returned total counts every card point in the tricks the declarer
wins, including the points on the declarer's own cards. It does not
include skat points, which are added afterwards by
[`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md).

The search is exponential in the number of remaining cards, tempered by
alpha-beta pruning, move ordering and a transposition table. It is
practical for endgames; a full ten-trick deal can still take a very long
time, which is what `max_tricks` guards against. The heavy lifting runs
in compiled C++, and the search polls for user interrupts so a long
solve can be cancelled.

## See also

[`sk_play_game()`](https://r-heller.github.io/skatR/reference/sk_play_game.md)
to play a deal out with heuristic players, and
[`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md)
to turn a point total into a scored result.

## Examples

``` r
# A two-card-each endgame in a grand game.
hands <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
sk_solve_dd(hands, game_type = "grand", declarer = 1)
#> [1] 35

# The declarer holds both top jacks and sweeps the table: 46 points, which
# includes the two card points on the declarer's own jacks.
sweep <- list(c("CJ", "SJ"), c("HA", "DA"), c("H10", "D10"))
sk_solve_dd(sweep, game_type = "grand", declarer = 1)
#> [1] 46

# A whole ten-trick deal is refused by default; raise the guard to solve it.
# \donttest{
deal <- sk_deal(seed = 1)
sk_solve_dd(deal$hands, game_type = "grand", declarer = 1, max_tricks = 10)
#> [1] 73
# }
```
