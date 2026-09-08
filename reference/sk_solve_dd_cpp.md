# Solve a double-dummy Skat endgame (C++ core)

Solve a double-dummy Skat endgame (C++ core)

## Usage

``` r
sk_solve_dd_cpp(
  hand0,
  hand1,
  hand2,
  leader,
  declarer,
  points,
  strength,
  eff_suit
)
```

## Arguments

- hand0, hand1, hand2:

  Integer vectors of card codes (0-31) held by seats 0, 1, and 2.

- leader:

  Integer seat (0-2) to lead the next trick.

- declarer:

  Integer seat (0-2) that is the declarer.

- points:

  Integer vector of length 32: card -\> card points.

- strength:

  Integer vector of length 32: card -\> trick strength.

- eff_suit:

  Integer vector of length 32: card -\> effective suit id (0-3 for
  suits, 4 for trump).

## Value

Integer: the maximum card points the declarer can guarantee.
