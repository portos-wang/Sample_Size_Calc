# Phase 6: print/summary rendering of new S3 elements.
# cli capture helpers live in helper-capture.R.

test_that("print renders metrics, roles and hints for estimation designs", {
  res <- calculate("singleProportion", p = 0.05, precision = 0.025)
  txt <- capture_cli(res)
  expect_match(txt, "Required sample size")
  expect_match(txt, "half the prevalence")
})

test_that("summary includes axes, roles, adjustments, and formula", {
  res <- calculate("cohort", "test", "proportion",
    p0 = 0.2, p1 = 0.3, dropout = 0.1
  )
  txt <- capture_cli_summary(res)
  expect_match(txt, "cohort")
  expect_match(txt, "Task:")
  expect_match(txt, "Adjustments applied")
  expect_match(txt, "dropout")
  expect_match(txt, "unexposed")
  expect_match(txt, "alpha/2", fixed = TRUE) # formula_latex present
  expect_match(txt, "Reference")
})

test_that("print and summary still return the object invisibly", {
  res <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
  expect_identical(print(res), res)
  expect_identical(summary(res), res)
})

test_that("unsupplied optional parameters are not rendered as blank entries", {
  res <- calculate(
    "predictiveModel",
    "plan",
    "rate",
    rate = 0.1,
    timepoint = 10,
    precision_delta = 0.05
  )
  summary_txt <- capture_cli_summary(res)
  expect_no_match(summary_txt, "n_parameters:")
  expect_no_match(summary_txt, "epv:")
  expect_match(summary_txt, "precision_delta")

  print_txt <- capture_cli(res)
  input_step <- grep("Input parameters", print_txt, value = TRUE)
  expect_length(input_step, 1)
  expect_no_match(input_step, "= ,")
  expect_match(input_step, "rate = 0.10", fixed = TRUE)
})

test_that("legacy designs still print their metrics", {
  res <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
  txt <- capture_cli(res)
  expect_match(txt, "Sample size per group")
  expect_match(txt, "37")
  expect_match(txt, "Total sample size")
})

test_that("new-design metrics render", {
  cluster <- calculate("clusterRCT", "test", "mean",
    mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20
  )
  txt <- capture_cli(cluster)
  expect_match(txt, "Clusters per arm")
  expect_match(txt, "Sample size per group")

  simon <- calculate("singleArmPhaseII", "test", "proportion",
    p0 = 0.1, p1 = 0.3, optimizer = "optimal"
  )
  txt2 <- capture_cli(simon)
  expect_match(txt2, "Stage 1 sample size")
  expect_match(txt2, "Total sample size")
})

test_that("print outputs plain text formula, LaTeX formula, calculation process, and reference", {
  res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
  txt <- capture_cli(res)

  # 1. Plain text formula
  expect_match(txt, "Formula (plain text)", fixed = TRUE)
  expect_match(txt, "Z_alpha/2", fixed = TRUE)

  # 2. LaTeX formula
  expect_match(txt, "Formula (LaTeX)", fixed = TRUE)
  expect_match(txt, "$$n = 2", fixed = TRUE)

  # 3. Calculation process
  expect_match(txt, "Calculation process", fixed = TRUE)
  expect_match(txt, "Step 1", fixed = TRUE)
  expect_match(txt, "Step 2", fixed = TRUE)
  expect_match(txt, "Step 3", fixed = TRUE)

  # 4. Reference
  expect_match(txt, "Reference", fixed = TRUE)
  expect_match(txt, "Chow", fixed = TRUE)

  # Verify object fields
  expect_true(!is.null(res$formula) && nzchar(res$formula))
  expect_true(!is.null(res$formula_latex) && nzchar(res$formula_latex))
  expect_true(!is.null(res$calculation) && length(res$calculation) > 0)
  expect_true(!is.null(res$calculation_steps) && length(res$calculation_steps) > 0)
  expect_identical(res$calculation, res$calculation_steps)
  expect_true(!is.null(res$reference) && nzchar(res$reference))
})

test_that("sample_size_calculator also outputs formulas, calculation process, and reference", {
  res <- sample_size_calculator("twoProportions", p1 = 0.85, p2 = 0.70)
  txt <- capture_cli(res)

  expect_match(txt, "Formula (plain text)", fixed = TRUE)
  expect_match(txt, "Formula (LaTeX)", fixed = TRUE)
  expect_match(txt, "Calculation process", fixed = TRUE)
  expect_match(txt, "Step 1", fixed = TRUE)
  expect_match(txt, "Reference", fixed = TRUE)

  expect_true(!is.null(res$formula) && nzchar(res$formula))
  expect_true(!is.null(res$formula_latex) && nzchar(res$formula_latex))
  expect_true(!is.null(res$calculation) && length(res$calculation) > 0)
  expect_true(!is.null(res$reference) && nzchar(res$reference))
})

test_that("summary includes Calculation Process along with Formula and Reference", {
  res <- calculate("rct", "test", "proportion", p1 = 0.85, p2 = 0.70)
  txt <- capture_cli_summary(res)

  expect_match(txt, "Formula", fixed = TRUE)
  expect_match(txt, "Plain text", fixed = TRUE)
  expect_match(txt, "LaTeX", fixed = TRUE)
  expect_match(txt, "Calculation Process", fixed = TRUE)
  expect_match(txt, "Step 1", fixed = TRUE)
  expect_match(txt, "Reference", fixed = TRUE)
})

