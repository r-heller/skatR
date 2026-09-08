# Simulate many Skat games

Runs a Monte Carlo experiment: deals `n` random games, plays each out
with the supplied players and game type, and returns a tidy table of
outcomes. Use it to estimate win rates, average scores, and the
distribution of declarer card points for a given strategy configuration.

## Usage

``` r
sk_simulate(
  n = 100,
  game_type = "grand",
  declarer = 1,
  players = NULL,
  seed = NULL,
  verbose = TRUE,
  call = rlang::caller_env()
)
```

## Arguments

- n:

  Number of games to simulate. Defaults to 100.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).
  Defaults to `"grand"`.

- declarer:

  Integer in `1:3`: the declaring seat. Defaults to 1.

- players:

  A length-3 list of `sk_player` objects. Defaults to heuristic players
  for all seats.

- seed:

  Optional whole-number seed for reproducibility. Defaults to `NULL`,
  which leaves the random state alone. When supplied, the previous
  random state is restored on exit.

- verbose:

  Logical; show a progress bar. Defaults to `TRUE`.

- call:

  The calling environment, used for error reporting.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per simulated game and columns: `game` (integer index),
`game_type` (character), `declarer` (integer), `declarer_points`
(integer card points credited to the declarer, trick points plus skat),
`won` (logical), `schneider` (logical), `schwarz` (logical),
`game_value` (integer), and `score` (integer). Always a tibble with
these nine columns and these types.

## See also

[`sk_plot_points()`](https://r-heller.github.io/skatR/reference/sk_plot_points.md)
and
[`sk_plot_winrate()`](https://r-heller.github.io/skatR/reference/sk_plot_winrate.md)
visualise the result.

## Examples

``` r
sim <- sk_simulate(n = 20, game_type = "grand", seed = 1, verbose = FALSE)
mean(sim$won)
#> [1] 0.35
head(sim, 3)
#> # A tibble: 3 × 9
#>    game game_type declarer declarer_points won   schneider schwarz game_value
#>   <int> <chr>        <int>           <int> <lgl> <lgl>     <lgl>        <int>
#> 1     1 grand            1              87 TRUE  FALSE     FALSE           48
#> 2     2 grand            1              34 FALSE FALSE     FALSE           96
#> 3     3 grand            1              82 TRUE  FALSE     FALSE           72
#> # ℹ 1 more variable: score <int>
```
