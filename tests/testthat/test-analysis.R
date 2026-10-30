test_that("base values match the rules", {
  expect_equal(sk_base_value("diamonds"), 9L)
  expect_equal(sk_base_value("hearts"), 10L)
  expect_equal(sk_base_value("spades"), 11L)
  expect_equal(sk_base_value("clubs"), 12L)
  expect_equal(sk_base_value("grand"), 24L)
  expect_true(is.na(sk_base_value("null")))
})

test_that("matador counting works with and without", {
  # With two top jacks (clubs, spades): count 2.
  m <- sk_matadors(c("CJ", "SJ", "HA"), "hearts")
  expect_true(m$with)
  expect_equal(m$count, 2L)
  # Without the jack of clubs: count of the leading absent run.
  m2 <- sk_matadors(c("HJ", "HA", "HK"), "hearts")
  expect_false(m2$with)
  expect_true(m2$count >= 1L)
})

test_that("the matador run stops at the first break", {
  # Holds CJ and SJ but not HJ: with 2.
  expect_equal(sk_matadors(c("CJ", "SJ", "DJ", "HA"), "hearts")$count, 2L)
  # Holds no jack but does hold the trump ace: without 4.
  m <- sk_matadors(c("HA", "H10", "S9"), "hearts")
  expect_false(m$with)
  expect_equal(m$count, 4L)
  # Holds every jack and the whole trump suit: with 11 in a suit game.
  full <- c("CJ", "SJ", "HJ", "DJ",
            "HA", "H10", "HK", "HQ", "H9", "H8", "H7")
  expect_equal(sk_matadors(full, "hearts")$count, 11L)
})

test_that("grand games count only the four jacks as matadors", {
  expect_equal(sk_matadors(c("CJ", "SJ", "HJ", "DJ", "HA"), "grand")$count, 4L)
  expect_equal(sk_matadors(c("CJ", "SJ", "HJ", "HA"), "grand")$count, 3L)
})

test_that("matadors are undefined for null games", {
  expect_error(sk_matadors(c("CJ", "HA"), "null"), "not")
})

test_that("game value multiplies base by matador multiplier", {
  # With 1 (jack of clubs only), game = with 1, +1 for game -> mult 2.
  gv <- sk_game_value(c("CJ", "HA", "HK"), "hearts")
  expect_equal(gv, sk_base_value("hearts") * (1L + 1L))
})

test_that("achieved levels and ouvert use the official multiplier table", {
  hand <- c("CJ", "HA", "HK")
  base <- sk_game_value(hand, "hearts")
  expect_equal(sk_game_value(hand, "hearts", hand_game = TRUE), base + 10L)
  expect_equal(sk_game_value(hand, "hearts", schneider = TRUE), base + 10L)
  expect_equal(
    sk_game_value(hand, "hearts", hand_game = TRUE, schneider = TRUE,
                  schwarz = TRUE, ouvert = TRUE),
    base + 60L  # hand, schneider, announced, schwarz, announced, ouvert
  )
})

test_that("null games have fixed values", {
  expect_equal(sk_game_value(character(0), "null"), 23L)
  expect_equal(sk_game_value(character(0), "null", hand_game = TRUE), 35L)
  expect_equal(sk_game_value(character(0), "null", ouvert = TRUE), 46L)
  expect_equal(
    sk_game_value(character(0), "null", hand_game = TRUE, ouvert = TRUE),
    59L
  )
})

test_that("scoring resolves win, loss, schneider", {
  expect_true(sk_score_game(72, "hearts", 20)$won)
  expect_false(sk_score_game(59, "hearts", 20)$won)
  expect_true(sk_score_game(95, "hearts", 20)$schneider)
  expect_equal(sk_score_game(59, "hearts", 20)$score, -40L)
})

test_that("61 points is the winning threshold", {
  expect_false(sk_score_game(60, "grand", 24)$won)
  expect_true(sk_score_game(61, "grand", 24)$won)
})

test_that("schneider and schwarz are resolved from points and tricks", {
  expect_true(sk_score_game(90, "grand", 24)$schneider)
  expect_false(sk_score_game(89, "grand", 24)$schneider)
  expect_true(sk_score_game(30, "grand", 24)$schneider)   # defence to 30
  expect_false(sk_score_game(31, "grand", 24)$schneider)
  expect_true(sk_score_game(120, "grand", 24, declarer_won_all = TRUE)$schwarz)
  expect_true(sk_score_game(0, "grand", 24, declarer_lost_all = TRUE)$schwarz)
  expect_false(sk_score_game(70, "grand", 24)$schwarz)
})

test_that("a lost game costs twice the game value", {
  won <- sk_score_game(80, "clubs", 36)
  lost <- sk_score_game(40, "clubs", 36)
  expect_equal(won$score, 36L)
  expect_equal(lost$score, -72L)
})

test_that("null scoring rewards taking no trick", {
  won <- sk_score_game(0, "null", 23, declarer_lost_all = TRUE)
  expect_true(won$won)
  expect_equal(won$score, 23L)
  lost <- sk_score_game(0, "null", 23, declarer_lost_all = FALSE)
  expect_false(lost$won)
  expect_equal(lost$score, -46L)
  # Null games never report schneider or schwarz.
  expect_false(won$schneider)
  expect_false(won$schwarz)
})

test_that("null ignores card points entirely", {
  expect_true(sk_score_game(119, "null", 23, declarer_lost_all = TRUE)$won)
  expect_false(sk_score_game(0, "null", 23)$won)
})

test_that("scoring validates its inputs", {
  expect_error(sk_score_game(121, "grand", 24), "between 0 and 120")
  expect_error(sk_score_game(-1, "grand", 24), "between 0 and 120")
  expect_error(sk_score_game(60, "grand", 0), "positive whole number")
  expect_error(
    sk_score_game(60, "grand", 24, declarer_won_all = TRUE,
                  declarer_lost_all = TRUE),
    "cannot both"
  )
})

test_that("results print", {
  expect_message(print(sk_score_game(72, "hearts", 20)), "won")
  expect_message(print(sk_score_game(20, "hearts", 20)), "lost")
})

test_that("simulation returns a type-stable tibble", {
  sim <- sk_simulate(n = 5, game_type = "grand", seed = 1, verbose = FALSE)
  expect_s3_class(sim, "tbl_df")
  expect_equal(nrow(sim), 5L)
  expect_true(all(c("won", "score", "declarer_points") %in% names(sim)))
  expect_type(sim$won, "logical")
})

test_that("double-dummy solver returns a valid point total", {
  hands <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
  val <- sk_solve_dd(hands, game_type = "grand", declarer = 1)
  expect_true(is.numeric(val))
  expect_true(val >= 0 && val <= 120)
})

test_that("solver: declarer with all trumps takes every point available", {
  # Declarer holds the two highest trumps; leads; should capture the aces.
  hands <- list(c("CJ", "SJ"), c("HA", "DA"), c("H10", "D10"))
  val <- sk_solve_dd(hands, game_type = "grand", declarer = 1, leader = 1)
  # Declarer wins both tricks with the top jacks. Trick points include the
  # declarer's own jacks (2 + 2) plus the swept aces and tens (11+11+10+10):
  # 4 + 42 = 46.
  expect_equal(val, 46L)
})

test_that("plots return ggplot objects", {
  sim <- sk_simulate(n = 10, seed = 2, verbose = FALSE)
  expect_s3_class(sk_plot_points(sim), "ggplot")
  expect_s3_class(sk_plot_winrate(sim), "ggplot")
})
