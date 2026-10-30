# Internal input-validation helpers. Not exported.

.sk_check_string <- function(x, arg = rlang::caller_arg(x),
                             call = rlang::caller_env()) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single non-{.code NA} string.",
      call = call
    )
  }
  invisible(x)
}

.sk_check_choice <- function(x, choices, arg = rlang::caller_arg(x),
                             call = rlang::caller_env()) {
  force(arg)
  .sk_check_string(x, arg = arg, call = call)
  if (!x %in% choices) {
    choices <- cli::cli_vec(choices, list("vec-last" = ", or "))
    cli::cli_abort(
      c(
        "{.arg {arg}} must be one of {.val {choices}}.",
        "x" = "Got {.val {x}}."
      ),
      call = call
    )
  }
  invisible(x)
}

.sk_check_flag <- function(x, arg = rlang::caller_arg(x),
                           call = rlang::caller_env()) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be {.code TRUE} or {.code FALSE}.",
      call = call
    )
  }
  invisible(x)
}

.sk_check_count <- function(x, arg = rlang::caller_arg(x),
                            call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < 1 ||
      x != trunc(x) || x > .Machine$integer.max) {
    cli::cli_abort(
      "{.arg {arg}} must be a single positive whole number.",
      call = call
    )
  }
  invisible(as.integer(x))
}

.sk_check_class <- function(x, cls, arg = rlang::caller_arg(x),
                            call = rlang::caller_env()) {
  if (!inherits(x, cls)) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a {.cls {cls}} object.",
        "x" = "Got {.cls {class(x)[[1]]}} instead."
      ),
      call = call
    )
  }
  invisible(x)
}

# Any single whole number, including zero and negatives (used for RNG seeds).
.sk_check_whole <- function(x, arg = rlang::caller_arg(x),
                            call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
      x != trunc(x) || abs(x) > .Machine$integer.max) {
    cli::cli_abort(
      "{.arg {arg}} must be a single whole number.",
      call = call
    )
  }
  invisible(as.integer(x))
}

# A single seat index in 1:3.
.sk_check_seat <- function(x, arg = rlang::caller_arg(x),
                           call = rlang::caller_env()) {
  force(arg)  # `x` is rebound below, which would lose the caller's expression
  x <- .sk_check_count(x, arg = arg, call = call)
  if (x > 3L) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a seat number: 1, 2, or 3.",
        "x" = "Got {.val {x}}."
      ),
      call = call
    )
  }
  invisible(x)
}

# A character vector (or sk_card) of valid deck codes. Returns the codes.
.sk_check_cards <- function(x, arg = rlang::caller_arg(x),
                            allow_empty = TRUE,
                            call = rlang::caller_env()) {
  force(arg)  # `x` is rebound below, which would lose the caller's expression
  if (inherits(x, "sk_card")) x <- as.character(x)
  if (!is.character(x)) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be an {.cls sk_card} object or a character vector \\
         of card codes.",
        "x" = "Got {.cls {class(x)[[1]]}} instead."
      ),
      call = call
    )
  }
  if (anyNA(x)) {
    cli::cli_abort(
      "{.arg {arg}} must not contain {.code NA}.",
      call = call
    )
  }
  if (!allow_empty && length(x) == 0L) {
    cli::cli_abort("{.arg {arg}} must not be empty.", call = call)
  }
  bad <- setdiff(x, .sk_deck_codes)
  if (length(bad) > 0L) {
    # Naming every offender helps nobody; the first few make the point.
    shown <- utils::head(bad, 5L)
    more <- length(bad) - length(shown)
    tail_note <- if (more > 0L) cli::format_inline(" (+{more} more)") else ""
    or <- list("vec-last" = ", or ")
    cli::cli_abort(
      c(
        "{.arg {arg}} must contain only valid Skat card codes.",
        "x" = "{cli::qty(length(bad))}Unknown card{?s}: \\
               {.val {shown}}{tail_note}.",
        "i" = "Codes are a suit letter ({.val {cli::cli_vec(sk_suits, or)}}) \\
               followed by a rank ({.val {cli::cli_vec(sk_ranks, or)}}), \\
               e.g. {.val CA} or {.val D10}."
      ),
      call = call
    )
  }
  invisible(x)
}

# A single card-point total in 0:120.
.sk_check_card_points <- function(x, arg = rlang::caller_arg(x),
                                  call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x != trunc(x) || x < 0 || x > 120) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a single whole number between 0 and 120.",
        "i" = "The 32 cards of a Skat deck hold 120 card points in total."
      ),
      call = call
    )
  }
  invisible(as.integer(x))
}
