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
