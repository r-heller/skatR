# skatR

**skatR** is a toolkit for analysing and simulating the German card game
**Skat**. It provides trick play and scoring for suit, grand, and null
games, game-value computation, players spanning rule-based heuristics
through determinized Monte Carlo to an exact double-dummy solver, Monte
Carlo simulation over many deals, and tidy analysis and visualisation of
outcomes.

The caller supplies a resolved contract and the final ten-card hands
plus skat. Bidding, skat pickup/discard decisions, overbidding, and a
tournament manager are outside the current engine.
[`sk_ruleset()`](https://r-heller.github.io/skatR/reference/sk_ruleset.md)
stores variant metadata; play and scoring do not consume Bock, Ramsch,
or Kontra settings.

Hand games include the skat in the declarer’s card points and matador
count. Automatic values include achieved Schneider/Schwarz; announced
levels and ouvert are checked explicitly. Corrected scores can differ
from earlier releases. `game_value` means the complete scoring value,
not the player’s bid.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("r-heller/skatR")
```

## Quick start

Deal a hand and play it out. Every seat is a strategy object, so the
same call covers random, heuristic, and search-based play.

``` r

library(skatR)

deal <- sk_deal(seed = 42)
game <- sk_play_game(deal$hands, deal$skat, declarer = 1, game_type = "grand")
game$result
#> <sk_result>: declarer lost
#> • Game value: 120
#> • Score: -240
#> • Schneider: yes
#> • Schwarz: no
```

Repeat it a few hundred times to see how a configuration performs.

``` r

sim <- sk_simulate(n = 500, game_type = "grand", seed = 1, verbose = FALSE)
mean(sim$won)
#> [1] 0.242

sk_plot_points(sim)
```

![Histogram of declarer card points across 500 simulated grand games,
filled by whether the declarer won, with a dashed line at the 61-point
winning threshold.](reference/figures/README-simulate-1.png)

Or solve an endgame exactly. The double-dummy solver runs an alpha-beta
search in C++ and returns the card points the declarer can guarantee
against perfect defence.

``` r

hands <- list(c("CJ", "SA"), c("HA", "H9"), c("DA", "D9"))
sk_solve_dd(hands, game_type = "grand", declarer = 1)
#> [1] 35
```

## What is in the box

| Area | Functions |
|----|----|
| Cards and ordering | [`sk_full_deck()`](https://r-heller.github.io/skatR/reference/sk_full_deck.md), [`sk_card()`](https://r-heller.github.io/skatR/reference/sk_card.md), [`sk_points()`](https://r-heller.github.io/skatR/reference/sk_points.md), [`sk_card_order()`](https://r-heller.github.io/skatR/reference/sk_card_order.md), [`sk_strength()`](https://r-heller.github.io/skatR/reference/sk_strength.md), [`sk_is_trump()`](https://r-heller.github.io/skatR/reference/sk_is_trump.md), [`sk_effective_suit()`](https://r-heller.github.io/skatR/reference/sk_effective_suit.md) |
| Bidding | [`sk_base_value()`](https://r-heller.github.io/skatR/reference/sk_base_value.md), [`sk_matadors()`](https://r-heller.github.io/skatR/reference/sk_matadors.md), [`sk_game_value()`](https://r-heller.github.io/skatR/reference/sk_game_value.md) |
| Play and scoring | [`sk_legal_moves()`](https://r-heller.github.io/skatR/reference/sk_legal_moves.md), [`sk_trick_winner()`](https://r-heller.github.io/skatR/reference/sk_trick_winner.md), [`sk_count_points()`](https://r-heller.github.io/skatR/reference/sk_count_points.md), [`sk_score_game()`](https://r-heller.github.io/skatR/reference/sk_score_game.md) |
| Players | [`sk_player()`](https://r-heller.github.io/skatR/reference/sk_player.md), [`sk_choose()`](https://r-heller.github.io/skatR/reference/sk_choose.md), [`sk_mcts_move()`](https://r-heller.github.io/skatR/reference/sk_mcts_move.md) |
| Solver | [`sk_solve_dd()`](https://r-heller.github.io/skatR/reference/sk_solve_dd.md) |
| Simulation | [`sk_deal()`](https://r-heller.github.io/skatR/reference/sk_deal.md), [`sk_play_game()`](https://r-heller.github.io/skatR/reference/sk_play_game.md), [`sk_simulate()`](https://r-heller.github.io/skatR/reference/sk_simulate.md) |
| Plots | [`sk_plot_points()`](https://r-heller.github.io/skatR/reference/sk_plot_points.md), [`sk_plot_winrate()`](https://r-heller.github.io/skatR/reference/sk_plot_winrate.md) |
| Rules and demo | [`sk_ruleset()`](https://r-heller.github.io/skatR/reference/sk_ruleset.md), [`sk_run_app()`](https://r-heller.github.io/skatR/reference/sk_run_app.md) |

[`vignette("skatR")`](https://r-heller.github.io/skatR/articles/skatR.md)
walks through all of it in order.

## License

MIT (c) Raban Heller

## Local maintenance candidate

See [MAINTENANCE.md](https://r-heller.github.io/skatR/MAINTENANCE.md)
for the 30 October 2026 repairs, exact local installation path,
verification results and remaining release limits.
