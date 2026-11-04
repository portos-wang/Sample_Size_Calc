test_that("z_alpha handles one- and two-sided alternatives", {
  expect_equal(z_alpha(0.05, "two.sided"), 1.959964, tolerance = 1e-6)
  expect_equal(z_alpha(0.05, "one.sided"), 1.644854, tolerance = 1e-6)
  expect_equal(z_alpha(0.10, "two.sided"), z_alpha(0.05, "one.sided"))
})

test_that("z_power matches known quantiles", {
  expect_equal(z_power(0.8), 0.8416212, tolerance = 1e-6)
  expect_equal(z_power(0.9), 1.2815516, tolerance = 1e-6)
})

test_that("inflate_n implements n/(1-d) with ceiling", {
  expect_equal(inflate_n(322.69), 323)
  # Bhardwaj 2024 states n/(1-d): 323/0.9 = 358.9 -> 359. The paper's own
  # worked example instead adds 10% (323+32=355); the discrepancy is
  # documented in inst/reference/NUMERIC_ANCHORS.md. We follow the stated formula.
  expect_equal(inflate_n(323, dropout = 0.10), 359)
  expect_equal(inflate_n(100, 0), 100)
  expect_equal(inflate_n(100, 0.5), 200)
})

test_that("inflate_n rejects invalid dropout", {
  expect_snapshot(error = TRUE, inflate_n(100, dropout = 1))
  expect_snapshot(error = TRUE, inflate_n(100, dropout = -0.1))
  expect_snapshot(error = TRUE, inflate_n(100, dropout = "10%"))
})

test_that("design_effect computes 1 + (m-1)*ICC", {
  # Machin & Campbell Ch.12 canonical example: m=20, ICC=0.05 -> 1.95
  expect_equal(design_effect(20, 0.05), 1.95, tolerance = 1e-12)
  expect_equal(design_effect(1, 0.3), 1)
})

test_that("design_effect rejects invalid inputs", {
  expect_snapshot(error = TRUE, design_effect(0, 0.05))
  expect_snapshot(error = TRUE, design_effect(20, 1))
  expect_snapshot(error = TRUE, design_effect(20, -0.1))
})

test_that("as_sample_size_result wraps calculate-style lists", {
  calc <- list(
    design_type = "Test design",
    n_per_group = 37L,
    total_n = 74L,
    parameters = list(sd = 3),
    formula = "n = ...",
    formula_latex = "$$n$$",
    reference = "Someone (2020).",
    roles = c("sd = common SD"),
    adjustments = list(dropout = 0)
  )
  res <- as_sample_size_result("rct", "test", "mean", calc)
  expect_s3_class(res, "sample_size_result")
  expect_identical(res$n_per_group, 37L)
  expect_identical(res$results$n_1, 37L)
  expect_identical(res$reference, "Someone (2020).")
  expect_identical(res$roles, c("sd = common SD"))
  validate_sample_size_result(res)
})
