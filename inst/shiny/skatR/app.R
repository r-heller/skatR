# skatR demo Shiny app.
#
# Uses only the skatR, shiny and bslib namespaces; no library() call, so the app
# exercises the same `pkg::fun()` path a user's session does. sk_run_app() checks
# that shiny and bslib are installed before this file is sourced.

# --- look and feel ----------------------------------------------------------

SK_ACCENT <- "#5E2C8E"
SK_INK <- "#2B2536"

sk_theme <- bslib::bs_theme(
  version = 5,
  bg = "#FFFFFF",
  fg = SK_INK,
  primary = SK_ACCENT,
  secondary = "#6B6478",
  success = SK_ACCENT,
  base_font = bslib::font_collection(
    "system-ui", "-apple-system", "Segoe UI", "Roboto", "Helvetica Neue",
    "Arial", "sans-serif"
  ),
  "border-radius" = "0.55rem",
  "card-border-color" = "#E5E2EB",
  "card-cap-bg" = "#F7F5FA"
)

# The hex logo ships once, in man/figures; R CMD INSTALL puts it under
# help/figures. Serve it from there rather than keeping a second copy.
sk_logo_dir <- system.file("help", "figures", package = "skatR")
sk_has_logo <- nzchar(sk_logo_dir) &&
  file.exists(file.path(sk_logo_dir, "logo.png"))
if (sk_has_logo) shiny::addResourcePath("skatr-figures", sk_logo_dir)

# --- card rendering ---------------------------------------------------------

SK_SUIT_GLYPH <- c(C = "\u2663", S = "\u2660", H = "\u2665", D = "\u2666")
SK_SUIT_NAME <- c(C = "clubs", S = "spades", H = "hearts", D = "diamonds")
SK_DISPLAY_RANKS <- c("A", "10", "K", "Q", "J", "9", "8", "7")
SK_TYPE_CHOICES <- c(
  "Grand" = "grand", "Clubs" = "clubs", "Spades" = "spades",
  "Hearts" = "hearts", "Diamonds" = "diamonds", "Null" = "null"
)
SK_STRATEGY_CHOICES <- c(
  "Heuristic" = "heuristic", "Random" = "random",
  "Monte Carlo tree search" = "mcts"
)

# Reading order: suit blocks, then descending rank within a suit.
sk_sort_hand <- function(codes) {
  codes[order(
    match(skatR::sk_suit_of(codes), skatR::sk_suits),
    match(skatR::sk_rank_of(codes), SK_DISPLAY_RANKS)
  )]
}

# One playing card. `state` dims cards already gone from a hand; `mark` puts the
# accent ring on the card that took the trick.
sk_card_tag <- function(code, state = c("live", "played"), mark = FALSE,
                        size = c("sm", "lg")) {
  state <- match.arg(state)
  size <- match.arg(size)
  suit <- skatR::sk_suit_of(code)
  rank <- skatR::sk_rank_of(code)
  shiny::div(
    class = paste(
      "sk-card",
      paste0("sk-", size),
      if (suit %in% c("H", "D")) "sk-red" else "sk-black",
      if (state == "played") "sk-spent" else "",
      if (mark) "sk-took" else ""
    ),
    `aria-label` = paste(rank, "of", SK_SUIT_NAME[[suit]]),
    shiny::span(class = "sk-rank", rank),
    shiny::span(class = "sk-suit", SK_SUIT_GLYPH[[suit]])
  )
}

# A fanned hand, with a gap between suit blocks.
sk_hand_tag <- function(codes, spent = character(0), size = "sm") {
  codes <- sk_sort_hand(codes)
  suits <- skatR::sk_suit_of(codes)
  items <- list()
  for (i in seq_along(codes)) {
    if (i > 1L && suits[[i]] != suits[[i - 1L]]) {
      items[[length(items) + 1L]] <- shiny::span(class = "sk-gap")
    }
    items[[length(items) + 1L]] <- sk_card_tag(
      codes[[i]],
      state = if (codes[[i]] %in% spent) "played" else "live",
      size = size
    )
  }
  shiny::div(class = "sk-hand", items)
}

sk_slot_tag <- function() shiny::div(class = "sk-card sk-lg sk-slot", "")

