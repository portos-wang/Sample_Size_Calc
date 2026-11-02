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

