#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data %||%
#' @useDynLib skatR, .registration = TRUE
#' @importFrom Rcpp sourceCpp
NULL

# Silence R CMD check notes for tidy-eval column names used in ggplot2 aes().
utils::globalVariables(c("."))