sk_empty_state <- function(text) {
  shiny::div(class = "sk-empty", shiny::p(text))
}

sk_stat <- function(label, value, sub = NULL) {
  shiny::div(
    class = "sk-stat",
    shiny::div(class = "sk-stat-label", label),
    shiny::div(class = "sk-stat-value", value),
    if (!is.null(sub)) shiny::div(class = "sk-stat-sub", sub)
  )
}

sk_pct <- function(x) paste0(format(round(100 * x, 1), nsmall = 1), "%")
sk_signed <- function(x) {
  paste0(if (x > 0) "+" else if (x < 0) "\u2212" else "", format(abs(x)))
}

# --- ui ---------------------------------------------------------------------

sk_brand <- shiny::tags$span(
  class = "sk-brand",
  if (sk_has_logo) {
    shiny::img(src = "skatr-figures/logo.png", class = "sk-brand-logo",
               alt = "")
  },
  shiny::tags$span(class = "sk-brand-name", "skatR"),
  shiny::tags$span(class = "sk-brand-tag", "Skat explorer")
)

sim_sidebar <- bslib::sidebar(
  width = 300,
  shiny::selectInput("game_type", "Game type", choices = SK_TYPE_CHOICES,
                     selected = "grand"),
  shiny::selectInput("strategy", "Player strategy",
                     choices = SK_STRATEGY_CHOICES, selected = "heuristic"),
  shiny::sliderInput("n", "Games to simulate", min = 50, max = 1000,
                     value = 200, step = 50, ticks = FALSE),
  shiny::numericInput("seed", "Seed", value = 1, min = 1, step = 1),
  shiny::actionButton("run", "Run simulation", class = "btn-primary w-100",
                      icon = NULL),
  shiny::div(
    class = "sk-note",
    "All three seats play the chosen strategy. Monte Carlo tree search is much",
    "slower than the others: start with 50 games."
  )
)

play_sidebar <- bslib::sidebar(
  width = 300,
  shiny::selectInput("deal_type", "Game type", choices = SK_TYPE_CHOICES,
                     selected = "grand"),
  shiny::selectInput("deal_declarer", "Declarer",
                     choices = c("Player 1" = "1", "Player 2" = "2",
                                 "Player 3" = "3"),
                     selected = "1"),
  shiny::numericInput("deal_seed", "Deal seed", value = 42, min = 1, step = 1),
  shiny::actionButton("deal_go", "Deal and play", class = "btn-primary w-100"),
  shiny::div(
    class = "sk-note",
    "Step the slider to walk the deal card by card: the hands empty, the",
    "trick fills up, and the running totals follow."
  )
)

ref_sidebar <- bslib::sidebar(
  width = 300,
  shiny::selectInput("ref_type", "Game type", choices = SK_TYPE_CHOICES,
                     selected = "grand"),
  shiny::div(
    class = "sk-note",
    "Trick-taking order runs weakest to strongest. In suit and grand games",
    "every jack is a trump, so the jacks sit above the trump suit."
  )
)

