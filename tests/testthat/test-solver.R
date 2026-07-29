test_that("solver: a suit-game endgame matches a by-hand trace", {
  # Hearts game, declarer in seat 1 and on lead, two cards each.
  #
  #   seat 1 (declarer): HJ (trump, 2 pts), C7 (0 pts)
  #   seat 2:            H7 (trump, 0 pts), CA (11 pts)
  #   seat 3:            DA (11 pts),       D10 (10 pts)
  #
  # Trick 1: the declarer leads HJ. Seat 2 must follow trumps and has only H7.
  # Seat 3 holds no trump and discards a diamond. The declarer takes the trick.
  # Trick 2: the declarer leads C7; seat 2 must follow with CA and wins it;
  # seat 3 sheds its other diamond. So the declarer's whole take is trick 1:
  # HJ (2) + H7 (0) + seat 3's discard.
  #
  # Seat 3 therefore keeps the ace for the trick its side wins and throws the
  # ten away: 2 + 0 + 10 = 12.
  hands <- list(c("HJ", "C7"), c("H7", "CA"), c("DA", "D10"))
  expect_equal(
    sk_solve_dd(hands, game_type = "hearts", declarer = 1, leader = 1),
    12L
  )
})

test_that("solver: unbeatable trumps sweep every point on the table", {
  # Hearts game. The declarer's CJ and HA are both trumps and no defender
  # holds one, so the declarer wins both tricks and every card point:
  # 2 + 11 + 11 + 10 + 11 + 10 = 55.
  hands <- list(c("CJ", "HA"), c("CA", "C10"), c("SA", "S10"))
  expect_equal(
    sk_solve_dd(hands, game_type = "hearts", declarer = 1, leader = 1),
    55L
  )
})

test_that("solver: a defender on lead can hold the declarer to nothing", {
  # Grand game, seat 2 leads. The declarer (seat 1) holds no trump and no ace,
  # and can never win a trick: 0 points.
  hands <- list(c("H7", "S7"), c("HA", "SA"), c("H8", "S8"))
  expect_equal(
    sk_solve_dd(hands, game_type = "grand", declarer = 1, leader = 2),
    0L
  )
})

test_that("solver: a null-game position resolves without trumps", {
  # Null game, declarer on lead, holding the two lowest cards of two suits.
  # Nothing can beat a seven, so the declarer takes no trick.
  hands <- list(c("H7", "S7"), c("HA", "SA"), c("H8", "S8"))
  expect_equal(
    sk_solve_dd(hands, game_type = "null", declarer = 1, leader = 1),
    0L
  )
})

test_that("solver: the result never exceeds the points on the table", {
  hands <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
  total <- sk_count_points(unlist(hands))
  val <- sk_solve_dd(hands, game_type = "grand", declarer = 1)
  expect_gte(val, 0L)
  expect_lte(val, total)
})

test_that("solver: an empty position scores nothing", {
  empty <- list(character(0), character(0), character(0))
  expect_equal(sk_solve_dd(empty, game_type = "grand", declarer = 1), 0L)
})

test_that("solver: leader defaults to the declarer", {
  hands <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
  expect_equal(
    sk_solve_dd(hands, game_type = "grand", declarer = 2),
    sk_solve_dd(hands, game_type = "grand", declarer = 2, leader = 2)
  )
})

test_that("solver validates its position", {
  ok <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
  expect_error(sk_solve_dd(ok[1:2], "grand", 1), "length-3 list")
  expect_error(sk_solve_dd(ok, "grand", 4), "1, 2, or 3")
  expect_error(sk_solve_dd(ok, "grand", 1, leader = 0), "positive whole")
  expect_error(
    sk_solve_dd(list(c("CJ"), c("HA", "H9"), c("DA", "D9")), "grand", 1),
    "same number of cards"
  )
  expect_error(
    sk_solve_dd(list(c("CJ", "SA"), c("CJ", "H9"), c("DA", "D9")), "grand", 1),
    "at most one seat"
  )
  expect_error(
    sk_solve_dd(list(c("CJ", "ZZ"), c("HA", "H9"), c("DA", "D9")), "grand", 1),
    "valid Skat card"
  )
})
