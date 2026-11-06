test_that("every public combination has representative contract inputs", {
  expect_length(ssr_combinations, 46L)
  expect_setequal(names(design_contract_cases), names(ssr_legacy_index))
})

# Each case checks the public interface and output invariants. Numerical
# anchors and independent power/precision checks live beside each kernel.
for (combination in ssr_combinations) {
  local({
    row <- combination
    test_that(
      paste("result contract holds for", row$design, row$task, row$outcome),
      {
        result <- do.call(
          calculate,
          c(
            list(design = row$design, task = row$task, outcome = row$outcome),
            design_contract_cases[[row$legacy]]
          )
        )
        expect_s3_class(result, "sample_size_result")
        expect_identical(result$design_canonical, row$design)
        expect_no_error(validate_sample_size_result(result))
        expect_gt(length(result$calculation_steps), 0L)
      }
    )
  })
}

test_that("screening counts cannot be partially matched into participant totals", {
  result <- calculate(
    "diagAccuracyCompare",
    "noninferiority",
    "proportion",
    p1 = 0.9,
    p2 = 0.85,
    margin = 0.05,
    prevalence = 0.3
  )
  expect_null(result[["total_subjects"]])
  expect_identical(result$total_n, 2L * result$n_per_group)
  expect_gte(result$total_subjects_to_screen, result$n_per_group)
})

test_that("VALIDATION_MATRIX.csv tracks every registered combination", {
  csv <- utils::read.csv(
    system.file("reference", "VALIDATION_MATRIX.csv", package = "SampleSizeCalc")
  )
  expect_named(csv, c(
    "design",
    "task",
    "outcome",
    "dispatch_key",
    "unit",
    "numerical_evidence",
    "scope_limit"
  ))
  expect_setequal(csv$dispatch_key, names(ssr_legacy_index))
  expect_setequal(
    sprintf("%s/%s/%s", csv$design, csv$task, csv$outcome),
    vapply(
      ssr_combinations,
      function(row) sprintf("%s/%s/%s", row$design, row$task, row$outcome),
      character(1)
    )
  )
})
