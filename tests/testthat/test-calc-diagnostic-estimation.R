test_that("dual endpoint recruitment covers cases and controls at high prevalence", {
  result <- calculate(
    "diagAccuracy",
    "test",
    "proportion",
    prob = 0.9,
    p0 = 0.8,
    prob_spec = 0.85,
    p0_spec = 0.75,
    dual = TRUE,
    prevalence = 0.9
  )
  expect_identical(result$cases_needed, 109L)
  expect_identical(result$controls_needed, 137L)
  expect_identical(result$total_subjects_to_screen, 1370L)
  expect_gte(0.9 * result$total_subjects_to_screen, result$cases_needed)
  expect_lte(
    result$controls_needed - (1 - 0.9) * result$total_subjects_to_screen,
    1e-10
  )
})

test_that("dual endpoint quotas can be recruited separately", {
  result <- calculate(
    "diagAccuracy",
    "test",
    "proportion",
    prob = 0.9,
    p0 = 0.8,
    prob_spec = 0.85,
    p0_spec = 0.75,
    dual = TRUE
  )
  expect_identical(result$total_subjects, 246L)
  expect_null(result$total_subjects_to_screen)
})

test_that("an extreme dual-endpoint prevalence aborts instead of overflowing", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "diagAccuracy",
      "test",
      "proportion",
      prob = 0.9,
      p0 = 0.7,
      dual = TRUE,
      prob_spec = 0.9,
      p0_spec = 0.7,
      prevalence = 1e-12
    )
  )
})

test_that("negative LR confidence-limit planning reaches its requested upper bound", {
  result <- calculate(
    "diagLR",
    sens = 0.9,
    spec = 0.5,
    target_lr = 0.4,
    lr_type = "negative"
  )
  expect_identical(result$cases_needed, 80L)
  upper <- 0.2 * exp(qnorm(0.975) * sqrt(10 / result$cases_needed))
  expect_lte(upper, 0.4)
  expect_gt(0.2 * exp(qnorm(0.975) * sqrt(10 / (result$cases_needed - 1))), 0.4)
  expect_equal(result$results$ci_limit, upper)
})

test_that("an impossible negative LR upper bound is rejected", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "diagLR",
      sens = 0.9,
      spec = 0.5,
      target_lr = 0.1,
      lr_type = "negative"
    )
  )
})

test_that("an impossible positive LR lower bound is rejected", {
  expect_snapshot(
    error = TRUE,
    calculate(
      "diagLR",
      sens = 0.8,
      spec = 0.7,
      target_lr = 5,
      lr_type = "positive"
    )
  )
})

# Phase 2 diagnostic estimation upgrades. Anchors: NUMERIC_ANCHORS.md A3/A4/A5.

# --- A3: diagnosticAccuracy ci_method upgrade (Zhou 6.1/6.2) ---

test_that("diagAccuracy precision method matches Zhou Eq 6.2 SPECT anchor (246)", {
  # Se=0.80, L=0.05, 95% CI -> z=1.96: 1.96^2*0.16/0.0025 = 245.86 -> 246
  res <- calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.80,
    d = 0.05,
    ci_method = "precision"
  )
  expect_identical(res$target_state_cases_needed, 246L)
})

test_that("diagAccuracy ci_width_power matches Zhou Eq 6.1 anchor (502)", {
  # Zhou p.195 uses rounded z (1.96+0.84): 501.76 -> 502. Exact quantiles give
  # 502.33 -> 503; the ±1 difference is a rounding-order artifact, documented
  # in NUMERIC_ANCHORS.md. We assert the transparent-formula value (503) and
  # record the book's rounded-z value.
  res <- calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.80,
    d = 0.05,
    power = 0.80,
    ci_method = "ci_width_power"
  )
  expect_identical(res$target_state_cases_needed, 503L)
})

