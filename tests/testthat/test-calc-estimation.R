# Phase 2: estimation designs (singleProportion / singleMean /
# singleCorrelation). Anchors: docs/NUMERIC_ANCHORS.md A1/A2/A6.

test_that("singleProportion matches the Bhardwaj 2024 anchor (p=0.30, d=0.05 -> 323)", {
  res <- calculate("singleProportion", p = 0.30, precision = 0.05)
  expect_s3_class(res, "sample_size_result")
  # (1.96^2 * 0.3 * 0.7) / 0.05^2 = 322.69 -> 323
  expect_identical(res$n_required, 323L)
  expect_identical(res$results$total_n, 323L)
})

test_that("singleProportion relative precision variant", {
  # epsilon = 0.10 of p = 0.30 -> d = 0.03: n = (1.96^2*0.21)/0.0009 = 896.4 -> 897
  res <- calculate("singleProportion", p = 0.30, precision = 0.10, precision_type = "relative")
  expect_identical(res$n_required, 897L)
})

test_that("singleProportion warns via hints for extreme prevalence conventions", {
  res_low <- calculate("singleProportion", p = 0.05, precision = 0.025)
  expect_match(res_low$hints, "half the prevalence")
  res_high <- calculate("singleProportion", p = 0.95, precision = 0.025)
  expect_match(res_high$hints, "0.5\\*\\(1-p\\)")
  res_mid <- calculate("singleProportion", p = 0.30, precision = 0.05)
  expect_length(res_mid$hints, 0)
})

test_that("singleProportion rejects invalid inputs", {
  expect_snapshot(error = TRUE, calculate("singleProportion", p = 1.2, precision = 0.05))
  expect_snapshot(error = TRUE, calculate("singleProportion", p = 0.3, precision = 0))
  # precision larger than 1-p*... nonsense is caught by formula, but negative errors
  expect_snapshot(error = TRUE, calculate("singleProportion", p = 0.3, precision = -0.1))
})

test_that("singleMean computes Z^2*sigma^2/d^2", {
  # sigma=10, d=2, alpha=0.05: (1.959964*10/2)^2 = 96.04 -> 97
  res <- calculate("singleMean", sigma = 10, precision = 2)
  expect_identical(res$n_required, 97L)
})

test_that("singleCorrelation matches the Machin Ch.19 formula", {
  # r = 0.5, epsilon = 0.10: ((1+0.25)/(0.5*0.1))^2 + 3 = 25^2+3 = 628
  res <- calculate("singleCorrelation", r = 0.5, epsilon = 0.10)
  expect_identical(res$n_required, 628L)
})

test_that("estimation designs carry roles and axis metadata", {
  res <- calculate("singleProportion", p = 0.3, precision = 0.05)
  expect_identical(res$design_canonical, "singleProportion")
  expect_identical(res$task, "estimate")
  expect_identical(res$outcome, "proportion")
  expect_true(length(res$roles) >= 2)
  expect_match(res$roles[1], "expected proportion")
  validate_sample_size_result(res)
})

test_that("estimation designs route through the same dispatcher", {
  # task/outcome omitted: default resolution
  res1 <- calculate("singleMean", sigma = 10, precision = 2)
  res2 <- calculate("singleMean", "estimate", "mean", sigma = 10, precision = 2)
  expect_identical(res1$n_required, res2$n_required)
})
