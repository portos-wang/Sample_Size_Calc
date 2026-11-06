# equal expected proportions are rejected before any division

    Code
      calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.8, p2 = 0.8,
        paired = FALSE, prevalence = 0.3)
    Condition
      Error in `calculate_diagnostic_comparison_two()`:
      ! `p1` and `p2` must differ.

# diagnostic margins reject margin <= |diff| for equivalence

    Code
      calculate("diagAccuracyCompare", "equivalence", "proportion", p1 = 0.9, p2 = 0.88,
        margin = 0.01)
    Condition
      Error in `calculate_diag_compare_margin_prop()`:
      ! Equivalence margin must exceed |p1 - p2|.
      x margin - |p1-p2| = -0.01 <= 0

---

    Code
      calculate("diagAccuracyCompare", "noninferiority", "proportion", p1 = 0.8, p2 = 0.85,
        margin = 0.04)
    Condition
      Error in `calculate_diag_compare_margin_prop()`:
      ! Non-inferiority margin not met.
      x p1 - p2 + margin = -0.00999999999999993 <= 0

# bioequivalence rejects a search cap that does not achieve target power

    Code
      calculate("bioequivalence", cv = 0.25, theta0 = 1.2499)
    Condition
      Error in `calculate_bioequivalence()`:
      ! No bioequivalence design reaches the requested power within 10000 participants.
      i Power at the search limit is 0.0524; target is 0.8.

# exact diagnostic planning rejects an unsupported two-sided request

    Code
      calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.7, method = "exact",
        alternative = "two.sided")
    Condition
      Error in `calculate_diagnostic_superiority_single()`:
      ! `method = 'exact'` supports only `alternative = 'one.sided'`.
      i Use the asymptotic method for the implemented two-sided convention.

# a narrow-margin BE target that 10000 cannot reach aborts

    Code
      calculate("bioequivalence", "equivalence", "mean", cv = 0.3, theta0 = 1,
        margin_low = 0.99, margin_high = 1.01, power = 0.99)
    Condition
      Error in `calculate_bioequivalence()`:
      ! No bioequivalence design reaches the requested power within 10000 participants.
      i Power at the search limit is 0.555; target is 0.99.

