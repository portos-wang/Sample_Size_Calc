# an impossible precision requirement aborts inside the integer range

    Code
      calculate("singleMean", sigma = 1, precision = 1e-06)
    Condition
      Error in `calculate_single_mean()`:
      ! The required sample size exceeds the supported integer range.

# singleProportion rejects invalid inputs

    Code
      calculate("singleProportion", p = 1.2, precision = 0.05)
    Condition
      Error in `validate_design_args()`:
      ! `p` must be a proportion in (0, 1).

---

    Code
      calculate("singleProportion", p = 0.3, precision = 0)
    Condition
      Error in `validate_design_args()`:
      ! `precision` must be positive.

---

    Code
      calculate("singleProportion", p = 0.3, precision = -0.1)
    Condition
      Error in `validate_design_args()`:
      ! `precision` must be positive.

