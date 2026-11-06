# invalid ICC values cannot produce negative recruitment

    Code
      calculate("clusterRCT", mean1 = 10, mean2 = 12, sd = 3, icc = -0.5,
        cluster_size = 20)
    Condition
      Error in `validate_design_args()`:
      ! `icc` must be in [0, 1).

# diagnostic probabilities must be between zero and one

    Code
      calculate("diagAccuracy", prob = 1.2, d = 0.05)
    Condition
      Error in `validate_design_args()`:
      ! `prob` must be a proportion in (0, 1).

# kappa values must be compatible with rater marginals

    Code
      calculate("kappa", pi1 = 0.1, pi2 = 0.9, kappa = 0.8, d = 0.1)
    Condition
      Error in `validate_kappa_joint()`:
      ! `kappa` is incompatible with the supplied rater marginal proportions.
      i The implied joint rating probabilities must all be between zero and one.

# missing alpha is rejected with an argument-specific error

    Code
      calculate("rct", mean1 = 10, mean2 = 12, sd = 3, alpha = NA_real_)
    Condition
      Error in `validate_alpha()`:
      ! `alpha` must be a single finite numeric value.

# NaN power is rejected before numerical calculation

    Code
      calculate("rct", mean1 = 10, mean2 = 12, sd = 3, power = NaN)
    Condition
      Error in `validate_power()`:
      ! `power` must be a single finite numeric value.

# infinite standard deviations cannot produce a sample size

    Code
      sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = Inf)
    Condition
      Error in `validate_numeric_scalar()`:
      ! `sd` must be a single finite numeric value.

# vector allocation ratios are rejected as non-scalar inputs

    Code
      calculate("diagAUC", auc = 0.8, d = 0.05, ratio = c(1, 4))
    Condition
      Error in `validate_numeric_scalar()`:
      ! `ratio` must be a single finite numeric value.

# non-finite ordinal proportions are rejected explicitly

    Code
      calculate("twoOrdinal", or = 2, prop_bar = c(0.5, NA_real_))
    Condition
      Error in `validate_design_args()`:
      ! `prop_bar` must contain at least two finite numeric proportions.

# screening rejects non-finite prevalence before searching

    Code
      screen_required(196, prevalence = NaN)
    Condition
      Error in `validate_numeric_scalar()`:
      ! `prevalence` must be a single finite numeric value.

# MRMC rejects missing covariance components before evaluating power

    Code
      mrmc_power(n = 50, J = 8, delta = 0.1, sigma_b2 = NA_real_, sigma_w2 = 0.00087,
        sigma_c2 = 0.00196, rho1 = 0.5, rho2 = 0.3, rho3 = 0.25)
    Condition
      Error in `validate_numeric_scalar()`:
      ! `sigma_b2` must be a single finite numeric value.

# unsupported dropout is rejected instead of ignored

    Code
      calculate("rct", mean1 = 10, mean2 = 12, sd = 3, dropout = 0.2)
    Condition
      Error in `validate_design_args()`:
      ! Unsupported arguments for design "twoMeans": `dropout`.
      i These arguments would not be used by this calculation.

# misspelled arguments are rejected by both entry points

    Code
      sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3, sdd = 4)
    Condition
      Error in `validate_design_args()`:
      ! Unsupported arguments for design "twoMeans": `sdd`.
      i These arguments would not be used by this calculation.

# unused test alternatives are rejected

    Code
      calculate("rct", mean1 = 10, mean2 = 12, sd = 3, alternative = "one.sided")
    Condition
      Error in `validate_design_args()`:
      ! Unsupported arguments for design "twoMeans": `alternative`.
      i These arguments would not be used by this calculation.

# parameters for inactive diagnostic branches are rejected

    Code
      calculate("diagAccuracyCompare", p1 = 0.85, p2 = 0.75, paired = FALSE, psi = 0.2)
    Condition
      Error in `validate_design_args()`:
      ! Unsupported arguments for design "diagnosticComparisonTwo": `psi`.
      i These arguments would not be used by this calculation.

# numeric arguments require names

    Code
      calculate("rct", 10, mean1 = 10, mean2 = 12, sd = 3)
    Condition
      Error in `validate_design_args()`:
      ! Design-specific arguments must have unique, non-empty names.

# duplicate numeric arguments cannot be silently selected

    Code
      calculate("rct", mean1 = 10, mean2 = 12, sd = 3, sd = 4)
    Condition
      Error in `validate_design_args()`:
      ! Design-specific arguments must have unique, non-empty names.

