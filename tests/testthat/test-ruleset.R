test_that("the tournament preset turns the casual variants off", {
  r <- sk_ruleset("tournament")
  expect_s3_class(r, "sk_ruleset")
  expect_equal(r$preset, "tournament")
  expect_false(r$bock)
  expect_false(r$ramsch)
  expect_false(r$contra_re)
})

test_that("the casual preset turns them on", {
  r <- sk_ruleset("casual")
  expect_true(r$ramsch)
  expect_true(r$contra_re)
  expect_false(r$bock)
  expect_true(sk_ruleset("casual", bock = TRUE)$bock)
})

test_that("individual options override the preset", {
  r <- sk_ruleset("casual", ramsch = FALSE, contra_re = FALSE)
  expect_false(r$ramsch)
  expect_false(r$contra_re)
})

test_that("casual options under tournament rules warn", {
  expect_warning(sk_ruleset("tournament", bock = TRUE), "Tournament rules")
  expect_warning(sk_ruleset("tournament", ramsch = TRUE), "Tournament rules")
})

test_that("rulesets validate their flags", {
  expect_error(sk_ruleset("kneipe"))
  expect_error(sk_ruleset("casual", bock = "yes"), "TRUE")
  expect_error(sk_ruleset("casual", ramsch = NA), "TRUE")
})

test_that("rulesets are recognised and printed", {
  expect_true(is_sk_ruleset(sk_ruleset("casual")))
  expect_false(is_sk_ruleset("casual"))
  expect_false(is_sk_ruleset(NULL))
  expect_message(print(sk_ruleset("casual")), "Ramsch")
  expect_invisible(suppressMessages(print(sk_ruleset("tournament"))))
})

test_that("game types are the six recognised everywhere", {
  expect_equal(
    sk_game_types(),
    c("diamonds", "hearts", "spades", "clubs", "grand", "null")
  )
})

test_that("the app launcher reports a missing shiny installation", {
  skip_if(requireNamespace("shiny", quietly = TRUE),
          "shiny is installed, so the guard cannot fire")
  expect_error(sk_run_app(), "shiny")
})

test_that("the bundled Shiny app ships and parses", {
  app_dir <- system.file("shiny", "skatR", package = "skatR")
  skip_if(!nzchar(app_dir), "app directory not installed")
  app_file <- file.path(app_dir, "app.R")
  expect_true(file.exists(app_file))
  expect_no_error(parse(app_file))
  # The app must not attach packages; it uses namespaces throughout.
  src <- readLines(app_file, warn = FALSE)
  expect_false(any(grepl("^\\s*(library|require)\\(", src)))
})
