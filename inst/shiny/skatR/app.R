# skatR demo Shiny app. Uses only the skatR and shiny namespaces; no library().
# bslib is optional: when it is installed the app picks up the suite's purple
# accent, otherwise it falls back to Shiny's default Bootstrap theme.

sk_theme <- if (requireNamespace("bslib", quietly = TRUE)) {
  bslib::bs_theme(version = 5, primary = "#5E2C8E")
} else {
  NULL
}

# The hex logo ships once, in man/figures; R CMD INSTALL puts it under
# help/figures. Serve it from there rather than keeping a second copy.
sk_logo_dir <- system.file("help", "figures", package = "skatR")
sk_has_logo <- nzchar(sk_logo_dir) &&
  file.exists(file.path(sk_logo_dir, "logo.png"))
if (sk_has_logo) shiny::addResourcePath("skatr-figures", sk_logo_dir)

ui <- shiny::fluidPage(
  theme = sk_theme,
  shiny::titlePanel(
    shiny::tagList(
      if (sk_has_logo) {
        shiny::img(src = "skatr-figures/logo.png", height = "48px",
                   style = "margin-right: 12px; vertical-align: middle;",
                   alt = "skatR logo")
      },
      "skatR \u2014 Skat simulation explorer"
    ),
    windowTitle = "skatR"
  ),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput(
        "game_type", "Game type",
        choices = skatR::sk_game_types(), selected = "grand"
      ),
      shiny::selectInput(
        "strategy", "Player strategy",
        choices = c("heuristic", "random", "mcts"), selected = "heuristic"
      ),
      shiny::sliderInput("n", "Number of games", min = 10, max = 1000,
                         value = 200, step = 10),
      shiny::numericInput("seed", "Seed", value = 1, min = 1),
      shiny::actionButton("run", "Run simulation", class = "btn-primary"),
      shiny::helpText(
        "Monte Carlo tree search is much slower than the other strategies;",
        "start with a small number of games."
      )
    ),
    shiny::mainPanel(
      shiny::verbatimTextOutput("summary"),
      shiny::plotOutput("points_plot"),
      shiny::plotOutput("winrate_plot")
    )
  )
)

server <- function(input, output, session) {
  sim <- shiny::eventReactive(input$run, {
    players <- rep(list(skatR::sk_player(input$strategy)), 3)
    shiny::withProgress(message = "Simulating games", value = 0, {
      skatR::sk_simulate(
        n = input$n, game_type = input$game_type,
        players = players, seed = input$seed, verbose = FALSE
      )
    })
  })

  output$summary <- shiny::renderPrint({
    s <- shiny::req(sim())
    cat("Games:", nrow(s), "\n")
    cat("Win rate:", round(mean(s$won), 3), "\n")
    cat("Mean declarer points:", round(mean(s$declarer_points), 1), "\n")
    cat("Mean score:", round(mean(s$score), 1), "\n")
  })

  output$points_plot <- shiny::renderPlot({
    skatR::sk_plot_points(shiny::req(sim()))
  })

  output$winrate_plot <- shiny::renderPlot({
    skatR::sk_plot_winrate(shiny::req(sim()))
  })
}

shiny::shinyApp(ui, server)
