# Play out a full Skat game

Plays all ten tricks of a Skat game given the three players' hands, the
declared game type, and which player is declarer. The two non-declarers
form the defending team. Bidding is assumed already resolved; this
simulates the card play and scores the result.

## Usage

``` r
sk_play_game(
  hands,
  skat,
  declarer,
  game_type,
  players = NULL,
  game_value = NULL,
  hand_game = FALSE,
  call = rlang::caller_env(),
  schneider_announced = FALSE,
  schwarz_announced = FALSE,
  ouvert = FALSE
)
```

## Arguments

- hands:

  A length-3 list of `sk_card` vectors (ten cards each), as from
  [`sk_deal()`](https://r-heller.github.io/skatR/reference/sk_deal.md).

- skat:

  An `sk_card` vector of length 2 (the skat). Its points are credited to
  the declarer in suit and grand games, including hand games.

- declarer:

  Integer in `1:3`: the declaring player.

- game_type:

  A single game-type string, one of
  [`sk_game_types()`](https://r-heller.github.io/skatR/reference/sk_game_types.md).

- players:

  A length-3 list of `sk_player` objects, one per seat. Defaults to
  heuristic players for all seats.

- game_value:

  Optional complete scoring value. If `NULL` (default), it is computed
  from the original hand plus skat and achieved/announced levels. This
  is not a bid; overbidding must be resolved by the caller.

- hand_game:

  Logical; whether the skat was left untouched. Defaults to `FALSE`.

- call:

  The calling environment, used for error reporting.

- schneider_announced, schwarz_announced:

  Logical announcements, valid only for suit/grand hand games. Failure
  to achieve the level loses the game.

- ouvert:

  Logical; open play. Suit/grand ouvert implies hand and both
  announcements and requires every trick; null ouvert still requires no
  trick.

## Value

An object of class `sk_game`: a list with elements

- `result`: an `sk_result` object from
  [`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md),

- `tricks`: a length-10 list, each element a list of `cards`, `leader`,
  `winner`, and `points`,

- `declarer`: the declaring seat,

- `game_type`: the game type played,

- `declarer_points`: the integer card points credited to the declarer,
  trick points plus skat points, including hand games – the same total
  the result was scored on,

- `tricks_won`: the integer number of tricks the declarer took.

## See also

[`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md)
to repeat this over many deals, and
[`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md)
for exact double-dummy analysis of an endgame.

## Examples

``` r
d <- sk_deal(seed = 42)
g <- sk_play_game(d$hands, d$skat, declarer = 1, game_type = "grand")
g$result$won
#> [1] FALSE
g$declarer_points
#> [1] 25
```
