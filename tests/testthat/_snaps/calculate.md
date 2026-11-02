# unknown design errors with valid design list

    Code
      calculate("rctMean", mean1 = 1, mean2 = 2, sd = 3)
    Condition
      Error in `ssr_resolve()`:
      ! Unknown design "rctMean".
      i Valid designs: "rct", "paired", "caseControl", "diagAccuracy", "diagAccuracyCompare", "diagLR", "diagAUC", "diagAUCCompare", "singleProportion", "singleMean", "singleCorrelation", "cohort", "caseControlMatched", "crosstab", "rctSingleArm", "crossover", "bioequivalence", "clusterRCT", ..., "predictiveModel", and "its"
      i See docs/DESIGN_MATRIX.md for the full combination table.

# cohort outcome=mean is an illegal combination (rate/proportion only)

    Code
      calculate("cohort", "test", "mean")
    Condition
      Error in `ssr_resolve()`:
      ! Illegal combination: design "cohort", task "test", outcome "mean".
      i Legal combinations: (cohort, test, proportion), (cohort, test, rate)