test_that("diagAccuracy legacy behavior is untouched (golden master)", {
  res <- calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.85,
    d = 0.05,
    prevalence = 0.2
  )
  expect_equal(res$target_state_cases_needed, 196) # legacy path (double)
  expect_null(res$parameters$ci_method)
})

test_that("diagAccuracy prevalence screening conversion still works", {
  # 246 cases at prevalence 0.8 -> ceil(246/0.8) = 308
  res <- calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.80,
    d = 0.05,
    prevalence = 0.8
  )
  expect_equal(res$total_subjects_to_screen, 308)
})

# --- A4: diagAUC var_method upgrade (Zhou 6.4/6.5/6.6) ---

test_that("diagAUC binormal variance matches Zhou CTC anchor (46, V=0.11946)", {
  # Zhou p.198: V(6.5) at A=0.80, R=1 = 0.11946; n=(1.96/0.10)^2*0.11946=45.9 -> 46
  res <- calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.80,
    d = 0.10,
    ratio = 1,
    var_method = "binormal"
  )
  expect_equal(auc_variance(0.80, 1, "binormal"), 0.11946, tolerance = 1e-4)
  expect_identical(res$target_state_cases_needed, 46L)
  expect_identical(res$total_subjects, 92L)
  expect_identical(res$controls_needed, 46L)
  expect_null(res$total_subjects_to_screen)
})

test_that("diagAUC exponential variance gives 38 (V=0.0978, corrected anchor)", {
  # V(6.4) at A=0.80, R=1 = 0.09778 -> n = 37.6 -> 38. The 46 anchor belongs
  # to the binormal variance (see NUMERIC_ANCHORS.md correction note).
  res <- calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.80,
    d = 0.10,
    ratio = 1,
    var_method = "exponential"
  )
  expect_equal(
    auc_variance(0.80, 1, "exponential"),
    0.0977778,
    tolerance = 1e-6
  )
  expect_identical(res$target_state_cases_needed, 38L)
})

test_that("diagAUC conservative bound matches Zhou anchor (62/124)", {
  # V(6.6)=0.16: n=(1.96/0.10)^2*0.16 = 61.5 -> 62 (Zhou p.198)
  res <- calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.80,
    d = 0.10,
    ratio = 1,
    var_method = "conservative"
  )
  expect_identical(res$target_state_cases_needed, 62L)
  expect_identical(res$total_subjects, 124L)
  expect_identical(
    res$total_subjects,
    res$target_state_cases_needed + res$controls_needed
  )
  expect_null(res$total_subjects_to_screen)
})

test_that("diagAUC legacy path uses the Zhou Eq 6.5 binormal variance", {
  # Zhou Eq 6.5 at A=0.80 with R = (1-0.2)/0.2 = 4:
  #   a = qnorm(0.8)*1.414 = 1.19
  #   V = 0.0099*exp(-a^2/2)*([5a^2+8] + [a^2+8]/R) = 0.085022
  #   n = (1.96/0.05)^2 * 0.085022 = 130.6 -> 131
  # The previous implementation used a mis-expanded Eq 6.4 variance
  # (A(1-A) + (1/K)(Q1-A^2) + (Q2-A^2) = 0.23778 -> 366), which both
  # overstated the sample size and divided by K = 0 whenever prevalence was
  # omitted.
  res <- calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.8,
    d = 0.05,
    prevalence = 0.2
  )
  expect_equal(res$parameters$ratio_R, 4)
  expect_equal(res$target_state_cases_needed, 131) # legacy path returns double
  expect_identical(res$total_subjects_to_screen, 655L)
  expect_identical(res$controls_needed, 524L)
})

