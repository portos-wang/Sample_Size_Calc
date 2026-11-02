# Phase 4: diagnostic margins, paired upgrade, crossover/BE, dual endpoint.

# --- diagnosticComparisonTwo paired upgrade (three-axis only) ---

test_that("three-axis paired comparison uses the Connor kernel (psi = discordant rate)", {
  # psi=0.05 = delta=0.05 minimum discordance, 80% power -> 155 (Connor)
  res <- calculate("diagAccuracyCompare", "test", "proportion",
    p1 = 0.90, p2 = 0.85, paired = TRUE, psi = 0.05, prevalence = 0.4
  )
  expect_identical(res$pairs_count, 155L)
  expect_identical(res$parameters$psi_type, "discordant-pair proportion")
  expect_match(res$design_type, "Connor")
})

test_that("legacy paired comparison keeps the old sqrt-scale psi behavior", {
  # Legacy diagnosticComparisonTwo with paired=TRUE and the same psi input
  # uses the old sqrt-scale parameterization -> different (locked) result.
  res <- sample_size_calculator("diagnosticComparisonTwo",
    p1 = 0.90, p2 = 0.85, paired = TRUE, psi = 0.05, prevalence = 0.4
  )
  expect_null(res$parameters$psi_type)
  expect_false(identical(res$pairs_count, 155L))
})

test_that("three-axis unpaired comparison matches legacy (golden master)", {
  old_res <- sample_size_calculator("diagnosticComparisonTwo",
    p1 = 0.85, p2 = 0.75, prevalence = 0.3, paired = FALSE
  )
  new_res <- calculate("diagAccuracyCompare", "test", "proportion",
    p1 = 0.85, p2 = 0.75, prevalence = 0.3, paired = FALSE
  )
  expect_identical(old_res$pairs_count, new_res$pairs_count)
})

# --- diagnostic margins (proportions) ---

test_that("diagCompareNI computes the margin framework transparently", {
  # p1=0.90, p2=0.85, margin=0.05: delta_e = 0.10
  # n = (1.6449+0.8416)^2 * (0.09+0.1275)/0.01 = 6.1826*0.2175/0.01 = 134.5 -> 135
  res <- calculate("diagAccuracyCompare", "noninferiority", "proportion",
    p1 = 0.90, p2 = 0.85, margin = 0.05
  )
  expect_identical(res$n_per_group, 135L)
  expect_match(res$design_type, "non-inferiority")
})

test_that("diagCompareEquiv uses Z_{beta/2} and margin-minus-diff", {
  # p1=0.90, p2=0.88, margin=0.05: delta_e = 0.03; transparent expectation:
  za <- qnorm(0.95)
  zb <- qnorm(0.90) # Z_{beta/2}
  expected <- ceiling((za + zb)^2 * (0.9 * 0.1 + 0.88 * 0.12) / 0.03^2)
  res <- calculate("diagAccuracyCompare", "equivalence", "proportion",
    p1 = 0.90, p2 = 0.88, margin = 0.05
  )
  expect_equal(res$n_per_group, expected)
})

test_that("diagnostic margins reject margin <= |diff| for equivalence", {
  expect_snapshot(error = TRUE, calculate("diagAccuracyCompare", "equivalence", "proportion",
    p1 = 0.90, p2 = 0.88, margin = 0.01
  ))
  expect_snapshot(error = TRUE, calculate("diagAccuracyCompare", "noninferiority", "proportion",
    p1 = 0.80, p2 = 0.85, margin = 0.04
  ))
})

# --- diagnostic margins (AUC) ---

test_that("diagAUCCompareNI computes the AUC margin framework", {
  # auc1=0.85, auc2=0.80, r=0.5, margin=0.05: delta_e = 0.10
  # V(6.4) at A_avg=0.825, R=1: Q1=0.825/1.175=0.70213, Q2=2*0.680625/1.825=0.74589
  # V = 0.70213 + 0.74589 - 0.680625*2 = 0.08677
  # n = 2*(1.6449+0.8416)^2*0.08677*0.5/0.01 = 2*6.1826*0.08677*0.5/0.01 = 53.6 -> 54
  res <- calculate("diagAUCCompare", "noninferiority", "auc",
    auc1 = 0.85, auc2 = 0.80, r = 0.5, margin = 0.05
  )
  expect_identical(res$target_state_cases_needed, 54L)
})

