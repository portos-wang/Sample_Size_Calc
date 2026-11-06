test_that("invalid ICC values cannot produce negative recruitment", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "clusterRCT",
      mean1 = 10,
      mean2 = 12,
      sd = 3,
      icc = -0.5,
      cluster_size = 20
    )
  )
})

test_that("diagnostic probabilities must be between zero and one", {
  expect_snapshot(error = TRUE, calculate("diagAccuracy", prob = 1.2, d = 0.05))
})

test_that("kappa values must be compatible with rater marginals", {
  expect_snapshot(
    error = TRUE,
    calculate("kappa", pi1 = 0.1, pi2 = 0.9, kappa = 0.8, d = 0.1)
  )
})

test_that("missing alpha is rejected with an argument-specific error", {
  expect_snapshot(
    error = TRUE,
    calculate("rct", mean1 = 10, mean2 = 12, sd = 3, alpha = NA_real_)
  )
})

test_that("NaN power is rejected before numerical calculation", {
  expect_snapshot(
    error = TRUE,
    calculate("rct", mean1 = 10, mean2 = 12, sd = 3, power = NaN)
  )
})

test_that("infinite standard deviations cannot produce a sample size", {
  expect_snapshot(
    error = TRUE,
    sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = Inf)
  )
})

test_that("vector allocation ratios are rejected as non-scalar inputs", {
  expect_snapshot(
    error = TRUE,
    calculate("diagAUC", auc = 0.8, d = 0.05, ratio = c(1, 4))
  )
})

test_that("non-finite ordinal proportions are rejected explicitly", {
  expect_snapshot(
    error = TRUE,
    calculate("twoOrdinal", or = 2, prop_bar = c(0.5, NA_real_))
  )
})

test_that("screening rejects non-finite prevalence before searching", {
  expect_snapshot(error = TRUE, screen_required(196, prevalence = NaN))
})

test_that("MRMC rejects missing covariance components before evaluating power", {
  expect_snapshot(
    error = TRUE,
    mrmc_power(
      n = 50,
      J = 8,
      delta = 0.1,
      sigma_b2 = NA_real_,
      sigma_w2 = 0.00087,
      sigma_c2 = 0.00196,
      rho1 = 0.5,
      rho2 = 0.3,
      rho3 = 0.25
    )
  )
})

test_that("unsupported dropout is rejected instead of ignored", {
  expect_snapshot(
    error = TRUE,
    calculate("rct", mean1 = 10, mean2 = 12, sd = 3, dropout = 0.2)
  )
})

test_that("misspelled arguments are rejected by both entry points", {
  expect_snapshot(
    error = TRUE,
    sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3, sdd = 4)
  )
})

test_that("unused test alternatives are rejected", {
  expect_snapshot(
    error = TRUE,
    calculate("rct", mean1 = 10, mean2 = 12, sd = 3, alternative = "one.sided")
  )
})

test_that("parameters for inactive diagnostic branches are rejected", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "diagAccuracyCompare",
      p1 = 0.85,
      p2 = 0.75,
      paired = FALSE,
      psi = 0.2
    )
  )
})

test_that("numeric arguments require names", {
  expect_snapshot(
    error = TRUE,
    calculate("rct", 10, mean1 = 10, mean2 = 12, sd = 3)
  )
})

test_that("duplicate numeric arguments cannot be silently selected", {
  expect_snapshot(
    error = TRUE,
    calculate("rct", mean1 = 10, mean2 = 12, sd = 3, sd = 4)
  )
})

test_that("supported dropout still inflates the cohort sample size", {
  result <- calculate("cohort", p0 = 0.2, p1 = 0.3, dropout = 0.2)

  expect_identical(result$n_per_group, 368L)
  expect_identical(result$total_n, 736L)
})
