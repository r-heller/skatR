#' Deal a Skat game
#'
#' Shuffles a full deck and deals ten cards to each of the three players plus a
#' two-card skat, following the standard 3-4-3 deal pattern (the pattern does
#' not affect play but is preserved for realism).
#'
#' @param seed Optional whole-number seed for reproducible shuffles. If `NULL`
#'   (the default) the current random state is used. When a seed is supplied the
#'   previous random state is restored on exit, by any path.
#' @param call The calling environment, used for error reporting.
#'
#' @return An object of class `sk_deal`: a list with elements
#'   * `hands`: a length-3 list of `sk_card` vectors, ten cards each
#'     (players 1, 2, 3),
#'   * `skat`: an `sk_card` vector of length 2.
#' @export
#' @family deal functions
#' @seealso [sk_play_game()] to play the deal out.
#' @examples
#' d <- sk_deal(seed = 1)
#' d$hands[[1]]
#' d$skat
sk_deal <- function(seed = NULL, call = rlang::caller_env()) {
  if (!is.null(seed)) {
    seed <- .sk_check_whole(seed, call = call)
    old <- .sk_save_seed()
    on.exit(.sk_restore_seed(old), add = TRUE)
    set.seed(seed)
  }
  deck <- sample(.sk_deck_codes)

  # 3-4-3 deal: P1,P2,P3 get 3; skat 2; P1,P2,P3 get 4; P1,P2,P3 get 3.
  hands <- list(character(0), character(0), character(0))
  idx <- 1L
  take <- function(n) {
    out <- deck[idx:(idx + n - 1L)]
    idx <<- idx + n
    out
  }
  for (p in seq_len(3L)) hands[[p]] <- c(hands[[p]], take(3))
  skat <- take(2)
  for (p in seq_len(3L)) hands[[p]] <- c(hands[[p]], take(4))
  for (p in seq_len(3L)) hands[[p]] <- c(hands[[p]], take(3))

  hands <- lapply(hands, new_sk_card)
  structure(
    list(hands = hands, skat = new_sk_card(skat)),
    class = "sk_deal"
  )
}

#' @export
print.sk_deal <- function(x, ...) {
  cli::cli_text("{.cls sk_deal}")
  for (p in seq_len(3L)) {
    cli::cli_text("Player {p}: {paste(format(x$hands[[p]]), collapse = ' ')}")
  }
  cli::cli_text("Skat: {paste(format(x$skat), collapse = ' ')}")
  invisible(x)
}

# --- seed helpers -----------------------------------------------------------

.sk_save_seed <- function() {
  if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
    get(".Random.seed", envir = globalenv(), inherits = FALSE)
  } else {
    NULL
  }
}

.sk_restore_seed <- function(old) {
  if (is.null(old)) {
    if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }
  } else {
    assign(".Random.seed", old, envir = globalenv())
  }
  invisible(NULL)
}
