test_that("dealing produces three ten-card hands and a two-card skat", {
  d <- sk_deal(seed = 1)
  expect_s3_class(d, "sk_deal")
  expect_length(d$hands, 3L)
  expect_true(all(vapply(d$hands, length, integer(1)) == 10L))
  expect_length(d$skat, 2L)
  all_cards <- c(unlist(lapply(d$hands, as.character)), as.character(d$skat))
  expect_setequal(all_cards, as.character(sk_full_deck()))
})

test_that("a seed makes the deal reproducible and restores the RNG state", {
  expect_equal(as.character(sk_deal(seed = 7)$skat),
               as.character(sk_deal(seed = 7)$skat))

  set.seed(99)
  before <- runif(1)
  set.seed(99)
  invisible(sk_deal(seed = 1))
  expect_equal(runif(1), before)
})

test_that("seeds may be zero or negative", {
  expect_s3_class(sk_deal(seed = 0), "sk_deal")
  expect_s3_class(sk_deal(seed = -5), "sk_deal")
  expect_error(sk_deal(seed = 1.5), "whole number")
})

test_that("deals print", {
  expect_message(print(sk_deal(seed = 3)), "Player 1")
})

test_that("a played game distributes all 120 card points", {
  d <- sk_deal(seed = 42)
  g <- sk_play_game(d$hands, d$skat, declarer = 1, game_type = "grand")
  expect_s3_class(g, "sk_game")
  expect_length(g$tricks, 10L)
  expect_equal(sum(vapply(g$tricks, function(tr) tr$points, integer(1))),
               120L - sk_count_points(d$skat))
})

test_that("declarer_points is the total the result was scored on", {
  d <- sk_deal(seed = 11)
  g <- sk_play_game(d$hands, d$skat, declarer = 2, game_type = "clubs")
  trick_pts <- sum(vapply(g$tricks, function(tr) {
    if (tr$winner == 2L) tr$points else 0L
  }, integer(1)))
  # A non-hand game credits the skat to the declarer.
  expect_equal(g$declarer_points, trick_pts + sk_count_points(d$skat))
  expect_equal(g$result$won, g$declarer_points >= 61L)
})

test_that("a hand game credits skat points under ISkO 2.5.4", {
  d <- sk_deal(seed = 11)
  g <- sk_play_game(d$hands, d$skat, declarer = 2, game_type = "clubs",
                    hand_game = TRUE)
  trick_pts <- sum(vapply(g$tricks, function(tr) {
    if (tr$winner == 2L) tr$points else 0L
  }, integer(1)))
  expect_equal(g$declarer_points, trick_pts + sk_count_points(d$skat))
})

test_that("every trick is legal and has one winner", {
  d <- sk_deal(seed = 5)
  g <- sk_play_game(d$hands, d$skat, declarer = 3, game_type = "hearts")
  played <- unlist(lapply(g$tricks, function(tr) tr$cards))
  expect_length(played, 30L)
  expect_length(unique(played), 30L)
  winners <- vapply(g$tricks, function(tr) tr$winner, integer(1))
  expect_true(all(winners %in% 1:3))
  # The winner of a trick leads the next one.
  leaders <- vapply(g$tricks, function(tr) tr$leader, integer(1))
  expect_equal(leaders[-1], winners[-10])
  expect_equal(leaders[1], 1L)  # forehand leads
})

test_that("a null game plays out and scores by tricks taken", {
  d <- sk_deal(seed = 8)
  g <- sk_play_game(d$hands, d$skat, declarer = 1, game_type = "null")
  expect_equal(g$result$game_value, 23L)
  expect_equal(g$result$won, g$tricks_won == 0L)
  expect_false(g$result$schneider)
  expect_false(g$result$schwarz)
})

test_that("games print", {
  d <- sk_deal(seed = 42)
  g <- sk_play_game(d$hands, d$skat, declarer = 1, game_type = "grand")
  expect_message(print(g), "sk_game")
  expect_invisible(suppressMessages(print(g)))
})

test_that("sk_play_game validates its inputs", {
  d <- sk_deal(seed = 1)
  expect_error(sk_play_game(d$hands[1:2], d$skat, 1, "grand"), "length-3 list")
  expect_error(sk_play_game(d$hands, d$skat, 4, "grand"), "1, 2, or 3")
  expect_error(sk_play_game(d$hands, d$skat, 1, "bells"), "must be one of")
  expect_error(
    sk_play_game(d$hands, d$skat, 1, "grand", players = list(1, 2, 3)),
    "sk_player"
  )
  short <- d$hands
  short[[1]] <- short[[1]][1:9]
  expect_error(sk_play_game(short, d$skat, 1, "grand"), "ten cards")
})
