test_that("players are constructed and printed", {
  p <- sk_player("heuristic")
  expect_s3_class(p, "sk_player")
  expect_equal(p$strategy, "heuristic")
  expect_equal(sk_player("mcts", n_sims = 500)$n_sims, 500L)
  expect_message(print(p), "heuristic")
  expect_message(print(sk_player("mcts", n_sims = 5)), "5 sims")
  expect_invisible(suppressMessages(print(p)))
})

test_that("player construction validates its arguments", {
  expect_error(sk_player("clairvoyant"))
  expect_error(sk_player("mcts", n_sims = 0), "positive whole number")
  expect_error(sk_player("mcts", n_sims = 2.5), "positive whole number")
})

test_that("every strategy returns a legal move", {
  hand <- c("HA", "HK", "H7", "CJ", "DA")
  legal <- as.character(sk_legal_moves(hand, "H9", "spades"))
  for (strategy in c("random", "heuristic", "mcts")) {
    p <- sk_player(strategy, n_sims = 10)
    set.seed(1)
    choice <- sk_choose(p, hand, led = "H9", game_type = "spades",
                        trick = "H9")
    expect_length(choice, 1L)
    expect_true(choice %in% legal)
  }
})

test_that("the heuristic takes a valuable trick with its cheapest winner", {
  # The king led is worth 4, so the trick is worth taking. In a spades game the
  # ten and the ace both beat a king; the ten is the weaker of the two, so the
  # ace is kept back.
  choice <- sk_choose(sk_player("heuristic"), c("HA", "H10", "H9"),
                      led = "HK", game_type = "spades", trick = "HK")
  expect_equal(choice, "H10")
})

test_that("the heuristic sheds its cheapest card on a worthless trick", {
  choice <- sk_choose(sk_player("heuristic"), c("HA", "HK", "H7"),
                      led = "H8", game_type = "spades", trick = "H8")
  expect_equal(choice, "H7")
})

test_that("the heuristic does not throw points at a trick it cannot win", {
  # Void in hearts, so any card is legal but none can win. It should discard
  # the cheapest card rather than an ace.
  choice <- sk_choose(sk_player("heuristic"), c("DA", "D7", "S8"),
                      led = "HA", game_type = "hearts", trick = "HA")
  expect_true(choice %in% c("D7", "S8"))
  expect_equal(sk_points(choice), 0L)
})

test_that("the heuristic leads its weakest card", {
  choice <- sk_choose(sk_player("heuristic"), c("HA", "H7", "CJ"),
                      led = NULL, game_type = "spades")
  expect_equal(choice, "H7")
})

test_that("a forced move is returned without simulating", {
  expect_equal(
    sk_mcts_move("HA", led = "H7", game_type = "spades", n_sims = 1000),
    "HA"
  )
})

test_that("mcts prefers the winning card when the trick is rich", {
  set.seed(42)
  # Holding the two top trumps of a spades game against a trick already worth
  # 21 points, the search should take it rather than discard.
  choice <- sk_mcts_move(c("CJ", "S7"), led = "HA", game_type = "spades",
                         trick = c("HA", "H10"), n_sims = 200)
  expect_equal(choice, "CJ")
})

test_that("mcts validates its inputs", {
  expect_error(sk_mcts_move(c("HA", "HK"), NULL, "bells"), "must be one of")
  expect_error(sk_mcts_move(c("HA", "HK"), NULL, "grand", n_sims = 0),
               "positive whole number")
  expect_error(sk_mcts_move(character(0), NULL, "grand"), "No legal moves")
  expect_error(
    sk_mcts_move(c("HA", "HK"), NULL, "grand", unseen = "H9", n_sims = 5),
    "Not enough unseen cards"
  )
})

test_that("sk_choose rejects non-players and empty hands", {
  expect_error(sk_choose("heuristic", "HA", NULL, "grand"), "sk_player")
  expect_error(
    sk_choose(sk_player("random"), character(0), NULL, "grand"),
    "No legal moves"
  )
})
