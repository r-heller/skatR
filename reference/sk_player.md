# Create a Skat player

Players are strategy objects that, given a legal set of moves and the
visible game context, choose a card to play. Three built-in strategies
are provided.

## Usage

``` r
sk_player(
  strategy = c("random", "heuristic", "mcts"),
  n_sims = 200,
  call = rlang::caller_env()
)
```

## Arguments

- strategy:

  One of `"random"`, `"heuristic"`, or `"mcts"`.

  - `"random"`: chooses uniformly among legal moves.

  - `"heuristic"`: greedy rules – take the trick with the cheapest card
    that beats it when the trick is worth taking, otherwise shed the
    lowest-value card.

  - `"mcts"`: determinized Monte Carlo search (see
    [`sk_mcts_move()`](https://r-heller.github.io/skatR/reference/sk_mcts_move.md)).

- n_sims:

  For `"mcts"`, the number of determinized playouts per decision.
  Ignored otherwise. Defaults to 200.

- call:

  The calling environment, used for error reporting.

## Value

An object of class `sk_player`: a list with elements `strategy`
(character) and `n_sims` (integer).

## See also

[`sk_choose()`](https://r-heller.github.io/skatR/reference/sk_choose.md)
to ask a player for a move.

Other player functions:
[`sk_choose()`](https://r-heller.github.io/skatR/reference/sk_choose.md),
[`sk_mcts_move()`](https://r-heller.github.io/skatR/reference/sk_mcts_move.md)

## Examples

``` r
sk_player("heuristic")
#> <sk_player>: heuristic
sk_player("mcts", n_sims = 500)
#> <sk_player>: mcts (500 sims)
```
