# an extreme dual-endpoint prevalence aborts instead of overflowing

    Code
      calculate("diagAccuracy", "test", "proportion", prob = 0.9, p0 = 0.7, dual = TRUE,
        prob_spec = 0.9, p0_spec = 0.7, prevalence = 1e-12)
    Condition
      Error in `expected_recruitment()`:
      ! Expected recruitment exceeds the supported integer range.

# an impossible negative LR upper bound is rejected

    Code
      calculate("diagLR", sens = 0.9, spec = 0.5, target_lr = 0.1, lr_type = "negative")
    Condition
      Error in `calculate_likelihood_ratio_v2()`:
      ! `target_lr` is on the wrong side of the anticipated likelihood ratio.
      i LR- requires an upper limit above the anticipated LR; LR+ requires a lower limit below it.

# an impossible positive LR lower bound is rejected

    Code
      calculate("diagLR", sens = 0.8, spec = 0.7, target_lr = 5, lr_type = "positive")
    Condition
      Error in `calculate_likelihood_ratio_v2()`:
      ! `target_lr` is on the wrong side of the anticipated likelihood ratio.
      i LR- requires an upper limit above the anticipated LR; LR+ requires a lower limit below it.

# AUC sampling assumptions cannot conflict

    Code
      calculate("diagAUC", auc = 0.8, d = 0.05, ratio = 4, prevalence = 0.2)
    Condition
      Error in `auc_sampling()`:
      ! Supply only one of `ratio` and `prevalence` for AUC planning.
      i Use ratio for fixed case-control quotas or prevalence for consecutive clinical recruitment.

# screen_required rejects invalid inputs

    Code
      screen_required(0, 0.5)
    Condition
      Error in `screen_required()`:
      ! `n` must be a positive integer number of cases.

---

    Code
      screen_required(100, 1.5)
    Condition
      Error in `screen_required()`:
      ! `prevalence` must be in (0, 1).

---

    Code
      screen_required(100, 0.5, beta = 0)
    Condition
      Error in `screen_required()`:
      ! `beta` must be in (0, 1).

