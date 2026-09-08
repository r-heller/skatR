# Plot win rate by game type

Summarises one or more simulation tibbles into a bar chart of the
declarer's win rate per game type, ordered from worst to best.

## Usage

``` r
sk_plot_winrate(sim, call = rlang::caller_env())
```

## Arguments

- sim:

  A simulation tibble from
  [`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md),
  or several row-bound together (with differing `game_type` values).

- call:

  The calling environment, used for error reporting.

## Value

A
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object, which can be printed, saved with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
or extended with further layers.

## See also

[`sk_plot_points()`](https://r-heller.github.io/skatR/reference/sk_plot_points.md)
for the per-game distribution.

Other plotting functions:
[`sk_plot_points()`](https://r-heller.github.io/skatR/reference/sk_plot_points.md)

## Examples

``` r
a <- sk_simulate(n = 40, game_type = "grand", seed = 1, verbose = FALSE)
b <- sk_simulate(n = 40, game_type = "clubs", seed = 2, verbose = FALSE)
sk_plot_winrate(rbind(a, b))
```
