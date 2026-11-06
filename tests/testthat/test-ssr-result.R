test_that("result construction rejects a negative count", {
  expect_snapshot(
    error = TRUE,
    new_sample_size_result(
      "singleMean",
      "estimate",
      "mean",
      "Invalid count",
      legacy = list(n_required = -1L)
    )
  )
})

test_that("result construction rejects a fractional participant total", {
  expect_snapshot(
    error = TRUE,
    new_sample_size_result(
      "caseControl",
      "test",
      "proportion",
      "Invalid total",
      legacy = list(
        cases_needed = 117L,
        controls_needed = 175L,
        total_subjects = 292.5
      )
    )
  )
})

test_that("result validation rejects inconsistent group totals", {
  expect_snapshot(
    error = TRUE,
    new_sample_size_result(
      "caseControl",
      "test",
      "proportion",
      "Inconsistent total",
      legacy = list(
        cases_needed = 3L,
        controls_needed = 4L,
        total_subjects = 8L
      )
    )
  )
})

test_that("mutation cannot desynchronize top-level and stored counts", {
  res <- new_sample_size_result(
    design = "singleMean",
    task = "estimate",
    outcome = "mean",
    design_type = "Mutation check",
    legacy = list(n_required = 10L)
  )
  res$n_required <- 11L
  expect_snapshot(error = TRUE, validate_sample_size_result(res))
})

test_that("new_sample_size_result builds a valid object with legacy aliases", {
  res <- new_sample_size_result(
    design = "rct",
    task = "test",
    outcome = "mean",
    design_type = "Two independent samples, mean comparison",
    parameters = list(mean1 = 10, mean2 = 12, sd = 3),
    legacy = list(n_per_group = 37L, total_n = 74L),
    roles = c("mean1 = control group mean")
  )

  expect_s3_class(res, "sample_size_result")
  expect_identical(res$design, "rct")
  expect_identical(res$task, "test")
  expect_identical(res$outcome, "mean")
  # Legacy top-level fields preserved
  expect_identical(res$n_per_group, 37L)
  expect_identical(res$total_n, 74L)
  # Canonical fields derived
  expect_identical(res$results$n_1, 37L)
  expect_identical(res$results$total_n, 74L)
  expect_identical(res$roles, c("mean1 = control group mean"))
})

test_that("canonical derivation covers pairs/events/cases fields", {
  res_pairs <- new_sample_size_result(
    design = "rct",
    task = "test",
    outcome = "mean",
    design_type = "Paired",
    legacy = list(pairs_count = 27L)
  )
  expect_identical(res_pairs$results$pairs, 27L)

  res_events <- new_sample_size_result(
    design = "rct",
    task = "test",
    outcome = "survival",
    design_type = "Survival",
    legacy = list(target_events_needed = 25L)
  )
  expect_identical(res_events$results$events, 25L)

  res_cases <- new_sample_size_result(
    design = "diagAccuracy",
    task = "estimate",
    outcome = "proportion",
    design_type = "Diagnostic",
    legacy = list(
      target_state_cases_needed = 246L,
      total_subjects_to_screen = 1230L
    )
  )
  expect_identical(res_cases$results$cases, 246L)
  expect_identical(res_cases$results$subjects_to_screen, 1230L)
})

test_that("validate_sample_size_result rejects malformed objects", {
  expect_snapshot(error = TRUE, validate_sample_size_result(list(a = 1)))
  expect_snapshot(error = TRUE, validate_sample_size_result("rct"))

  bad <- new_sample_size_result(
    design = "rct",
    task = "test",
    outcome = "mean",
    design_type = "ok",
    roles = NULL
  )
  # roles = NULL is dropped from the list by [<-, so emulate malformed field
  bad$roles <- 123
  expect_snapshot(error = TRUE, validate_sample_size_result(bad))
})

test_that("assert_sample_size_result passes through valid objects", {
  res <- new_sample_size_result(
    design = "cohort",
    task = "test",
    outcome = "proportion",
    design_type = "Cohort"
  )
  expect_identical(assert_sample_size_result(res), res)
})

test_that("sample_size_calculator output remains valid under the validator", {
  res <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
  # Existing results predate the constructor; validate() must still accept
  # them because it only checks the required core fields.
  expect_error(validate_sample_size_result(res), NA)
})

test_that("new_sample_size_result sets and auto-derives calculation steps", {
  # Auto-derivation
  res_auto <- new_sample_size_result(
    design = "rct",
    task = "test",
    outcome = "mean",
    design_type = "Two independent samples, mean comparison",
    parameters = list(mean1 = 10, mean2 = 12, sd = 3),
    legacy = list(n_per_group = 37L, total_n = 74L)
  )
  expect_true(is.character(res_auto$calculation_steps))
  expect_gt(length(res_auto$calculation_steps), 0)
  expect_identical(res_auto$calculation, res_auto$calculation_steps)

  # Custom calculation steps
  custom_steps <- c("Step 1: Custom step", "Step 2: Custom calculation")
  res_custom <- new_sample_size_result(
    design = "rct",
    task = "test",
    outcome = "mean",
    design_type = "Two independent samples, mean comparison",
    parameters = list(mean1 = 10, mean2 = 12, sd = 3),
    legacy = list(n_per_group = 37L, total_n = 74L),
    calculation = custom_steps
  )
  expect_identical(res_custom$calculation, custom_steps)
  expect_identical(res_custom$calculation_steps, custom_steps)
})
