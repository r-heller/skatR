#' Plot the distribution of declarer card points
#'
#' Draws a histogram of the declarer's card points across a simulation, split by
#' outcome, on the full 0-120 point scale with the 61-point winning threshold
#' marked.
#'
#' @param sim A simulation tibble from [sk_simulate()].
#' @param bins Approximate number of histogram bins across the 0-120 point
#'   range. Defaults to 24 (five points wide). Bin edges are anchored on 61, so
#'   no bin straddles the winning threshold and each bar of a suit or grand
#'   simulation is a single colour.
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

  dat <- as.data.frame(sim)
  dat$.outcome <- .sk_outcome(dat$won)

  # Anchor the bin edges on the winning threshold rather than on the range of
  # the data, so bars are comparable between runs and the colour split lands on
  # a bin edge instead of inside a bar.
  width <- 120 / bins
  edges <- seq(
    61 - width * ceiling(61 / width),
    61 + width * ceiling(60 / width),
    by = width
  )

  ggplot2::ggplot(dat, ggplot2::aes(x = .data$declarer_points,
                                   fill = .data$.outcome)) +
    ggplot2::geom_histogram(
      breaks = edges, colour = .sk_pal$paper, linewidth = 0.3
    ) +
    ggplot2::geom_vline(
      xintercept = 61, colour = .sk_pal$ink, linetype = "dashed",
      linewidth = 0.4
    ) +
    ggplot2::annotate(
      "text", x = 61, y = Inf, label = "61 to win", hjust = -0.12, vjust = 1.4,
      size = 3.1, colour = .sk_pal$mid
    ) +
    ggplot2::scale_fill_manual(
      values = c(Won = .sk_pal$won, Lost = .sk_pal$lost), drop = FALSE
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(0, 30, 61, 90, 120),
      expand = ggplot2::expansion(mult = 0.01)
    ) +
    ggplot2::scale_y_continuous(
      breaks = .sk_int_breaks,
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    ggplot2::coord_cartesian(xlim = c(0, 120), clip = "off") +
    ggplot2::labs(
      title = "Declarer card-point distribution",
      subtitle = .sk_points_subtitle(dat),
      x = "Declarer card points (of 120)",
      y = "Games",
      caption = .sk_caption(dat)
    ) +
    .sk_theme()
}

#' Plot win rate by game type
#'
#' Summarises one or more simulation tibbles into a bar chart of the declarer's
#' win rate per game type, best at the top.
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
  counts <- vapply(types, function(gt) {
    sum(sim$game_type == gt)
  }, integer(1), USE.NAMES = FALSE)

  summary_df <- tibble::tibble(
    game_type = .sk_title_case(types),
    win_rate = rates,
    n = counts,
    label = .sk_pct(rates),
    # Short bars cannot hold their own label, so those labels go outside in ink
    # and the rest sit inside the bar in white.
    hjust = ifelse(rates >= 0.14, 1.25, -0.25),
    colour = ifelse(rates >= 0.14, .sk_pal$paper, .sk_pal$ink)
  )

  ggplot2::ggplot(
    summary_df,
    ggplot2::aes(x = .data$win_rate,
                 y = stats::reorder(.data$game_type, .data$win_rate))
  ) +
    ggplot2::geom_col(fill = .sk_pal$won, width = 0.62) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label, hjust = .data$hjust,
                   colour = .data$colour),
      size = 3.4, fontface = "bold", show.legend = FALSE
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_x_continuous(
      limits = c(0, 1), breaks = seq(0, 1, by = 0.25), labels = .sk_pct,
      expand = ggplot2::expansion(mult = c(0, 0.01))
    ) +
    ggplot2::scale_y_discrete(expand = ggplot2::expansion(add = 0.85)) +
    ggplot2::labs(
      title = "Declarer win rate by game type",
      subtitle = .sk_winrate_subtitle(summary_df),
      x = NULL,
      y = NULL,
      caption = .sk_caption(sim)
    ) +
    .sk_theme() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(
        colour = .sk_pal$ink, face = "bold", hjust = 1
      )
    )
}

# --- shared plot furniture ---------------------------------------------------

# Outcome as an ordered factor, so the legend reads Won then Lost and both keys
# are shown even when a simulation is all one way.
.sk_outcome <- function(won) {
  factor(ifelse(won, "Won", "Lost"), levels = c("Won", "Lost"))
}

.sk_caption <- function(sim) {
  n <- nrow(sim)
  types <- unique(sim$game_type)
  paste0(
    n, " simulated game", if (n == 1L) "" else "s", ": ",
    paste(.sk_title_case(sort(types)), collapse = ", ")
  )
}

.sk_points_subtitle <- function(dat) {
  base <- paste0(
    "Declarer won ", .sk_pct(mean(dat$won)),
    " of games; a suit or grand game needs 61 of the 120 card points"
  )
  if (any(dat$game_type == "null")) {
    paste0(
      base,
      ". Null games are won by taking no trick, so they fall either side"
    )
  } else {
    base
  }
}

.sk_winrate_subtitle <- function(summary_df) {
  n <- summary_df$n
  if (length(unique(n)) == 1L) {
    paste0("Share of games the declarer won, out of ", n[[1]], " per game type")
  } else {
    paste0(
      "Share of games the declarer won, out of ",
      min(n), "-", max(n), " games per game type"
    )
  }
}

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
