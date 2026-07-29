## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local: Ubuntu 24.04, R 4.6.1

  `R CMD check --as-cran` reports `Status: OK`. Note that this machine's R is
  the distribution build, whose `etc/Makeconf` injects
  `-mno-omit-leaf-frame-pointer` into `CXXFLAGS`; that raises a "non-portable
  flag" NOTE for any package with compiled code. The package ships no
  `Makevars` of its own, and the check is clean with a stock toolchain.

* GitHub Actions: ubuntu-latest, macos-latest, windows-latest (all R release)

## This is a new submission.
