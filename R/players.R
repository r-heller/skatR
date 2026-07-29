#' Create a Skat player
#'
#' Players are strategy objects that, given a legal set of moves and the visible
#' game context, choose a card to play. Three built-in strategies are provided.
#'
#' @param strategy One of `"random"`, `"heuristic"`, or `"mcts"`.
#'   * `"random"`: chooses uniformly among legal moves.
#'   * `"heuristic"`: greedy rules -- take the trick with the cheapest card that
#'     beats it when the trick is worth taking, otherwise shed the lowest-value
#'     card.
#'   * `"mcts"`: determinized Monte Carlo search (see [sk_mcts_move()]).
#' @param n_sims For `"mcts"`, the number of determinized playouts per decision.
#'   Ignored otherwise. Defaults to 200.
#' @param call The calling environment, used for error reporting.
#'
#' @return An object of class `sk_player`: a list with elements `strategy`
#'   (character) and `n_sims` (integer).
#' @export
#' @family player functions
#' @seealso [sk_choose()] to ask a player for a move.
#' @examples
#' sk_player("heuristic")
#' sk_player("mcts", n_sims = 500)
sk_player <- function(strategy = c("random", "heuristic", "mcts"),
                      n_sims = 200, call = rlang::caller_env()) {
  strategy <- match.arg(strategy)
  n_sims <- .sk_check_count(n_sims, call = call)
  structure(list(strategy = strategy, n_sims = n_sims), class = "sk_player")
}

#' @export
print.sk_player <- function(x, ...) {
  extra <- if (identical(x$strategy, "mcts")) {
    cli::format_inline(" ({x$n_sims} sims)")
  } else {
    ""
  }
  cli::cli_text("{.cls sk_player}: {x$strategy}{extra}")
  invisible(x)
}

#' Ask a player to choose a card
#'
#' Dispatches to the player's strategy and returns a single legal card.
#'
#' @param player An `sk_player` object.
#' @param hand The player's current hand (`sk_card` or character vector).
#' @param led The led card, or `NULL` if this player leads.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param trick Cards already played to the current trick, in play order and
#'   including the led card. Defaults to `character(0)`; when it is empty but
#'   `led` is supplied, `led` is taken as the whole trick so far.
#' @param call The calling environment, used for error reporting.
#'
#' @return A single card code: a character scalar drawn from
#'   `sk_legal_moves(hand, led, game_type)`.
#' @export
#' @family player functions
#' @seealso [sk_legal_moves()] for the set a choice is drawn from.
#' @examples
#' p <- sk_player("heuristic")
#' sk_choose(p, hand = c("HA", "H7", "CJ"), led = "HK", game_type = "spades")
#'
#' # Leading, the heuristic sheds its cheapest card.
#' sk_choose(p, hand = c("HA", "H7", "CJ"), led = NULL, game_type = "spades")
sk_choose <- function(player, hand, led, game_type, trick = character(0),
                      call = rlang::caller_env()) {
  .sk_check_class(player, "sk_player", call = call)
  .sk_check_choice(game_type, sk_game_types(), call = call)
  legal <- as.character(sk_legal_moves(hand, led, game_type, call = call))
  if (length(legal) == 0L) {
    cli::cli_abort(
      c(
        "No legal moves available.",
        "x" = "{.arg hand} is empty."
      ),
      call = call
    )
  }
  switch(player$strategy,
    random = legal[sample.int(length(legal), 1L)],
    heuristic = .sk_heuristic_move(legal, led, game_type, trick),
    mcts = sk_mcts_move(hand, led, game_type, trick,
                        n_sims = player$n_sims, call = call)
  )
}

# The cards played to the trick so far, in play order. `led` is a fallback for
# callers that pass only the led card.
.sk_trick_so_far <- function(trick, led) {
  trick <- as.character(trick)
  if (length(trick) > 0L) return(trick)
  if (is.null(led)) character(0) else as.character(led)
}

# Would each candidate be winning the trick if it were played next? Uses the
# same eligibility rules as sk_trick_winner().
.sk_would_win <- function(cands, so_far, game_type) {
  vapply(cands, function(cd) {
    codes <- c(so_far, cd)
    led_suit <- sk_effective_suit(codes[1], game_type)
    eff <- sk_effective_suit(codes, game_type)
    eligible <- if (any(eff == "T")) eff == "T" else eff == led_suit
    str <- sk_strength(codes, game_type)
    str[!eligible] <- -1L
    which.max(str) == length(codes)
  }, logical(1), USE.NAMES = FALSE)
}

# Greedy heuristic: when leading, shed the weakest, cheapest card. When
# following, take a trick that holds points with the cheapest card that wins it;
# otherwise discard the lowest-value card.
.sk_heuristic_move <- function(legal, led, game_type, trick) {
  pts <- sk_points(legal)
  str <- sk_strength(legal, game_type)
  so_far <- .sk_trick_so_far(trick, led)

  if (length(so_far) == 0L) {
    # Leading: play the lowest-strength card, breaking ties by fewest points.
    return(legal[order(str, pts)[1]])
  }

  can_win <- .sk_would_win(legal, so_far, game_type)
  if (any(can_win) && sk_count_points(so_far) >= 4L) {
    winners <- legal[can_win]
    # Cheapest winner: weakest card that still takes it, fewest points given up.
    ord <- order(sk_strength(winners, game_type), sk_points(winners))
    return(winners[ord[1]])
  }
  # Cannot or should not win: discard lowest points, then lowest strength.
  legal[order(pts, str)[1]]
}
