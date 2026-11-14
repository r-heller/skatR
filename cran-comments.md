## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Raban Heller <raban.heller@uni-ulm.de>'
  New submission

  This is the first submission of skatR to CRAN.

## Test environments

* Local: macOS (aarch64-apple-darwin), R 4.6.1, 14 November 2026:
  full `R CMD check --as-cran` on the built source tarball, including
  PDF manual compilation with TinyTeX (TeX Live 2026) and HTML manual
  validation. This supersedes the earlier local check environment.
* GitHub Actions (r-lib/actions v2):
  * macos-latest (R release)
  * windows-latest (R release)
  * ubuntu-latest (R devel, R release, R oldrel-1)

## Notes for the reviewer

* The double-dummy solver (`sk_solve_dd()`) is compiled C++ via 'Rcpp'. The
  package ships no `Makevars`; it uses the default C++ standard.
* `sk_solve_dd()` refuses positions deeper than `max_tricks` (default 8
  cards per hand) so that a call cannot start a search that does not finish.
  Examples and tests solve small endgames only.
* The Monte Carlo players and simulations use small numbers of deals and
  playouts in examples and tests; each example finishes in about two seconds
  and the whole test suite in a few seconds.
* The Shiny demo (`sk_run_app()`) needs 'shiny' and 'bslib' from Suggests; its
  example runs only in interactive sessions.

## This is a new submission.