ui <- bslib::page_navbar(
  title = sk_brand,
  window_title = "skatR",
  theme = sk_theme,
  navbar_options = bslib::navbar_options(bg = SK_INK, theme = "dark"),
  header = shiny::tags$head(
    shiny::tags$link(rel = "stylesheet", type = "text/css",
                     href = "skatr.css")
  ),
  bslib::nav_panel(
    "Simulate",
    bslib::layout_sidebar(
      sidebar = sim_sidebar,
      shiny::uiOutput("sim_stats"),
      bslib::layout_column_wrap(
        width = 1,
        heights_equal = "row",
        bslib::card(
          bslib::card_header("Card points the declarer collected"),
          shiny::plotOutput("points_plot", height = "340px")
        ),
        bslib::card(
          bslib::card_header("Win rate"),
          shiny::plotOutput("winrate_plot", height = "260px")
        )
      )
    )
  ),
  bslib::nav_panel(
    "Deal & play",
    bslib::layout_sidebar(
      sidebar = play_sidebar,
      bslib::card(
        bslib::card_header("The deal"),
        bslib::card_body(
          shiny::uiOutput("play_controls"),
          shiny::uiOutput("play_hands")
        )
      ),
      bslib::layout_column_wrap(
        width = 1 / 2,
        heights_equal = "row",
        bslib::card(
          bslib::card_header("Trick in progress"),
          shiny::uiOutput("play_trick")
        ),
        bslib::card(
          bslib::card_header("Where the game stands"),
          shiny::uiOutput("play_tally")
        )
      )
    )
  ),
  bslib::nav_panel(
    "Reference",
    bslib::layout_sidebar(
      sidebar = ref_sidebar,
      bslib::card(
        bslib::card_header("Trick-taking order, weakest to strongest"),
        shiny::uiOutput("ref_order")
      ),
      bslib::layout_column_wrap(
        width = 1 / 2,
        heights_equal = "row",
        bslib::card(
          bslib::card_header("Card points"),
          shiny::uiOutput("ref_points")
        ),
        bslib::card(
          bslib::card_header("Game values"),
          shiny::uiOutput("ref_values")
        )
      )
    )
  ),
  bslib::nav_spacer(),
  bslib::nav_item(
    shiny::tags$a(
      "Documentation", href = "https://r-heller.github.io/skatR/",
      target = "_blank", rel = "noopener"
    )
  )
)

# --- server -----------------------------------------------------------------

