test_that('invalid counts and fractional card points cannot alter scoring', {
  for (bad in list(Inf,-Inf,NA_real_,1.5,.Machine$integer.max+1))
    expect_error(.sk_check_count(bad),'whole number')
  expect_error(sk_score_game(60.9,'hearts',game_value=20),'whole number')
  expect_error(sk_score_game(NA_real_,'hearts',game_value=20),'whole number')
  expect_false(sk_score_game(60,'hearts',game_value=20)$won)
  expect_true(sk_score_game(61,'hearts',game_value=20)$won)
})
