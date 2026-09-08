# Test whether an object is a ruleset

Test whether an object is a ruleset

## Usage

``` r
is_sk_ruleset(x)
```

## Arguments

- x:

  An object to test.

## Value

A logical scalar: `TRUE` if `x` inherits from `sk_ruleset`.

## See also

[`sk_ruleset()`](https://r-heller.github.io/skatR/reference/sk_ruleset.md)
to build one.

Other ruleset functions:
[`sk_ruleset()`](https://r-heller.github.io/skatR/reference/sk_ruleset.md)

## Examples

``` r
is_sk_ruleset(sk_ruleset("casual"))
#> [1] TRUE
is_sk_ruleset("tournament")
#> [1] FALSE
```
