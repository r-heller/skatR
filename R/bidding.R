#' Base value of a game type
#'
#' The multiplier base used in Skat game-value computation: diamonds 9, hearts
#' 10, spades 11, clubs 12, grand 24. Null games use fixed values instead and
#' return `NA` here.
#'
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param call The calling environment, used for error reporting.
#' @return A single integer base value, or `NA_integer_` for `"null"`.
#' @export
#' @family bidding functions
#' @seealso [sk_game_value()], which multiplies this by the matador multiplier.
#' @examples
#' sk_base_value("clubs")
#' sk_base_value("grand")
#' sk_base_value("null")
sk_base_value <- function(game_type, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  vals <- c(diamonds = 9L, hearts = 10L, spades = 11L, clubs = 12L,
            grand = 24L, null = NA_integer_)
  unname(vals[game_type])
}

#' Count matadors (Spitzen)
#'
#' Counts the length of the unbroken run of top trumps a hand holds ("with") or
#' lacks ("without"), starting from the jack of clubs. The count is the number
#' of matadors; the multiplier game contributes this count plus one.
#'
#' @param hand An `sk_card` object or character vector: the declarer's cards. For
#'   an authentic count this should include the two skat cards the declarer
#'   picked up (12 cards); for a hand game use the 10 dealt cards.
#' @param game_type A single suit or grand game type (not `"null"`).
#' @param call The calling environment, used for error reporting.
#'
#' @return A list with elements `with` (logical; `TRUE` if the run starts with
#'   the jack of clubs) and `count` (integer number of matadors).
#' @export
#' @family bidding functions
#' @seealso [sk_game_value()] turns the count into a game value.
#' @examples
#' # With two top jacks:
#' sk_matadors(c("CJ", "SJ", "HA", "HK", "H9"), "hearts")
#' # Without the jack of clubs:
#' sk_matadors(c("HJ", "HA", "HK"), "hearts")
sk_matadors <- function(hand, game_type, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  if (identical(game_type, "null")) {
    cli::cli_abort(
      c(
        "{.arg game_type} must be a suit or grand game, not {.val null}.",
        "i" = "Null games have fixed values; see {.fn sk_game_value}."
      ),
      call = call
    )
  }
  codes <- .sk_check_cards(hand, call = call)

  # Ordered top trumps: four jacks, then trump-suit A,10,K,Q,9,8,7 (suit games).
  top <- .sk_jacks
  trump <- .sk_trump_suit(game_type)
  if (!is.na(trump)) {
    top <- c(top, paste0(trump, c("A", "10", "K", "Q", "9", "8", "7")))
  }

  have_top <- top[1] %in% codes
  # Count the leading run of matching presence/absence.
  present <- top %in% codes
  run <- 0L
  for (p in present) {
    if (p == have_top) run <- run + 1L else break
  }
  list(with = have_top, count = run)
}

#' Game value (Reizwert)
#'
#' Computes the value of a declared game: for suit and grand games, the base
#' value times the multiplier (matadors + 1, plus one for game, plus levels for
#' hand, schneider, schwarz, ouvert as announced). Null games use their fixed
#' values.
#'
#' @param hand An `sk_card` object or character vector: the declarer's cards used
#'   for matador counting.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param hand_game Logical; `TRUE` if played as a hand game (skat not picked
#'   up). Defaults to `FALSE`.
#' @param schneider Logical; announced schneider. Defaults to `FALSE`.
#' @param schwarz Logical; announced schwarz. Defaults to `FALSE`.
#' @param ouvert Logical; open (ouvert) game. Defaults to `FALSE`.
#' @param call The calling environment, used for error reporting.
#'
#' @return A single integer game value. Null games return one of the four fixed
#'   values 23, 35, 46, or 59.
#' @export
#' @family bidding functions
#' @seealso [sk_matadors()] for the multiplier and [sk_score_game()] for what a
#'   game value is worth once played.
#' @examples
#' sk_game_value(c("CJ", "SJ", "HA", "HK", "H10", "H9"), "hearts")
#' sk_game_value(character(0), "null")
#' sk_game_value(character(0), "null", hand_game = TRUE, ouvert = TRUE)
sk_game_value <- function(hand, game_type, hand_game = FALSE,
                          schneider = FALSE, schwarz = FALSE, ouvert = FALSE,
                          call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  .sk_check_flag(hand_game, call = call)
  .sk_check_flag(schneider, call = call)
  .sk_check_flag(schwarz, call = call)
  .sk_check_flag(ouvert, call = call)

  if (identical(game_type, "null")) {
    val <- if (ouvert && hand_game) {
      59L
    } else if (ouvert) {
      46L
    } else if (hand_game) {
      35L
    } else {
      23L
    }
    return(val)
  }

  base <- sk_base_value(game_type, call = call)
  mat <- sk_matadors(hand, game_type, call = call)

  mult <- mat$count + 1L        # with/without N -> game is N+1
  if (hand_game) mult <- mult + 1L
  if (schneider) mult <- mult + 1L
  if (schwarz) mult <- mult + 1L
  if (ouvert) mult <- mult + 1L

  as.integer(base * mult)
}
