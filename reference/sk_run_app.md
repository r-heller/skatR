# Launch the skatR demo Shiny app

Opens an interactive Shiny application for exploring simulations: pick a
game type and player strategies, run a batch of games, and view the win
rate and card-point distribution.

## Usage

``` r
sk_run_app(call = rlang::caller_env())
```

## Arguments

- call:

  The calling environment, used for error reporting.

## Value

Invisible `NULL`, called for the side effect of launching a Shiny
application in the default browser.

## See also

[`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md),
which the app calls under the hood.

## Examples

``` r
# \donttest{
if (interactive()) {
  sk_run_app()
}
# }
```
