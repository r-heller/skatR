#' Skat card constants
#'
#' The four suits and eight ranks of a 32-card Skat deck, together with the
#' card-point values used for scoring.
#'
#' @format Character and integer vectors.
#' @details
#' Suits are ordered by their bidding rank: clubs (highest), spades, hearts,
#' diamonds (lowest). Ranks run seven, eight, nine, jack, queen, king, ten, ace
#' in card-point order, though trick-taking order depends on the game type (see
#' [sk_card_order()]).
#'
#' `sk_suits` uses the single letters `C`, `S`, `H`, `D`. `sk_ranks` uses `7`,
#' `8`, `9`, `J`, `Q`, `K`, `10`, `A`.
#' @name skat-constants
NULL

#' @rdname skat-constants
#' @export
sk_suits <- c("C", "S", "H", "D")

#' @rdname skat-constants
#' @export
sk_ranks <- c("7", "8", "9", "J", "Q", "K", "10", "A")

#' @rdname skat-constants
#' @export
sk_card_points <- c(
  "7" = 0L, "8" = 0L, "9" = 0L, "J" = 2L,
  "Q" = 3L, "K" = 4L, "10" = 10L, "A" = 11L
)

# Human-readable suit labels, used only for printing.
.sk_suit_labels <- c(C = "\u2663", S = "\u2660", H = "\u2665", D = "\u2666")

# Reading order for a hand: suit blocks clubs, spades, hearts, diamonds, and
# within a suit the descending rank a player fans their cards in. Trick-taking
# order depends on the game type, which `print()` does not know, so this is a
# display order only -- see `sk_card_order()` for the order that plays.
.sk_display_ranks <- c("A", "10", "K", "Q", "J", "9", "8", "7")

.sk_display_order <- function(codes) {
  order(
    match(sk_suit_of(codes), sk_suits),
    match(sk_rank_of(codes), .sk_display_ranks)
  )
}

# The 32 deck codes, in suit-then-rank order. Built once at load time because
# validation and the solver consult it on every call.
.sk_deck_codes <- paste0(
  rep(sk_suits, each = length(sk_ranks)),
  rep(sk_ranks, times = length(sk_suits))
)

#' Construct a Skat card
#'
#' Creates a single card, represented as an S3 object of class `sk_card`. A card
#' is stored as a length-one character code of the form `"<suit><rank>"`, e.g.
#' `"CA"` for the ace of clubs or `"D10"` for the ten of diamonds.
#'
#' @param suit A single suit code, one of `sk_suits` (`"C"`, `"S"`, `"H"`,
#'   `"D"`).
#' @param rank A single rank code, one of `sk_ranks`.
#' @param call The calling environment, used for error reporting.
#'
#' @return An `sk_card` object (a length-one character vector with class
#'   `sk_card`).
#' @export
#' @family card functions
#' @examples
#' sk_card("C", "A")
#' sk_card("D", "10")
sk_card <- function(suit, rank, call = rlang::caller_env()) {
  .sk_check_choice(suit, sk_suits, call = call)
  .sk_check_choice(rank, sk_ranks, call = call)
  new_sk_card(paste0(suit, rank))
}

# Low-level constructor: trusted input, no validation.
new_sk_card <- function(code = character()) {
  structure(code, class = "sk_card")
}

#' Extract the suit of a card
#'
#' @param x An `sk_card` object or a character vector of card codes.
#' @return A character vector of suit codes (`"C"`, `"S"`, `"H"`, or `"D"`), the
#'   same length as `x`.
#' @export
#' @family card functions
#' @seealso [sk_rank_of()] for the other half of a card code.
#' @examples
#' sk_suit_of(sk_card("H", "K"))
#' sk_suit_of(c("CA", "D10"))
sk_suit_of <- function(x) {
  substr(as.character(x), 1L, 1L)
}

