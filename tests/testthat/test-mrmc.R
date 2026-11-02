# 3.1 preview: MRMC power (Zhou Eq 6.32, paired-patient paired-reader).

test_that("mrmc_power reproduces the Zhou mammography anchor (~0.89)", {
  res <- mrmc_power(
    n = 50, J = 8, delta = 0.10,
    sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.05,
    rho1 = 0.25, rho2 = 0.2, rho3 = 0.1, alpha = 0.05
  )
  expect_s3_class(res, "sample_size_result")
  expect_equal(res$power, 0.888, tolerance = 0.005) # book: "89% power"
})

test_that("mrmc_power increases with J and decreases with rho2", {
  p_low <- mrmc_power(
    50, 4, 0.10, 0.00123, 0.00087, 0.05,
    0.25, 0.2, 0.1
  )$power
  p_high <- mrmc_power(
    50, 12, 0.10, 0.00123, 0.00087, 0.05,
    0.25, 0.2, 0.1
  )$power
  expect_gt(p_high, p_low)

  p_r2low <- mrmc_power(
    50, 8, 0.10, 0.00123, 0.00087, 0.05,
    0.25, 0.1, 0.05
  )$power
  p_r2high <- suppressWarnings(mrmc_power(
    50, 8, 0.10, 0.00123, 0.00087, 0.05,
    0.25, 0.4, 0.1
  )$power)
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
})
