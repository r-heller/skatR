#' Determinized Monte Carlo move selection
#'
#' Chooses a card by sampling many random completions of the hidden cards
#' ("determinizations"): for each legal move the rest of the trick is filled in
#' at random from the unseen cards, and the move with the best average card-point
#' outcome is returned. Points the move captures count in its favour; points it
#' hands to the opponents count half against it, so a cheap loss is preferred to
#' an expensive one.
#'
#' This is a light-weight imperfect-information heuristic, not a full
#' information-set MCTS. It plays reasonably and costs little; for exact play use
#' [sk_solve_dd()] on an endgame.
#'
#' @param hand The deciding player's hand (`sk_card` or character vector).
#' @param led The led card, or `NULL` if this player leads.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param trick Cards already played to the current trick, in play order and
#'   including the led card. Defaults to `character(0)`.
#' @param unseen Optional character vector of cards not visible to the player
#'   (opponents' cards plus skat). If `NULL`, inferred as the full deck minus the
#'   player's hand and the visible trick.
#' @param n_sims Number of determinized rollouts per legal move. Defaults to 200.
#' @param call The calling environment, used for error reporting.
#'
#' @return A single card code: a character scalar drawn from the legal moves.
#' @export
#' @family player functions
#' @seealso [sk_player()] wraps this as a strategy; [sk_solve_dd()] plays
#'   exactly when every hand is known.
#' @examples
#' set.seed(1)
#' sk_mcts_move(c("HA", "H7", "CJ", "DA"), led = "HK",
#'              game_type = "spades", n_sims = 50)
sk_mcts_move <- function(hand, led, game_type, trick = character(0),
                         unseen = NULL, n_sims = 200,
                         call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  n_sims <- .sk_check_count(n_sims, call = call)
  hand <- .sk_check_cards(hand, call = call)
  trick <- .sk_check_cards(trick, call = call)

  legal <- as.character(sk_legal_moves(hand, led, game_type, call = call))
  if (length(legal) == 0L) {
    cli::cli_abort(
      c("No legal moves available.", "x" = "{.arg hand} is empty."),
      call = call
    )
  }
  if (length(legal) == 1L) return(legal[1])

  so_far <- .sk_trick_so_far(trick, led)
  if (is.null(unseen)) {
    unseen <- setdiff(.sk_deck_codes, c(hand, so_far))
  } else {
    unseen <- .sk_check_cards(unseen, call = call)
  }

  # Seats still to play after us. A Skat trick holds three cards.
  n_to_complete <- max(0L, 2L - length(so_far))
  if (n_to_complete > length(unseen)) {
    cli::cli_abort(
      c(
        "Not enough unseen cards to complete the trick.",
        "x" = "Need {n_to_complete} but only {length(unseen)} {?is/are} unseen."
      ),
      call = call
    )
  }
  our_pos <- length(so_far) + 1L

  scores <- vapply(legal, function(cand) {
    total <- 0
    for (s in seq_len(n_sims)) {
      others <- if (n_to_complete > 0L) {
        unseen[sample.int(length(unseen), n_to_complete)]
      } else {
        character(0)
      }
      full_trick <- c(so_far, cand, others)
      win_pos <- sk_trick_winner(full_trick, game_type, call = call)
      pts <- sk_count_points(full_trick)
      total <- total + if (win_pos == our_pos) pts else -pts / 2
    }
    total / n_sims
  }, numeric(1), USE.NAMES = FALSE)

  legal[which.max(scores)]
}
