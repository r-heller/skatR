# Canonical build script for skatR.
# Run from the package root: Rscript _build.R
# Regenerates compiled attributes, documentation, runs tests, and checks.

if (!requireNamespace("Rcpp", quietly = TRUE)) stop("Install Rcpp first.")
if (!requireNamespace("devtools", quietly = TRUE)) stop("Install devtools first.")

message("== compileAttributes ==")
Rcpp::compileAttributes()

message("== document ==")
devtools::document()

message("== load_all ==")
devtools::load_all()

message("== test ==")
devtools::test()

message("== check (--as-cran) ==")
devtools::check(args = c("--as-cran", "--no-manual"))

message("== done ==")
