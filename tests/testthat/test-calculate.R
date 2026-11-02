# Golden master: legacy keyword calls and three-axis calculate() calls must
# produce identical results (silent compatibility, one dispatch path).
# Test data lives in helper-golden.R (shuffled-run safe).

test_that("all 17 legacy keywords produce identical results via calculate()", {
  for (case in golden_cases) {
    old_res <- do.call(sample_size_calculator, c(list(design = case$old), case$args))
    new_res <- do.call(calculate, c(
      list(design = case$new[1], task = case$new[2], outcome = case$new[3]),
      case$args
    ))
    for (field in golden_fields) {
      expect_identical(old_res[[field]], new_res[[field]],
        label = sprintf("%s: %s", case$old, field)
      )
    }
  }
})

test_that("new-style results carry axis metadata the legacy ones lack", {
  res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
  expect_identical(res$design_canonical, "rct")
  expect_identical(res$task, "test")
  expect_identical(res$outcome, "mean")
  expect_identical(res$results$n_1, res$n_per_group)
})

test_that("task/outcome can be omitted for unambiguous designs", {
  res_full <- calculate("diagAUC", "estimate", "auc", auc = 0.8, d = 0.05)
  res_default <- calculate("diagAUC", auc = 0.8, d = 0.05)
  expect_identical(res_full$n_per_group, res_default$n_per_group)
})

test_that("unknown design errors with valid design list", {
  expect_snapshot(error = TRUE, calculate("rctMean", mean1 = 1, mean2 = 2, sd = 3))
})

test_that("cohort outcome=mean is an illegal combination (rate/proportion only)", {
  expect_snapshot(error = TRUE, calculate("cohort", "test", "mean"))
})
