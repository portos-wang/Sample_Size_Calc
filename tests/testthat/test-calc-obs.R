test_that("cohort rate planning preserves protective exposures and reaches target power", {
  result <- calculate(
    "cohort",
    "test",
    "rate",
    rate0 = 0.2,
    rate1 = 0.1,
    ratio = 4
  )
  expect_equal(result$parameters$rate0, 0.2)
  expect_equal(result$parameters$rate1, 0.1)
  expect_identical(result$person_time_unexposed, 177L)
  expect_identical(result$person_time_exposed, 707L)
  se <- sqrt(
    0.2 / result$person_time_unexposed + 0.1 / result$person_time_exposed
  )
  expect_gte(pnorm(0.1 / se - qnorm(0.975)), 0.8)
})

test_that("unequal cohort groups have distinct canonical counts", {
  result <- calculate("cohort", p0 = 0.2, p1 = 0.3, ratio = 4)
  expect_identical(result$results$n_1, 177L)
  expect_identical(result$results$n_2, 707L)
  expect_identical(result$results$total_n, 884L)
})

test_that("fractional case-control ratios still give an integer total", {
  result <- calculate("caseControl", p0 = 0.3, OR = 2, m = 1.5)
  expect_equal(result$cases_needed, 117)
  expect_equal(result$controls_needed, 175)
  expect_equal(result$total_subjects, 292)
  expect_equal(
    result$total_subjects,
    result$cases_needed + result$controls_needed
  )
})

# Phase 3: observational designs + paired binary + single-arm.
# Anchors: inst/reference/NUMERIC_ANCHORS.md B3/B4/B8.

# --- cohort (proportion) ---

test_that("cohort matches the Bhardwaj p.2559 anchor (±1 rounding artifact)", {
  # Paper (rounded z: 1.96/0.84): 292.82 -> 293; exact quantiles: 293.16 -> 294.
  # We assert the transparent-formula value; ±1 documented in NUMERIC_ANCHORS.md.
  res <- calculate("cohort", "test", "proportion", p0 = 0.20, p1 = 0.30)
  expect_identical(res$n_per_group, 294L)
  expect_identical(res$n_exposed, 294L)
  expect_identical(res$n_unexposed, 294L)
  expect_identical(res$total_n, 588L)
})

test_that("cohort dropout adjustment is recorded and applied", {
  res <- calculate(
    "cohort",
    "test",
    "proportion",
    p0 = 0.20,
    p1 = 0.30,
    dropout = 0.10
  )
  # canonical inflate: ceil(294/0.9) = 327 (paper's additive arithmetic: 322)
  expect_identical(res$n_per_group, 327L)
  expect_identical(res$adjustments$dropout, 0.10)
})

test_that("cohort 1:2 allocation roughly doubles the unexposed arm", {
  res <- calculate(
    "cohort",
    "test",
    "proportion",
    p0 = 0.20,
    p1 = 0.30,
    ratio = 2
  )
  expect_identical(res$n_unexposed, res$n_exposed * 2L)
})

test_that("cohort rejects invalid inputs", {
  expect_snapshot(
    error = TRUE,
    calculate("cohort", "test", "proportion", p0 = 0.3, p1 = 0.3)
  )
  expect_snapshot(
    error = TRUE,
    calculate("cohort", "test", "proportion", p0 = 0.2, p1 = 0.3, ratio = 0.5)
  )
})

# --- cohort (rate) ---

test_that("cohortRate computes person-time transparently", {
  # T0 = (1.96+0.8416)^2 * (0.2+0.1)/0.01 = 7.849*30 = 235.5 -> 236; T1 = 236
  res <- calculate("cohort", "test", "rate", rate0 = 0.10, rate1 = 0.20)
  expect_identical(res$person_time_unexposed, 236L)
  expect_identical(res$person_time_exposed, 236L)
  expect_gt(res$expected_events, 0)
})

test_that("cohortRate unequal allocation shifts person-time to unexposed", {
  res <- calculate(
    "cohort",
    "test",
    "rate",
    rate0 = 0.10,
    rate1 = 0.20,
    ratio = 2
  )
  expect_identical(res$person_time_exposed, res$person_time_unexposed * 2L)
})

