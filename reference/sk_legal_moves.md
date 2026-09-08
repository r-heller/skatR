# Legal cards to play

Given a player's hand, the game type, and the card led (if any), returns
the subset of the hand that may legally be played. Skat requires
following the led *effective* suit if able; otherwise any card is legal.
In suit and grand games every jack counts as a trump, so leading a jack
demands a trump, and a hand holding only off-suit jacks is not void in
trumps.

## Usage

``` r
sk_legal_moves(hand, led, game_type, call = rlang::caller_env())
```

## Arguments

- hand:

  An `sk_card` object or character vector: the player's remaining cards.

- led:

  A single card code (or `sk_card`) that was led, or `NULL` if this
  player leads the trick.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- call:

  The calling environment, used for error reporting.

## Value

An `sk_card` object containing the legal subset of `hand`. Always an
`sk_card`, including when the hand is empty.

## See also

[`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md)
for the suit a card must be followed under.

Other play functions:
[`sk_count_points()`](https://r-heller.github.io/skatR/reference/sk_count_points.md),
[`sk_trick_winner()`](https://r-heller.github.io/skatR/reference/sk_trick_winner.md)

## Examples

``` r
hand <- c("HA", "HK", "CJ", "DA")
# Holding hearts, the player must follow hearts.
sk_legal_moves(hand, led = "H7", game_type = "spades")
#> 2 Skat cards: ♥A ♥K
# Leading, anything goes.
sk_legal_moves(hand, led = NULL, game_type = "spades")
#> 4 Skat cards: ♣J · ♥A ♥K · ♦A
# Void in the led suit: anything goes again.
sk_legal_moves(c("CJ", "DA"), led = "H7", game_type = "spades")
#> 2 Skat cards: ♣J · ♦A
```
