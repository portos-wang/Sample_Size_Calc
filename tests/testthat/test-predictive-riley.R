# 3.1: prediction model sample size (Riley 2020, BMJ m441).
# Anchors from the paper's own figures/boxes and the pmsampsize worked examples.

test_that("B3 shrinkage criterion matches pmsampsize example exactly (5249)", {
  # prev=0.05, P=30, R2cs=0.05, S=0.9 -> 5249 (263 events, EPP 8.75)
  res <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.05,
    n_parameters = 30,
    r2_cs = 0.05
  )
  expect_identical(res$n_required, 5249L)
  expect_identical(res$events_required, 263L)
  expect_equal(res$epp, 8.75, tolerance = 0.01)
  # driven by B3, not B1:
  expect_match(res$hints[2], "B3")
})

test_that("B3 matches the Fig 3 worked example (P=20, R2cs=0.1 -> 1698)", {
  res <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.1,
    n_parameters = 20,
    r2_cs = 0.1
  )
  # exact: 1698.037 -> ceiling 1699; the book truncates to 1698 (±1 documented)
  expect_equal(res$n_required, 1699)
  expect_equal(res$epp, 8.5, tolerance = 0.01)
})

test_that("max R2cs entropy formula matches the paper (0.05 -> 0.33)", {
  expect_equal(max_r2cs_binary(0.05), 0.3277, tolerance = 0.001)
})

test_that("B2 MAPE formula matches Fig 2 example (461)", {
  phi <- 0.3
  n_b2 <- exp((-0.508 + 0.259 * log(phi) + 0.504 * log(10) - log(0.05)) / 0.544)
  expect_equal(n_b2, 460.9, tolerance = 0.1)
})

test_that("B4 optimism can require more participants than B3", {
  result <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.05,
    n_parameters = 10,
    r2_cs = 0.2,
    shrinkage = 0.9
  )

  # pmsampsize 1.1.3: B1=73, B3=398, B4=542 for these inputs.
  expect_identical(result$n_required, 542L)
  expect_equal(result$results$criterion_n, c(B1 = 73, B3 = 398, B4 = 542))
  expect_match(
    paste(result$hints, collapse = " "),
    "max(B1, B3, B4)",
    fixed = TRUE
  )
})

test_that("B1 precision can determine the Riley sample size", {
  result <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.5,
    n_parameters = 1,
    r2_cs = 0.3
  )

  expect_identical(result$n_required, 385L)
  expect_equal(result$results$criterion_n[["B1"]], result$n_required)
})

test_that("Riley criteria agree with the pmsampsize implementation", {
  skip_if_not_installed("pmsampsize")
  reference <- pmsampsize::pmsampsize(
    type = "b",
    csrsquared = 0.2,
    parameters = 10,
    prevalence = 0.05,
    shrinkage = 0.9
  )
  result <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.05,
    n_parameters = 10,
    r2_cs = 0.2,
    shrinkage = 0.9
  )

  expect_equal(result$n_required, reference$sample_size)
  expect_equal(
    unname(result$results$criterion_n),
    unname(reference$results_table[c(3, 1, 2), "Samp_size"])
  )
  expect_equal(result$epp, reference$EPP)
})

test_that("MAPE is reported without constraining the Riley sample size", {
  result <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.3,
    n_parameters = 10,
    r2_cs = 0.2,
    mape = 0.01
  )

  expect_identical(result$n_required, 398L)
  expect_equal(result$results$mape_n, 8881)
  expect_match(
    paste(result$roles, collapse = " "),
    "informational B2",
    fixed = TRUE
  )
})

test_that("Riley rejects a shrinkage target below the anticipated R-squared", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "predictiveModel",
      "plan",
      "binary",
      prev = 0.3,
      n_parameters = 10,
      r2_cs = 0.2,
      shrinkage = 0.1
    )
  )
})

test_that("Riley rejects an impossible MAPE target", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "predictiveModel",
      "plan",
      "binary",
      prev = 0.3,
      n_parameters = 10,
      r2_cs = 0.2,
      mape = 0
    )
  )
})

test_that("Riley rejects MAPE when its informational formula is unavailable", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "predictiveModel",
      "plan",
      "binary",
      prev = 0.3,
      n_parameters = 31,
      r2_cs = 0.2,
      mape = 0.05
    )
  )
})

test_that("T1 person-years matches the Fig 1 worked example (2366)", {
  res <- calculate(
    "predictiveModel",
    "plan",
    "rate",
    rate = 0.10,
    timepoint = 10,
    precision_delta = 0.05
  )
  # exact search: smallest T with both CI margins <= 0.05
  f_t <- 1 - exp(-0.1 * 10)
  expect_gte(res$person_time_required, 2300)
  expect_lte(res$person_time_required, 2450)
  # guarantee holds at the returned T:
  z <- qnorm(0.975)
  lam_hi <- 0.1 + z * sqrt(0.1 / res$person_time_required)
  lam_lo <- 0.1 - z * sqrt(0.1 / res$person_time_required)
  expect_lte((1 - exp(-lam_hi * 10)) - f_t, 0.05)
  expect_lte(f_t - (1 - exp(-lam_lo * 10)), 0.05)
})

test_that("r2_cs above the entropy max errors informatively", {
  expect_error(
    calculate(
      "predictiveModel",
      "plan",
      "binary",
      prev = 0.05,
      n_parameters = 30,
      r2_cs = 0.5
    ),
    class = "rlang_error"
  )
})
