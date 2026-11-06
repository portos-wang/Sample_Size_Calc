# zero-effect inputs are rejected with argument-specific errors

    Code
      sample_size_calculator("twoMeans", mean1 = 10, mean2 = 10, sd = 3)
    Condition
      Error in `calculate_two_means()`:
      ! `mean1` and `mean2` must differ.

---

    Code
      sample_size_calculator("twoProportions", p1 = 0.5, p2 = 0.5)
    Condition
      Error in `calculate_two_proportions()`:
      ! `p1` and `p2` must differ.

---

    Code
      sample_size_calculator("pairedMeans", meanDiff = 0, sdDiff = 3)
    Condition
      Error in `calculate_paired_means()`:
      ! `meanDiff` must be non-zero.

# partially matched control arguments are rejected

    Code
      sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3, p = 0.5)
    Condition
      Error in `sample_size_calculator()`:
      ! Argument `p` partially matches control argument `power`.
      i Name the design with `design = ...`, and spell `alpha` and `power` in full.
      i Design-specific arguments must use their documented names.

---

    Code
      sample_size_calculator("auc_single", auc = 0.8, d = 0.05)
    Condition
      Error in `sample_size_calculator()`:
      ! Argument `d` partially matches control argument `design`.
      i Name the design with `design = ...`, and spell `alpha` and `power` in full.
      i Design-specific arguments must use their documented names.