#' Extract the rank of a card
#'
#' @param x An `sk_card` object or a character vector of card codes.
#' @return A character vector of rank codes, the same length as `x`. The ten is
#'   two characters wide (`"10"`); every other rank is one.
#' @export
#' @family card functions
#' @seealso [sk_suit_of()] for the other half of a card code.
#' @examples
#' sk_rank_of(sk_card("H", "K"))
#' sk_rank_of(c("CA", "D10"))
sk_rank_of <- function(x) {
  codes <- as.character(x)
  substr(codes, 2L, nchar(codes))
}

#' Card-point value of one or more cards
#'
#' Returns the Skat card-point value (jack 2, queen 3, king 4, ten 10, ace 11,
#' others 0). The card points of all 32 cards sum to 120.
#'
#' @param x An `sk_card` object or character vector of card codes.
#' @param call The calling environment, used for error reporting.
#' @return An integer vector of card-point values, the same length as `x`.
#' @export
#' @family card functions
#' @seealso [sk_count_points()] to total the points of a set of cards.
#' @examples
#' sk_points(c("CA", "D10", "H7"))
#' sum(sk_points(sk_full_deck()))
sk_points <- function(x, call = rlang::caller_env()) {
  codes <- .sk_check_cards(x, call = call)
  unname(sk_card_points[sk_rank_of(codes)])
}

#' A full 32-card Skat deck
#'
#' @return An `sk_card` object of length 32 containing every suit-rank
#'   combination, ordered by suit and then by rank.
#' @export
#' @family card functions
#' @seealso [sk_card_order()] for trick-taking order under a given game type.
#' @examples
#' sk_full_deck()
#' length(sk_full_deck())
sk_full_deck <- function() {
  new_sk_card(.sk_deck_codes)
}

#' Format and print Skat cards
#'
#' Renders card codes with their suit symbols, so `"CA"` prints as the ace of
#' clubs rather than as a bare string.
#'
#' @param x An `sk_card` object.
#' @param i An index, passed on to the default `[` method.
#' @param ... Ignored; present for consistency with the S3 generics.
#'
#' @return `format()` returns a character vector of pretty card labels, the same
#'   length as `x`, in the order `x` holds them. `print()` returns `x` invisibly
#'   and is called for the side effect of printing; it sorts the cards into suit
#'   blocks for reading, the way a player fans a hand, while `x` itself keeps its
#'   order. `[` returns an `sk_card` object, so subsetting a hand stays a hand.
#' @export
#' @family card functions
#' @examples
#' format(sk_full_deck()[1:4])
#' print(sk_card("C", "A"))
#' sk_full_deck()[1:4]
format.sk_card <- function(x, ...) {
  codes <- as.character(x)
  vapply(codes, function(cd) {
    s <- substr(cd, 1L, 1L)
    r <- substr(cd, 2L, nchar(cd))
    label <- .sk_suit_labels[s]
    paste0(if (is.na(label)) s else label, r)
  }, character(1), USE.NAMES = FALSE)
}

#' @rdname format.sk_card
#' @export
print.sk_card <- function(x, ...) {
  n <- length(x)
  if (n == 0L) {
    cli::cli_text("{.cls sk_card}: no cards")
    return(invisible(x))
  }
  line <- .sk_hand_line(x)
  cli::cli_text("{.strong {n} Skat card{?s}}: {line}")
  invisible(x)
}

# A hand on one line: sorted into suit blocks, divided by a middle dot so the
# eye can count a suit without reading every card. cli collapses runs of spaces,
# so the divider has to be a visible character rather than a wider gap.
.sk_hand_line <- function(x) {
  codes <- as.character(x)
  if (length(codes) == 0L) return("")
  ord <- .sk_display_order(codes)
  labels <- format(x)[ord]
  suits <- sk_suit_of(codes)[ord]
  breaks <- c(FALSE, suits[-1] != suits[-length(suits)])
  paste(paste0(ifelse(breaks, "\u00b7 ", ""), labels), collapse = " ")
}

#' @rdname format.sk_card
#' @export
`[.sk_card` <- function(x, i, ...) {
  new_sk_card(NextMethod())
}
