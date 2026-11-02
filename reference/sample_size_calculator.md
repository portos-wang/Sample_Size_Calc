# Sample size calculator for clinical study designs (legacy API)

Computes sample size (or events) for two-group or single-group designs:
continuous outcomes, proportions, survival (log-rank), diagnostic
accuracy, case-control, AUC comparisons,
non-inferiority/superiority/equivalence. Uses parameter validation and
unified S3 result objects.

## Usage

``` r
sample_size_calculator(
  design = c("twoMeans", "twoProportions", "pairedMeans", "survival",
    "nonInferiorityMeans", "superiorityMeans", "equivalenceMeans",
    "diagnosticAccuracySingle", "caseControl", "superiorityProportions",
    "diagnosticSuperioritySingle", "diagnosticComparisonTwo", "likelihoodRatioTest",
    "auc_single", "aucSuperiority", "aucComparison", "equivalenceProportions"),
  alpha = 0.05,
  power = 0.8,
  ...
)

sampleSizeCalculator(design, alpha = 0.05, power = 0.8, ...)
```

## Arguments

- design:

  Study design type (see list in usage).

- alpha:

  Type I error (default 0.05).

- power:

  Target power (default 0.8).

- ...:

  Design-specific arguments (e.g. mean1, mean2, sd for twoMeans).

## Value

Object of class `sample_size_result` with `print`, `summary`, `plot`
methods.

## Details

`sample_size_calculator()` is the legacy single-keyword API retained for
backward compatibility. New code should prefer the three-axis
[`calculate()`](https://portos-wang.github.io/Sample_Size_Calc/reference/calculate.md)
entry point; see docs/DESIGN_MATRIX.md for the keyword mapping. Results
are identical between the two entry points.

## Functions

- `sampleSizeCalculator()`: Deprecated alias; use
  `sample_size_calculator`.

## Examples

``` r
sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two independent samples, mean comparison"
#> • Sample size per group: 37
#> • Total sample size: 74
#> ────────────────────────────────────────────────────────────────────────────────
sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Survival (log-rank)"
#> • Events needed: 247
#> ────────────────────────────────────────────────────────────────────────────────
```
