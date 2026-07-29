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

test_that("solver: deeper positions keep the values the plain search gave", {
  # Regression fixtures. These four positions were solved by the original
  # unmemoised, unordered alpha-beta search; the transposition table and move
  # ordering added afterwards are pure optimisations, so every value here must
  # survive unchanged. They are deep enough (five and six tricks) that the
  # table is exercised, and shallow enough to stay well under a second.
  a <- list(
    c("DA", "HJ", "HA", "DJ", "CA"),
    c("S10", "CQ", "CK", "HK", "D10"),
    c("SJ", "SQ", "C9", "D8", "H7")
  )
  expect_equal(sk_solve_dd(a, "grand", declarer = 1, leader = 1), 59L)
  expect_equal(sk_solve_dd(a, "clubs", declarer = 1, leader = 1), 65L)

  b <- list(
    c("S8", "DA", "HJ", "HA", "DJ", "CA"),
    c("S7", "S10", "CQ", "CK", "HK", "D10"),
    c("SA", "SJ", "SQ", "C9", "D8", "H7")
  )
  expect_equal(sk_solve_dd(b, "grand", declarer = 1, leader = 1), 55L)
  expect_equal(sk_solve_dd(b, "clubs", declarer = 1, leader = 1), 55L)

  d <- list(
    c("D7", "SJ", "HJ", "DQ", "DK", "D10"),
    c("CK", "SA", "S9", "DA", "H10", "S7"),
    c("CJ", "SK", "H7", "C7", "SQ", "H8")
  )
  expect_equal(sk_solve_dd(d, "grand", declarer = 1, leader = 1), 28L)
  expect_equal(sk_solve_dd(d, "clubs", declarer = 1, leader = 1), 6L)
})

test_that("solver: seating the same three hands elsewhere changes nothing", {
  # Skat is symmetric under rotating the table. The transposition table keys on
  # the per-seat masks and the leader, so a rotation is a genuinely different
  # set of keys reaching the same game -- and must reach the same value.
  h1 <- c("CJ", "HA", "H7", "S8")
  h2 <- c("SJ", "H10", "H8", "SA")
  h3 <- c("HJ", "HK", "H9", "S9")
  base <- sk_solve_dd(list(h1, h2, h3), "hearts", declarer = 1, leader = 1)
  # Everyone moves one seat round the table; the declarer moves with them.
  expect_equal(
    sk_solve_dd(list(h3, h1, h2), "hearts", declarer = 2, leader = 2),
    base
  )
  expect_equal(
    sk_solve_dd(list(h2, h3, h1), "hearts", declarer = 3, leader = 3),
    base
  )
})

test_that("solver: agrees with a plain minimax over the R rules engine", {
  # An independent oracle: unpruned, unmemoised minimax driven by the package's
  # own R-level rules (sk_legal_moves(), sk_trick_winner(), sk_points()), which
  # share no code with the C++ core. If pruning, ordering or the transposition
  # table ever changed a value, this would catch it.
  minimax <- function(hands, game_type, declarer, leader, trick = character(0),
                      seats = integer(0)) {
    if (all(lengths(hands) == 0L) && length(trick) == 0L) {
      return(0L)
    }
    led <- if (length(trick) > 0L) trick[1] else NULL
    moves <- as.character(sk_legal_moves(hands[[leader]], led, game_type))
    vals <- vapply(moves, function(card) {
      nh <- hands
      nh[[leader]] <- setdiff(nh[[leader]], card)
      nt <- c(trick, card)
      ns <- c(seats, leader)
      if (length(nt) == 3L) {
        winner <- ns[[sk_trick_winner(nt, game_type)]]
        gain <- if (winner == declarer) sk_count_points(nt) else 0L
        gain + minimax(nh, game_type, declarer, winner)
      } else {
        minimax(nh, game_type, declarer, leader %% 3L + 1L, nt, ns)
      }
    }, integer(1))
    if (leader == declarer) max(vals) else min(vals)
  }

  cases <- list(
    list(
      hands = list(c("CJ", "HA", "S7"), c("HJ", "H10", "SA"),
                   c("DJ", "HK", "S10")),
      game_type = "hearts", leader = 1
    ),
    list(
      hands = list(c("CA", "D10", "SK"), c("C10", "DA", "S9"),
                   c("CK", "DK", "SA")),
      game_type = "grand", leader = 2
    ),
    list(
      hands = list(c("H7", "S8", "DQ"), c("H9", "SA", "DK"),
                   c("HJ", "S10", "D7")),
      game_type = "null", leader = 3
    )
  )
  for (cs in cases) {
    expect_equal(
      sk_solve_dd(cs$hands, cs$game_type, declarer = 1, leader = cs$leader),
      minimax(cs$hands, cs$game_type, 1L, cs$leader),
      info = cs$game_type
    )
  }
})

test_that("solver: max_tricks refuses a position that is too deep", {
  deal <- sk_deal(seed = 1)
  hands <- lapply(deal$hands, as.character)
  expect_error(sk_solve_dd(hands, "grand", declarer = 1), "too deep")
  expect_error(
    sk_solve_dd(hands, "grand", declarer = 1, max_tricks = 0),
    "positive whole"
  )

  # Shrinking the position to the guard is the escape route the message
  # suggests, and it works.
  slice <- lapply(hands, function(h) h[7:10])
  expect_type(sk_solve_dd(slice, "grand", declarer = 1), "integer")

  # Raising the guard is the other route. It gates the position and nothing
  # else: the same position solved under a higher guard gives the same answer.
  five <- lapply(hands, function(h) h[6:10])
  expect_error(
    sk_solve_dd(five, "grand", declarer = 1, max_tricks = 4),
    "too deep"
  )
  expect_equal(
    sk_solve_dd(five, "grand", declarer = 1, max_tricks = 5),
    sk_solve_dd(five, "grand", declarer = 1)
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
