test_that("twoMeans returns n_per_group and total_n as positive integers", {
  res <- sample_size_calculator(
    "twoMeans",
    mean1 = 10,
    mean2 = 12,
    sd = 3,
    alpha = 0.05,
    power = 0.8
  )
  expect_s3_class(res, "sample_size_result")
  expect_true(!is.null(res$n_per_group))
  expect_true(!is.null(res$total_n))
  expect_identical(res$design, "twoMeans")
  expect_gte(res$n_per_group, 1L)
  expect_gte(res$total_n, 2L)
  expect_equal(res$total_n, 2L * res$n_per_group)
})

test_that("survival returns target_events_needed", {
  res <- sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
  expect_s3_class(res, "sample_size_result")
  expect_true(!is.null(res$target_events_needed))
  expect_identical(res$design, "survival")
  expect_gte(res$target_events_needed, 1L)
})

test_that("twoProportions returns valid sample sizes", {
  res <- sample_size_calculator(
    "twoProportions",
    p1 = 0.3,
    p2 = 0.5,
    alpha = 0.05,
    power = 0.8
  )
  expect_s3_class(res, "sample_size_result")
  expect_true(!is.null(res$n_per_group))
  expect_true(!is.null(res$total_n))
  expect_gte(res$n_per_group, 1L)
})

test_that("missing required arguments throws with clear message", {
  expect_error(
    sample_size_calculator("twoMeans", mean1 = 10),
    "requires missing arguments",
    class = "rlang_error"
  )
  expect_error(
    sample_size_calculator("survival"),
    "requires missing arguments",
    class = "rlang_error"
  )
})

test_that("print and summary run without error", {
  res <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
  expect_error(print(res), NA)
  expect_error(summary(res), NA)
  expect_identical(print(res), res)
  expect_identical(summary(res), res)
})

test_that("plot_power_curve runs without error", {
  res <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
  expect_error(plot_power_curve(res), NA)

  # Test with survival design
  res_survival <- sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
  expect_error(plot_power_curve(res_survival), NA)

  # Test with twoProportions design
  res_proportions <- sample_size_calculator("twoProportions", p1 = 0.3, p2 = 0.5, alpha = 0.05, power = 0.8)
  expect_error(plot_power_curve(res_proportions), NA)
})
