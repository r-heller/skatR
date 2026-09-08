# Plot the distribution of declarer card points

Draws a histogram of the declarer's card points across a simulation,
filled by outcome, with the 61-point winning threshold marked.

## Usage

``` r
sk_plot_points(sim, bins = 24, call = rlang::caller_env())
```

## Arguments

- sim:

  A simulation tibble from
  [`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md).

- bins:

  Number of histogram bins. Defaults to 24.

- call:

  The calling environment, used for error reporting.

## Value

A
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object, which can be printed, saved with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
or extended with further layers.

## See also

[`sk_plot_winrate()`](https://r-heller.github.io/skatR/reference/sk_plot_winrate.md)
for the aggregate view.

Other plotting functions:
[`sk_plot_winrate()`](https://r-heller.github.io/skatR/reference/sk_plot_winrate.md)

## Examples

``` r
sim <- sk_simulate(n = 50, seed = 1, verbose = FALSE)
sk_plot_points(sim)
```
