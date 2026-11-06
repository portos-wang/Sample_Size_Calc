# Phase 5: complex designs. Anchors: inst/reference/NUMERIC_ANCHORS.md Phase 5 section.

# --- clusterRCT ---

test_that("clusterRCT reproduces Machin (2018) Example 12.1 (p. 206)", {
  # delta = 3.5, sigma = 6.94, m = 2, ICC = 0.025, 2-sided alpha = 0.05,
  # power = 0.90, phi = 1.  DE = 1 + (2-1)*0.025 = 1.025 (Eq 12.5).
  # Eq 12.10: N = 1.025 * [4 * (1.96+1.2816)^2/(3.5/6.94)^2 + 1.96^2/2]
  #           = 1.025 * 167.17 = 171.35 -> 172 children, K = 86 (43 per arm).
  res <- calculate(
    "clusterRCT",
    "test",
    "mean",
    mean1 = 12.40,
    mean2 = 15.90,
    sd = 6.94,
    icc = 0.025,
    cluster_size = 2,
    alpha = 0.05,
    power = 0.9
  )
  expect_equal(res$parameters$design_effect, 1.025)
  expect_identical(res$total_n, 172L)
  expect_identical(res$n_clusters, 43L) # per arm; 86 total
  expect_identical(res$n_per_group, 86L)
})

test_that("clusterRCT ICC sensitivity matches the book (rho .1 -> 184, .2 -> 204)", {
  # Machin p. 206: "If the ICC assumed was set as rho = 0.1 or 0.2, then these
  # would increase N to 184 and 204 respectively."
  for (case in list(c(0.025, 172L), c(0.1, 184L), c(0.2, 204L))) {
    res <- calculate(
      "clusterRCT",
      "test",
      "mean",
      mean1 = 12.40,
      mean2 = 15.90,
      sd = 6.94,
      icc = case[1],
      cluster_size = 2,
      alpha = 0.05,
      power = 0.9
    )
    expect_identical(
      res$total_n,
      as.integer(case[2]),
      label = sprintf("ICC = %.3f", case[1])
    )
  }
})

test_that("clusterRCT applies Eq 12.10 (Student t correction) and rounds once", {
  # Eq 12.10 adds z^2/2 to the per-arm term and rounds at the CLUSTER level,
  # not on the individual count. A double rounding would give 44 clusters
  # instead of 43 in Example 12.1.
  eq1210 <- function(delta, sigma, m, rho, alpha = 0.05, power = 0.9) {
    de <- 1 + (m - 1) * rho
    za <- qnorm(1 - alpha / 2)
    zb <- qnorm(power)
    per_arm <- 2 * (za + zb)^2 * sigma^2 / delta^2 / 2
    de * (4 * per_arm + za^2 / 2) / 2
  }
  n_arm <- eq1210(3.5, 6.94, 2, 0.025)
  expect_equal(n_arm, 171.35 / 2, tolerance = 0.02)
  res <- calculate(
    "clusterRCT",
    "test",
    "mean",
    mean1 = 12.40,
    mean2 = 15.90,
    sd = 6.94,
    icc = 0.025,
    cluster_size = 2,
    alpha = 0.05,
    power = 0.9
  )
  expect_identical(res$n_clusters, as.integer(ceiling(n_arm / 2)))
})

test_that("clusterRCT applies DE = 1+(m-1)*ICC with cluster-level rounding", {
  # twoMeans base ~37/group; m=20, ICC=0.05 -> DE=1.95
  res <- calculate(
    "clusterRCT",
    "test",
    "mean",
    mean1 = 10,
    mean2 = 12,
    sd = 3,
    icc = 0.05,
    cluster_size = 20
  )
  expect_identical(res$n_per_group, 80L)
  expect_identical(res$n_clusters, 4L)
  expect_equal(res$parameters$design_effect, 1.95)
  expect_identical(res$total_n, 160L)
})

test_that("clusterRCT works for proportions", {
  res <- calculate(
    "clusterRCT",
    "test",
    "proportion",
    p1 = 0.3,
    p2 = 0.5,
    icc = 0.01,
    cluster_size = 10
  )
  # DE = 1+9*0.01 = 1.09; cluster-level rounding
  expect_identical(res$n_clusters, 11L)
  expect_identical(res$n_per_group, 110L)
  expect_equal(res$parameters$design_effect, 1.09)
})

