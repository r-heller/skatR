# Maintenance record — 30 October 2026

## Purpose and acceptance criteria

Skat card play, resolved-contract scoring, simulation and double-dummy analysis.

The current milestone requires correct supported rules, bounded/validated inputs,
meaningful failure-path regressions, an installable source package, and a working
local app. Original checkouts and unrelated work are preserved in isolated review
branches. No release, push or deployment is implied by this local record.

## Evidence-led findings and repairs

- High: hand games excluded skat points and automatic values omitted achieved Schneider/Schwarz. Include the skat in points and matadors for hand games; compute automatic scoring values after play.
- High: ouvert/announced multiplier levels and winning conditions were incomplete. Implement official hand/announcement levels, implied requirements, 90-point Schneider and all-tricks Schwarz conditions. Keep null's 23/35/46/59 values distinct.
- Medium: validate a complete 32-unique-card deal before players run; reject fractional/non-finite values and score overflow.
- Compatibility: new contract flags follow the existing `call` argument, retaining old positional calls. `game_value` is explicitly a complete scoring value, not a bid. Corrected automatic scores intentionally differ from previous releases.
- Documentation: ruleset objects are descriptive metadata; Bock/Ramsch/Kontra are not consumed by the engine. Update the README examples and plot from actual execution.

Rule source checked: https://dskv.de/app/uploads/sites/18/2020/08/ISkO-2022-1.pdf

## Roadmap and completion

1. Essential repairs: correct the confirmed rule/process defects above and protect
   them with independent boundary cases. Implemented and locally validated.
2. Everyday use: preserve user state, validate invalid inputs, install the package,
   exercise play/analysis and the app. Completed for the paths below.
3. Release preparation: synchronize documentation and package checks. Local
   candidate prepared; platform CI and maintainer publication review remain.
4. Deferred enhancements: retain the focused supported model; do not add engines,
   rule variants or infrastructure without an explicit use case and validation.

## Actual verification

R 4.6.1 on ARM64 macOS, 30 October 2026:

- Full source tests: 532 assertions passed, one environment-guard skip. Final package build/check with vignettes: **Status OK**, 516 assertions and 7 conditional skips.
- Official-rule regression cases include clubs ouvert with two matadors = 108, grand with four = 264, announced failure at 89 vs success at 90, Schwarz all-tricks requirements, all 32 unique cards and point conservation.
- Installed journey: official value examples, independently traced double-dummy endgame and 30 complete hand games passed.
- Installed browser: 200-game simulation plots, full deal play with points including the skat, and reference cards passed with no page errors. README regenerated from executed R Markdown.

Exact command results and logs are retained locally in
`/Users/rh/Documents/GitHub/.repository-audit/2026-10-30-rheller-refinement/skatR/`.
Failures preceding fixes remain there alongside the final evidence.

## First use from this checkout

Install R (tested with 4.6.1). For compiled dependencies use Xcode command-line
tools on macOS, Rtools on Windows, or the matching Linux C/C++ toolchain. From
this repository, install dependencies and the local candidate:

```sh
Rscript --vanilla -e 'install.packages("remotes", repos="https://cloud.r-project.org"); remotes::install_local(".", dependencies=TRUE, upgrade="never", build_vignettes=FALSE)'
Rscript --vanilla -e 'skatR::sk_run_app()'
```

Open the local URL printed by Shiny. The README gives the scriptable workflow.
To repeat source tests, run `Rscript --vanilla -e
'pkgload::load_all(); testthat::test_local(stop_on_failure=TRUE)'` after installing
the development dependencies.

## Limits and next release action

The caller supplies a resolved contract and final hands/skat. Bidding, pickup/discard choices, overbidding resolution and tournament management remain outside this release. The double-dummy solver assumes known hands. Windows/Linux and hosted CI were not run.

Review the local diff and run required platform CI on the chosen release commit;
then decide whether to publish. No hosted result or external acceptance is claimed.
