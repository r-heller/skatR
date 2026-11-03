# Define a Skat ruleset

Builds a configuration object describing which rule variant to use. Two
presets cover the common cases: official tournament rules as used by the
German Skat federation (DSkV) and the International Skat Players
Association (ISPA), and a relaxed casual ("Kneipe") variant. Individual
options can be overridden. This is descriptive metadata: play and
scoring functions do not consume this object. Bock, Ramsch and Kontra/Re
game flows are not implemented.

## Usage

``` r
sk_ruleset(
  preset = c("tournament", "casual"),
  bock = FALSE,
  ramsch = NULL,
  contra_re = NULL,
  call = rlang::caller_env()
)
```

## Arguments

- preset:

  One of `"tournament"` or `"casual"`. Sets sensible defaults for the
  remaining options.

- bock:

  Logical; whether Bock rounds (doubled scores) are in effect. Only
  meaningful for `"casual"`; ignored in scoring unless enabled. Defaults
  to `FALSE`.

- ramsch:

  Logical; whether a passed-in deal is played as Ramsch rather than
  thrown in. Casual only. Defaults to the preset.

- contra_re:

  Logical; whether Kontra/Re announcements are permitted. Casual only.
  Defaults to the preset.

- call:

  The calling environment, used for error reporting.

## Value

An object of class `sk_ruleset`: a list with the logical elements
`preset`, `bock`, `ramsch`, and `contra_re`.

## See also

[`is_sk_ruleset()`](https://r-heller.github.io/skatR/reference/is_sk_ruleset.md)
to test an object.

Other ruleset functions:
[`is_sk_ruleset()`](https://r-heller.github.io/skatR/reference/is_sk_ruleset.md)

## Examples

``` r
sk_ruleset("tournament")
#> <sk_ruleset> ("tournament")
#> • Bock rounds: FALSE
#> • Ramsch on pass: FALSE
#> • Kontra/Re: FALSE
sk_ruleset("casual", bock = TRUE)
#> <sk_ruleset> ("casual")
#> • Bock rounds: TRUE
#> • Ramsch on pass: TRUE
#> • Kontra/Re: TRUE
```
