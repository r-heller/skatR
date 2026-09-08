#' Launch the skatR demo Shiny app
#'
#' Opens an interactive Shiny application with three tabs. *Simulate* runs a
#' batch of games and reports the win rate, mean score and card-point
#' distribution. *Deal & play* deals a game and steps through it card by card,
#' showing every hand, the trick in progress and the final verdict.
#' *Reference* lays out the trick-taking order, card points and game values for
#' a chosen game type.
#'
#' Needs the `shiny` and `bslib` packages, both suggested rather than required.
#'
#' @param call The calling environment, used for error reporting.
#'
#' @return Invisible `NULL`, called for the side effect of launching a Shiny
#'   application in the default browser.
#' @export
#' @family app functions
#' @seealso [sk_simulate()], which the app calls under the hood.
#' @examples
#' \donttest{
#' if (interactive()) {
#'   sk_run_app()
#' }
#' }
sk_run_app <- function(call = rlang::caller_env()) {
  needed <- c("shiny", "bslib")
  missing <- needed[!vapply(
    needed, requireNamespace, logical(1), quietly = TRUE
  )]
  if (length(missing) > 0L) {
    cli::cli_abort(
      c(
        "The {.pkg {missing}} package{?s} {?is/are} required to run the demo \\
         app.",
        "i" = "Install {?it/them} with {.code install.packages()}."
      ),
      call = call
    )
  }
  app_dir <- system.file("shiny", "skatR", package = "skatR")
  if (!nzchar(app_dir)) {
    cli::cli_abort(
      c(
        "Could not locate the bundled Shiny app.",
        "i" = "Reinstall {.pkg skatR} to restore {.path inst/shiny/skatR}."
      ),
      call = call
    )
  }
  shiny::runApp(app_dir, display.mode = "normal")
  invisible(NULL)
}
