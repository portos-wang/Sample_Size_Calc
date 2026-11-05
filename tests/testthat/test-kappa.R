# 3.1: Cohen's kappa sample size (Cantor 1996).
# Anchors: the paper's own worked examples and its Tables 1-2.

test_that("kappa_Q reproduces Cantor Table 1 (p. 152)", {
  # Spot checks across the full range of pi1., pi.1 and kappa.
  cases <- list(
    c(0.1, 0.1, 0.0, 1.000), c(0.2, 0.1, 0.0, 0.852), c(0.2, 0.2, 0.0, 1.000),
    c(0.3, 0.2, 0.0, 0.931), c(0.3, 0.3, 0.0, 1.000), c(0.3, 0.3, 0.5, 0.893),
    c(0.3, 0.3, 0.6, 0.768), c(0.4, 0.3, 0.0, 0.953), c(0.4, 0.3, 0.3, 0.929),
    c(0.4, 0.4, 0.0, 1.000), c(0.5, 0.5, 0.0, 1.000), c(0.5, 0.5, 0.7, 0.510),
    c(0.5, 0.5, 0.5, 0.750), c(0.5, 0.5, 0.6, 0.640), c(0.6, 0.4, 0.3, 0.748),
    c(0.7, 0.3, 0.0, 0.524), c(0.8, 0.2, 0.0, 0.221), c(0.9, 0.5, 0.0, 0.360)
  )
  for (cs in cases) {
    expect_equal(
      SampleSizeCalc:::kappa_Q(cs[1], cs[2], cs[3]), cs[4],
      tolerance = 0.0025,
      label = sprintf("Q(%.1f,%.1f,%.1f)", cs[1], cs[2], cs[3])
    )
  }
})

test_that("kappa_Q reproduces Cantor Table 2 maxima (p. 153)", {
  # Table 2 lists Q_MAX and the kappa at which it occurs.
  max_q <- function(a, b) {
    ks <- seq(0, 0.999, by = 0.0005)
    q <- vapply(ks, function(k) SampleSizeCalc:::kappa_Q(a, b, k), numeric(1))
    q[!is.finite(q)] <- -Inf
    i <- which.max(q)
    c(Qmax = q[i], kappa = ks[i])
  }
  expected <- list(
    c(0.3, 0.3, 1.07003, 0.187),
    c(0.4, 0.4, 1.00558, 0.067),
    c(0.5, 0.5, 1.00000, 0.000),
    c(0.7, 0.3, 0.52438, 0.000),
    c(0.9, 0.1, 0.04819, 0.000)
  )
  for (e in expected) {
    m <- max_q(e[1], e[2])
    expect_equal(m[["Qmax"]], e[3], tolerance = 1e-4,
                 label = sprintf("Q_MAX(%.1f,%.1f)", e[1], e[2]))
    expect_equal(m[["kappa"]], e[4], tolerance = 0.002,
                 label = sprintf("argmax kappa(%.1f,%.1f)", e[1], e[2]))
  }
})

test_that("kappa estimate matches the Cantor precision example (165)", {
  # p. 151: pi1. = pi.1 = 0.3, no kappa assumption -> Q_MAX = 1.0,
  # 80% CI with d = 0.1 -> n = 1.0/(0.1/1.28)^2 = 165.
  # (The paper's own text uses pi = 0.3 and Q_MAX = 1.0, which happens to be
  #  the (0.5, 0.5) entry; at (0.3, 0.3) the Table 2 maximum is 1.07003.)
  res <- calculate("kappa", "estimate", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa = 0, d = 0.1, alpha = 0.20
  )
  expect_equal(res$n_required, 165)
  expect_equal(res$parameters$Q, 1.0, tolerance = 1e-6)
})

test_that("kappa test matches the Cantor two-questionnaire example (214)", {
  # p. 153: K1 = 0.7 (null), K2 = 0.5 (alternative), pi1. = pi.1 = 0.5,
  # two-sided alpha 0.05, power 0.80 -> Q01 = Q02 = 0.510, QA1 = 0.510,
  # QA2 = 0.750 -> N = 214.
  res <- calculate("kappa", "test", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa1 = 0.7, kappa2 = 0.5
  )
  expect_equal(res$n_required, 214)
  expect_equal(res$parameters$Q_null, 0.510, tolerance = 1e-6)
  expect_equal(res$parameters$Q_alt, 0.750, tolerance = 1e-6)
})

test_that("kappa test rejects equal kappas and invalid marginals", {
  expect_snapshot(error = TRUE, calculate("kappa", "test", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa1 = 0.7, kappa2 = 0.7
  ))
  expect_snapshot(error = TRUE, calculate("kappa", "estimate", "proportion",
    pi1 = 0.5, pi2 = 0.5, kappa = 0.7, d = 0
  ))
})
