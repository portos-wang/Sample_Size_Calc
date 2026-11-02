# Unified sample size calculator (three-axis API)

Computes sample size (or events/cases) for a study design identified by
the triple design / task / outcome. See `docs/DESIGN_MATRIX.md` (source
repository) for the complete combination table, formulas, and literature
sources.

## Usage

``` r
calculate(...)
```

## Arguments

- ...:

  Control and design arguments, resolved by EXACT name (partial matching
  is deliberately avoided so that design-specific arguments such as `d`
  cannot be swallowed by the `design` slot). Recognised control
  arguments: `design` (e.g. "rct", "caseControl", "diagAccuracy"; may be
  the first positional argument), `task` ("estimate", "test",
  "noninferiority", "superiority", "equivalence"; optional for
  unambiguous designs, may be the second positional argument), `outcome`
  ("mean", "proportion", "rate", "survival", "auc", "lr", "correlation",
  "ordinal", "events"; optional for unambiguous designs, may be the
  third positional argument), `alpha` (type I error, default 0.05), and
  `power` (target power, default 0.8). All remaining named arguments are
  design-specific parameters, identical to the names used by the legacy
  [`sample_size_calculator()`](https://portos-wang.github.io/Sample_Size_Calc/reference/sample_size_calculator.md)
  API.

## Value

Object of class `sample_size_result` with print, summary, and plot
methods. New-style objects additionally carry axis metadata (task,
outcome, design_canonical, results, roles, adjustments).

## Examples

``` r
calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two independent samples, mean comparison"
#> • Sample size per group: 37
#> • Total sample size: 74
#> ────────────────────────────────────────────────────────────────────────────────
calculate(
  design = "rct", task = "noninferiority", outcome = "mean",
  mean1 = 10, mean2 = 9.5, sd = 3, margin = 1
)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Non-inferiority (means)"
#> • Sample size per group: 50
#> • Total sample size: 100
#> ────────────────────────────────────────────────────────────────────────────────
calculate("diagAUC", auc = 0.80, d = 0.05)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-group AUC CI precision"
#> ────────────────────────────────────────────────────────────────────────────────
```
