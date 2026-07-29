# Internal: the four jacks in bidding order (highest first).
.sk_jacks <- c("CJ", "SJ", "HJ", "DJ")

#' Game types
#'
#' The valid Skat game types recognised throughout the package.
#'
#' @details
#' * Suit games: `"diamonds"`, `"hearts"`, `"spades"`, `"clubs"` (the named suit
#'   plus all four jacks are trumps).
#' * `"grand"`: only the four jacks are trumps.
#' * `"null"`: no trumps; ranks run 7-8-9-10-J-Q-K-A low to high.
#'
#' @return A character vector of the six valid game-type strings.
#' @export
#' @family game-type functions
#' @seealso [sk_card_order()] for the ordering each type implies.
#' @examples
#' sk_game_types()
sk_game_types <- function() {
  c("diamonds", "hearts", "spades", "clubs", "grand", "null")
}

# Map a suit-game string to its trump suit code.
.sk_trump_suit <- function(game_type) {
  switch(game_type,
    diamonds = "D",
    hearts = "H",
    spades = "S",
    clubs = "C",
    NA_character_
  )
}

#' Trick-taking order for a game type
#'
#' Returns every card in strict ascending trick-taking strength for the given
#' game type. The last element is the strongest card.
#'
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#'
#' @return A character vector of all 32 card codes ordered from weakest to
#'   strongest for the given game type.
#' @export
#' @family game-type functions
#' @seealso [sk_strength()] to look a card up in this order.
#' @examples
#' # The jack of clubs is the strongest card of every suit and grand game.
#' tail(sk_card_order("grand"), 4)
#' tail(sk_card_order("hearts"), 4)
#' # Null games have no trumps at all.
#' head(sk_card_order("null"), 8)
sk_card_order <- function(game_type, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)

  if (identical(game_type, "null")) {
    null_ranks <- c("7", "8", "9", "10", "J", "Q", "K", "A")
    ord <- character(0)
    for (s in sk_suits) ord <- c(ord, paste0(s, null_ranks))
    return(ord)
  }

  # Non-trump ranks, weakest to strongest, within a plain suit.
  suit_ranks <- c("7", "8", "9", "Q", "K", "10", "A")

  trump <- .sk_trump_suit(game_type)
  non_trump_suits <- setdiff(sk_suits, trump)
  if (is.na(trump)) non_trump_suits <- sk_suits  # grand: no suit trump

  ord <- character(0)
  for (s in non_trump_suits) ord <- c(ord, paste0(s, suit_ranks))

  # Trump block (strongest), weakest to strongest:
  # trump-suit pip cards (if any), then the four jacks D<H<S<C.
  trump_block <- character(0)
  if (!is.na(trump)) {
    trump_block <- paste0(trump, suit_ranks)
  }
  trump_block <- c(trump_block, rev(.sk_jacks))  # DJ,HJ,SJ,CJ ascending
  c(ord, trump_block)
}

#' Numeric strength of cards under a game type
#'
#' Positions each card in the trick-taking order returned by [sk_card_order()],
#' so strengths can be compared directly: higher beats lower.
#'
#' @param x An `sk_card` object or character vector of card codes.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#' @return An integer vector of strengths in `1:32` (higher beats lower), the
#'   same length as `x`.
#' @export
#' @family game-type functions
#' @seealso [sk_card_order()] for the underlying order.
#' @examples
#' sk_strength(c("CJ", "DA", "H7"), "grand")
sk_strength <- function(x, game_type, call = rlang::caller_env()) {
  codes <- .sk_check_cards(x, call = call)
  match(codes, sk_card_order(game_type, call = call))
}

#' Test whether a card is a trump
#'
#' @param x An `sk_card` object or character vector of card codes.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#' @return A logical vector, the same length as `x`. In `"null"` games this is
#'   always `FALSE`, because null games have no trumps.
#' @export
#' @family game-type functions
#' @seealso [sk_effective_suit()], which folds this into the follow-suit rule.
#' @examples
#' sk_is_trump(c("CJ", "DA", "HK"), "hearts")
#' sk_is_trump(c("CJ", "DA", "HK"), "null")
sk_is_trump <- function(x, game_type, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  codes <- .sk_check_cards(x, call = call)
  if (identical(game_type, "null")) {
    return(rep(FALSE, length(codes)))
  }
  trump <- .sk_trump_suit(game_type)
  is_trump_suit <- if (is.na(trump)) {
    rep(FALSE, length(codes))
  } else {
    sk_suit_of(codes) == trump
  }
  (codes %in% .sk_jacks) | is_trump_suit
}

#' The effective suit a card follows
#'
#' In suit and grand games every jack counts as a trump, not as its printed
#' suit, so leading a jack forces trumps rather than that suit. This function
#' returns the suit a card must be followed under, using the sentinel `"T"` for
#' trump.
#'
#' @param x An `sk_card` object or character vector of card codes.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#' @return A character vector the same length as `x`: one of the suit codes
#'   (`"C"`, `"S"`, `"H"`, `"D"`), or `"T"` for trump.
#' @export
#' @family game-type functions
#' @seealso [sk_legal_moves()], which applies this rule.
#' @examples
#' # In a hearts game the jack of clubs is a trump, not a club.
#' sk_effective_suit(c("CJ", "HA", "D10"), "hearts")
#' # In a null game it is simply a club.
#' sk_effective_suit(c("CJ", "HA", "D10"), "null")
sk_effective_suit <- function(x, game_type, call = rlang::caller_env()) {
  codes <- as.character(x)
  trump <- sk_is_trump(codes, game_type, call = call)
  out <- sk_suit_of(codes)
  out[trump] <- "T"
  out
}
