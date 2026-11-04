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

  Study design keyword. One of:

  |  |  |  |
  |----|----|----|
  | Keyword | Design | Key parameters |
  | `twoMeans` | two-arm superiority RCT, continuous | `mean1`, `mean2`, `sd` |
  | `twoProportions` | two-arm RCT, binary | `p1`, `p2` |
  | `pairedMeans` | pre-post / matched pairs, continuous | `meanDiff`, `sdDiff` |
  | `survival` | log-rank events | `hr`, `pE` |
  | `nonInferiorityMeans` | NI trial, continuous | `mean1`, `mean2`, `sd`, `margin` |
  | `superiorityMeans` | superiority, continuous | `mean1`, `mean2`, `sd`, `margin` |
  | `equivalenceMeans` | equivalence, continuous | `mean1`, `mean2`, `sd`, `margin` |
  | `diagnosticAccuracySingle` | Se/Sp precision | `prob`, `d`, `prevalence` |
  | `caseControl` | unmatched case-control | `p0`, `OR`, `m` |
  | `superiorityProportions` | superiority, binary | `p1`, `p2`, `margin` |
  | `diagnosticSuperioritySingle` | Se vs null | `prob`, `p0`, `prevalence` |
  | `diagnosticComparisonTwo` | two tests | `p1`, `p2`, `prevalence`, `paired`, `psi` |
  | `likelihoodRatioTest` | LR precision | `sens`, `spec`, `prevalence`, `precision` |
  | `auc_single` | AUC CI precision | `auc`, `d`, `prevalence` |
  | `aucSuperiority` | AUC vs null | `auc`, `auc0`, `prevalence` |
  | `aucComparison` | two AUCs | `auc1`, `auc2`, `r`, `prevalence` |
  | `equivalenceProportions` | equivalence, binary | `p1`, `p2`, `margin` |

  New code should prefer the three-axis
  [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  API.

- alpha:

  Type I error; scalar in (0, 1). Default 0.05 (two-sided designs).
  Non-inferiority designs interpret alpha as one-sided (use 0.025 to
  spend a full two-sided 0.05).

- power:

  Target power; scalar in (0, 1), typically 0.8 or 0.9. Default 0.8.

- ...:

  Design-specific arguments (see the table in `design` and
  [`?calculate`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  for domains; e.g. `mean1`, `mean2`, `sd` for twoMeans). Parameters
  outside their validated domain abort with a structured `cli` error
  naming the offending argument.

## Value

Object of class `sample_size_result` with print, summary, and plot
methods. Default printing includes the plain-text formula (`formula`),
LaTeX source (`formula_latex`), calculation process
(`calculation_steps`, alias `calculation`), and literature references
(`reference`). These fields can also be extracted directly from the
object. See
[`print.sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/print.sample_size_result.md)
and
[`summary.sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/summary.sample_size_result.md).

## Details

`sample_size_calculator()` is the legacy single-keyword API retained for
backward compatibility. New code should prefer the three-axis
[`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
entry point; see inst/reference/DESIGN_MATRIX.md for the keyword
mapping. Results are identical between the two entry points.

## Functions

- `sampleSizeCalculator()`: Deprecated alias; use
  `sample_size_calculator`.

## Examples

``` r
# Antihypertensive RCT: 10 vs 12 mmHg SBP reduction, SD 3 -> 37 per arm
sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two independent samples, mean comparison"
#> • Sample size per group: 37
#> • Total sample size: 74
#> Formula (plain text):
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$ 
#> Calculation process:
#> 
#> • Step 1: State hypotheses: H0: mu1 = mu2 vs H1: mu1 != mu2 (two-sided alpha =
#> 0.05, power = 0.80).
#> • Step 2: Calculate mean difference delta = |mu1 - mu2| = |10 - 12| = 2; common
#> SD sigma = 3.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96 (for two-sided alpha =
#> 0.05), Z_beta = 0.8416 (for power = 0.80).
#> • Step 4: Compute initial sample size via normal approximation: n0 = 2 *
#> ((Z_(alpha/2) + Z_beta) * sigma / delta)^2 = 2 * ((1.96 + 0.8416) * 3 / 2)^2 =
#> 35.32.
#> • Step 5: Refine via exact two-sample Student's t-test power iteration
#> (accounting for degrees of freedom df = 2n - 2).
#> • Step 6: Round up to integer: n = 37 per group, total sample size N = 74.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 3 (Comparing Means), Section 3.2.1 two-sample parallel design, Eq 3.11 (p. 48; the Student t refinement is Table 3.2, p. 49).
#> 
#>  Also: Machin et al. (2018) Eq 5.4, p. 69 (same formula with the Student t correction term). 
#> ────────────────────────────────────────────────────────────────────────────────
#> 

# NSCLC immunotherapy trial: HR = 0.70, 1:1 allocation -> 247 events
sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Survival (log-rank)"
#> • Events needed: 247
#> Formula (plain text):
#> `E = (Z_a/2 + Z_b)^2 / (pE*(1-pE)*log(HR)^2)`
#> Formula (LaTeX):
#> $$E = \frac{(Z_{\alpha/2} + Z_{\beta})^2}{p_E(1-p_E)[\ln(HR)]^2}$$ 
#> Calculation process:
#> 
#> • Step 1: State survival parameters: Hazard Ratio HR = 0.70, experimental arm
#> allocation pE = 0.50 (alpha = 0.05, power = 0.80).
#> • Step 2: Compute log hazard ratio: ln(HR) = ln(0.70) = -0.3567.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Apply Schoenfeld formula: E = (Z_(alpha/2) + Z_beta)^2 / [pE * (1 -
#> pE) * (ln HR)^2] = (1.96 + 0.8416)^2 / [0.50 * 0.50 * (-0.3567)^2] = 246.79.
#> • Step 5: Round up to integer: Target events needed E = 247.
#> Reference:
#> Primary: Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. Biometrics, 39(2), 499-503.
#> 
#> Extensions:
#> - Hsieh, F. Y., & Lavori, P. W. (2000). Sample-size calculations for the Cox proportional hazards regression model with nonbinary covariates. Controlled Clinical Trials, 21(6), 552-560.
#> - Rubinstein, L. V., Gail, M. H., & Santner, T. J. (1981). Planning the duration of a comparative clinical trial with loss to follow-up and a period of continued observation. Journal of Chronic Diseases, 34(9-10), 469-479. 
#> ────────────────────────────────────────────────────────────────────────────────
#> 

# H. pylori eradication: quadruple 85% vs triple 70% -> 121 per arm
sample_size_calculator("twoProportions", p1 = 0.85, p2 = 0.70)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two independent proportions"
#> • Sample size per group: 121
#> • Total sample size: 242
#> Formula (plain text):
#> `n = (Z_a/2 * sqrt(2*p_bar*(1-p_bar)) + Z_b * sqrt(p1*(1-p1)+p2*(1-p2)))^2 /
#> (p1-p2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_2(1-p_2)}\right]^2}{(p_1 - p_2)^2}$$ 
#> Calculation process:
#> 
#> • Step 1: State hypotheses: H0: p1 = p2 vs H1: p1 != p2 (two-sided alpha =
#> 0.05, power = 0.80).
#> • Step 2: Compute pooled proportion: p_bar = (p1 + p2) / 2 = (0.85 + 0.70) / 2
#> = 0.775.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Compute Fleiss formula numerator components:
#> Z_(alpha/2)*sqrt(2*p_bar*(1-p_bar)) = 1.1575; Z_beta*sqrt(p1(1-p1)+p2(1-p2)) =
#> 0.4889.
#> • Step 5: Calculate unrounded sample size per group: n = (1.1575 + 0.4889)^2 /
#> (0.85 - 0.70)^2 = 120.47.
#> • Step 6: Round up to integer: n = 121 per group, total sample size N = 242.
#> Reference:
#> Primary (formula as implemented, without continuity correction): Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346.
#> 
#> With continuity correction: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-494.
#> 
#> Book: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley. 
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```
