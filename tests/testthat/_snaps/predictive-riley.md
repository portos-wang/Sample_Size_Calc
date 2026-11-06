# Riley rejects a shrinkage target below the anticipated R-squared

    Code
      calculate("predictiveModel", "plan", "binary", prev = 0.3, n_parameters = 10,
        r2_cs = 0.2, shrinkage = 0.1)
    Condition
      Error in `calculate_predictive_riley_binary()`:
      ! `shrinkage` must exceed `r2_cs` and be below 1.

# Riley rejects an impossible MAPE target

    Code
      calculate("predictiveModel", "plan", "binary", prev = 0.3, n_parameters = 10,
        r2_cs = 0.2, mape = 0)
    Condition
      Error in `calculate_predictive_riley_binary()`:
      ! `mape` must be in (0, 1).

# Riley rejects MAPE when its informational formula is unavailable

    Code
      calculate("predictiveModel", "plan", "binary", prev = 0.3, n_parameters = 31,
        r2_cs = 0.2, mape = 0.05)
    Condition
      Error in `validate_design_args()`:
      ! `mape` is available only when `n_parameters` is at most 30.

