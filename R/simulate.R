#' Simulate many Skat games
#'
#' Runs a Monte Carlo experiment: deals `n` random games, plays each out with
#' the supplied players and game type, and returns a tidy table of outcomes. Use
#' it to estimate win rates, average scores, and the distribution of declarer
#' card points for a given strategy configuration.
#'
#' @param n Number of games to simulate. Defaults to 100.
#' @param game_type A single game-type string, one of [sk_game_types()].
#'   Defaults to `"grand"`.
#' @param declarer Integer in `1:3`: the declaring seat. Defaults to 1.
#' @param players A length-3 list of `sk_player` objects. Defaults to heuristic
#'   players for all seats.
#' @param seed Optional whole-number seed for reproducibility. Defaults to
#'   `NULL`, which leaves the random state alone. When supplied, the previous
#'   random state is restored on exit.
#' @param verbose Logical; show a progress bar. Defaults to `TRUE`.
#' @param call The calling environment, used for error reporting.
#'
#' @return A [tibble::tibble()] with one row per simulated game and columns:
#'   `game` (integer index), `game_type` (character), `declarer` (integer),
#'   `declarer_points` (integer card points credited to the declarer, trick
#'   points plus skat), `won` (logical), `schneider` (logical), `schwarz`
#'   (logical), `game_value` (integer), and `score` (integer). Always a tibble
#'   with these nine columns and these types.
#' @export
#' @family simulation functions
#' @seealso [sk_plot_points()] and [sk_plot_winrate()] visualise the result.
#' @examples
#' sim <- sk_simulate(n = 20, game_type = "grand", seed = 1, verbose = FALSE)
#' mean(sim$won)
#' head(sim, 3)
sk_simulate <- function(n = 100, game_type = "grand", declarer = 1,
                        players = NULL, seed = NULL, verbose = TRUE,
                        call = rlang::caller_env()) {
  n <- .sk_check_count(n, call = call)
  .sk_check_choice(game_type, sk_game_types(), call = call)
  declarer <- .sk_check_seat(declarer, call = call)
  .sk_check_flag(verbose, call = call)
  players <- players %||% rep(list(sk_player("heuristic")), 3)

  if (!is.null(seed)) {
    seed <- .sk_check_whole(seed, call = call)
    old <- .sk_save_seed()
    on.exit(.sk_restore_seed(old), add = TRUE)
    set.seed(seed)
  }

  game_idx <- seq_len(n)
  dec_pts <- integer(n)
  won <- logical(n)
  schneider <- logical(n)
  schwarz <- logical(n)
  gval <- integer(n)
  score <- integer(n)

  if (verbose) {
    cli::cli_progress_bar("Simulating games", total = n, .envir = environment())
  }
  for (i in game_idx) {
    d <- sk_deal()
    g <- sk_play_game(d$hands, d$skat, declarer = declarer,
                      game_type = game_type, players = players, call = call)
    r <- g$result
    dec_pts[i] <- g$declarer_points
    won[i] <- r$won
    schneider[i] <- r$schneider
    schwarz[i] <- r$schwarz
    gval[i] <- r$game_value
    score[i] <- r$score
    if (verbose) cli::cli_progress_update(.envir = environment())
  }
  if (verbose) cli::cli_progress_done(.envir = environment())

  tibble::tibble(
    game = game_idx,
    game_type = game_type,
    declarer = declarer,
    declarer_points = dec_pts,
    won = won,
    schneider = schneider,
    schwarz = schwarz,
    game_value = gval,
    score = score
  )
}
