test_that("full deck has 32 unique cards summing to 120 points", {
  deck <- sk_full_deck()
  expect_s3_class(deck, "sk_card")
  expect_length(deck, 32L)
  expect_length(unique(as.character(deck)), 32L)
  expect_equal(sum(sk_points(deck)), 120L)
})

test_that("card points are correct", {
  expect_equal(sk_points("CA"), 11L)
  expect_equal(sk_points("D10"), 10L)
  expect_equal(sk_points("HK"), 4L)
  expect_equal(sk_points("SQ"), 3L)
  expect_equal(sk_points("CJ"), 2L)
  expect_equal(sk_points("H7"), 0L)
})

test_that("every suit holds 30 of the 120 card points", {
  deck <- as.character(sk_full_deck())
  per_suit <- vapply(sk_suits, function(s) {
    sum(sk_points(deck[sk_suit_of(deck) == s]))
  }, integer(1))
  expect_true(all(per_suit == 30L))
})

test_that("sk_card validates inputs", {
  expect_error(sk_card("X", "A"))
  expect_error(sk_card("C", "1"))
  expect_s3_class(sk_card("C", "A"), "sk_card")
  expect_equal(as.character(sk_card("D", "10")), "D10")
})

test_that("suit and rank extraction handle the ten", {
  expect_equal(sk_suit_of("D10"), "D")
  expect_equal(sk_rank_of("D10"), "10")
  expect_equal(sk_rank_of("CA"), "A")
  expect_equal(sk_suit_of(c("CA", "D10")), c("C", "D"))
  expect_equal(sk_rank_of(c("CA", "D10")), c("A", "10"))
})

test_that("card codes are validated", {
  expect_error(sk_points("ZZ"), "valid Skat card")
  expect_error(sk_points(c("CA", NA)), "NA")
  expect_error(sk_points(1:3), "character vector")
  expect_equal(sk_points(character(0)), integer(0))
})

test_that("subsetting a hand keeps it an sk_card", {
  deck <- sk_full_deck()
  expect_s3_class(deck[1:4], "sk_card")
  expect_length(deck[1:4], 4L)
  expect_s3_class(deck[0], "sk_card")
})

test_that("cards format with their suit symbol", {
  expect_equal(format(sk_card("C", "A")), "\u2663A")
  expect_equal(format(sk_card("D", "10")), paste0("\u2666", "10"))
  expect_equal(format(sk_card("S", "J")), "\u2660J")
  expect_equal(format(sk_card("H", "K")), "\u2665K")
  expect_length(format(sk_full_deck()), 32L)
  expect_equal(format(sk_full_deck()[0]), character(0))
})

test_that("printing a hand returns it invisibly", {
  card <- sk_card("H", "K")
  expect_message(print(card), "Skat card")
  expect_invisible(suppressMessages(print(card)))
  expect_equal(suppressMessages(withVisible(print(card)))$value, card)
  expect_message(print(sk_full_deck()[0]), "no cards")
})
