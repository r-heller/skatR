test_that("the simulation tibble has a stable shape and types", {
  sim <- sk_simulate(n = 8, game_type = "hearts", seed = 3, verbose = FALSE)
  expect_s3_class(sim, "tbl_df")
  expect_equal(nrow(sim), 8L)
  expect_named(sim, c("game", "game_type", "declarer", "declarer_points",
                      "won", "schneider", "schwarz", "game_value", "score"))
  expect_type(sim$game, "integer")
  expect_type(sim$game_type, "character")
  expect_type(sim$declarer, "integer")
  expect_type(sim$declarer_points, "integer")
  expect_type(sim$won, "logical")
  expect_type(sim$schneider, "logical")
  expect_type(sim$schwarz, "logical")
  expect_type(sim$game_value, "integer")
  expect_type(sim$score, "integer")
})

test_that("a single game still returns a one-row tibble", {
  sim <- sk_simulate(n = 1, seed = 1, verbose = FALSE)
  expect_s3_class(sim, "tbl_df")
  expect_equal(nrow(sim), 1L)
})

test_that("simulations are reproducible and restore the RNG state", {
  a <- sk_simulate(n = 5, seed = 12, verbose = FALSE)
  b <- sk_simulate(n = 5, seed = 12, verbose = FALSE)
  expect_equal(a, b)

  set.seed(4)
  before <- runif(1)
  set.seed(4)
  invisible(sk_simulate(n = 3, seed = 1, verbose = FALSE))
  expect_equal(runif(1), before)
})

test_that("reported points agree with the reported outcome", {
  sim <- sk_simulate(n = 25, game_type = "grand", seed = 6, verbose = FALSE)
  expect_equal(sim$won, sim$declarer_points >= 61L)
  expect_true(all(sim$declarer_points >= 0L & sim$declarer_points <= 120L))
  expect_equal(sim$score, ifelse(sim$won, sim$game_value, -2L * sim$game_value))
})

test_that("null simulations score by tricks, not points", {
  sim <- sk_simulate(n = 10, game_type = "null", seed = 2, verbose = FALSE)
  expect_true(all(sim$game_value == 23L))
  expect_false(any(sim$schneider))
  expect_false(any(sim$schwarz))
})

test_that("the progress bar path runs", {
  expect_no_error(sk_simulate(n = 2, seed = 1, verbose = TRUE))
})

test_that("simulation validates its arguments", {
  expect_error(sk_simulate(n = 0), "positive whole number")
  expect_error(sk_simulate(n = 5, game_type = "bells"), "must be one of")
  expect_error(sk_simulate(n = 5, declarer = 4), "1, 2, or 3")
  expect_error(sk_simulate(n = 5, verbose = NA), "TRUE")
  expect_error(sk_simulate(n = 5, seed = "one"), "whole number")
})

test_that("plots are ggplot objects and read the right columns", {
  sim <- sk_simulate(n = 10, seed = 2, verbose = FALSE)
  p <- sk_plot_points(sim)
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))

  both <- rbind(
    sk_simulate(n = 10, game_type = "grand", seed = 1, verbose = FALSE),
    sk_simulate(n = 10, game_type = "clubs", seed = 2, verbose = FALSE)
  )
  w <- sk_plot_winrate(both)
  expect_s3_class(w, "ggplot")
  expect_no_error(ggplot2::ggplot_build(w))
})

test_that("plots reject anything that is not a simulation tibble", {
  expect_error(sk_plot_points(1:10), "simulation tibble")
  expect_error(sk_plot_winrate(data.frame(x = 1)), "Missing column")
  sim <- sk_simulate(n = 5, seed = 1, verbose = FALSE)
  expect_error(sk_plot_points(sim, bins = 0), "positive whole number")
})
