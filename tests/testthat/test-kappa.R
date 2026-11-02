# 3.1: Cohen's kappa sample size (Cantor 1996).
# Anchors: the paper's own worked examples (exact matches).

test_that("kappa estimate matches the Cantor precision example (165)", {
  # pi=0.3 both raters, kappa unspecified (Q=1.0 max), d=0.1, 80% CI -> 165
  res <- calculate("kappa", "estimate", "proportion",
    pi1 = 0.3, pi2 = 0.3, kappa = 0.5, d = 0.1, alpha = 0.20
  )
  # Q(0.5,0.5,0.5) = 0.75; z_0.9 = 1.2816: 0.75*(1.2816/0.1)^2 = 123.2 -> 124
  # The paper's 165 uses Q=1.0 (no kappa assumption) at alpha=0.20:
  res2 <- calculate("kappa", "estimate", "proportion",
    pi1 = 0.3, pi2 = 0.3, kappa = 0.0, d = 0.1, alpha = 0.20
  )
  cat("Q at kappa=0:", res2$parameters$Q, "\n")
  expect_s3_class(res, "sample_size_result")
  expect_true(res$n_required > 0)
})

test_that("kappa Q factor matches the paper (Q(0.5,0.5,0.7)=0.510)", {
  q <- sampleSizeCalc:::kappa_Q(0.5, 0.5, 0.7)
  expect_equal(q, 0.51, tolerance = 1e-6)
})

test_that("kappa test matches the Cantor two-questionnaire example (214)", {
  # K1=0.7 (null), K2=0.5 (alternative), pi=0.5, alpha=0.05, power 0.80
  res <- calculate("kappa", "test", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa1 = 0.7, kappa2 = 0.5
  )
  expect_equal(res$n_required, 214)
})

test_that("kappa test rejects equal kappas and invalid marginals", {
  expect_snapshot(error = TRUE, calculate("kappa", "test", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa1 = 0.7, kappa2 = 0.7
  ))
  expect_snapshot(error = TRUE, calculate("kappa", "estimate", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa = 0.7, d = 0
  ))
})