test_that("cluster_size_inflation supports variable cluster sizes (Eq 12.7)", {
  expect_equal(SampleSizeCalc:::cluster_size_inflation(20, 0.05), 1.95) # Eq 12.5
  # Eq 12.7: DE = 1 + [(CV(m)^2 + 1)*m - 1]*rho
  expect_equal(
    SampleSizeCalc:::cluster_size_inflation(20, 0.05, cv_m = 0.35),
    1 + ((0.35^2 + 1) * 20 - 1) * 0.05
  )
  expect_error(
    SampleSizeCalc:::cluster_size_inflation(20, 0.05, cv_m = -1),
    class = "rlang_error"
  )
})

# --- singleArmPhaseII ---

test_that("Simon optimal matches the Machin Example 17.2 anchor (1/10, 5/29)", {
  res <- calculate(
    "singleArmPhaseII",
    "test",
    "proportion",
    p0 = 0.1,
    p1 = 0.3,
    optimizer = "optimal"
  )
  expect_identical(res$n_stage_1, 10L)
  expect_identical(res$r_stage_1, 1L)
  expect_identical(res$n_total, 29L)
  expect_identical(res$r_total, 5L)
})

test_that("Simon minimax keeps total n=25 (book n; n1 differs under exact power)", {
  # Book reports (2/15, 5/25), whose exact power is 0.7696 < 0.80; under the
  # strict definition our minimax for n=25 is (0/11, 5/25). Documented in
  # NUMERIC_ANCHORS.md.
  res <- calculate(
    "singleArmPhaseII",
    "test",
    "proportion",
    p0 = 0.1,
    p1 = 0.3,
    optimizer = "minimax"
  )
  expect_identical(res$n_total, 25L)
  expect_identical(res$r_total, 5L)
})

test_that("Simon design constraints hold exactly for (0.2, 0.4, 0.05, 0.90)", {
  res <- calculate(
    "singleArmPhaseII",
    "test",
    "proportion",
    p0 = 0.2,
    p1 = 0.4,
    power = 0.90,
    optimizer = "optimal"
  )
  p_eff0 <- simon_power(
    0.2,
    res$n_stage_1,
    res$n_total - res$n_stage_1,
    res$r_stage_1,
    res$r_total
  )
  p_eff1 <- simon_power(
    0.4,
    res$n_stage_1,
    res$n_total - res$n_stage_1,
    res$r_stage_1,
    res$r_total
  )
  expect_lte(p_eff0, 0.05)
  expect_gte(p_eff1, 0.90)
  # Transparent search result (exact-z policy: constraints verified above)
  expect_identical(res$n_total, 54L)
  expect_identical(res$n_stage_1, 19L)
  expect_identical(res$r_stage_1, 4L)
  expect_identical(res$r_total, 15L)
})

test_that("A'Hern matches Machin Table 17.1 anchors", {
  # (0.1, 0.3, a=0.05, 80%): C/N = 6/25 -> r = 5, n = 25
  res1 <- calculate_ahern(0.1, 0.3, 0.05, 0.8)
  expect_identical(res1$n_required, 25L)
  expect_identical(res1$r_total, 5L)
  # (0.2, 0.4, a=0.05, 80%): C/N = 12/35 -> r = 11, n = 35
  res2 <- calculate_ahern(0.2, 0.4, 0.05, 0.8)
  expect_identical(res2$n_required, 35L)
  expect_identical(res2$r_total, 11L)
})

# --- rct non-inferiority proportions ---

test_that("rct NI proportions matches the margin framework", {
  # same kernel as diagCompareNI: p1=0.90, p2=0.85, margin=0.05 -> 135
  res <- calculate(
    "rct",
    "noninferiority",
    "proportion",
    p1 = 0.90,
    p2 = 0.85,
    margin = 0.05
  )
  expect_identical(res$n_per_group, 135L)
  expect_match(res$design_type, "Non-inferiority")
})

# --- twoOrdinal (Whitehead) ---

test_that("twoOrdinal rounds Whitehead's 186.98 to 94 per arm and 188 total", {
  # p. 2261: theta_R = log{0.85(1-0.7) / [0.7(1-0.85)]} = 0.887 is ALREADY the
  # log odds ratio; pi_bar = (0.289, 0.486, 0.153, 0.072); 1 - sum(p^3) = 0.857;
  # 2-sided alpha = 0.05, power = 0.90, A = 1.
  # Eq 10: n = 3(1+1)^2 (1.960 + 1.282)^2 / (0.887^2 * 0.857) = 186.98 -> 187
  res <- calculate(
    "twoOrdinal",
    "test",
    "ordinal",
    or = exp(0.887),
    prop_bar = c(0.289, 0.486, 0.153, 0.072),
    power = 0.9
  )
  expect_identical(res$total_n, 188L)
  expect_identical(res$n_per_group, 94L)
  expect_identical(res$total_n, res$n_standard + res$n_test)
})

