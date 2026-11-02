# singleProportion rejects invalid inputs

    Code
      calculate("singleProportion", p = 1.2, precision = 0.05)
    Condition
      Error in `calculate_single_proportion()`:
      ! `p` must be a single proportion in (0, 1).
      x You provided 1.2.

---

    Code
      calculate("singleProportion", p = 0.3, precision = 0)
    Condition
      Error in `calculate_single_proportion()`:
      ! `precision` must be a single positive number.
      x You provided 0.

---

    Code
      calculate("singleProportion", p = 0.3, precision = -0.1)
    Condition
      Error in `calculate_single_proportion()`:
      ! `precision` must be a single positive number.
      x You provided -0.1.