# --- caseControlMatched ---

test_that("caseControlMatched derives discordance and returns pairs", {
  # p0=0.3, OR=2: p1 = 2*0.3/(0.7+0.6) = 0.4615
  # pi10 = 0.4615*0.7 = 0.3231; pi01 = 0.3*0.5385 = 0.1615
  # psi = 0.4846; delta = 0.1615
  # n = (1.96*sqrt(0.4846) + 0.8416*sqrt(0.4846-0.0261))^2/0.0261
  #   = (1.3653 + 0.5681)^2/0.0261 = 3.7384/0.0261 = 143.2 -> 144
  res <- calculate("caseControlMatched", "test", "proportion", p0 = 0.3, OR = 2)
  expect_identical(res$n_pairs, 144L)
  expect_equal(res$parameters$expected_p1, 0.4615385, tolerance = 1e-6)
  expect_identical(res$cases_needed, res$controls_needed)
})

test_that("caseControlMatched rejects OR=1 and invalid p0", {
  expect_snapshot(
    error = TRUE,
    calculate("caseControlMatched", "test", "proportion", p0 = 0.3, OR = 1)
  )
  expect_snapshot(
    error = TRUE,
    calculate("caseControlMatched", "test", "proportion", p0 = 1.2, OR = 2)
  )
})

# --- crosstab ---

test_that("crosstab association reuses the two-proportion kernel with prevalence roles", {
  res <- calculate("crosstab", "test", "proportion", p0 = 0.20, p1 = 0.30)
  expect_identical(res$n_per_group, 294L) # same kernel as cohort at ratio 1
  expect_match(res$roles[3], "prevalence ratio")
  expect_match(res$design_type, "Cross-sectional")
})

# --- paired proportions ---

test_that("pairedProportions matches the Connor formula at Akoglu Table 6A minimum", {
  # psi = delta = 0.05 (minimum discordance), 80% power:
  # n = (1.96*sqrt(0.05) + 0.8416*sqrt(0.05-0.0025))^2/0.0025 = 154.5 -> 155
  res <- calculate(
    "paired",
    "test",
    "proportion",
    p1 = 0.35,
    p2 = 0.30,
    psi = 0.05
  )
  expect_identical(res$pairs_count, 155L)
  # Akoglu Table 6A reports 159 with Yates CC (uncorrected base 155)
})

test_that("pairedProportions output is in pairs", {
  res <- calculate(
    "paired",
    "test",
    "proportion",
    p1 = 0.4,
    p2 = 0.3,
    psi = 0.2
  )
  expect_identical(res$total_n, res$pairs_count)
  expect_identical(res$n_measurements, res$pairs_count * 2L)
  expect_match(paste(res$roles, collapse = " "), "PAIRS")
})

test_that("pairedProportions rejects psi smaller than the difference", {
  expect_snapshot(
    error = TRUE,
    calculate("paired", "test", "proportion", p1 = 0.4, p2 = 0.2, psi = 0.1)
  )
})

# --- rctSingleArm ---

test_that("singleArmProportion matches the Hajian-Tilaki Eq 6.8 anchor (153)", {
  res <- calculate("rctSingleArm", "test", "proportion", p0 = 0.70, p1 = 0.80)
  expect_identical(res$n_required, 153L)
})

test_that("singleArmMean computes the single-sample formula", {
  # (1.96+0.8416)^2 * 100 / 4 = 7.849*25 = 196.2 -> 197
  res <- calculate("rctSingleArm", "test", "mean", mu0 = 0, mu1 = 2, sigma = 10)
  expect_identical(res$n_required, 197L)
})

test_that("single-arm designs reject equal proportions/means", {
  expect_snapshot(
    error = TRUE,
    calculate("rctSingleArm", "test", "proportion", p0 = 0.5, p1 = 0.5)
  )
  expect_snapshot(
    error = TRUE,
    calculate("rctSingleArm", "test", "mean", mu0 = 1, mu1 = 1, sigma = 1)
  )
})
