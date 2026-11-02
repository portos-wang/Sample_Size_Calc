# twoOrdinal rejects proportions not summing to 1

    Code
      calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.3))
    Condition
      Error in `calculate_two_ordinal()`:
      ! `prop_bar` must be positive proportions summing to 1.

