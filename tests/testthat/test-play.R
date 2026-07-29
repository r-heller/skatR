test_that("must follow led suit when able", {
  hand <- c("HA", "HK", "CJ", "DA")
  legal <- as.character(sk_legal_moves(hand, led = "H7", game_type = "spades"))
  expect_setequal(legal, c("HA", "HK"))
})

test_that("any card is legal when void in led suit", {
  hand <- c("CJ", "DA", "S9")
  legal <- as.character(sk_legal_moves(hand, led = "H7", game_type = "spades"))
  expect_setequal(legal, hand)
})

test_that("leading allows any card", {
  hand <- c("HA", "CJ", "DA")
  legal <- as.character(sk_legal_moves(hand, led = NULL, game_type = "grand"))
  expect_setequal(legal, hand)
})

test_that("legal moves are type stable", {
  hand <- c("HA", "HK", "CJ")
  expect_s3_class(sk_legal_moves(hand, "H7", "spades"), "sk_card")
  expect_s3_class(sk_legal_moves(hand, NULL, "spades"), "sk_card")
  empty <- sk_legal_moves(character(0), "H7", "spades")
  expect_s3_class(empty, "sk_card")
  expect_length(empty, 0L)
})

test_that("a led jack demands a trump, not its printed suit", {
  # Clubs game: the hand holds a club (trump) and a jack (trump), plus hearts.
  hand <- c("C9", "HJ", "HA", "H7")
  legal <- as.character(sk_legal_moves(hand, led = "SJ", game_type = "clubs"))
  expect_setequal(legal, c("C9", "HJ"))

  # Void in trumps: anything goes.
  hand2 <- c("HA", "H7", "DA")
  legal2 <- as.character(sk_legal_moves(hand2, led = "SJ", game_type = "clubs"))
  expect_setequal(legal2, hand2)
})

test_that("a led jack in a null game demands its printed suit", {
  hand <- c("CA", "C7", "HA")
  legal <- as.character(sk_legal_moves(hand, led = "CJ", game_type = "null"))
  expect_setequal(legal, c("CA", "C7"))
})

test_that("holding only a jack of the led suit still counts as following", {
  hand <- c("HJ", "DA", "S9")
  # Suit game: HJ is a trump, so the player is void in hearts.
  legal <- as.character(sk_legal_moves(hand, led = "HA", game_type = "spades"))
  expect_setequal(legal, hand)
  # Null game: HJ is a heart, so it must be played.
  legal_null <- as.character(sk_legal_moves(hand, led = "HA", "null"))
  expect_setequal(legal_null, "HJ")
})

test_that("trick winner respects trump and led suit", {
  # No trump: highest of led suit wins.
  expect_equal(sk_trick_winner(c("H7", "HK", "HA"), "spades"), 3L)
  # A jack (trump) beats the ace of the led suit.
  expect_equal(sk_trick_winner(c("HA", "SJ", "H10"), "spades"), 2L)
  # Off-suit discard cannot win.
  expect_equal(sk_trick_winner(c("HA", "D7", "H9"), "clubs"), 1L)
})

test_that("the higher trump wins when several are played", {
  expect_equal(sk_trick_winner(c("SJ", "CJ", "DJ"), "grand"), 2L)
  expect_equal(sk_trick_winner(c("H7", "HA", "HJ"), "hearts"), 3L)
})

test_that("null trick resolution has no trumps and a natural ten", {
  # Jack beats the ten in a null game, and clubs cannot win a heart trick.
  expect_equal(sk_trick_winner(c("H10", "HJ", "H9"), "null"), 2L)
  expect_equal(sk_trick_winner(c("H7", "CJ", "H8"), "null"), 3L)
  expect_equal(sk_trick_winner(c("HA", "H10", "HK"), "null"), 1L)
})

test_that("trick winner needs exactly three cards", {
  expect_error(sk_trick_winner(c("HA", "HK"), "grand"), "exactly 3")
  expect_error(sk_trick_winner(c("HA", "HK", "H9", "H8"), "grand"), "exactly 3")
})

test_that("point counting sums correctly", {
  expect_equal(sk_count_points(c("CA", "D10", "HK")), 25L)
  expect_equal(sk_count_points(c("H7", "S8", "D9")), 0L)
  expect_equal(sk_count_points(character(0)), 0L)
  expect_equal(sk_count_points(sk_full_deck()), 120L)
})
