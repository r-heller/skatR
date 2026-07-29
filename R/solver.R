#' Solve a double-dummy Skat endgame
#'
#' Computes, by exhaustive alpha-beta search, the maximum card points the
#' declarer can guarantee from a fully specified position where every hand is
#' known (a "double-dummy" analysis). This is exact perfect-information play: it
#' assumes both defenders cooperate optimally against the declarer.
#'
#' The returned total counts every card point in the tricks the declarer wins,
#' including the points on the declarer's own cards. It does not include skat
#' points, which are added afterwards by [sk_score_game()].
#'
#' The search is exponential in the number of remaining cards, tempered by
#' alpha-beta pruning, move ordering and a transposition table. It is practical
#' for endgames; a full ten-trick deal can still take a very long time, which is
#' what `max_tricks` guards against. The heavy lifting runs in compiled C++, and
#' the search polls for user interrupts so a long solve can be cancelled.
#'
#' @param hands A length-3 list of `sk_card` vectors (or character vectors of
#'   card codes): the remaining cards of seats 1, 2, and 3. Every seat must hold
#'   the same number of cards, and no card may be held twice.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param declarer Integer in `1:3`: the declaring seat.
#' @param leader Integer in `1:3`: the seat to lead the next trick. Defaults to
#'   `declarer`.
#' @param max_tricks Maximum number of cards per hand the solver will accept,
#'   as a guard against accidentally launching an intractable search. Deeper
#'   positions raise an error rather than running. At the default of `8` a solve
#'   stays well under a second on ordinary hardware; each further trick
#'   multiplies the work several times over, and a whole ten-trick deal
#'   (`max_tricks = 10`) can take tens of seconds.
#' @param call The calling environment, used for error reporting.
#'
#' @return A single integer: the maximum card points (0-120) the declarer can
#'   guarantee against best defence.
#' @export
#' @family solver functions
#' @seealso [sk_play_game()] to play a deal out with heuristic players, and
#'   [sk_score_game()] to turn a point total into a scored result.
#' @examples
#' # A two-card-each endgame in a grand game.
#' hands <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
#' sk_solve_dd(hands, game_type = "grand", declarer = 1)
#'
#' # The declarer holds both top jacks and sweeps the table: 46 points, which
#' # includes the two card points on the declarer's own jacks.
#' sweep <- list(c("CJ", "SJ"), c("HA", "DA"), c("H10", "D10"))
#' sk_solve_dd(sweep, game_type = "grand", declarer = 1)
#'
#' # A whole ten-trick deal is refused by default; raise the guard to solve it.
#' \donttest{
#' deal <- sk_deal(seed = 1)
#' sk_solve_dd(deal$hands, game_type = "grand", declarer = 1, max_tricks = 10)
#' }
sk_solve_dd <- function(hands, game_type, declarer, leader = declarer,
                        max_tricks = 8, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  declarer <- .sk_check_seat(declarer, call = call)
  leader <- .sk_check_seat(leader, call = call)
  max_tricks <- .sk_check_count(max_tricks, call = call)
  if (!is.list(hands) || length(hands) != 3L) {
    cli::cli_abort(
      c(
        "{.arg hands} must be a length-3 list, one element per seat.",
        "x" = "Got a length-{length(hands)} {.cls {class(hands)[[1]]}}."
      ),
      call = call
    )
  }

  hands <- lapply(seq_along(hands), function(i) {
    .sk_check_cards(hands[[i]], arg = paste0("hands[[", i, "]]"), call = call)
  })

  sizes <- vapply(hands, length, integer(1))
  if (length(unique(sizes)) != 1L) {
    cli::cli_abort(
      c(
        "Each seat must hold the same number of cards.",
        "x" = "Got sizes {.val {sizes}}."
      ),
      call = call
    )
  }

  all_cards <- unlist(hands, use.names = FALSE)
  dupes <- unique(all_cards[duplicated(all_cards)])
  if (length(dupes) > 0L) {
    cli::cli_abort(
      c(
        "Each card may be held by at most one seat.",
        "x" = "Duplicated card{?s}: {.val {dupes}}."
      ),
      call = call
    )
  }

  # The position is well formed; is it small enough to be worth starting?
  n_tricks <- sizes[[1]]
  if (n_tricks > max_tricks) {
    cli::cli_abort(
      c(
        "This position is too deep for an exact solve.",
        "x" = "Each seat holds {n_tricks} cards, more than \\
               {.arg max_tricks} = {max_tricks}.",
        "i" = "Solve an endgame slice instead: keep the last {max_tricks} \\
               card{?s} of each hand. Raise {.arg max_tricks} only if you are \\
               prepared to wait; every extra trick costs roughly another order \\
               of magnitude."
      ),
      call = call
    )
  }

  deck <- as.character(sk_full_deck())

  # The C++ core indexes every lookup table by the 0-based card id, so each
  # table must be in deck order: its i-th element describes deck[i].
  ord <- sk_card_order(game_type, call = call)
  strength <- match(deck, ord)
  points <- sk_points(deck)

  suit_id <- c(D = 0L, H = 1L, S = 2L, C = 3L, "T" = 4L)
  eff_id <- unname(suit_id[sk_effective_suit(deck, game_type, call = call)])

  # 0-based card ids per seat.
  hand_ids <- lapply(hands, function(h) match(h, deck) - 1L)

  sk_solve_dd_cpp(
    hand0 = as.integer(hand_ids[[1]]),
    hand1 = as.integer(hand_ids[[2]]),
    hand2 = as.integer(hand_ids[[3]]),
    leader = leader - 1L,
    declarer = declarer - 1L,
    points = as.integer(points),
    strength = as.integer(strength),
    eff_suit = as.integer(eff_id)
  )
}
