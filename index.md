# sampleSizeCalc

> Sample Size Calculator for Clinical Research

A comprehensive R package for sample size determination across **39
design combinations**: experimental trials (superiority /
non-inferiority / equivalence), observational studies (cohort,
case-control, cross-sectional), diagnostic accuracy studies (estimation,
testing, comparison, AUC), and complex designs (cluster RCT, Simon
two-stage, bioequivalence, ordered outcomes, prediction models,
interrupted time series).

Every result displays the formula in plain text and LaTeX, a calculation
process, and literature references in the default R console output.
Parameter roles and methodological hints are included where available.

## Installation

``` r

devtools::install_github("portos-wang/Sample_Size_Calc")
# or from a local source
devtools::install_local("path/to/Sample_Size_Calc")
```

## Quick start: clinical study planning

These are teaching protocols with illustrative clinical inputs. In a
real study, document compatible evidence for the expected effects,
variability, prevalence, and margins; a citation for the formula does
not establish those clinical assumptions. The
[English](https://rpackages.portos.wang/sample_size_calc/articles/sampleSizeCalc-guide-en.html)
and
[Chinese](https://rpackages.portos.wang/sample_size_calc/articles/sampleSizeCalc-guide-zh.html)
guides expand 52 scenarios into population, endpoint, parameter, design,
and recruitment decisions.

**Scenario 1 — Antihypertensive RCT (continuous endpoint).** A blinded,
1:1 parallel trial enrolls adults aged 40–75 with stable background
therapy. The primary endpoint is baseline minus week-12 systolic BP,
using the same averaged seated-reading protocol at both visits. Assume
mean reductions of 10 mmHg with placebo and 12 mmHg with study
treatment, with change-score SD 3 mmHg, two-sided alpha 0.05, and power
80%. The relevant SD is for the change score, not baseline BP. The
decision is how many independent patients with complete endpoints are
required.

``` r

library(sampleSizeCalc)

# design x task x outcome
trial_mean <- calculate("rct", "test", "mean",
  mean1 = 10, mean2 = 12, sd = 3
)
trial_mean
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
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

This requires 37 complete patients per arm. If 10% are expected to lack
the primary endpoint, plan 42 recruits per arm (84 total); this
additional allowance is not included in the displayed RCT result.

**Scenario 2 — *H. pylori* eradication RCT (binary endpoint).** Adults
with confirmed infection are randomized to two 14-day regimens. Define
eradication by a standardized post-treatment breath test in a fixed
follow-up window, with prespecified rules for invalid tests, rescue
treatment, and missing assessments. Assume cure rates of 85% and 70%,
with independent groups, two-sided alpha 0.05, and power 80%. Evidence
for these rates should match treatment history and local resistance
patterns; symptomatic improvement is not the eradication endpoint.

``` r

trial_prop <- calculate("rct", "test", "proportion",
  p1 = 0.85, p2 = 0.70
)
trial_prop
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

The result is 121 patients per arm, 242 total. Endpoint completeness of
90% would require 135 recruits per arm, alongside the prespecified
analysis and missing-data strategy.

**Scenario 3 — Test versus reference formulation (bioequivalence).**
Eligible healthy adults are randomized to AB or BA in a two-period
crossover study. Evaluate one prespecified log-transformed PK endpoint,
such as AUC, with standardized sampling and a justified washout period.
Assume within-subject CV 25%, expected geometric mean ratio 1.0,
acceptance limits 0.80–1.25, one-sided alpha 0.05, and target power 80%.
CV should come from compatible crossover data for the same PK endpoint;
additional co-primary PK endpoints require their own planning.

``` r

be_trial <- calculate("bioequivalence", "equivalence", "mean", cv = 0.25)
be_trial
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Bioequivalence (2x2 crossover, exact TOST noncentral t)"
#> • Required sample size: 12
#> • Total sample size: 24
#> • Power achieved: 0.8372
#> Parameter roles
#> 
#> • cv = intra-subject coefficient of variation (log scale implied)
#> • theta0 = anticipated geometric mean ratio (true ratio, default 1.0)
#> • margin = [0.80, 1.25] average BE criteria
#> • n is per sequence; total subjects = 2n
#> Formula (plain text):
#> `exact TOST (Phillips 1990): power = pt(-t, df, ncp=d2) - pt(t, df, ncp=d1)`
#> Formula (LaTeX):
#> $$\text{Power} = F_t(-t_{1-\alpha,\, \nu};\, \nu,\, \delta_2) - F_t(t_{1-\alpha,\, \nu};\, \nu,\, \delta_1), \quad \nu = N-2$$
#> Calculation process:
#> 
#> • Step 1: Intra-subject variance on log scale: sigma_w = sqrt(ln(1 + CV^2)) =
#> sqrt(ln(1 + 0.25^2)) = 0.2462.
#> • Step 2: Standard BE log-scale boundaries: [ln(0.80), ln(1.25)] = [-0.2231,
#> 0.2231].
#> • Step 3: Two One-Sided Tests (TOST) under assumed geometric mean ratio theta0
#> = 1.
#> • Step 4: Search sequence sample size n by evaluating the difference of
#> noncentral t distribution probabilities (Phillips 1990; df = 2n - 2).
#> • Step 5: Required sample size: n = 12 per sequence (achieved power = 0.8372,
#> Total N = 24).
#> Reference:
#> Primary: Phillips, K. F. (1990). Power of the two one-sided tests procedure in bioequivalence. Journal of Pharmacokinetics and Biopharmaceutics, 18(2), 137-144.
#> 
#>  Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes for clinical trials with normal data. Statistics in Medicine, 23, 1921-1986 (Eq 13, p. 1941);
#>  Schuirmann, D. J. (1987). J Pharmacokinet Biopharm, 15(6), 657-680;
#>  Chow & Liu (2009). Design and Analysis of Bioavailability and Bioequivalence Studies.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

This needs 12 complete subjects per sequence, 24 total, each completing
both periods. With 10% incomplete follow-up, a balanced recruitment plan
is 28 subjects.

**Scenario 4 — Diagnostic sensitivity in a colorectal referral clinic.**
Consecutively enroll symptomatic or high-risk patients referred for
colonoscopy, collect the index-test specimen before reference
assessment, and keep the positive threshold fixed. Assume sensitivity
85%, a 95% CI half-width of 0.05, and disease prevalence 20% in this
referral setting. Prevalence converts confirmed-case requirements into
screening capacity; it is not the test sensitivity and need not match
community prevalence. Plan specificity separately if it is also a
primary objective.

``` r

diag_precision <- calculate("diagAccuracy", "estimate", "proportion",
  prob = 0.85, d = 0.05, prevalence = 0.2
)
diag_precision
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic accuracy (single)"
#> • Cases needed: 196
#> • Total subjects to screen: 980
#> • Total subjects: 980
#> Formula (plain text):
#> `N_cases = (Z_1-a/2)^2 * P*(1-P)/d^2`
#> Formula (LaTeX):
#> $$n_{{{cases}}} = \frac{Z_{1-\alpha/2}^2 \cdot p(1-p)}{d^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify diagnostic accuracy prob (Se or Sp) = 0.85, margin of error d
#> = 0.05, prevalence = 0.20 (alpha = 0.05).
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Calculate target cases required: n_cases = Z_sum^2 * prob * (1 -
#> prob) / d^2 = (1.96)^2 * 0.85 * 0.15 / (0.05)^2 = 195.91.
#> • Step 4: Adjust for disease prevalence: total subjects to screen = n_cases /
#> prevalence = 195.91 / 0.20 = 979.57.
#> • Step 5: Round up to integer: Target cases needed = 196, Total subjects to
#> screen = 980.
#> Reference:
#> Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.
#> 
#> Review: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

The requirement is 196 confirmed cases, with an expectation-based
screening total of 980. A 90% probability of enough cases instead
requires 1061 complete participants under the binomial prevalence
assumption. Incomplete reference examinations need additional
operational allowance.

**Scenario 5 — Diabetes prevalence in a defined older population.** A
district survey samples eligible residents aged 65 years or older from
an explicit population frame. Apply the same disease-ascertainment
protocol to each participant. For teaching, assume prevalence 30% and
seek a 95% CI absolute half-width of 5 percentage points; this is
precision estimation, so no between-group difference or target power is
specified. Cluster sampling and nonresponse require separate
adjustments.

``` r

survey <- calculate("singleProportion", p = 0.30, precision = 0.05)
survey
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single proportion estimation (precision)"
#> • Required sample size: 323
#> Parameter roles
#> 
#> • p = expected proportion (e.g. prevalence)
#> • precision = margin of error d (half-width of the CI)
#> • confidence level = 95%
#> Formula (plain text):
#> `n = Z^2 * p(1-p) / d^2`
#> Formula (LaTeX):
#> $$n = \frac{Z_{1-\alpha/2}^2 \cdot p(1-p)}{d^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify anticipated proportion p = 0.30, margin of error d = 0.05
#> (absolute precision), alpha = 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Compute variance component: p * (1 - p) = 0.30 * 0.70 = 0.21.
#> • Step 4: Calculate unrounded sample size: n = Z_(1-alpha/2)^2 * p * (1 - p) /
#> d^2 = (1.96)^2 * 0.21 / (0.05)^2 = 322.68.
#> • Step 5: Round up to integer: Required sample size n = 323.
#> Reference:
#> Bhardwaj et al. (2024). Determination of sample size for various study designs in medical research: A practical primer. Journal of Family Medicine and Primary Care, 13(7), 2555-2561 (p. 2558).
#> 
#> Also: Lwanga, S. K., & Lemeshow, S. (1991). Sample size determination in health studies: A practical manual. World Health Organization.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

Obtain 323 valid records; at a 90% response rate, invite about 359
people before any design-effect adjustment.

**Scenario 6 — Precision of a continuous biomarker’s AUC.** Select
reference-confirmed cases and clinically comparable non-cases in equal
numbers, using a frozen score and one observation per patient. Assume
AUC 0.80 and a 95% CI half-width of 0.10 under a binormal variance
model. The quota sample estimates discrimination; it does not directly
estimate population prevalence. Because this design is unambiguous,
`task` and `outcome` can be omitted:

``` r

auc_precision <- calculate("diagAUC", auc = 0.80, d = 0.10,
  ratio = 1, var_method = "binormal"
)
auc_precision
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-group AUC CI precision"
#> • Cases needed: 46
#> • Total subjects to screen: 92
#> • Total subjects: 92
#> Parameter roles
#> 
#> • auc = anticipated area under the ROC curve
#> • precision = desired CI half-width L
#> • ratio = case:control ratio R (cases:non-cases; default 1)
#> • var_method = binormal variance function
#> Formula (plain text):
#> `N_cases = (Z_1-a/2 / d)^2 * V(AUC)`
#> Formula (LaTeX):
#> $$n_{cases} = \left(\frac{Z_{1-\alpha/2}}{d}\right)^2 \cdot V(AUC)$$
#> Calculation process:
#> 
#> • Step 1: Anticipated AUC = 0.80, precision d = 0.10, supplied allocation R =
#> 1, alpha = 0.05.
#> • Step 2: Use the binormal variance model with the supplied allocation: V(AUC)
#> = 0.1195.
#> • Step 3: Calculate cases: n_cases = (Z_(1-alpha/2)/d)^2 * V(AUC) =
#> (1.96/0.10)^2 * 0.1195 = 45.89.
#> • Step 4: Convert using the supplied allocation: total = n_cases*(1+R) =
#> 45.89*(1+1) = 91.78.
#> • Step 5: Round up: Target cases needed = 46, Total subjects to screen = 92.
#> Reference:
#> Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley. Section 6.1.2, pp. 196-199 (Eq 6.4/6.5/6.6; CTC worked example).
#> 
#>  Original variance: Hanley, J. A., & McNeil, B. J. (1982). Radiology, 143(1), 29-36.
#>  Binormal variance: Obuchowski, N. A. (1994). Medical Decision Making, 14(2), 154-162.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

Plan 46 cases and the same number of non-cases, each contributing a
complete score and reference result.

Illegal combinations error with the list of legal ones. The [English
guide](https://rpackages.portos.wang/sample_size_calc/articles/sampleSizeCalc-guide-en.html)
and [Chinese
guide](https://rpackages.portos.wang/sample_size_calc/articles/sampleSizeCalc-guide-zh.html)
cover design choices, parameters, formulas, and worked clinical
examples. The [regression
tests](https://github.com/portos-wang/Sample_Size_Calc/tree/master/tests/testthat)
check sample sizes against published examples.

## Legacy API (silently compatible)

All 17 pre-3.0 keywords keep working with identical results:

``` r

sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)  # 37/group
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
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
sample_size_calculator("survival", hr = 0.7)                        # 247 events
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
```

## Result object

[`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
returns a `sample_size_result` S3 object. Printing the object (or
calling [`print()`](https://rdrr.io/r/base/print.html)) displays the
design, sample size, and all four report components:

| Report component | Console label | Result field |
|----|----|----|
| Plain-text formula | `Formula (plain text)` | `formula` |
| LaTeX source | `Formula (LaTeX)` | `formula_latex` |
| Calculation process | `Calculation process` | `calculation_steps` (also `calculation`) |
| Literature sources | `Reference` | `reference` |

The same reporting components are available through
[`sample_size_calculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md).
Assigning a result to a variable stores it; print that variable to
display the report. [`summary()`](https://rdrr.io/r/base/summary.html)
additionally shows all input parameters, classification axes, and
recorded adjustments.
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) provides the
supported visual diagnostics.

``` r

res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
summary(res)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Summary
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Study Design
#> • Type: "Two independent samples, mean comparison"
#> • Design: "rct"
#> • Task: "test" | Outcome: "mean"
#> 
#> ── Parameters
#> • mean1: 10
#> • mean2: 12
#> • sd: 3
#> • alpha: 0.05
#> • power: 0.8
#> 
#> ── Sample Size Results
#> • Sample size per group: 37
#> • Total sample size: 74
#> 
#> ── Formula
#> Plain text:
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> LaTeX:
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
#> 
#> ── Calculation Process
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
#> 
#> ── Reference
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
```

You can also extract the report components for a protocol or manuscript:

``` r

res$formula
cat(res$formula_latex)
cat(res$calculation_steps, sep = "\n")
cat(res$reference)
```

The R console displays LaTeX as copyable source. In an R Markdown
document, use `cat(res$formula_latex)` in a chunk with
`results = "asis"` to typeset it. See the [reporting
guide](https://rpackages.portos.wang/sample_size_calc/articles/result-reporting.html)
for an executed example and instructions in English and Chinese.

## Study designs (family overview)

| Family | Designs |
|----|----|
| Trials | `rct` (test/NI/superiority/equivalence x mean/proportion/survival), `paired` (mean/proportion), `rctSingleArm`, `crossover`, `bioequivalence`, `singleArmPhaseII` (Simon optimal/minimax, A’Hern) |
| Observational | `cohort` (proportion/rate), `caseControl`, `caseControlMatched`, `crosstab` |
| Diagnostic | `diagAccuracy` (estimate/test/dual-endpoint), `diagAccuracyCompare` (test/NI/equivalence), `diagAUC`, `diagAUCCompare` (test/NI/equivalence), `diagLR` |
| Estimation | `singleProportion`, `singleMean`, `singleCorrelation` |
| Complex | `clusterRCT`, `steppedWedge`, `kappa`, `twoOrdinal`, `predictiveModel`, `its` (experimental) |

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
  version = {3.1.1},
  url = {https://github.com/portos-wang/Sample_Size_Calc}
}
```

## License

MIT (see
[LICENSE](https://github.com/portos-wang/Sample_Size_Calc/blob/master/LICENSE)).