test_that("diagAUC with prevalence omitted falls back to a 1:1 quota, not Inf", {
  # Historical default prevalence = 1 made R = 0 and every AUC variance term
  # infinite. The fallback uses R = 1 and says so in `hints`.
  res <- calculate("diagAUC", "estimate", "auc", auc = 0.80, d = 0.10)
  expect_true(is.finite(res$target_state_cases_needed))
  expect_identical(res$parameters$ratio_R, 1)
  # Zhou Eq 6.5 at A = 0.80, R = 1 -> V = 0.11946 -> n = 45.9 -> 46
  expect_equal(res$target_state_cases_needed, 46)
  expect_true(any(grepl("fell back to 1", res$hints)))

  res_test <- calculate("diagAUC", "test", "auc", auc = 0.80, auc0 = 0.70)
  expect_true(is.finite(res_test$target_state_cases_needed))

  res_cmp <- calculate(
    "diagAUCCompare",
    "test",
    "auc",
    auc1 = 0.80,
    auc2 = 0.70,
    r = 0.5
  )
  expect_true(is.finite(res_cmp$target_state_cases_needed))
})

test_that("diagAUC superiority reproduces the Zhou p.200 CTC anchor (13 cases)", {
  # Zhou Eq 6.8 with A0 = 0.50, A1 = 0.80, R = 1: V0 = 0.1584, V1 = 0.11946
  #   n = ((1.96*sqrt(0.1584) + 0.84*sqrt(0.11946))/0.30)^2 = 12.74 -> 13
  res <- calculate(
    "diagAUC",
    "test",
    "auc",
    auc = 0.80,
    auc0 = 0.50,
    prevalence = 1
  )
  expect_equal(res$target_state_cases_needed, 13)
})

test_that("AUC allocation works without an explicit variance model", {
  result <- calculate("diagAUC", auc = 0.8, d = 0.05, ratio = 4)
  explicit <- calculate(
    "diagAUC",
    auc = 0.8,
    d = 0.05,
    ratio = 4,
    var_method = "binormal"
  )

  expect_identical(result$results, explicit$results)
  expect_identical(result$target_state_cases_needed, 131L)
  expect_identical(result$controls_needed, 524L)
  expect_identical(result$total_subjects, 655L)
  expect_null(result$total_subjects_to_screen)
})

test_that("AUC prevalence remains active with an explicit variance model", {
  result <- calculate(
    "diagAUC",
    auc = 0.8,
    d = 0.05,
    prevalence = 0.2,
    var_method = "binormal"
  )

  expect_equal(result$parameters$ratio_R, 4)
  expect_identical(result$total_subjects_to_screen, 655L)
  expect_gte(
    result$total_subjects_to_screen * 0.2,
    result$target_state_cases_needed
  )
  expect_gte(result$total_subjects_to_screen * 0.8, result$controls_needed)
})

test_that("AUC allocation supports more cases than controls", {
  result <- calculate("diagAUC", auc = 0.8, d = 0.1, ratio = 0.5)

  expect_equal(result$parameters$ratio_R, 0.5)
  expect_identical(
    result$controls_needed,
    as.integer(ceiling(result$target_state_cases_needed / 2))
  )
  expect_identical(
    result$total_subjects,
    result$target_state_cases_needed + result$controls_needed
  )
})

test_that("AUC sampling assumptions cannot conflict", {
  expect_snapshot(
    error = TRUE,
    calculate("diagAUC", auc = 0.8, d = 0.05, ratio = 4, prevalence = 0.2)
  )
})

test_that("AUC tests use the requested allocation and report integer quotas", {
  result <- calculate(
    "diagAUC",
    "test",
    "auc",
    auc = 0.8,
    auc0 = 0.5,
    ratio = 4
  )

  expect_equal(result$parameters$ratio_R, 4)
  expect_identical(
    result$controls_needed,
    4L * result$target_state_cases_needed
  )
  expect_identical(
    result$total_subjects,
    result$target_state_cases_needed + result$controls_needed
  )
  expect_null(result$total_subjects_to_screen)
})

