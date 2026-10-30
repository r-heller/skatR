# game-type errors read well

    Code
      sk_card_order("bells")
    Condition
      Error:
      ! `game_type` must be one of "diamonds", "hearts", "spades", "clubs", "grand", or "null".
      x Got "bells".

---

    Code
      sk_card_order(42)
    Condition
      Error:
      ! `game_type` must be a single non-`NA` string.

---

    Code
      sk_matadors(c("CJ", "HA"), "null")
    Condition
      Error:
      ! `game_type` must be a suit or grand game, not "null".
      i Null games have fixed values; see `sk_game_value()`.

# card errors read well

    Code
      sk_points("ZZ")
    Condition
      Error:
      ! `x` must contain only valid Skat card codes.
      x Unknown card: "ZZ".
      i Codes are a suit letter ("C", "S", "H", or "D") followed by a rank ("7", "8", "9", "J", "Q", "K", "10", or "A"), e.g. "CA" or "D10".

---

    Code
      sk_points(1:3)
    Condition
      Error:
      ! `x` must be an <sk_card> object or a character vector of card codes.
      x Got <integer> instead.

---

    Code
      sk_trick_winner(c("HA", "HK"), "grand")
    Condition
      Error:
      ! `cards` must contain exactly 3 cards.
      x Got 2.

# solver errors read well

    Code
      sk_solve_dd(list(c("CJ"), c("HA", "H9"), c("DA", "D9")), "grand", 1)
    Condition
      Error:
      ! Each seat must hold the same number of cards.
      x Got sizes 1, 2, and 2.

---

    Code
      sk_solve_dd(list(c("CJ", "SA"), c("CJ", "H9"), c("DA", "D9")), "grand", 1)
    Condition
      Error:
      ! Each card may be held by at most one seat.
      x Duplicated card: "CJ".

---

    Code
      sk_solve_dd(list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9")), "grand", 9)
    Condition
      Error:
      ! `declarer` must be a seat number: 1, 2, or 3.
      x Got 9.

---

    Code
      sk_solve_dd(lapply(sk_deal(seed = 1)$hands, as.character), "grand", 1)
    Condition
      Error:
      ! This position is too deep for an exact solve.
      x Each seat holds 10 cards, more than `max_tricks` = 8.
      i Solve an endgame slice instead: keep the last 8 cards of each hand. Raise `max_tricks` only if you are prepared to wait; every extra trick costs roughly another order of magnitude.

# scoring errors read well

    Code
      sk_score_game(200, "grand", 24)
    Condition
      Error:
      ! `declarer_points` must be a single whole number between 0 and 120.
      i The 32 cards of a Skat deck hold 120 card points in total.

---

    Code
      sk_score_game(60, "grand", 24, declarer_won_all = TRUE, declarer_lost_all = TRUE)
    Condition
      Error:
      ! The declarer cannot both take every trick and take none.
      x `declarer_won_all` and `declarer_lost_all` are both `TRUE`.

# plotting errors read well

    Code
      sk_plot_points(1:10)
    Condition
      Error:
      ! `sim` must be a simulation tibble from `sk_simulate()`.
      x Got <integer> instead.

---

    Code
      sk_plot_winrate(data.frame(won = TRUE))
    Condition
      Error:
      ! `sim` must be a simulation tibble from `sk_simulate()`.
      x Missing columns: declarer_points and game_type.
      i It needs declarer_points, won, and game_type.

# player errors read well

    Code
      sk_choose("heuristic", "HA", NULL, "grand")
    Condition
      Error:
      ! `player` must be a <sk_player> object.
      x Got <character> instead.

---

    Code
      sk_play_game(sk_deal(seed = 1)$hands, sk_deal(seed = 1)$skat, 1, "grand",
      players = list(1, 2, 3))
    Condition
      Error:
      ! `players` must be a length-3 list of <sk_player> objects.
      i Build one with `sk_player()`, e.g. `rep(list(sk_player("heuristic")), 3)`.