test_that("diagAUCCompareEquiv computes with Z_{beta/2}", {
  # transparent expectation via Zhou Eq 6.4 at A_avg = 0.835, R = 1:
  A_avg <- (0.85 + 0.82) / 2
  Q1 <- A_avg / (2 - A_avg)
  Q2 <- 2 * A_avg^2 / (1 + A_avg)
  V <- Q1 + Q2 - A_avg^2 * 2
  za <- qnorm(0.95)
  zb <- qnorm(0.90)
  expected <- ceiling(2 * (za + zb)^2 * V * 0.5 / (0.05 - 0.03)^2) # delta_e = 0.02
  res <- calculate("diagAUCCompare", "equivalence", "auc",
    auc1 = 0.85, auc2 = 0.82, r = 0.5, margin = 0.05
  )
  expect_equal(res$target_state_cases_needed, expected)
})

# --- crossover / BE ---

test_that("crossoverMean uses 2*sigma_w^2 parameterization", {
  # delta=2, sigma_w=3: n = 2*(1.96+0.8416)^2*9/4 = 2*7.849*9/4 = 35.3 -> 36
  res <- calculate("crossover", "test", "mean", delta = 2, sigma_within = 3)
  expect_identical(res$n_required, 36L)
  expect_identical(res$total_n, 72L) # per sequence x2
})

test_that("bioequivalence CV=25% matches exact TOST (Phillips 1990) and PowerTOST", {
  # CV = 0.25, theta0 = 1.0, 80% power -> n = 12 per sequence, total N = 24
  res <- calculate("bioequivalence", "equivalence", "mean", cv = 0.25)
  expect_identical(res$n_required, 12L)
  expect_identical(res$total_n, 24L)

  # Check with theta0 = 0.95 -> n = 14 per sequence, total N = 28
  res_095 <- calculate("bioequivalence", "equivalence", "mean", cv = 0.25, theta0 = 0.95)
  expect_identical(res_095$n_required, 14L)
  expect_identical(res_095$total_n, 28L)

  if (requireNamespace("PowerTOST", quietly = TRUE)) {
    pt_ref <- PowerTOST::sampleN.TOST(CV = 0.25, theta0 = 1.0, targetpower = 0.8, print = FALSE)
    expect_identical(res$total_n, as.integer(pt_ref[1, "Sample size"]))
    pt_ref_095 <- PowerTOST::sampleN.TOST(CV = 0.25, theta0 = 0.95, targetpower = 0.8, print = FALSE)
    expect_identical(res_095$total_n, as.integer(pt_ref_095[1, "Sample size"]))
  }
})

test_that("bioequivalence warns for high CV (replicate design hint)", {
  res <- calculate("bioequivalence", "equivalence", "mean", cv = 0.40)
  expect_match(res$hints, "replicate")
  res_low <- calculate("bioequivalence", "equivalence", "mean", cv = 0.20)
  expect_length(res_low$hints, 0)
})

# --- dual endpoint ---

test_that("dual endpoint takes the max of Se and Sp requirements at dual_power", {
  res <- calculate("diagAccuracy", "test", "proportion",
    prob = 0.90, p0 = 0.80, prob_spec = 0.85, p0_spec = 0.75,
    prevalence = 0.4, dual = TRUE
  )
  # transparent expectation:
  za <- qnorm(0.95)
  zb <- qnorm(0.90) # dual_power = 0.90
  n_se <- (za * sqrt(0.8 * 0.2) + zb * sqrt(0.9 * 0.1))^2 / 0.1^2
  n_sp <- (za * sqrt(0.75 * 0.25) + zb * sqrt(0.85 * 0.15))^2 / 0.1^2
  expect_equal(res$n_sensitivity, ceiling(n_se))
  expect_equal(res$n_specificity, ceiling(n_sp))
  expect_identical(res$target_state_cases_needed, as.integer(ceiling(max(n_se, n_sp))))
  expect_identical(res$parameters$dual_power, 0.9)
})

test_that("dual endpoint default is off (golden master untouched)", {
  res <- calculate("diagAccuracy", "test", "proportion", prob = 0.9, p0 = 0.8)
  expect_null(res$parameters$dual)
})

test_that("diagAccuracy test supports method='exact' (A'Hern exact binomial)", {
  # prob = 0.85, p0 = 0.70, alpha = 0.05, power = 0.80
  # Asymptotic formula gives 50 cases
  res_asym <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70)
  expect_identical(res_asym$target_state_cases_needed, 50L)

  # Exact method gives 49 cases, critical successes r = 40
  res_exact <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, method = "exact")
  expect_identical(res_exact$target_state_cases_needed, 49L)
  expect_identical(res_exact$critical_successes, 40L)
  expect_true(res_exact$actual_alpha <= 0.05)
  expect_true(res_exact$actual_power >= 0.80)
})
