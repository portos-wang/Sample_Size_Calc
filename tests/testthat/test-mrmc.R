test_that("MRMC results follow the common object and display contract", {
  result <- mrmc_power(
    50,
    8,
    0.1,
    0.00123,
    0.00087,
    0.00196,
    0.5,
    0.3,
    0.25,
    rho_b = 0.75
  )
  expect_no_error(validate_sample_size_result(result))
  expect_identical(result$power_achieved, result$power)
  expect_contains(ssr_collect_metrics(result), "power_achieved")
  expect_match(capture_cli(result), "Power achieved")
})

# 3.1 preview: MRMC power (Zhou Eq 6.32, paired-patient paired-reader).

test_that("mrmc_power reproduces the Zhou mammography anchor (0.89)", {
  # Zhou 2011 pp. 221-225: n = 50 malignant + 50 benign patients, J = 8 readers,
  # delta = 0.10, sigma_b2 = 0.00123, sigma_w2 = 0.00087,
  # sigma_c2 = 0.00196 (from Eq 6.5 at n = 50), rho1 = 0.5, rho2 = 0.3,
  # rho3 = 0.25, rho_b = 0.75. Eq 6.32 gives lambda = 14.0672 and power
  # 0.8933; the book reports "89% power".
  res <- mrmc_power(
    n = 50,
    J = 8,
    delta = 0.10,
    sigma_b2 = 0.00123,
    sigma_w2 = 0.00087,
    sigma_c2 = 0.00196,
    rho1 = 0.50,
    rho2 = 0.30,
    rho3 = 0.25,
    rho_b = 0.75
  )
  expect_s3_class(res, "sample_size_result")
  expect_equal(res$power, 0.893, tolerance = 0.005)
  expect_equal(res$parameters$noncentrality_lambda, 14.0672, tolerance = 1e-3)
})

test_that("mrmc_power follows Eq 6.32 exactly (printed-formula cross-check)", {
  # Independent evaluation of the printed Eq 6.32, with no package code.
  eq632 <- function(
    n,
    J,
    delta,
    sb2,
    sw2,
    sc2,
    r1,
    r2,
    r3,
    rb,
    Q = 1,
    alpha = 0.05
  ) {
    lam <- J *
      delta^2 /
      (2 * (sb2 * (1 - rb) + sw2 / Q + sc2 * ((1 - r1) + (J - 1) * (r2 - r3))))
    1 - pf(qf(1 - alpha, 1, J - 1), 1, J - 1, ncp = lam)
  }
  args <- list(
    n = 50,
    J = 8,
    delta = 0.10,
    sb2 = 0.00123,
    sw2 = 0.00087,
    sc2 = 0.00196,
    r1 = 0.5,
    r2 = 0.3,
    r3 = 0.25,
    rb = 0.75
  )
  expect_equal(
    mrmc_power(
      n = args$n,
      J = args$J,
      delta = args$delta,
      sigma_b2 = args$sb2,
      sigma_w2 = args$sw2,
      sigma_c2 = args$sc2,
      rho1 = args$r1,
      rho2 = args$r2,
      rho3 = args$r3,
      rho_b = args$rb
    )$power,
    round(do.call(eq632, args), 3)
  )
})

test_that("mrmc_power defaults rho_b to rho1 (backward-compatible path)", {
  # Without an explicit rho_b the earlier signature (no rho_b argument) must
  # keep working; rho_b then equals rho1.
  res <- mrmc_power(
    50,
    8,
    0.10,
    0.00123,
    0.00087,
    0.00196,
    0.5,
    0.3,
    0.25
  )
  expect_true(res$parameters$rho_b_defaulted)
  expect_equal(res$parameters$rho_b, 0.5)
  expect_equal(res$power, 0.862, tolerance = 0.005)
})

test_that("mrmc_power increases with J and decreases with rho2", {
  p_low <- mrmc_power(
    50,
    4,
    0.10,
    0.00123,
    0.00087,
    0.00196,
    0.5,
    0.3,
    0.25
  )$power
  p_high <- mrmc_power(
    50,
    12,
    0.10,
    0.00123,
    0.00087,
    0.00196,
    0.5,
    0.3,
    0.25
  )$power
  expect_gt(p_high, p_low)

  p_r2low <- mrmc_power(
    50,
    8,
    0.10,
    0.00123,
    0.00087,
    0.00196,
    0.5,
    0.1,
    0.05
  )$power
  p_r2high <- suppressWarnings(
    mrmc_power(
      50,
      8,
      0.10,
      0.00123,
      0.00087,
      0.00196,
      0.5,
      0.4,
      0.1
    )$power
  )
  expect_gt(p_r2low, p_r2high)
})

test_that("mrmc_power validates correlation ordering and inputs", {
  expect_warning(
    mrmc_power(50, 8, 0.1, 0.001, 0.001, 0.05, 0.1, 0.4, 0.2),
    "rho1 > rho2"
  )
  expect_error(
    mrmc_power(50, 1, 0.1, 0.001, 0.001, 0.05, 0.25, 0.2, 0.1),
    class = "rlang_error"
  )
  expect_error(
    mrmc_power(50, 8, 0.1, 0.001, 0.001, 0.05, 0.25, 0.2, 0.1, rho_b = 1),
    class = "rlang_error"
  )
})
