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

test_that("singleMean iterates the Student t quantile (Machin Eq 9.18)", {
  # sigma=10, d=2, alpha=0.05: the z start is (1.959964*10/2)^2 = 96.04, but
  # Machin Eq 9.18 requires N = (t_{N-1}*sigma/d)^2, which iterates up to 99.
  res <- calculate("singleMean", sigma = 10, precision = 2)
  expect_identical(res$n_required, 99L)

  # Large-N case: the t correction becomes negligible
  res_big <- calculate("singleMean", sigma = 100, precision = 2)
  expect_identical(res_big$n_required, 9607L)
})

test_that("singleCorrelation matches Machin 2018 Ch.19 Eqs 19.5-19.8 and presize::prec_cor", {
  # r = 0.5, epsilon = 0.10 (d = 0.05, 95% CI width w = 0.10) -> 867 (matches presize exactly)
  res <- calculate("singleCorrelation", r = 0.5, epsilon = 0.10)
  expect_identical(res$n_required, 867L)
  if (requireNamespace("presize", quietly = TRUE)) {
    ref1 <- presize::prec_cor(r = 0.5, conf.width = 0.10, method = "pearson")
    expect_identical(res$n_required, as.integer(ref1$n))
  }

  # r = 0.5, precision = 0.10 (95% CI width w = 0.20) -> matches presize exactly: 219
  res2 <- calculate("singleCorrelation", r = 0.5, precision = 0.10)
  expect_identical(res2$n_required, 219L)
  if (requireNamespace("presize", quietly = TRUE)) {
    ref2 <- presize::prec_cor(r = 0.5, conf.width = 0.20, method = "pearson")
    expect_identical(res2$n_required, as.integer(ref2$n))
  }
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
