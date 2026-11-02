# 3.1: stepped wedge (Hussey & Hughes 2007, Eq 8).
# Anchor: H&H EPT example — transparent Eq-8 computation (the paper's
# "80% at RR~0.64" is a figure reading; at Eq 8, RR=0.64 gives 0.959 and the
# 80% crossing is at RR=0.73; documented in NUMERIC_ANCHORS.md).

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
  expect_equal(res$power_achieved, 0.959, tolerance = 0.002)
})

test_that("steppedWedge 80% power crossing at RR=0.73 (documented anchor)", {
  res <- calculate("steppedWedge", "test", "proportion",
    theta = 0.05 * (0.73 - 1),
    tau2 = (0.3 * 0.05)^2,
    sigma2_ind = 0.05 * 0.95,
    m = 100,
    n_clusters = 24,
    clusters_per_step = 6
  )
  expect_equal(res$power_achieved, 0.80, tolerance = 0.01)
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
