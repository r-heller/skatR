#' Score a completed Skat game
#'
#' Determines whether the declarer won and by how much, given the declarer's
#' card points, whether they took every trick, the complete scoring value, and
#' the game type.
#'
#' The declarer needs 61 of the 120 card points to win a suit or grand game.
#' Reaching 90 (or holding the defence to 30) is schneider; taking every trick
#' is schwarz. Null games invert the goal: the declarer wins only by taking no
#' trick at all, and neither schneider nor schwarz applies. A lost game costs
#' twice the game value.
#'
#' @param declarer_points Card points (0-120) the declarer collected in tricks,
#'   including the skat, even in a hand game.
#' @param game_type A single game-type string, one of [sk_game_types()].
#' @param game_value The complete value including achieved/announced levels
#'   (see [sk_game_value()]). It is not a bid; overbidding is resolved externally.
#' @param schneider_announced,schwarz_announced Logical; contract requirements.
#'   Schwarz announced implies schneider announced. Defaults to `FALSE`.
#' @param ouvert Logical; suit/grand ouvert requires every trick. Null ouvert
#'   retains the no-trick objective. Defaults to `FALSE`.
#' @param declarer_won_all Logical; `TRUE` if the declarer took every trick
#'   (relevant for schwarz). Defaults to `FALSE`.
#' @param declarer_lost_all Logical; `TRUE` if the declarer took no trick at all.
#'   Defaults to `FALSE`. For null games this determines the outcome directly.
#' @param call The calling environment, used for error reporting.
#'
#' @return A list of class `sk_result` with elements:
#'   * `won`: logical, did the declarer win;
#'   * `schneider`: logical, was schneider reached (declarer to 90 or defence
#'     held to 30);
#'   * `schwarz`: logical, was schwarz reached (one side took every trick);
#'   * `game_value`: integer, the complete scoring value;
#'   * `score`: integer, points credited to the declarer -- the game value if
#'     won, twice the negated game value if lost.
#' @export
#' @family scoring functions
#' @seealso [sk_game_value()] computes the scoring value; [sk_play_game()]
#'   calls this on a played-out deal.
#' @examples
#' sk_score_game(72, "hearts", game_value = 20)
#' sk_score_game(59, "hearts", game_value = 20)  # lost, did not reach 61
#' sk_score_game(0, "null", game_value = 23, declarer_lost_all = TRUE)
sk_score_game <- function(declarer_points, game_type, game_value,
                          declarer_won_all = FALSE, declarer_lost_all = FALSE,
                          call = rlang::caller_env(), schneider_announced = FALSE,
                          schwarz_announced = FALSE, ouvert = FALSE) {
  .sk_check_choice(game_type, sk_game_types(), call = call)
  declarer_points <- .sk_check_card_points(declarer_points, call = call)
  game_value <- .sk_check_count(game_value, call = call)
  .sk_check_flag(declarer_won_all, call = call)
  .sk_check_flag(declarer_lost_all, call = call)
  .sk_check_flag(schneider_announced, call = call)
  .sk_check_flag(schwarz_announced, call = call)
  .sk_check_flag(ouvert, call = call)
  if (game_value > .Machine$integer.max / 2)
    cli::cli_abort("game_value is too large to represent a doubled loss.", call=call)
  if (declarer_won_all && declarer_lost_all) {
    cli::cli_abort(
      c(
        "The declarer cannot both take every trick and take none.",
        "x" = "{.arg declarer_won_all} and {.arg declarer_lost_all} are both \\
               {.code TRUE}."
      ),
      call = call
    )
  }

  if (identical(game_type, "null")) {
    if (schneider_announced || schwarz_announced)
      cli::cli_abort("Null games have no schneider/schwarz announcements.", call=call)
    # The declarer wins a null game only by taking no trick at all.
    won <- declarer_lost_all
    return(new_sk_result(won, FALSE, FALSE, game_value,
                         .sk_result_score(won, game_value)))
  }

  schwarz_announced <- schwarz_announced || ouvert
  schneider_announced <- schneider_announced || schwarz_announced
  won <- declarer_points >= if (schneider_announced) 90L else 61L
  if (schwarz_announced) won <- won && declarer_won_all
  schneider <- declarer_points >= 90L || declarer_points <= 30L
  schwarz <- declarer_won_all || declarer_lost_all

  new_sk_result(won, schneider, schwarz, game_value,
                .sk_result_score(won, game_value))
}

# A won game scores its value; a lost game costs twice that.
.sk_result_score <- function(won, game_value) {
  if (won) as.integer(game_value) else -2L * as.integer(game_value)
}

new_sk_result <- function(won, schneider, schwarz, game_value, score) {
  structure(
    list(won = won, schneider = schneider, schwarz = schwarz,
         game_value = as.integer(game_value), score = as.integer(score)),
    class = "sk_result"
  )
}

#' @export
print.sk_result <- function(x, ...) {
  outcome <- if (x$won) "won" else "lost"
  schneider <- .sk_yesno(x$schneider)
  schwarz <- .sk_yesno(x$schwarz)
  cli::cli_text("{.cls sk_result}: declarer {.strong {outcome}}")
  cli::cli_bullets(c(
    "*" = "Game value: {x$game_value}",
    "*" = "Score: {x$score}",
    "*" = "Schneider: {schneider}",
    "*" = "Schwarz: {schwarz}"
  ))
  invisible(x)
}

# Logical flags read better as words than as TRUE/FALSE in printed output.
.sk_yesno <- function(x) if (isTRUE(x)) "yes" else "no"
