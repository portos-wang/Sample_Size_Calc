# Phase 5: complex designs. Anchors: docs/NUMERIC_ANCHORS.md Phase 5 section.

# --- clusterRCT ---

test_that("clusterRCT applies DE = 1+(m-1)*ICC with cluster-level rounding", {
  # twoMeans base 37/group; m=20, ICC=0.05 -> DE=1.95
  # clusters = ceil(37*1.95/20) = ceil(3.6075) = 4 -> 80 individuals/group
  res <- calculate("clusterRCT", "test", "mean",
    mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20
  )
  expect_identical(res$n_per_group, 80L)
  expect_identical(res$n_clusters, 4L)
  expect_equal(res$parameters$design_effect, 1.95)
  expect_identical(res$total_n, 160L)
})

test_that("clusterRCT works for proportions", {
  res <- calculate("clusterRCT", "test", "proportion",
    p1 = 0.3, p2 = 0.5, icc = 0.01, cluster_size = 10
  )
  # twoProportions base 93/group; DE = 1+9*0.01 = 1.09
  # clusters = ceil(93*1.09/10) = ceil(10.137) = 11 -> 110/group
  expect_identical(res$n_clusters, 11L)
  expect_identical(res$n_per_group, 110L)
})

# --- singleArmPhaseII ---

test_that("Simon optimal matches the Machin Example 17.2 anchor (1/10, 5/29)", {
  res <- calculate("singleArmPhaseII", "test", "proportion",
    p0 = 0.1, p1 = 0.3, optimizer = "optimal"
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
  res <- calculate("singleArmPhaseII", "test", "proportion",
    p0 = 0.1, p1 = 0.3, optimizer = "minimax"
  )
  expect_identical(res$n_total, 25L)
  expect_identical(res$r_total, 5L)
})

test_that("Simon design constraints hold exactly for (0.2, 0.4, 0.05, 0.90)", {
  res <- calculate("singleArmPhaseII", "test", "proportion",
    p0 = 0.2, p1 = 0.4, power = 0.90, optimizer = "optimal"
  )
  p_eff0 <- simon_power(
    0.2, res$n_stage_1, res$n_total - res$n_stage_1,
    res$r_stage_1, res$r_total
  )
  p_eff1 <- simon_power(
    0.4, res$n_stage_1, res$n_total - res$n_stage_1,
    res$r_stage_1, res$r_total
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
  res <- calculate("rct", "noninferiority", "proportion",
    p1 = 0.90, p2 = 0.85, margin = 0.05
  )
  expect_identical(res$n_per_group, 135L)
  expect_match(res$design_type, "Non-inferiority")
})

# --- twoOrdinal (Whitehead) ---

test_that("twoOrdinal matches the Whitehead formula transparently", {
  # or=1.5, prop_bar=c(.2,.3,.3,.2): sum p^3 = 0.07
  # N = 3*(1.96+0.8416)^2/(log(1.5)^2*0.93) = 3*7.849/(0.1644*0.93) = 154.1
  res <- calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.3, 0.3, 0.2))
  expect_equal(res$total_n, 155)
  expect_identical(res$n_per_group, 78L)
})

test_that("twoOrdinal rejects proportions not summing to 1", {
  expect_snapshot(error = TRUE, calculate("twoOrdinal", "test", "ordinal",
    or = 1.5, prop_bar = c(0.2, 0.3)
  ))
})

# --- predictive EPV ---

test_that("predictive EPV rule computes events and subjects", {
  res <- calculate("predictiveModel", "plan", "events",
    n_parameters = 10, event_prevalence = 0.2
  )
  expect_identical(res$events_required, 100L)
  expect_identical(res$n_required, 500L)
  expect_match(res$hints[1], "Riley")
})

# --- its (experimental) ---

test_that("its computes AR(1)-adjusted power transparently", {
  res <- calculate("its", "test", "rate",
    effect_sd = 1.0, n_pre = 12, n_post = 12, rho = 0.3
  )
  n_eff <- 12 * 0.7 / 1.3 # 6.4615
  se <- sqrt(2 / n_eff)
  expected_power <- pnorm(1.0 / se - qnorm(0.975))
  expect_equal(res$power_achieved, round(expected_power, 3))
  expect_match(res$hints[1], "EXPERIMENTAL")
})

test_that("its warns when segments are below the >=8 rule of thumb", {
  res <- calculate("its", "test", "rate",
    effect_sd = 2, n_pre = 5, n_post = 5, rho = 0
  )
  expect_match(res$hints[length(res$hints)], "below the >= 8 rule")
})