server <- function(input, output, session) {

  # -- simulate --------------------------------------------------------------

  sim <- shiny::eventReactive(input$run, {
    players <- rep(list(skatR::sk_player(input$strategy)), 3)
    shiny::withProgress(message = "Simulating games", value = 0, {
      skatR::sk_simulate(
        n = input$n, game_type = input$game_type,
        players = players, seed = input$seed, verbose = FALSE
      )
    })
  })

  output$sim_stats <- shiny::renderUI({
    if (input$run == 0L) {
      return(sk_empty_state(
        paste("Pick a game type and a strategy, then press Run simulation.",
              "The declarer's card points, win rate and score come back here.")
      ))
    }
    s <- sim()
    shiny::div(
      class = "sk-stat-row",
      sk_stat("Games", format(nrow(s), big.mark = ","),
              names(SK_TYPE_CHOICES)[match(s$game_type[[1]],
                                           SK_TYPE_CHOICES)]),
      sk_stat("Declarer win rate", sk_pct(mean(s$won)),
              paste(sum(s$won), "won")),
      sk_stat("Mean card points", format(round(mean(s$declarer_points), 1),
                                         nsmall = 1), "of 120"),
      sk_stat("Mean score", sk_signed(round(mean(s$score), 1)),
              "per game")
    )
  })

  output$points_plot <- shiny::renderPlot({
    skatR::sk_plot_points(shiny::req(sim()))
  }, res = 104)

  output$winrate_plot <- shiny::renderPlot({
    skatR::sk_plot_winrate(shiny::req(sim()))
  }, res = 104)

  # -- deal & play -----------------------------------------------------------

  deal <- shiny::eventReactive(input$deal_go, {
    skatR::sk_deal(seed = input$deal_seed)
  }, ignoreNULL = FALSE)

  game <- shiny::reactive({
    d <- deal()
    skatR::sk_play_game(
      d$hands, d$skat,
      declarer = as.integer(input$deal_declarer),
      game_type = input$deal_type
    )
  })

  # One row per card played, in play order: 30 plies over ten tricks.
  plies <- shiny::reactive({
    g <- game()
    do.call(rbind, lapply(seq_along(g$tricks), function(t) {
      tr <- g$tricks[[t]]
      seats <- ((tr$leader - 1L + 0:2) %% 3L) + 1L
      data.frame(
        trick = t, pos = 1:3, seat = seats, card = tr$cards,
        winner = tr$winner, stringsAsFactors = FALSE
      )
    }))
  })

  output$play_controls <- shiny::renderUI({
    shiny::sliderInput(
      "ply", "Cards played", min = 0, max = 30,
      value = 30, step = 1, width = "100%", ticks = FALSE,
      animate = shiny::animationOptions(interval = 550)
    )
  })

  output$play_hands <- shiny::renderUI({
    d <- deal()
    g <- game()
    p <- shiny::req(input$ply)
    pl <- plies()
    spent <- if (p > 0L) pl$card[seq_len(p)] else character(0)
    declarer <- g$declarer

    seat_rows <- lapply(1:3, function(s) {
      hand <- as.character(d$hands[[s]])
      left <- setdiff(hand, spent)
      shiny::div(
        class = paste("sk-seat", if (s == declarer) "sk-seat-declarer" else ""),
        shiny::div(
          class = "sk-seat-head",
          shiny::span(class = "sk-seat-name", paste("Player", s)),
          if (s == declarer) {
            shiny::span(class = "sk-badge", "declarer")
          } else {
            shiny::span(class = "sk-badge sk-badge-quiet", "defence")
          },
          shiny::span(
            class = "sk-seat-meta",
            paste0(length(left), " card", if (length(left) == 1L) "" else "s",
                   " left")
          )
        ),
        sk_hand_tag(hand, spent = spent)
      )
    })

    shiny::tagList(
      seat_rows,
      shiny::div(
        class = "sk-seat sk-seat-skat",
        shiny::div(
          class = "sk-seat-head",
          shiny::span(class = "sk-seat-name", "Skat"),
          shiny::span(
            class = "sk-seat-meta",
            paste(skatR::sk_count_points(d$skat), "card points to the declarer")
          )
        ),
        sk_hand_tag(as.character(d$skat))
      )
    )
  })

  output$play_trick <- shiny::renderUI({
    g <- game()
    p <- shiny::req(input$ply)
    pl <- plies()
    if (p == 0L) {
      return(sk_empty_state("Nothing played yet. Move the slider to lead."))
    }
    t <- ((p - 1L) %/% 3L) + 1L
    shown <- p - 3L * (t - 1L)
    rows <- pl[pl$trick == t, ]
    complete <- shown == 3L
    slots <- lapply(1:3, function(i) {
      if (i > shown) {
        return(shiny::div(class = "sk-play", sk_slot_tag(),
                          shiny::div(class = "sk-play-seat", shiny::HTML("&nbsp;"))))
      }
      r <- rows[i, ]
      took <- complete && r$seat == r$winner
      shiny::div(
        class = paste("sk-play", if (took) "sk-play-took" else ""),
        sk_card_tag(r$card, mark = took, size = "lg"),
        shiny::div(class = "sk-play-seat", paste("P", r$seat, sep = ""))
      )
    })
    played <- rows$card[seq_len(shown)]
    shiny::tagList(
      shiny::div(
        class = "sk-trick-head",
        shiny::span(class = "sk-trick-no", paste("Trick", t, "of 10")),
        shiny::span(
          class = "sk-trick-meta",
          paste0(skatR::sk_count_points(played), " card points on the table")
        )
      ),
      shiny::div(class = "sk-trick", slots),
      shiny::div(
        class = "sk-trick-foot",
        if (complete) {
          paste0("Player ", rows$winner[[1]], " takes it",
                 if (rows$winner[[1]] == g$declarer) " for the declarer." else
                   " for the defence.")
        } else {
          paste0("Player ", rows$seat[[shown]], " has played; ",
                 3L - shown, " to come.")
        }
      )
    )
  })

  output$play_tally <- shiny::renderUI({
    g <- game()
    p <- shiny::req(input$ply)
    pl <- plies()
    done <- (p %/% 3L)
    dec_pts <- 0L
    dec_tricks <- 0L
    if (done > 0L) {
      for (t in seq_len(done)) {
        tr <- g$tricks[[t]]
        if (tr$winner == g$declarer) {
          dec_pts <- dec_pts + tr$points
          dec_tricks <- dec_tricks + 1L
        }
      }
    }
    finished <- p == 30L
    res <- g$result

    shiny::tagList(
      shiny::div(
        class = "sk-stat-row sk-stat-row-tight",
        sk_stat("Tricks to declarer", paste0(dec_tricks, " / ", done)),
        sk_stat("Card points in tricks", paste0(dec_pts, " / 120")),
        sk_stat("Needed to win", if (g$game_type == "null") "no trick" else "61")
      ),
      if (finished) {
        shiny::div(
          class = paste("sk-verdict",
                        if (res$won) "sk-verdict-won" else "sk-verdict-lost"),
          shiny::div(
            class = "sk-verdict-head",
            paste0("Declarer ", if (res$won) "won" else "lost",
                   " the ", input$deal_type, " game")
          ),
          shiny::tags$dl(
            class = "sk-dl",
            shiny::tags$dt("Card points"),
            shiny::tags$dd(paste0(g$declarer_points, " of 120 (tricks + skat)")),
            shiny::tags$dt("Game value"), shiny::tags$dd(res$game_value),
            shiny::tags$dt("Score"), shiny::tags$dd(sk_signed(res$score)),
            shiny::tags$dt("Schneider"),
            shiny::tags$dd(if (res$schneider) "yes" else "no"),
            shiny::tags$dt("Schwarz"),
            shiny::tags$dd(if (res$schwarz) "yes" else "no")
          )
        )
      } else {
        shiny::div(
          class = "sk-note sk-note-inline",
          "The verdict appears once all ten tricks are played."
        )
      }
    )
  })

  # -- reference -------------------------------------------------------------

  output$ref_order <- shiny::renderUI({
    ord <- skatR::sk_card_order(input$ref_type)
    trumps <- skatR::sk_is_trump(ord, input$ref_type)
    shiny::tagList(
      shiny::div(
        class = "sk-legend",
        shiny::span(class = "sk-legend-item", "Weakest first"),
        shiny::span(class = "sk-legend-arrow", "\u2192"),
        shiny::span(class = "sk-legend-item", "Strongest last"),
        if (any(trumps)) {
          shiny::span(class = "sk-badge", paste(sum(trumps), "trumps"))
        }
      ),
      shiny::div(
        class = "sk-order",
        lapply(seq_along(ord), function(i) {
          shiny::div(
            class = if (trumps[[i]]) "sk-order-cell sk-order-trump" else
              "sk-order-cell",
            sk_card_tag(ord[[i]])
          )
        })
      )
    )
  })

  output$ref_points <- shiny::renderUI({
    ranks <- c("A", "10", "K", "Q", "J", "9", "8", "7")
    pts <- skatR::sk_points(paste0("C", ranks))
    names <- c("Ace", "Ten", "King", "Queen", "Jack", "Nine", "Eight", "Seven")
    shiny::tags$table(
      class = "sk-table",
      shiny::tags$thead(shiny::tags$tr(
        shiny::tags$th("Rank"), shiny::tags$th("Card"),
        shiny::tags$th(class = "sk-num", "Points")
      )),
      shiny::tags$tbody(
        lapply(seq_along(ranks), function(i) {
          shiny::tags$tr(
            shiny::tags$td(names[[i]]),
            shiny::tags$td(sk_card_tag(paste0("C", ranks[[i]]))),
            shiny::tags$td(class = "sk-num", pts[[i]])
          )
        }),
        shiny::tags$tr(
          class = "sk-table-total",
          shiny::tags$td("All 32 cards"), shiny::tags$td(""),
          shiny::tags$td(class = "sk-num", "120")
        )
      )
    )
  })

  output$ref_values <- shiny::renderUI({
    types <- c("clubs", "spades", "hearts", "diamonds", "grand")
    base <- vapply(types, skatR::sk_base_value, integer(1), USE.NAMES = FALSE)
    rows <- lapply(seq_along(types), function(i) {
      shiny::tags$tr(
        shiny::tags$td(names(SK_TYPE_CHOICES)[match(types[[i]],
                                                    SK_TYPE_CHOICES)]),
        shiny::tags$td(class = "sk-num", base[[i]]),
        shiny::tags$td("base x (matadors + 1 + achieved/announced levels)")
      )
    })
    shiny::tags$table(
      class = "sk-table",
      shiny::tags$thead(shiny::tags$tr(
        shiny::tags$th("Game"), shiny::tags$th(class = "sk-num", "Base"),
        shiny::tags$th("Value")
      )),
      shiny::tags$tbody(
        rows,
        shiny::tags$tr(
          shiny::tags$td("Null"), shiny::tags$td(class = "sk-num", "\u2014"),
          shiny::tags$td("23 fixed; 35 hand, 46 ouvert, 59 hand ouvert")
        )
      )
    )
  })
}

shiny::shinyApp(ui, server)
