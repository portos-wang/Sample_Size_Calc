# 3.1: stepped wedge (Hussey & Hughes 2007, Eq 8).
# Anchor: H&H Washington EPT example - I=24 counties, T=5 (baseline + 4
# steps of 6), m=100, p=0.05, CV=0.3. Eq 8 (p. 187) gives power 0.774 at
# RR=0.64, which matches the paper's own "about 80% power to detect a
# decrease in prevalence of roughly 36% (from 0.05 to 0.032)".

test_that("steppedWedge reproduces the H&H EPT design structure", {
  res <- calculate("steppedWedge", "test", "proportion",
    theta = 0.05 * (0.64 - 1), # -0.018 (RR=0.64)
    tau2 = (0.3 * 0.05)^2,
    sigma2_ind = 0.05 * 0.95,
    m = 100,
    n_clusters = 24,
    clusters_per_step = 6
  )
  expect_s3_class(res, "sample_size_result")
  expect_identical(res$n_clusters, 24L)
  expect_identical(res$n_time_points, 5L)
  # Eq 8 with sigma^2 = 0.0475/100 and tau^2 = 2.25e-4:
  #   Var = 4.405e-5, SE = 0.006638, power = 0.774
  expect_equal(res$results$se_theta, 0.006638, tolerance = 1e-5)
  expect_equal(res$power_achieved, 0.774, tolerance = 0.002)
})

test_that("steppedWedge follows Eq 8 exactly (printed-formula cross-check)", {
  # Independent evaluation of the printed Eq 8, with no package code.
  eq8 <- function(theta, tau2, sigma2, m, I, cps, alpha = 0.05) {
    s2 <- sigma2 / m
    T <- I / cps + 1
    X <- matrix(0, I, T)
    idx <- 1
    for (t in 2:T) {
      X[idx:(idx + cps - 1), t:T] <- 1
      idx <- idx + cps
    }
    U <- sum(X); W <- sum(colSums(X)^2); V <- sum(rowSums(X)^2)
    var <- I * s2 * (s2 + T * tau2) /
      ((I * U - W) * s2 + (U^2 + I * T * U - T * W - I * V) * tau2)
    c(se = sqrt(var), power = pnorm(abs(theta) / sqrt(var) - qnorm(1 - alpha / 2)))
  }
  for (rr in c(0.60, 0.64, 0.70, 0.75)) {
    th <- 0.05 * (rr - 1)
    ref <- eq8(th, (0.3 * 0.05)^2, 0.05 * 0.95, 100, 24, 6)
    res <- calculate("steppedWedge", "test", "proportion",
      theta = th, tau2 = (0.3 * 0.05)^2, sigma2_ind = 0.05 * 0.95,
      m = 100, n_clusters = 24, clusters_per_step = 6
    )
    expect_equal(res$power_achieved, round(ref[["power"]], 3), tolerance = 1e-3)
  }
})

test_that("steppedWedge power decreases with fewer clusters", {
  p24 <- calculate("steppedWedge", "test", "mean",
    theta = -0.1, tau2 = 0.01, sigma2_ind = 1, m = 20,
    n_clusters = 24, clusters_per_step = 4
  )$power_achieved
  p12 <- calculate("steppedWedge", "test", "mean",
    theta = -0.1, tau2 = 0.01, sigma2_ind = 1, m = 20,
    n_clusters = 12, clusters_per_step = 2
  )$power_achieved
  expect_gt(p24, p12)
})

test_that("steppedWedge rejects zero theta and invalid cluster allocation", {
  expect_snapshot(error = TRUE, calculate("steppedWedge", "test", "mean",
    theta = 0, tau2 = 0.01, sigma2_ind = 1, m = 20,
    n_clusters = 24, clusters_per_step = 4
  ))
  expect_snapshot(error = TRUE, calculate("steppedWedge", "test", "mean",
    theta = -0.1, tau2 = 0.01, sigma2_ind = 1, m = 20,
    n_clusters = 25, clusters_per_step = 4
  ))
})
