test_that("jack of clubs is the strongest card in suit and grand games", {
  for (gt in c("diamonds", "hearts", "spades", "clubs", "grand")) {
    ord <- sk_card_order(gt)
    expect_equal(ord[length(ord)], "CJ")
  }
})

test_that("every game type orders all 32 cards exactly once", {
  deck <- as.character(sk_full_deck())
  for (gt in sk_game_types()) {
    ord <- sk_card_order(gt)
    expect_length(ord, 32L)
    expect_setequal(ord, deck)
  }
})

test_that("all four jacks are trumps in suit and grand games", {
  jacks <- c("CJ", "SJ", "HJ", "DJ")
  expect_true(all(sk_is_trump(jacks, "hearts")))
  expect_true(all(sk_is_trump(jacks, "grand")))
})

test_that("jacks rank clubs over spades over hearts over diamonds", {
  jacks <- c("DJ", "HJ", "SJ", "CJ")
  for (gt in c("diamonds", "hearts", "spades", "clubs", "grand")) {
    expect_equal(order(sk_strength(jacks, gt)), 1:4)
  }
})

test_that("a suit game has eleven trumps, grand has four, null none", {
  deck <- as.character(sk_full_deck())
  expect_equal(sum(sk_is_trump(deck, "hearts")), 11L)
  expect_equal(sum(sk_is_trump(deck, "clubs")), 11L)
  expect_equal(sum(sk_is_trump(deck, "grand")), 4L)
  expect_equal(sum(sk_is_trump(deck, "null")), 0L)
})

test_that("null games have no trumps and ace-high ordering", {
  expect_false(any(sk_is_trump(c("CJ", "HA", "S10"), "null")))
  ord <- sk_card_order("null")
  # Within a suit, ace is strongest, seven weakest.
  h_ord <- ord[startsWith(ord, "H")]
  expect_equal(h_ord[length(h_ord)], "HA")
  expect_equal(h_ord[1], "H7")
})

test_that("the null ten sits naturally between the nine and the jack", {
  expect_true(sk_strength("H9", "null") < sk_strength("H10", "null"))
  expect_true(sk_strength("H10", "null") < sk_strength("HJ", "null"))
  expect_true(sk_strength("HJ", "null") < sk_strength("HQ", "null"))
})

test_that("effective suit routes jacks to trump", {
  expect_equal(sk_effective_suit("HJ", "spades"), "T")
  expect_equal(sk_effective_suit("SA", "spades"), "T")  # trump suit
  expect_equal(sk_effective_suit("HA", "spades"), "H")
})

test_that("effective suit leaves jacks in their printed suit for null", {
  expect_equal(sk_effective_suit(c("CJ", "HJ", "HA"), "null"),
               c("C", "H", "H"))
})

test_that("ten sits between king and ace in trick strength", {
  s_king <- sk_strength("HK", "grand")
  s_ten <- sk_strength("H10", "grand")
  s_ace <- sk_strength("HA", "grand")
  expect_true(s_king < s_ten)
  expect_true(s_ten < s_ace)
})

test_that("every trump outranks every non-trump", {
  deck <- as.character(sk_full_deck())
  is_t <- sk_is_trump(deck, "hearts")
  expect_true(min(sk_strength(deck[is_t], "hearts")) >
                max(sk_strength(deck[!is_t], "hearts")))
})

test_that("unknown game types are rejected", {
  expect_error(sk_card_order("bells"), "must be one of")
  expect_error(sk_is_trump("CA", "bells"), "must be one of")
  expect_error(sk_card_order(c("grand", "null")), "single")
})
