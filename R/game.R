#' Play out a full Skat game
#'
#' Plays all ten tricks of a Skat game given the three players' hands, the
#' declared game type, and which player is declarer. The two non-declarers form
#' the defending team. Bidding is assumed already resolved; this simulates the
#' card play and scores the result.
#'
#' @param hands A length-3 list of `sk_card` vectors (ten cards each), as from
#'   [sk_deal()].
#' @param skat An `sk_card` vector of length 2 (the skat). Its points are
#'   credited to the declarer for non-hand games.
#' @param declarer Integer in `1:3`: the declaring player.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param players A length-3 list of `sk_player` objects, one per seat. Defaults
#'   to heuristic players for all seats.
#' @param game_value The announced game value. If `NULL` (default) it is computed
#'   from the declarer's hand plus skat.
#' @param hand_game Logical; whether the skat was left untouched. Defaults to
#'   `FALSE`.
#' @param call The calling environment, used for error reporting.
#'
#' @return An object of class `sk_game`: a list with elements
#'   * `result`: an `sk_result` object from [sk_score_game()],
#'   * `tricks`: a length-10 list, each element a list of `cards`, `leader`,
#'     `winner`, and `points`,
#'   * `declarer`: the declaring seat,
#'   * `game_type`: the game type played,
#'   * `declarer_points`: the integer card points credited to the declarer,
#'     trick points plus skat points for a non-hand game -- the same total the
#'     result was scored on,
#'   * `tricks_won`: the integer number of tricks the declarer took.
#' @export
#' @family game functions
#' @seealso [sk_simulate()] to repeat this over many deals, and [sk_solve_dd()]
#'   for exact double-dummy analysis of an endgame.
#' @examples
#' d <- sk_deal(seed = 42)
#' g <- sk_play_game(d$hands, d$skat, declarer = 1, game_type = "grand")
#' g$result$won
#' g$declarer_points
sk_play_game <- function(hands, skat, declarer, game_type,
                         players = NULL, game_value = NULL,
                         hand_game = FALSE, call = rlang::caller_env()) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  .sk_check_flag(hand_game, call = call)
  if (!is.list(hands) || length(hands) != 3L) {
    cli::cli_abort(
      c(
        "{.arg hands} must be a length-3 list, one element per seat.",
        "x" = "Got a length-{length(hands)} {.cls {class(hands)[[1]]}}."
      ),
      call = call
    )
  }
  declarer <- .sk_check_seat(declarer, call = call)
  skat <- .sk_check_cards(skat, call = call)

  hands <- lapply(seq_along(hands), function(i) {
    .sk_check_cards(hands[[i]], arg = paste0("hands[[", i, "]]"), call = call)
  })
  n_cards <- vapply(hands, length, integer(1))
  if (!all(n_cards == 10L)) {
    cli::cli_abort(
      c(
        "Every seat must hold ten cards at the start of play.",
        "x" = "Got sizes {.val {n_cards}}."
      ),
      call = call
    )
  }

  players <- players %||% rep(list(sk_player("heuristic")), 3)
  if (!is.list(players) || length(players) != 3L ||
      !all(vapply(players, inherits, logical(1), "sk_player"))) {
    cli::cli_abort(
      c(
        "{.arg players} must be a length-3 list of {.cls sk_player} objects.",
        "i" = "Build one with {.fn sk_player}, e.g. \\
               {.code rep(list(sk_player(\"heuristic\")), 3)}."
      ),
      call = call
    )
  }

  # Compute the game value up front, from the declarer's original cards plus
  # skat, before any cards are played.
  if (is.null(game_value)) {
    game_value <- if (identical(game_type, "null")) {
      sk_game_value(character(0), "null", hand_game = hand_game, call = call)
    } else {
      sk_game_value(c(hands[[declarer]], skat), game_type,
                    hand_game = hand_game, call = call)
    }
  }

  leader <- 1L  # forehand leads the first trick
  tricks <- vector("list", 10L)
  declarer_trick_points <- 0L
  declarer_tricks_won <- 0L

  for (t in seq_len(10L)) {
    trick_cards <- character(3)
    order_seats <- ((leader - 1L + 0:2) %% 3L) + 1L
    for (i in seq_along(order_seats)) {
      seat <- order_seats[i]
      led <- if (i == 1L) NULL else trick_cards[1]
      played <- if (i == 1L) character(0) else trick_cards[seq_len(i - 1L)]
      choice <- sk_choose(players[[seat]], hands[[seat]], led, game_type,
                          trick = played, call = call)
      trick_cards[i] <- choice
      hands[[seat]] <- setdiff(hands[[seat]], choice)
    }
    win_pos <- sk_trick_winner(trick_cards, game_type, call = call)
    winner_seat <- order_seats[win_pos]
    trick_pts <- sk_count_points(trick_cards)
    if (winner_seat == declarer) {
      declarer_trick_points <- declarer_trick_points + trick_pts
      declarer_tricks_won <- declarer_tricks_won + 1L
    }
    tricks[[t]] <- list(cards = trick_cards, leader = leader,
                        winner = winner_seat, points = trick_pts)
    leader <- winner_seat
  }

  skat_pts <- if (hand_game) 0L else sk_count_points(skat)
  total_declarer_pts <- declarer_trick_points + skat_pts

  result <- sk_score_game(
    total_declarer_pts, game_type, game_value,
    declarer_won_all = declarer_tricks_won == 10L,
    declarer_lost_all = declarer_tricks_won == 0L,
    call = call
  )

  structure(
    list(result = result, tricks = tricks, declarer = declarer,
         game_type = game_type,
         declarer_points = as.integer(total_declarer_pts),
         tricks_won = as.integer(declarer_tricks_won)),
    class = "sk_game"
  )
}

#' @export
print.sk_game <- function(x, ...) {
  cli::cli_text("{.cls sk_game}: {x$game_type}, declarer P{x$declarer}")
  cli::cli_text(
    "Declarer took {x$tricks_won} trick{?s} for {x$declarer_points} card \\
     point{?s}."
  )
  print(x$result)
  invisible(x)
}
