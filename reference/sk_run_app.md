# Launch the skatR demo Shiny app

Opens an interactive Shiny application with three tabs. *Simulate* runs
a batch of games and reports the win rate, mean score and card-point
distribution. *Deal & play* deals a game and steps through it card by
card, showing every hand, the trick in progress and the final verdict.
*Reference* lays out the trick-taking order, card points and game values
for a chosen game type.

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

## Details

Needs the `shiny` and `bslib` packages, both suggested rather than
required.

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
