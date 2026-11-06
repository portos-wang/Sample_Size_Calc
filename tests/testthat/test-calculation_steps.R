test_that("AUC binormal reports finite intermediate values and the returned size", {
  res <- calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.80,
    d = 0.10,
    ratio = 1,
    var_method = "binormal"
  )
  steps <- paste(res$calculation_steps, collapse = "\n")

  expect_match(steps, "binormal", fixed = TRUE)
  expect_match(steps, "0.1195", fixed = TRUE)
  expect_match(steps, "45.89", fixed = TRUE)
  expect_match(steps, "Target cases needed = 46", fixed = TRUE)
  expect_match(steps, "Total subjects = 46 + 46 = 92", fixed = TRUE)
  expect_no_match(steps, "subjects to screen")
  expect_no_match(steps, "Inf|NaN|NA\\b")
})

test_that("AUC conservative reports the supplied allocation instead of prevalence", {
  res <- calculate(
    "diagAUC",
    "estimate",
    "auc",
    auc = 0.80,
    d = 0.10,
    ratio = 2,
    var_method = "conservative"
  )
  steps <- paste(res$calculation_steps, collapse = "\n")

  expect_match(steps, "conservative", fixed = TRUE)
  expect_match(steps, "R = 2", fixed = TRUE)
  expect_match(steps, "61.46", fixed = TRUE)
  expect_match(steps, "Target cases needed = 62", fixed = TRUE)
  expect_match(steps, "Total subjects = 62 + 124 = 186", fixed = TRUE)
  expect_no_match(steps, "prevalence|Inf|NaN")
})

test_that("diagnostic CI-width reports preserve nondefault power", {
  res <- calculate(
    "diagAccuracy",
    "estimate",
    "proportion",
    prob = 0.85,
    d = 0.05,
    prevalence = 0.20,
    ci_method = "ci_width_power",
    power = 0.90
  )
  steps <- paste(res$calculation_steps, collapse = "\n")

  expect_equal(res$parameters$power, 0.90)
  expect_match(steps, "1.2816", fixed = TRUE)
  expect_match(steps, "535.88", fixed = TRUE)
  expect_match(steps, "Target cases needed = 536", fixed = TRUE)
})

test_that("cohort reports show rounding before dropout inflation", {
  res <- calculate(
    "cohort",
    "test",
    "proportion",
    p0 = 0.20,
    p1 = 0.30,
    dropout = 0.10
  )
  steps <- paste(res$calculation_steps, collapse = "\n")

  expect_match(steps, "dropout", fixed = TRUE)
  expect_match(steps, "294", fixed = TRUE)
  expect_match(steps, "327", fixed = TRUE)
  expect_match(steps, "654", fixed = TRUE)
})

test_that("generic calculation reports retain final metrics from constructed objects", {
  res <- calculate(
    "predictiveModel",
    "plan",
    "binary",
    prev = 0.30,
    n_parameters = 10,
    r2_cs = 0.10
  )
  steps <- paste(res$calculation_steps, collapse = "\n")

  expect_match(steps, "Required sample size: 850", fixed = TRUE)
  expect_match(steps, "Events required: 255", fixed = TRUE)
})
