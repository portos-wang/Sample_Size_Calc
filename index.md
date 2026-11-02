# sampleSizeCalc

> Sample Size Calculator for Clinical Research

A comprehensive R package for sample size determination across **39
design combinations**: experimental trials (superiority /
non-inferiority / equivalence), observational studies (cohort,
case-control, cross-sectional), diagnostic accuracy studies (estimation,
testing, comparison, AUC), and complex designs (cluster RCT, Simon
two-stage, bioequivalence, ordered outcomes, prediction models,
interrupted time series).

Every result carries: the formula (plain text + LaTeX), precise
literature references (section/page level), parameter-role
documentation, and methodological hints.

## Installation

``` r

devtools::install_github("portos-wang/sampleSizeCalc")
# or from a local source
devtools::install_local("path/to/Sample_Size_Calc")
```

## Quick start: the three-axis API

``` r

library(sampleSizeCalc)

# design x task x outcome
calculate("rct", "test", "mean",
  mean1 = 10, mean2 = 12, sd = 3
)
calculate("rct", "noninferiority", "proportion",
  p1 = 0.90, p2 = 0.85, margin = 0.05
)
calculate("cohort", "test", "proportion",
  p0 = 0.20, p1 = 0.30, ratio = 2, dropout = 0.10
)
calculate("caseControl", "test", "proportion", p0 = 0.3, OR = 2.0)
calculate("diagAccuracy", "estimate", "proportion",
  prob = 0.85, d = 0.05, prevalence = 0.2
)
calculate("diagAUC", "estimate", "auc",
  auc = 0.80, d = 0.10, ratio = 1, var_method = "binormal"
)
calculate("singleArmPhaseII", "test", "proportion",
  p0 = 0.1, p1 = 0.3, optimizer = "optimal"
)
calculate("clusterRCT", "test", "mean",
  mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20
)
calculate("bioequivalence", "equivalence", "mean", cv = 0.25)
```

Unambiguous designs allow omitting `task`/`outcome`:

``` r

calculate("diagAUC", auc = 0.80, d = 0.05)
calculate("singleProportion", p = 0.30, precision = 0.05)   # -> 323
```

Illegal combinations error with the list of legal ones. The full design
x task x outcome table, formulas, and sources live in
[docs/DESIGN_MATRIX.md](https://portos-wang.github.io/Sample_Size_Calc/docs/DESIGN_MATRIX.md);
published worked examples used as numeric test anchors are catalogued in
[docs/NUMERIC_ANCHORS.md](https://portos-wang.github.io/Sample_Size_Calc/docs/NUMERIC_ANCHORS.md).

## Legacy API (silently compatible)

All 17 pre-3.0 keywords keep working with identical results:

``` r

sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)  # 37/group
sample_size_calculator("survival", hr = 0.7)                        # 65 events
```

## Result object

[`calculate()`](https://portos-wang.github.io/Sample_Size_Calc/reference/calculate.md)
returns a `sample_size_result` S3 object with
[`print()`](https://rdrr.io/r/base/print.html),
[`summary()`](https://rdrr.io/r/base/summary.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods.
[`print()`](https://rdrr.io/r/base/print.html) shows the metrics, the
role of each parameter under the chosen design, and any methodological
hints; [`summary()`](https://rdrr.io/r/base/summary.html) adds the
formula, LaTeX, precise references and the adjustment audit trail.

## Study designs (family overview)

| Family | Designs |
|----|----|
| Trials | `rct` (test/NI/superiority/equivalence x mean/proportion/rate/survival), `paired` (mean/proportion), `rctSingleArm`, `crossover`, `bioequivalence`, `singleArmPhaseII` (Simon optimal/minimax, A’Hern) |
| Observational | `cohort` (proportion/rate), `caseControl`, `caseControlMatched`, `crosstab` |
| Diagnostic | `diagAccuracy` (estimate/test/dual-endpoint), `diagAccuracyCompare` (test/NI/equivalence), `diagAUC`, `diagAUCCompare` (test/NI/equivalence), `diagLR` |
| Estimation | `singleProportion`, `singleMean`, `singleCorrelation` |
| Complex | `clusterRCT`, `twoOrdinal`, `predictiveModel`, `its` (experimental) |
| Deferred | `kappa`, `steppedWedge` (formula sources under verification) |

## Literature

Methods are anchored to primary sources, with worked examples from the
reference literature used as automated numeric test benchmarks:

- Zhou, Obuchowski & McClish (2011). *Statistical Methods in Diagnostic
  Medicine* (2nd ed.), Wiley - diagnostic module.
- Machin, Campbell, Tan & Tan (2018). *Sample Sizes for Clinical,
  Laboratory and Epidemiology Studies* (4th ed.), Wiley - trial/complex
  designs.
- Hajian-Tilaki (2014). *J Biomed Informatics* 48:193-204 - diagnostic
  formulas.
- Akoglu (2022). *Turkish J Emergency Medicine* 22(4):177-185 -
  diagnostic comparisons and dual-endpoint strategy.
- Bhardwaj et al. (2024). *J Family Med Prim Care* 13(7):2555-2561 -
  prevalence studies and dropout adjustment.
- Plus the original methods: Schoenfeld (1983), Fleiss et al. (1980),
  Casagrande et al. (1978), Schlesselman (1982), Dupont (1988), Connor
  (1987), Hanley & McNeil (1982/1983), Buderer (1996), Simon (1989),
  A’Hern (2001), Whitehead (1993), Peduzzi et al. (1996), Schuirmann
  (1987).

## Citation

If you use the package in research, please cite the original methodology
papers for each design (listed in every result’s `reference` field)
along with the package:

``` bibtex
@software{sampleSizeCalc,
  title = {sampleSizeCalc: Sample Size Calculator for Clinical Research},
  author = {Portos (Yishan) Wang and Bingxin Cai},
  organization = {Gansu Provincial Maternity and Child-care Hospital (Gansu Provincial Central Hospital)},
  year = {2026},
  version = {3.1.0},
  url = {https://github.com/portos-wang/sampleSizeCalc}
}
```

## License

MIT (see
[LICENSE](https://portos-wang.github.io/Sample_Size_Calc/LICENSE)).
