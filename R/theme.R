# Shared visual language for every skatR figure. Kept internal: the plots are
# meant to look like one family without the package promising a public theme.

# Suite palette. `won` is the purple accent used across the package, its website
# and the demo app; `lost` is an amber chosen so the pair separates by value as
# well as by hue, which keeps it readable in greyscale and under the two common
# forms of colour-vision deficiency.
.sk_pal <- list(
  won   = "#5E2C8E",
  lost  = "#E29A2D",
  ink   = "#2B2536",
  mid   = "#6B6478",
  grid  = "#E5E2EB",
  paper = "#FFFFFF"
)

# Lightweight percent formatter, so the package need not depend on scales.
.sk_pct <- function(x) paste0(round(100 * x), "%")

# Count axes are counts: never label them 0.5 games.
.sk_int_breaks <- function(limits) {
  b <- pretty(c(0, max(limits, na.rm = TRUE)), n = 5)
  unique(b[b == round(b)])
}

# Game types are enum strings; nobody wants to read "diamonds" on an axis.
.sk_title_case <- function(x) {
  paste0(toupper(substr(x, 1L, 1L)), substr(x, 2L, nchar(x)))
}

# One theme, both plots. Titles and captions align to the whole plot rather than
# to the panel, gridlines stay quiet, and the legend sits above the panel so it
# never steals width from the data.
.sk_theme <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = .sk_pal$ink),
      plot.title = ggplot2::element_text(
        face = "bold", size = ggplot2::rel(1.2), colour = .sk_pal$ink,
        margin = ggplot2::margin(b = 3)
      ),
      plot.subtitle = ggplot2::element_text(
        size = ggplot2::rel(0.92), colour = .sk_pal$mid,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = ggplot2::rel(0.78), colour = .sk_pal$mid, hjust = 0,
        margin = ggplot2::margin(t = 10)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.title = ggplot2::element_text(
        size = ggplot2::rel(0.88), colour = .sk_pal$mid
      ),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 6)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 6)),
      axis.text = ggplot2::element_text(
        size = ggplot2::rel(0.86), colour = .sk_pal$mid
      ),
      panel.grid.major = ggplot2::element_line(
        colour = .sk_pal$grid, linewidth = 0.3
      ),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "top",
      legend.justification = "left",
      legend.direction = "horizontal",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.88)),
      legend.key.size = ggplot2::unit(10, "pt"),
      legend.margin = ggplot2::margin(b = 2),
      plot.margin = ggplot2::margin(12, 14, 10, 12)
    )
}
