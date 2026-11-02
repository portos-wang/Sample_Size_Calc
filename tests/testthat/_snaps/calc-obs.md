# cohort rejects invalid inputs

    Code
      calculate("cohort", "test", "proportion", p0 = 0.3, p1 = 0.3)
    Condition
      Error in `calculate_cohort_proportion()`:
      ! `p1` and `p0` must differ.

---

    Code
      calculate("cohort", "test", "proportion", p0 = 0.2, p1 = 0.3, ratio = 0.5)
    Condition
      Error in `calculate_cohort_proportion()`:
      ! `ratio` (unexposed:exposed) must be >= 1.

# caseControlMatched rejects OR=1 and invalid p0

    Code
      calculate("caseControlMatched", "test", "proportion", p0 = 0.3, OR = 1)
    Condition
      Error in `calculate_case_control_matched()`:
      ! `OR` must be a positive number != 1.

---

    Code
      calculate("caseControlMatched", "test", "proportion", p0 = 1.2, OR = 2)
    Condition
      Error in `calculate_case_control_matched()`:
      ! `p0` (control-group exposure rate) must be in (0, 1).

# pairedProportions rejects psi smaller than the difference

    Code
      calculate("paired", "test", "proportion", p1 = 0.4, p2 = 0.2, psi = 0.1)
    Condition
      Error in `paired_proportion_n()`:
      ! Inconsistent inputs: need psi >= delta (or psi > delta^2).
      x psi = 0.1, |p1-p2| = 0.2.
      i psi is the expected proportion of discordant pairs

# single-arm designs reject equal proportions/means

    Code
      calculate("rctSingleArm", "test", "proportion", p0 = 0.5, p1 = 0.5)
    Condition
      Error in `calculate_single_arm_proportion()`:
      ! `p1` and `p0` must differ.

---

    Code
      calculate("rctSingleArm", "test", "mean", mu0 = 1, mu1 = 1, sigma = 1)
    Condition
      Error in `calculate_single_arm_mean()`:
      ! `mu1` and `mu0` must differ.

