test_that("paired means count people separately from repeated measurements", {
  result <- calculate("paired", "test", "mean", meanDiff = 5, sdDiff = 10)
  expect_equal(result$pairs_count, 34)
  expect_equal(result$total_individuals, 34)
  expect_equal(result$total_n, 34)
  expect_equal(result$n_measurements, 68)
})

test_that("matched-subject mean pairs contain two distinct people", {
  result <- calculate(
    "paired",
    "test",
    "mean",
    meanDiff = 5,
    sdDiff = 10,
    pairing = "matched_subjects"
  )
  expect_equal(result$pairs_count, 34)
  expect_equal(result$total_individuals, 68)
  expect_equal(result$total_n, 68)
  expect_equal(result$n_measurements, 68)
})

test_that("paired binary outcomes default to repeated records from one person", {
  result <- calculate(
    "paired",
    "test",
    "proportion",
    p1 = 0.8,
    p2 = 0.6,
    psi = 0.25
  )
  expect_identical(result$pairs_count, 47L)
  expect_identical(result$total_n, 47L)
  expect_identical(result$n_measurements, 94L)
})

test_that("matched-subject binary pairs report the distinct participant total", {
  result <- calculate(
    "paired",
    "test",
    "proportion",
    p1 = 0.8,
    p2 = 0.6,
    psi = 0.25,
    pairing = "matched_subjects"
  )
  expect_identical(result$total_individuals, 94L)
  expect_identical(result$total_n, 94L)
  expect_identical(result$results$total_n, 94L)
})

test_that("discordance cannot imply negative joint probabilities", {
  expect_snapshot(
    error = TRUE,
    calculate("paired", "test", "proportion", p1 = 0.9, p2 = 0.8, psi = 0.8)
  )
})
