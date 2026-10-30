#' Define a Skat ruleset
#'
#' Builds a configuration object describing which rule variant to use. Two
#' presets cover the common cases: official tournament rules as used by the
#' German Skat federation (DSkV) and the International Skat Players Association
#' (ISPA), and a relaxed casual ("Kneipe") variant. Individual options can be
#' overridden. This is descriptive metadata: play and scoring functions do not
#' consume this object. Bock, Ramsch and Kontra/Re game flows are not implemented.
#'
#' @param preset One of `"tournament"` or `"casual"`. Sets sensible defaults for
#'   the remaining options.
#' @param bock Logical; whether Bock rounds (doubled scores) are in effect. Only
#'   meaningful for `"casual"`; ignored in scoring unless enabled. Defaults to
#'   `FALSE`.
#' @param ramsch Logical; whether a passed-in deal is played as Ramsch rather
#'   than thrown in. Casual only. Defaults to the preset.
#' @param contra_re Logical; whether Kontra/Re announcements are permitted.
#'   Casual only. Defaults to the preset.
#' @param call The calling environment, used for error reporting.
#'
#' @return An object of class `sk_ruleset`: a list with the logical elements
#'   `preset`, `bock`, `ramsch`, and `contra_re`.
#' @export
#' @family ruleset functions
#' @seealso [is_sk_ruleset()] to test an object.
#' @examples
#' sk_ruleset("tournament")
#' sk_ruleset("casual", bock = TRUE)
sk_ruleset <- function(preset = c("tournament", "casual"),
                       bock = FALSE,
                       ramsch = NULL,
                       contra_re = NULL,
                       call = rlang::caller_env()) {
  preset <- match.arg(preset)
  .sk_check_flag(bock, call = call)

  defaults <- if (identical(preset, "tournament")) {
    list(ramsch = FALSE, contra_re = FALSE, bock = FALSE)
  } else {
    list(ramsch = TRUE, contra_re = TRUE, bock = bock)
  }

  ramsch <- ramsch %||% defaults$ramsch
  contra_re <- contra_re %||% defaults$contra_re
  .sk_check_flag(ramsch, call = call)
  .sk_check_flag(contra_re, call = call)

  if (identical(preset, "tournament") && (ramsch || contra_re || bock)) {
    cli::cli_warn(c(
      "!" = "Tournament rules do not normally use Bock, Ramsch, or Kontra/Re.",
      "i" = "Use {.code preset = \"casual\"} for those variants."
    ))
  }

  structure(
    list(preset = preset, bock = bock, ramsch = ramsch,
         contra_re = contra_re),
    class = "sk_ruleset"
  )
}

#' @export
print.sk_ruleset <- function(x, ...) {
  cli::cli_text("{.cls sk_ruleset} ({.val {x$preset}})")
  cli::cli_bullets(c(
    "*" = "Bock rounds: {x$bock}",
    "*" = "Ramsch on pass: {x$ramsch}",
    "*" = "Kontra/Re: {x$contra_re}"
  ))
  invisible(x)
}

#' Test whether an object is a ruleset
#'
#' @param x An object to test.
#' @return A logical scalar: `TRUE` if `x` inherits from `sk_ruleset`.
#' @export
#' @family ruleset functions
#' @seealso [sk_ruleset()] to build one.
#' @examples
#' is_sk_ruleset(sk_ruleset("casual"))
#' is_sk_ruleset("tournament")
is_sk_ruleset <- function(x) {
  inherits(x, "sk_ruleset")
}
