#' Launch the skatR demo Shiny app
#'
#' Opens an interactive Shiny application for exploring simulations: pick a game
#' type and player strategies, run a batch of games, and view the win rate and
#' card-point distribution.
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
  if (!requireNamespace("shiny", quietly = TRUE)) {
    cli::cli_abort(
      c(
        "The {.pkg shiny} package is required to run the demo app.",
        "i" = "Install it with {.code install.packages(\"shiny\")}."
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
