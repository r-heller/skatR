#' Plot the distribution of declarer card points
#'
#' Draws a histogram of the declarer's card points across a simulation, filled
#' by outcome, with the 61-point winning threshold marked.
#'
#' @param sim A simulation tibble from [sk_simulate()].
#' @param bins Number of histogram bins. Defaults to 24.
#' @param call The calling environment, used for error reporting.
#'
#' @return A [ggplot2::ggplot()] object, which can be printed, saved with
#'   [ggplot2::ggsave()], or extended with further layers.
#' @export
#' @family plotting functions
#' @seealso [sk_plot_winrate()] for the aggregate view.
#' @examples
#' sim <- sk_simulate(n = 50, seed = 1, verbose = FALSE)
#' sk_plot_points(sim)
sk_plot_points <- function(sim, bins = 24, call = rlang::caller_env()) {
  .sk_check_sim(sim, call = call)
  bins <- .sk_check_count(bins, call = call)
  ggplot2::ggplot(
    sim,
    ggplot2::aes(x = .data$declarer_points, fill = .data$won)
  ) +
    ggplot2::geom_histogram(bins = bins, colour = "white", linewidth = 0.2) +
    ggplot2::geom_vline(xintercept = 60.5, linetype = "dashed") +
    ggplot2::scale_fill_manual(
      values = c(`FALSE` = .sk_pal$lost, `TRUE` = .sk_pal$won),
      labels = c(`FALSE` = "Lost", `TRUE` = "Won"),
      name = "Outcome",
      drop = FALSE
    ) +
    ggplot2::labs(
      title = "Declarer card-point distribution",
      subtitle = "Dashed line marks the 61-point winning threshold",
      x = "Declarer card points",
      y = "Games"
    ) +
    ggplot2::theme_minimal()
}

#' Plot win rate by game type
#'
#' Summarises one or more simulation tibbles into a bar chart of the declarer's
#' win rate per game type, ordered from worst to best.
#'
#' @param sim A simulation tibble from [sk_simulate()], or several row-bound
#'   together (with differing `game_type` values).
#' @param call The calling environment, used for error reporting.
#'
#' @return A [ggplot2::ggplot()] object, which can be printed, saved with
#'   [ggplot2::ggsave()], or extended with further layers.
#' @export
#' @family plotting functions
#' @seealso [sk_plot_points()] for the per-game distribution.
#' @examples
#' a <- sk_simulate(n = 40, game_type = "grand", seed = 1, verbose = FALSE)
#' b <- sk_simulate(n = 40, game_type = "clubs", seed = 2, verbose = FALSE)
#' sk_plot_winrate(rbind(a, b))
sk_plot_winrate <- function(sim, call = rlang::caller_env()) {
  .sk_check_sim(sim, call = call)
  types <- unique(sim$game_type)
  rates <- vapply(types, function(gt) {
    mean(sim$won[sim$game_type == gt])
  }, numeric(1), USE.NAMES = FALSE)
  summary_df <- tibble::tibble(
    game_type = types,
    win_rate = rates,
    label = .sk_pct(rates)
  )

  ggplot2::ggplot(
    summary_df,
    ggplot2::aes(x = stats::reorder(.data$game_type, .data$win_rate),
                 y = .data$win_rate)
  ) +
    ggplot2::geom_col(fill = .sk_pal$won) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label),
      hjust = -0.1, size = 3
    ) +
    ggplot2::coord_flip(clip = "off") +
    ggplot2::ylim(0, 1) +
    ggplot2::labs(
      title = "Declarer win rate by game type",
      x = "Game type",
      y = "Win rate"
    ) +
    ggplot2::theme_minimal()
}

# Suite palette: the purple accent used across the package and its website.
.sk_pal <- list(won = "#5E2C8E", lost = "#B0413E")

# Lightweight percent formatter, so the package need not depend on scales.
.sk_pct <- function(x) paste0(round(100 * x), "%")

.sk_check_sim <- function(sim, arg = rlang::caller_arg(sim),
                          call = rlang::caller_env()) {
  needed <- c("declarer_points", "won", "game_type")
  if (!inherits(sim, "data.frame")) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a simulation tibble from {.fn sk_simulate}.",
        "x" = "Got {.cls {class(sim)[[1]]}} instead."
      ),
      call = call
    )
  }
  missing <- setdiff(needed, names(sim))
  if (length(missing) > 0L) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a simulation tibble from {.fn sk_simulate}.",
        "x" = "Missing column{?s}: {.field {missing}}.",
        "i" = "It needs {.field {needed}}."
      ),
      call = call
    )
  }
  invisible(sim)
}