test_that("AUC comparisons consume the variance model and allocation", {
  result <- calculate(
    "diagAUCCompare",
    "test",
    "auc",
    auc1 = 0.8,
    auc2 = 0.7,
    r = 0.5,
    ratio = 2,
    var_method = "exponential"
  )

  expect_equal(result$parameters$ratio_R, 2)
  expect_identical(result$parameters$var_method, "exponential")
  expect_identical(
    result$controls_needed,
    2L * result$target_state_cases_needed
  )
  expect_identical(
    result$total_subjects,
    result$target_state_cases_needed + result$controls_needed
  )
})

# --- A5: diagLR log-CI rewrite (Hajian-Tilaki 6.4) ---

test_that("negative LR precision reproduces the published 80-per-group example", {
  res <- calculate(
    "diagLR",
    "estimate",
    "lr",
    sens = 0.9,
    spec = 0.5,
    target_lr = 0.4,
    lr_type = "negative"
  )
  expect_identical(res$cases_needed, 80L)
  expect_identical(res$controls_needed, 80L)
  expect_equal(res$total_subjects, 160)
})

test_that("positive LR precision uses the false-positive probability", {
  res <- calculate(
    "diagLR",
    "estimate",
    "lr",
    sens = 0.8,
    spec = 0.7,
    target_lr = 2,
    lr_type = "positive"
  )
  expect_identical(res$cases_needed, 120L)
  expect_identical(res$controls_needed, 120L)
  expect_equal(res$total_subjects, 240)
})

test_that("diagLR legacy path is untouched (golden master)", {
  res <- calculate(
    "diagLR",
    "estimate",
    "lr",
    sens = 0.9,
    spec = 0.8,
    prevalence = 0.3
  )
  expect_null(res$parameters$target_lr)
  expect_false(is.null(res$recommended_cases))
})

test_that("diagLR legacy path no longer returns Inf when prevalence is omitted", {
  # prevalence = 1 (the historical default) used to make the control
  # multiplier P/(1-P) infinite.
  res <- calculate("diagLR", "estimate", "lr", sens = 0.9, spec = 0.5)
  expect_true(is.finite(res$recommended_cases))
  expect_identical(res$parameters$ratio_R, 1)
  expect_true(any(grepl("fell back to 1", res$hints)))
})

test_that("diagLR without target_lr errors informatively", {
  expect_error(
    calculate(
      "diagLR",
      "estimate",
      "lr",
      sens = 0.9,
      spec = 0.8,
      lr_type = "negative"
    ),
    "target_lr"
  )
})

# --- F5: screen_required utility ---

test_that("screen_required matches the Zhou p.196 anchor (350 @ 80%, 90% guarantee)", {
  # Zhou's normal approximation gives 452; exact binomial search gives 451
  # (P(X>=350) at N=451, prev=0.8 already exceeds 0.9). We follow the exact
  # binomial guarantee - the transparent implementation - and document the
  # approximation difference in NUMERIC_ANCHORS.md.
  expect_identical(screen_required(350, 0.8, beta = 0.10), 451L)
  # Exact guarantee check
  expect_lte(pbinom(349, 451, 0.8), 0.10)
  expect_gt(pbinom(349, 450, 0.8), 0.10)
})

test_that("screen_required minimal enrollment guarantee", {
  # 246 cases at prevalence ~1: N=246 satisfies the 0.10-beta guarantee
  # exactly (P(fail) ~= 0), and the minimisation loop makes it minimal.
  N <- screen_required(246, 0.99999)
  expect_identical(N, 246L)
  expect_lte(pbinom(245, N, 0.99999), 0.10)
  # minimality: N-1 must violate the guarantee
  expect_gt(pbinom(245, N - 1L, 0.99999), 0.10)
})

test_that("screen_required rejects invalid inputs", {
  expect_snapshot(error = TRUE, screen_required(0, 0.5))
  expect_snapshot(error = TRUE, screen_required(100, 1.5))
  expect_snapshot(error = TRUE, screen_required(100, 0.5, beta = 0))
})
