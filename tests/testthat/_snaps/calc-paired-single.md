# discordance cannot imply negative joint probabilities

    Code
      calculate("paired", "test", "proportion", p1 = 0.9, p2 = 0.8, psi = 0.8)
    Condition
      Error in `paired_proportion_n()`:
      ! `psi` is incompatible with `p1` and `p2`: the implied joint probabilities must be non-negative.

