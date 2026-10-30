# ISkO 2022 sections 2.3.2, 2.5.1, 2.5.4, 2.5.7 and 2.5.8.
# https://dskv.de/app/uploads/sites/18/2020/08/ISkO-2022-1.pdf

test_that('official hand and ouvert multiplier examples agree', {
  two <- c('CJ','SJ','HA')
  expect_equal(sk_game_value(two,'clubs',ouvert=TRUE),108L)
  expect_equal(sk_game_value(c('CJ','SJ','HJ','DJ'),'grand',ouvert=TRUE),264L)
  expect_equal(sk_game_value(two,'clubs',schwarz=TRUE),60L)
  expect_equal(sk_game_value(two,'clubs',hand_game=TRUE,schneider_announced=TRUE),72L)
  expect_error(sk_game_value(two,'clubs',schneider_announced=TRUE),'hand game')
  expect_error(sk_game_value(two,'null',schwarz_announced=TRUE),'no schneider')
  expect_equal(sk_game_value(character(),'null',hand_game=TRUE,ouvert=TRUE),59L)
})

test_that('announcements change the win condition and lost games double', {
  expect_false(sk_score_game(89,'clubs',72,schneider_announced=TRUE)$won)
  expect_equal(sk_score_game(89,'clubs',72,schneider_announced=TRUE)$score,-144L)
  expect_true(sk_score_game(90,'clubs',72,schneider_announced=TRUE)$won)
  expect_false(sk_score_game(120,'clubs',108,ouvert=TRUE)$won)
  expect_true(sk_score_game(120,'clubs',108,ouvert=TRUE,declarer_won_all=TRUE)$won)
  expect_false(sk_score_game(90,'grand',168,schwarz_announced=TRUE)$won)
  expect_true(sk_score_game(0,'null',46,ouvert=TRUE,declarer_lost_all=TRUE)$won)
  expect_error(sk_score_game(60,'grand',.Machine$integer.max),'doubled loss')
})

test_that('invalid deals fail before a player is invoked', {
  d <- sk_deal(seed=42)
  d$hands[[1]][1] <- d$hands[[2]][1]
  expect_error(sk_play_game(d$hands,d$skat,1,'grand'),'32 cards exactly once')
  d <- sk_deal(seed=42)
  expect_error(sk_play_game(d$hands,d$skat[1],1,'grand'),'32 cards exactly once')
})

test_that('completed deals conserve cards and include skat and achieved levels', {
  for (seed in 1:6) for (type in sk_game_types()) {
    d <- sk_deal(seed=seed)
    hand <- seed %% 2 == 0
    g <- sk_play_game(d$hands,d$skat,1,type,hand_game=hand)
    cards <- unlist(lapply(g$tricks,function(t)t$cards))
    expect_setequal(c(cards,as.character(d$skat)),as.character(sk_full_deck()))
    expect_equal(sum(vapply(g$tricks,function(t)t$points,integer(1)))+sk_count_points(d$skat),120)
    points <- sum(vapply(g$tricks,function(t)if(t$winner==1)t$points else 0L,integer(1)))+sk_count_points(d$skat)
    expect_equal(g$declarer_points,points)
    if(type!='null') {
      # Independently assemble ISkO scoring levels from the observed outcome.
      levels <- 1L + as.integer(hand) + as.integer(points<=30 || points>=90) + as.integer(g$tricks_won %in% c(0L,10L))
      value <- sk_base_value(type)*(sk_matadors(c(d$hands[[1]],d$skat),type)$count+levels)
      expect_equal(g$result$game_value,value)
      expect_equal(g$result$score,if(points>=61)value else -2L*value)
    }
  }
})
