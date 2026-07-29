#' Legal cards to play
#'
#' Given a player's hand, the game type, and the card led (if any), returns the
#' subset of the hand that may legally be played. Skat requires following the
#' led *effective* suit if able; otherwise any card is legal. In suit and grand
#' games every jack counts as a trump, so leading a jack demands a trump, and a
#' hand holding only off-suit jacks is not void in trumps.
#'
#' @param hand An `sk_card` object or character vector: the player's remaining
#'   cards.
#' @param led A single card code (or `sk_card`) that was led, or `NULL` if this
#'   player leads the trick.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#'
#' @return An `sk_card` object containing the legal subset of `hand`. Always an
#'   `sk_card`, including when the hand is empty.
#' @export
#' @family play functions
#' @seealso [sk_effective_suit()] for the suit a card must be followed under.
#' @examples
#' hand <- c("HA", "HK", "CJ", "DA")
#' # Holding hearts, the player must follow hearts.
#' sk_legal_moves(hand, led = "H7", game_type = "spades")
#' # Leading, anything goes.
#' sk_legal_moves(hand, led = NULL, game_type = "spades")
#' # Void in the led suit: anything goes again.
#' sk_legal_moves(c("CJ", "DA"), led = "H7", game_type = "spades")
sk_legal_moves <- function(hand, led, game_type, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  codes <- .sk_check_cards(hand, call = call)
  if (is.null(led) || length(led) == 0L) {
    return(new_sk_card(codes))
  }
  led <- .sk_check_cards(led, call = call)
  led_suit <- sk_effective_suit(led[1], game_type, call = call)
  hand_suit <- sk_effective_suit(codes, game_type, call = call)
  can_follow <- codes[hand_suit == led_suit]
  if (length(can_follow) > 0L) {
    new_sk_card(can_follow)
  } else {
    new_sk_card(codes)
  }
}

#' Determine the winner of a completed trick
#'
#' A trump beats any non-trump; among cards of the same effective suit the
#' stronger one wins; a card that neither follows the led suit nor trumps cannot
#' win at all.
#'
#' @param cards A length-3 `sk_card` object or character vector: the cards played
#'   in play order (first element led).
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#'
#' @return An integer in `1:3`: the position within `cards` that won the trick.
#' @export
#' @family play functions
#' @seealso [sk_strength()] for the ordering this uses.
#' @examples
#' sk_trick_winner(c("H7", "HK", "HA"), "spades")
#' sk_trick_winner(c("H7", "SJ", "HA"), "spades")  # a jack trumps
#' sk_trick_winner(c("H10", "HJ", "H9"), "null")   # no trumps, jack over ten
sk_trick_winner <- function(cards, game_type, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  codes <- .sk_check_cards(cards, call = call)
  if (length(codes) != 3L) {
    cli::cli_abort(
      c(
        "{.arg cards} must contain exactly 3 cards.",
        "x" = "Got {length(codes)}."
      ),
      call = call
    )
  }
  led_suit <- sk_effective_suit(codes[1], game_type, call = call)
  eff <- sk_effective_suit(codes, game_type, call = call)
  strength <- sk_strength(codes, game_type, call = call)

  # A card can win only if it is a trump or follows the led suit; and once any
  # trump is on the table, only trumps are in the running.
  eligible <- if (any(eff == "T")) eff == "T" else eff == led_suit
  which.max(ifelse(eligible, strength, -1L))
}

#' Total card points in a set of cards
#'
#' @param cards An `sk_card` object or character vector.
#' @param call The calling environment, used for error reporting.
#' @return A single integer: the sum of the card points. Zero for no cards.
#' @export
#' @family play functions
#' @seealso [sk_points()] for the per-card values.
#' @examples
#' sk_count_points(c("CA", "D10", "HK"))
#' sk_count_points(sk_full_deck())
sk_count_points <- function(cards, call = rlang::caller_env()) {
  sum(sk_points(cards, call = call))
}
