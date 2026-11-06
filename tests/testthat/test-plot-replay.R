test_that("power replay preserves a nondefault alpha", {
  original <- calculate("rct", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.01)
  result <- ssr_replay_at_power(original, 0.9)
  expect_equal(result$parameters$alpha, 0.01)
  expect_equal(result$n_per_group, 69)
})

test_that("legacy power replay preserves a nondefault alpha", {
  original <- sample_size_calculator(
    "twoMeans",
    mean1 = 10,
    mean2 = 12,
    sd = 3,
    alpha = 0.01
  )
  result <- ssr_replay_at_power(original, 0.9)
  expect_equal(result$parameters$alpha, 0.01)
  expect_equal(result$n_per_group, 69)
})

# Replay tests: power-curve machinery must work for both entry points and
# both old and new parameter storage. Regression: the legacy survival power
# curve silently produced an empty plot because parameters stored
# `hazard_ratio` while the function argument is `hr`.

test_that("survival power curve replay uses original argument names", {
  res <- sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
  r <- ssr_replay_at_power(res, 0.9)
  expect_false(is.null(r$target_events_needed))
  expect_gte(r$target_events_needed, 1L)
})

test_that("three-axis designs replay through calculate()", {
  res <- calculate("cohort", "test", "proportion", p0 = 0.2, p1 = 0.3)
  r <- ssr_replay_at_power(res, 0.9)
  expect_false(is.null(r$n_per_group))
  expect_identical(r$design_canonical, "cohort")
})

test_that("replay_args are stored on both API paths", {
  legacy_res <- sample_size_calculator(
    "twoMeans",
    mean1 = 10,
    mean2 = 12,
    sd = 3
  )
  new_res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
  expect_false(is.null(legacy_res$replay_args))
  expect_false(is.null(new_res$replay_args))
  expect_identical(new_res$replay_args$sd, 3)
})