test_that("twoOrdinal matches Machin (2018) Example 4.1 (N4 ~ 60-61)", {
  # p. 59: kappa = 4, phi = 1, OR = 3.65, 2-sided alpha = 0.05, power = 0.80.
  # The book reports N4 = 60.09 using the C-and-P averaged proportions
  # (1 - sum p^3 = 0.9351) and N4 = 60.91 using the C proportions alone
  # (1 - sum p^3 = 0.9147); the two variants differ by 0.8. Our package takes
  # the supplied proportions as-is: with the C proportions alone it returns
  # 61.42 -> 62 (the book's 60.91 uses a slightly different rounding chain).
  # Use a +/-1 tolerance against both printed values. The book's averaged
  # proportions (0.2564, 0.2792, 0.2056, 0.2619) are rounded and sum to
  # 1.0031, so normalise before calling.
  avg <- c(0.2564, 0.2792, 0.2056, 0.2619)
  res_avg <- calculate(
    "twoOrdinal",
    "test",
    "ordinal",
    or = 3.65,
    prop_bar = avg / sum(avg),
    power = 0.8
  )
  expect_identical(res_avg$total_n, 62L)
  expect_identical(res_avg$n_standard, 31L)
  expect_identical(res_avg$n_test, 31L)

  res_c <- calculate(
    "twoOrdinal",
    "test",
    "ordinal",
    or = 3.65,
    prop_bar = c(0.14, 0.24, 0.24, 0.38),
    power = 0.8
  )
  expect_identical(res_c$total_n, 62L)
})

test_that("twoOrdinal includes the (1+phi)^2/phi allocation factor", {
  # Machin Eq 4.3 = Gamma (1+phi)^2/phi (z+z)^2/(log OR)^2, which is
  # Whitehead Eq 10 with A = phi. At phi = 1 the factor is 4; the earlier
  # implementation omitted it and returned one quarter of the required size.
  pb <- c(0.14, 0.24, 0.24, 0.38)
  gamma <- 3 / (1 - sum(pb^3))
  z <- qnorm(0.975) + qnorm(0.8)
  for (phi in c(0.5, 1, 2)) {
    expected <- gamma * (1 + phi)^2 / phi * z^2 / (log(3.65))^2
    got <- calculate(
      "twoOrdinal",
      "test",
      "ordinal",
      or = 3.65,
      prop_bar = pb,
      power = 0.8,
      allocation = phi
    )
    expect_gte(got$total_n, ceiling(expected))
    expect_identical(got$total_n, got$n_standard + got$n_test)
    expect_identical(got$results$n_1, got$n_standard)
    expect_identical(got$results$n_2, got$n_test)
  }
})

test_that("twoOrdinal rejects proportions not summing to 1", {
  expect_snapshot(
    error = TRUE,
    calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.3))
  )
})

# --- predictive EPV ---

test_that("predictive EPV rule computes events and subjects", {
  res <- calculate(
    "predictiveModel",
    "plan",
    "events",
    n_parameters = 10,
    event_prevalence = 0.2
  )
  expect_identical(res$events_required, 100L)
  expect_identical(res$n_required, 500L)
  expect_match(res$hints[1], "Riley")
})

# --- its (experimental) ---

test_that("its computes AR(1)-adjusted power transparently", {
  res <- calculate(
    "its",
    "test",
    "rate",
    effect_sd = 1.0,
    n_pre = 12,
    n_post = 12,
    rho = 0.3
  )
  n_eff <- 12 * 0.7 / 1.3 # 6.4615
  se <- sqrt(2 / n_eff)
  expected_power <- pnorm(1.0 / se - qnorm(0.975))
  expect_equal(res$power_achieved, round(expected_power, 3))
  expect_match(res$hints[1], "EXPERIMENTAL")
})

test_that("its warns when segments are below the >=8 rule of thumb", {
  res <- calculate(
    "its",
    "test",
    "rate",
    effect_sd = 2,
    n_pre = 5,
    n_post = 5,
    rho = 0
  )
  expect_match(res$hints[length(res$hints)], "below the >= 8 rule")
})
