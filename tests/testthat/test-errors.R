# Snapshots of the user-facing input-validation messages. These are the
# contract between skatR and its users: if a message changes, the snapshot
# should be reviewed deliberately rather than drift unnoticed.

test_that("game-type errors read well", {
  expect_snapshot(sk_card_order("bells"), error = TRUE)
  expect_snapshot(sk_card_order(42), error = TRUE)
  expect_snapshot(sk_matadors(c("CJ", "HA"), "null"), error = TRUE)
})

test_that("card errors read well", {
  expect_snapshot(sk_points("ZZ"), error = TRUE)
  expect_snapshot(sk_points(1:3), error = TRUE)
  expect_snapshot(sk_trick_winner(c("HA", "HK"), "grand"), error = TRUE)
})

test_that("solver errors read well", {
  expect_snapshot(
    sk_solve_dd(list(c("CJ"), c("HA", "H9"), c("DA", "D9")), "grand", 1),
    error = TRUE
  )
  expect_snapshot(
    sk_solve_dd(list(c("CJ", "SA"), c("CJ", "H9"), c("DA", "D9")), "grand", 1),
    error = TRUE
  )
  expect_snapshot(
    sk_solve_dd(list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9")), "grand", 9),
    error = TRUE
  )
})

test_that("scoring errors read well", {
  expect_snapshot(sk_score_game(200, "grand", 24), error = TRUE)
  expect_snapshot(
    sk_score_game(60, "grand", 24, declarer_won_all = TRUE,
                  declarer_lost_all = TRUE),
    error = TRUE
  )
})

test_that("plotting errors read well", {
  expect_snapshot(sk_plot_points(1:10), error = TRUE)
  expect_snapshot(sk_plot_winrate(data.frame(won = TRUE)), error = TRUE)
})

test_that("player errors read well", {
  expect_snapshot(sk_choose("heuristic", "HA", NULL, "grand"), error = TRUE)
  expect_snapshot(
    sk_play_game(sk_deal(seed = 1)$hands, sk_deal(seed = 1)$skat, 1, "grand",
                 players = list(1, 2, 3)),
    error = TRUE
  )
})
