# sampleSizeCalc: A Comprehensive Guide to Sample Size Determination in Clinical Research

## Introduction: The Lifeblood of Clinical Research

For clinical investigators, calculating sample size is often the most
critical step when preparing grant proposals or IRB submissions.

Underpowered trials risk false-negative findings (\\P \> 0.05\\),
wasting research grants and patient effort. Conversely, overpowered
trials waste resources and expose unnecessary subjects to experimental
risks.

The `sampleSizeCalc` package provides support for **42 specific clinical
scenarios**. Default printed results include the plain-text formula,
LaTeX source, calculation process, and literature references, with
parameter roles where available. **Every executable example below runs
when the site is built**, so its output comes from the package.

------------------------------------------------------------------------

## Plain-English Glossary of Statistical Terms

- **\\\alpha\\ (Type I Error / False Positive)**: The probability of
  declaring a treatment effective when it truly is not — the
  “probability of convicting an innocent drug” (conventionally
  **0.05**).
- **\\\text{Power} = 1 - \beta\\ (True Positive Detection)**: The
  probability of catching a true effect when it exists — the
  “probability of catching the real culprit” (routinely **0.80** or
  **0.90**).
- **Continuous vs. Binary Endpoints**: Continuous measures numerical
  values (systolic BP drop in mmHg, fasting glucose in mmol/L); binary
  measures event status (eradicated vs. not, cured vs. not).
- **Two-Sided vs. One-Sided**: Two-sided tests for differences in either
  direction (classical RCTs); one-sided tests for non-inferiority and
  directional superiority.
- **Dropout Rate (\\d\\)**: Inflation formula \\N\_{\text{screen}} =
  \lceil N / (1 - d) \rceil\\.

------------------------------------------------------------------------

## Unified Syntax: The Three-Axis Function `calculate()`

\\\texttt{calculate(design, task, outcome, ...)}\\

- **Axis 1 `design`**: what type of study? (`"rct"`, `"paired"`,
  `"cohort"`, `"caseControl"`, `"diagAccuracy"`, `"diagAUC"`,
  `"singleArmPhaseII"`, `"bioequivalence"`, `"clusterRCT"`, …)
- **Axis 2 `task`**: what scientific question? (`"test"` hypothesis
  testing, `"estimate"` CI precision, `"noninferiority"`,
  `"superiority"`, `"equivalence"`)
- **Axis 3 `outcome`**: how is the endpoint measured? (`"mean"`,
  `"proportion"`, `"survival"`, `"auc"`, `"rate"`, `"ordinal"`, `"lr"`,
  `"correlation"`, `"events"`)

Printing a result shows the formula in plain text and LaTeX, the
calculation process, and references.
[`summary()`](https://rdrr.io/r/base/summary.html) also lists all
inputs, design axes, and recorded adjustments.

------------------------------------------------------------------------

## Chapter 1: Randomized Controlled Trials (RCTs)

### 1.1 Two Independent Means (Continuous Endpoint)

- **Clinical scenario**: A cardiology group runs a phase-III
  antihypertensive trial of a new ACE-inhibitor vs. placebo. The
  phase-II data showed a mean systolic BP reduction of 10 mmHg on
  placebo and 12 mmHg on the new drug, with a pooled SD of 3 mmHg.
  Two-sided \\\alpha = 0.05\\, power 80%.
- **Formula**: \\n = 2\left(\frac{(Z\_{\alpha/2} + Z\_{\beta}) \cdot
  \sigma}{\mu_1 - \mu_2}\right)^2\\ Chow, Shao, Wang & Lokhnygina
  (2017), *Sample Size Calculations in Clinical Research* (3rd ed.), CRC
  Press.

``` r

res_1_1 <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)
print(res_1_1)
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

- **Output**: 37 patients per arm, 74 total. The calculation process
  shows the normal approximation (about 35.32 per arm), then explains
  the noncentral t power calculation used by
  [`stats::power.t.test()`](https://rdrr.io/r/stats/power.t.test.html)
  and rounding to 37.

#### The four report components

| Component | Console label | Result field |
|----|----|----|
| Plain-text formula | `Formula (plain text)` | `formula` |
| LaTeX source | `Formula (LaTeX)` | `formula_latex` |
| Calculation process | `Calculation process` | `calculation_steps` (alias `calculation`) |
| References | `Reference` | `reference` |

``` r

res_1_1$formula
cat(res_1_1$formula_latex)
cat(res_1_1$calculation_steps, sep = "\n")
cat(res_1_1$reference)
```

The R console displays copyable LaTeX source. To typeset it in R
Markdown, use `cat(res_1_1$formula_latex)` in a chunk with
`results = "asis"`. The [reporting
guide](https://portos-wang.github.io/Sample_Size_Calc/articles/result-reporting.md)
includes an executed example and instructions for saving the report.

### 1.2 Two Independent Proportions (Binary Endpoint)

- **Clinical scenario**: Gastroenterology trial of *H. pylori*
  eradication: 14-day bismuth quadruple therapy is expected to eradicate
  85% of infections vs. 70% with standard triple therapy. Two-sided
  \\\alpha = 0.05\\, power 80%.
- **Formula** (Fleiss asymptotic): \\n =
  \frac{\left\[Z\_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} +
  Z\_{\beta}\sqrt{p_1(1-p_1)+p_2(1-p_2)}\right\]^2}{(p_1-p_2)^2}\\
  Fleiss, Tytun & Ury (1980), *Biometrics* 36(2), 343-346.

``` r

res_1_2 <- calculate("rct", "test", "proportion", p1 = 0.85, p2 = 0.70, alpha = 0.05, power = 0.8)
print(res_1_2)
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

- **Output**: 121 patients per arm, 242 total.

### 1.3 Survival Analysis (Log-Rank Test Events)

- **Clinical scenario**: Oncology trial of first-line immunotherapy
  vs. chemotherapy in non-small-cell lung cancer; the anticipated hazard
  ratio is HR = 0.70 with 1:1 allocation. How many deaths/progressions
  must accrue?
- **Formula** (Schoenfeld): \\E = \frac{(Z\_{\alpha/2} +
  Z\_{\beta})^2}{p_E(1 - p_E)\[\ln(HR)\]^2}\\ Schoenfeld (1983),
  *Biometrics* 39(2), 499-503.

``` r

res_1_3 <- calculate("rct", "test", "survival", hr = 0.70, pE = 0.50, alpha = 0.05, power = 0.8)
print(res_1_3)
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

- **Output**: Exactly **247 primary events (deaths/progressions)**
  required.

### 1.4 Non-Inferiority Trial (Continuous Mean)

- **Clinical scenario**: A domestic generic antidiabetic must show it is
  not worse than the originator by more than the prespecified margin. On
  a 0-30 neuropathy symptom score the improvement is expected to be 10
  vs. 9.5 points (SD = 3); the margin is \\\Delta = 1.0\\. One-sided
  \\\alpha = 0.05\\.
- **Formula**: \\n = 2\left(\frac{(Z\_{\alpha} +
  Z\_{\beta})\sigma}{\mu_1 - \mu_2 + \Delta}\right)^2\\ Chow et
  al. (2017), Chapter 4.

``` r

res_1_4 <- calculate("rct", "noninferiority", "mean", mean1 = 10, mean2 = 9.5, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Non-inferiority (means)"
#> • Sample size per group: 50
#> • Total sample size: 100
#> Formula (plain text):
#> `n = 2*(Z_a+Z_b)^2*sd^2/(mean1-mean2+margin)^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{(Z_{\alpha} + Z_{\beta})\sigma}{\mu_1 - \mu_2 + \Delta}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State non-inferiority hypotheses: H0: mu1 - mu2 <= -margin vs H1: mu1
#> - mu2 > -margin (margin Delta = 1, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = mu1 - mu2 + margin = 10 - 9.50 + 1 =
#> 1.50; SD sigma = 3.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 /
#> delta_E^2 = 2 * (1.6449 + 0.8416)^2 * 3^2 / (1.50)^2 = 49.46.
#> • Step 5: Round up to integer: n = 50 per group, total sample size N = 100.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 50 per arm, 100 total.

### 1.5 Non-Inferiority Trial (Binary Endpoint)

- **Clinical scenario**: A generic antibiotic must show non-inferior
  cure rates vs. the originator: both anticipated at 85%, with a
  clinically acceptable margin of 5% (\\\Delta = 0.05\\). One-sided
  \\\alpha = 0.05\\.
- **Formula**: \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(p_1-p_2+\Delta)^2}\\
  Chow et al. (2017); Machin et al. (2018) Ch. 11.

``` r

res_1_5 <- calculate("rct", "noninferiority", "proportion", p1 = 0.85, p2 = 0.85, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_1_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Non-inferiority (proportions)"
#> • Sample size per group: 631
#> • Total sample size: 1262
#> Parameter roles
#> 
#> • p1 = experimental-group response rate
#> • p2 = active-control response rate
#> • margin = non-inferiority margin Delta (one-sided alpha)
#> Formula (plain text):
#> `n = (Za+Zb)^2 * (p1q1+p2q2) / (p1-p2+margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha}+Z_{\beta})^2\left[p_1(1-p_1)+p_2(1-p_2)\right]}{(p_1-p_2+\Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: State non-inferiority hypotheses: H0: p1 - p2 <= -margin vs H1: p1 -
#> p2 > -margin (margin Delta = 0.05, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = p1 - p2 + margin = 0.85 - 0.85 + 0.05
#> = 0.05.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)]
#> / delta_E^2 = 630.62.
#> • Step 5: Round up to integer: n = 631 per group, total sample size N = 1262.
#> Reference:
#> Primary: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press; Machin et al. (2018) Chapter 11 (Non-inferiority and Equivalence).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 631 per arm, 1262 total.

### 1.6 Superiority Trial (Continuous Mean)

- **Clinical scenario**: Knee osteoarthritis trial: a new NSAID gel must
  beat the active comparator on the WOMAC pain subscale (0-20) by more
  than 1 point. Anticipated reductions: 12 vs. 10 points, SD = 3.
  One-sided \\\alpha = 0.05\\.
- **Formula**: \\n = 2\left(\frac{(Z\_{\alpha} +
  Z\_{\beta})\sigma}{\mu_1 - \mu_2 - \Delta}\right)^2\\ Chow et
  al. (2017).

``` r

res_1_6 <- calculate("rct", "superiority", "mean", mean1 = 12, mean2 = 10, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Superiority (means)"
#> • Sample size per group: 112
#> • Total sample size: 224
#> Formula (plain text):
#> `n = 2*(Z_a+Z_b)^2*sd^2/(mean1-mean2-margin)^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{(Z_{\alpha} + Z_{\beta})\sigma}{\mu_1 - \mu_2 - \Delta}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State superiority hypotheses: H0: mu1 - mu2 <= margin vs H1: mu1 -
#> mu2 > margin (margin Delta = 1, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = mu1 - mu2 - margin = 12 - 10 - 1 = 1;
#> SD sigma = 3.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 /
#> delta_E^2 = 2 * (1.6449 + 0.8416)^2 * 3^2 / (1)^2 = 111.29.
#> • Step 5: Round up to integer: n = 112 per group, total sample size N = 224.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 112 per arm, 224 total.

### 1.7 Superiority Trial (Binary Endpoint)

- **Clinical scenario**: Onychomycosis trial: complete cure rate 30%
  with the new oral antifungal vs. 20% with terbinafine, and the sponsor
  requires the difference to exceed a 5% superiority margin.
- **Formula**: \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(p_1-p_2-\Delta)^2}\\
  Chow et al. (2017).

``` r

res_1_7 <- calculate("rct", "superiority", "proportion", p1 = 0.30, p2 = 0.20, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_1_7)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Superiority (proportions)"
#> • Sample size per group: 916
#> • Total sample size: 1832
#> Formula (plain text):
#> `n = (Z_alpha + Z_beta)^2 * (p1*(1-p1) + p2*(1-p2)) / (p1 - p2 - margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha} + Z_{\beta})^2[p_1(1-p_1) + p_2(1-p_2)]}{(p_1 - p_2 - \Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: State superiority hypotheses: H0: p1 - p2 <= margin vs H1: p1 - p2 >
#> margin (margin Delta = 0.05, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = p1 - p2 - margin = 0.30 - 0.20 - 0.05
#> = 0.05.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)]
#> / delta_E^2 = (1.6449 + 0.8416)^2 * [0.21 + 0.16] / (0.05)^2 = 915.02.
#> • Step 5: Round up to integer: n = 916 per group, total sample size N = 1832.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 916 per arm, 1832 total.

### 1.8 Equivalence Trial (Continuous Mean)

- **Clinical scenario**: Two formulations of levothyroxine must be shown
  therapeutically equivalent: mean serum thyroxine 10 vs. 10.2
  \\\mu\\g/dL (SD = 3), equivalence corridor \\\pm 1.0\\ \\\mu\\g/dL.
- **Formula** (TOST): \\n = 2\left(\frac{(Z\_{\alpha} +
  Z\_{\beta/2})\sigma}{\Delta - \|\mu_1 - \mu_2\|}\right)^2\\ Chow et
  al. (2017).

``` r

res_1_8 <- calculate("rct", "equivalence", "mean", mean1 = 10, mean2 = 10.2, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Equivalence (means)"
#> • Sample size per group: 241
#> • Total sample size: 482
#> Formula (plain text):
#> `n = 2*(Z_a+Z_b/2)^2*sd^2/(margin-|mean1-mean2|)^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{(Z_{\alpha} + Z_{\beta/2})\sigma}{\Delta - |\mu_1 - \mu_2|}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State equivalence hypotheses (TOST): H0: |mu1 - mu2| >= margin vs H1:
#> |mu1 - mu2| < margin (margin Delta = 1, alpha = 0.05, power = 0.80).
#> • Step 2: Margin clearance: Delta - |mu1 - mu2| = 1 - |10 - 10.20| = 0.80; SD
#> sigma = 3.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_(beta/2) =
#> 1.2816.
#> • Step 4: Compute sample size: n = 2 * (Z_alpha + Z_(beta/2))^2 * sigma^2 /
#> (Delta - |mu1 - mu2|)^2 = 2 * (1.6449 + 1.2816)^2 * 3^2 / (0.80)^2 = 240.86.
#> • Step 5: Round up to integer: n = 241 per group, total sample size N = 482.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 241 per arm, 482 total.

### 1.9 Equivalence Trial (Binary Endpoint)

- **Clinical scenario**: Two analgesics for post-operative pain:
  response rates 50% vs. 52%; regulators accept equivalence within \\\pm
  10\\ percentage points.
- **Formula**: \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta/2})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(\Delta-\|p_1-p_2\|)^2}\\
  Chow et al. (2017).

``` r

res_1_9 <- calculate("rct", "equivalence", "proportion", p1 = 0.50, p2 = 0.52, margin = 0.10, alpha = 0.05, power = 0.8)
print(res_1_9)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Equivalence (proportions)"
#> • Sample size per group: 669
#> • Total sample size: 1338
#> Formula (plain text):
#> `n = (Z_alpha + Z_beta/2)^2 * (p1*(1-p1) + p2*(1-p2)) / (margin - |p1 - p2|)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha} + Z_{\beta/2})^2[p_1(1-p_1) + p_2(1-p_2)]}{(\Delta - |p_1-p_2|)^2}$$
#> Calculation process:
#> 
#> • Step 1: State equivalence hypotheses (TOST): H0: |p1 - p2| >= margin vs H1:
#> |p1 - p2| < margin (margin Delta = 0.10, alpha = 0.05, power = 0.80).
#> • Step 2: Margin clearance: Delta - |p1 - p2| = 0.10 - |0.50 - 0.52| = 0.08.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_(beta/2) =
#> 1.2816.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_(beta/2))^2 * [p1(1-p1) +
#> p2(1-p2)] / (Delta - |p1 - p2|)^2 = 668.52.
#> • Step 5: Round up to integer: n = 669 per group, total sample size N = 1338.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 669 per arm, 1338 total.

------------------------------------------------------------------------

## Chapter 2: Paired, Single-Arm, and Crossover Trials

### 2.1 Paired Means (Pre- vs. Post-Treatment)

- **Clinical scenario**: Asthma cohort: the same patients are measured
  before and after 12 weeks of inhaled corticosteroids. Mean FVC
  improvement is 2 L with SD of the within-patient differences 3 L.
- **Formula**: \\n = \left(\frac{(Z\_{\alpha/2} + Z\_{\beta}) \cdot
  \sigma_d}{\mu_d}\right)^2\\ Rosner (2015), *Fundamentals of
  Biostatistics* (8th ed.).

``` r

res_2_1 <- calculate("paired", "test", "mean", meanDiff = 2, sdDiff = 3, alpha = 0.05, power = 0.8)
print(res_2_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Paired means"
#> • Pairs needed: 20
#> • Total individuals: 40
#> Formula (plain text):
#> `n = ((Z_a/2 + Z_b) * sd_diff / mean_diff)^2`
#> Formula (LaTeX):
#> $$n = \left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma_d}{\mu_d}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State paired difference hypotheses: H0: mu_d = 0 vs H1: mu_d != 0
#> (alpha = 0.05, power = 0.80).
#> • Step 2: Expected paired difference mu_d = 2, SD of differences sigma_d = 3.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Normal approximation: n0 = ((Z_(alpha/2) + Z_beta) * sigma_d /
#> mu_d)^2 = ((1.96 + 0.8416) * 3 / 2)^2 = 17.66.
#> • Step 5: Exact paired Student's t-test degrees of freedom iteration.
#> • Step 6: Round up to integer: n = 20 pairs (total individuals = 40).
#> Reference:
#> Rosner, B. (2015). *Fundamentals of biostatistics* (8th ed.). Cengage Learning.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 20 pairs (40 total measurements).

### 2.2 Paired Binary Outcomes (McNemar / Connor)

- **Clinical scenario**: The same patients receive two SARS-CoV-2
  assays: a rapid antigen test (positive 80%) and RT-PCR (positive 60%).
  The expected proportion of discordant pairs is \\\psi = 0.25\\.
- **Formula** (Connor): \\n = \frac{\left\[Z\_{\alpha/2}\sqrt{\psi} +
  Z\_{\beta}\sqrt{\psi-\delta^2}\right\]^2}{\delta^2}, \quad \delta =
  \|p_1-p_2\|\\ Connor (1987), *Biometrics* 43(1), 207-211.

``` r

res_2_2 <- calculate("paired", "test", "proportion", p1 = 0.80, p2 = 0.60, psi = 0.25, alpha = 0.05, power = 0.8)
print(res_2_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Paired binary outcomes (McNemar / Connor)"
#> • Total sample size: 94
#> • Pairs needed: 47
#> Parameter roles
#> 
#> • p1/p2 = expected proportions (or sensitivities) in pairs
#> • psi = expected discordant-pair proportion (pi10 + pi01)
#> • output is in PAIRS (n individuals = 2 x pairs)
#> Formula (plain text):
#> `n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi-\delta^2}\right]^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Paired binary parameters: p1 = 0.80, p2 = 0.60, discordant pair
#> proportion psi = 0.25, difference delta = |p1 - p2| = 0.20.
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) + Z_beta*sqrt(psi -
#> delta^2)]^2 / delta^2 = 46.63.
#> • Step 4: Round up to integer: Pairs needed = 47.
#> Reference:
#> Primary: Connor, R. J. (1987). Sample size for testing differences in proportions for the paired-sample design. Biometrics, 43(1), 207-211.
#> 
#>  Also: Akoglu, H. (2022). Turkish Journal of Emergency Medicine, 22(4), Table 2 Eq 3b + Tables 6A/6B (uncorrected and Yates-corrected values).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 47 pairs.

### 2.3 Single-Arm Mean vs. Historical Benchmark

- **Clinical scenario**: A rare-disease trial (no control arm feasible):
  historical median-based mean survival is 10 months; the new targeted
  therapy is expected to reach 12 months (SD = 3).
- **Formula**: \\n = \frac{(Z\_{\alpha/2} + Z\_{\beta})^2
  \sigma^2}{(\mu_1 - \mu_0)^2}\\ Machin et al. (2018), Chapter 5.

``` r

res_2_3 <- calculate("rctSingleArm", "test", "mean", mu0 = 10, mu1 = 12, sigma = 3, alpha = 0.05, power = 0.8)
print(res_2_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm trial (continuous, vs fixed value)"
#> • Required sample size: 18
#> Parameter roles
#> 
#> • mu0 = reference/historical control mean (the null value)
#> • mu1 = anticipated treatment mean
#> • sigma = population standard deviation
#> Formula (plain text):
#> `n = (Za/2 + Zb)^2 * sigma^2 / (mu1-mu0)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha/2} + Z_{\beta})^2 \sigma^2}{(\mu_1 - \mu_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Single-arm continuous hypotheses: H0: mu = 10 vs H1: mu = 12, SD
#> sigma = 3 (alpha = 0.05, power = 0.80).
#> • Step 2: Effect size delta = |mu1 - mu0| = |12 - 10| = 2.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Sample size: n = (Z_(alpha/2) + Z_beta)^2 * sigma^2 / delta^2 = (1.96
#> + 0.8416)^2 * 3^2 / (2)^2 = 17.66.
#> • Step 5: Round up to integer: Required sample size n = 18.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 5 (Continuous Outcomes, single-sample comparison).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 18 patients.

### 2.4 Single-Arm Proportion vs. Historical Benchmark

- **Clinical scenario**: Relapsed/refractory lymphoma: historical best
  response rate is 70%; the new CAR-T protocol is anticipated to reach
  80%.
- **Formula**: \\n = \frac{\left\[Z\_{\alpha/2}\sqrt{p_0(1-p_0)} +
  Z\_{\beta}\sqrt{p_1(1-p_1)}\right\]^2}{(p_1-p_0)^2}\\ Hajian-Tilaki
  (2014), Eq 6.8.

``` r

res_2_4 <- calculate("rctSingleArm", "test", "proportion", p0 = 0.70, p1 = 0.80, alpha = 0.05, power = 0.8)
print(res_2_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm trial (binary, vs fixed value)"
#> • Required sample size: 153
#> Parameter roles
#> 
#> • p0 = null/historical control proportion
#> • p1 = anticipated treatment proportion
#> Formula (plain text):
#> `n = [Za*sqrt(p0q0) + Zb*sqrt(p1q1)]^2/(p1-p0)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p_1(1-p_1)}\right]^2}{(p_1 - p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Single-arm binary hypotheses: H0: p = 0.70 vs H1: p = 0.80 (alpha =
#> 0.05, power = 0.80).
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Sample size: n = [Z_(alpha/2)*sqrt(p0*q0) + Z_beta*sqrt(p1*q1)]^2 /
#> (p1 - p0)^2 = 152.48.
#> • Step 4: Round up to integer: Required sample size n = 153.
#> Reference:
#> Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204 (Eq 6.8; worked example 0.70 vs 0.80 -> n=153).
#> 
#>  Also: Akoglu, H. (2022). Table 2, Equation 2; Machin et al. (2018) Ch.3.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 153 patients.

### 2.5 Phase II Simon’s Optimal Two-Stage Design

- **Clinical scenario**: A single-arm phase-II trial of a new sarcoma
  regimen: unacceptable response rate \\p_0 = 0.10\\, target \\p_1 =
  0.30\\. The *optimal* design minimises the expected sample size when
  the drug is ineffective.
- **Formula**: exact binomial enumeration (Simon 1989). The design
  \\(r_1/n_1, r/n)\\ satisfies \\\underbrace{P(X_1 \le r_1 \mid
  p_0)}\_{\text{early stop}} +
  \sum\_{x_1=r_1+1}^{n_1}\binom{n_1}{x_1}p_0^{x_1}(1-p_0)^{n_1-x_1}\\\underbrace{P(X_2
  \> r - x_1 \mid p_0)}\_{\text{stage 2}} \le \alpha\\ and the analogous
  expression under \\p_1\\ must reach the target power. Simon (1989),
  *Controlled Clinical Trials* 10(1), 1-10.

``` r

res_2_5 <- calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "optimal")
print(res_2_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm phase II (Simon two-stage, optimal)"
#> • Stage 1 sample size: 10
#> • Stage 1 futility boundary (stop if responses <= r1): 1
#> • Total sample size (both stages): 29
#> • Overall boundary (declare effective if responses > r): 5
#> Parameter roles
#> 
#> • p0 = unacceptable response rate (null)
#> • p1 = desirable response rate (alternative)
#> • stage 1: stop for futility if responses <= r_stage_1 of n_stage_1
#> • overall: declare effective if responses > r_total of n_total
#> Formula (plain text):
#> `exact binomial: P(effective|p0) <= alpha and P(effective|p1) >= power`
#> Formula (LaTeX):
#> $$P(\text{reject } H_0 \mid p_0) \le \alpha \quad \text{and} \quad P(\text{reject } H_0 \mid p_1) \ge 1-\beta$$
#> Calculation process:
#> 
#> • Step 1: State phase II hypotheses: H0: p <= 0.10 (unacceptable) vs H1: p >=
#> 0.30 (promising) (alpha = 0.05, power = 0.80).
#> • Step 2: Exhaustive exact binomial search under 'optimal' criterion.
#> • Step 3: Stage 1: Accrue n1 = 10 patients; stop early for futility if
#> responses <= r1 = 1.
#> • Step 4: Stage 2: If > 1 responses observed, accrue additional 19 patients up
#> to total n = 29.
#> • Step 5: Final decision: Declare effective if total responses > r = 5
#> (Expected sample size under H0 = 15).
#> Reference:
#> Primary: Simon, R. (1989). Optimal two-stage designs for phase II clinical trials. Controlled Clinical Trials, 10(1), 1-10.
#> 
#>  Also: Machin et al. (2018) Chapter 17 (Therapeutic Exploratory Trials).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: Stage 1 enrolls 10 (stop if \\\le 1\\ response); Stage 2
  reaches 29 (effective if \\\>5\\ responses). Expected \\N = 15.0\\.

### 2.6 Phase II Simon’s Minimax Two-Stage Design

- **Clinical scenario**: Same sarcoma trial, but the sponsor needs to
  cap the *worst-case* enrollment (budget/facility constraints).

``` r

res_2_6 <- calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "minimax")
print(res_2_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm phase II (Simon two-stage, minimax)"
#> • Stage 1 sample size: 11
#> • Stage 1 futility boundary (stop if responses <= r1): 0
#> • Total sample size (both stages): 25
#> • Overall boundary (declare effective if responses > r): 5
#> Parameter roles
#> 
#> • p0 = unacceptable response rate (null)
#> • p1 = desirable response rate (alternative)
#> • stage 1: stop for futility if responses <= r_stage_1 of n_stage_1
#> • overall: declare effective if responses > r_total of n_total
#> ! Multiple designs may achieve the minimum total sample size N;
#> ! this implementation selects the design minimizing Type I error (alpha) among ties.
#> 
#> Formula (plain text):
#> `exact binomial: P(effective|p0) <= alpha and P(effective|p1) >= power`
#> Formula (LaTeX):
#> $$P(\text{reject } H_0 \mid p_0) \le \alpha \quad \text{and} \quad P(\text{reject } H_0 \mid p_1) \ge 1-\beta$$
#> Calculation process:
#> 
#> • Step 1: State phase II hypotheses: H0: p <= 0.10 (unacceptable) vs H1: p >=
#> 0.30 (promising) (alpha = 0.05, power = 0.80).
#> • Step 2: Exhaustive exact binomial search under 'minimax' criterion.
#> • Step 3: Stage 1: Accrue n1 = 11 patients; stop early for futility if
#> responses <= r1 = 0.
#> • Step 4: Stage 2: If > 0 responses observed, accrue additional 14 patients up
#> to total n = 25.
#> • Step 5: Final decision: Declare effective if total responses > r = 5
#> (Expected sample size under H0 = 20.60).
#> Reference:
#> Primary: Simon, R. (1989). Optimal two-stage designs for phase II clinical trials. Controlled Clinical Trials, 10(1), 1-10.
#> 
#>  Also: Machin et al. (2018) Chapter 17 (Therapeutic Exploratory Trials).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: Total \\N = 25\\ patients (Stage 1 enrolls 11, stop if
  \\\le 0\\).

### 2.7 A’Hern Exact Single-Stage Binomial Design

- **Clinical scenario**: The same phase-II question answered with a
  single-stage design (no interim futility analysis possible).

``` r

res_2_7 <- sampleSizeCalc:::calculate_ahern(p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8)
print(res_2_7)
#> $design_type
#> [1] "Single-arm phase II (A'Hern single-stage)"
#> 
#> $n_required
#> [1] 25
#> 
#> $r_total
#> [1] 5
#> 
#> $parameters
#> $parameters$p0
#> [1] 0.1
#> 
#> $parameters$p1
#> [1] 0.3
#> 
#> $parameters$alpha
#> [1] 0.05
#> 
#> $parameters$power
#> [1] 0.8
#> 
#> 
#> $formula
#> [1] "P(X > r | p0) <= alpha and P(X > r | p1) >= power"
#> 
#> $formula_latex
#> [1] "$$P(X > r \\mid p_0) \\le \\alpha \\quad \\text{and} \\quad P(X > r \\mid p_1) \\ge 1-\\beta$$"
#> 
#> $reference
#> [1] "Primary: A'Hern, R. P. (2001). Single stage and double sampling phase II trials. British Journal of Cancer, 85(2), 223-226."
#> 
#> $roles
#> [1] "p0 = unacceptable response rate"                       
#> [2] "p1 = desirable response rate"                          
#> [3] "declare effective if responses > r_total of n_required"
```

- **Output**: 25 patients, reject null if responses \\\>5\\ (\\\ge 6\\).
- **Formula**: exact binomial — \\P(X \ge r \mid p_0) \le \alpha\\ and
  \\P(X \ge r \mid p_1) \ge 1-\beta\\ (A’Hern 2001).

### 2.8 2x2 Crossover Trial (Continuous Mean)

- **Clinical scenario**: Asthma patients receive two inhaled salbutamol
  formulations in random order (washout 7 days); FEV1 % predicted
  improvement differs by 2 percentage points, within-subject SD
  \\\sigma_w = 3\\.
- **Formula**: \\n =
  \frac{2(Z\_{\alpha/2}+Z\_{\beta})^2\sigma_w^2}{\delta^2}\\ Senn
  (2002), *Cross-over Trials in Clinical Research* (2nd ed.).

``` r

res_2_8 <- calculate("crossover", "test", "mean", delta = 2, sigma_within = 3, alpha = 0.05, power = 0.8)
print(res_2_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "2x2 crossover trial (continuous)"
#> • Required sample size: 36
#> • Total sample size: 72
#> Parameter roles
#> 
#> • delta = anticipated treatment difference (mu_T - mu_R)
#> • sigma_within = within-subject standard deviation
#> • n is per sequence; total subjects = 2n (each receives both treatments)
#> Formula (plain text):
#> `n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2 (per sequence)`
#> Formula (LaTeX):
#> $$n = \frac{2(Z_{\alpha/2}+Z_{\beta})^2\sigma_w^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: 2x2 crossover trial (continuous).
#> • Step 2: Input parameters: delta = 2, sigma_within = 3, alpha = 0.05, power =
#> 0.80.
#> • Step 3: Apply design formula: n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2 (per
#> sequence).
#> • Step 4: Calculated sample size metrics: Required sample size: 36; Total
#> sample size: 72.
#> Reference:
#> Primary: Senn, S. (2002). Cross-over Trials in Clinical Research (2nd ed.). Wiley.
#> 
#>  Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes for clinical trials with normal data. Statistics in Medicine, 23, 1921-1986 (crossover section).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 36 per sequence, 72 total.

### 2.9 Bioequivalence (BE) Exact TOST

- **Clinical scenario**: Generic amlodipine vs. originator in healthy
  volunteers, \\2\times2\\ crossover, intra-subject CV = 25%, expected
  geometric mean ratio \\\theta_0 = 1.0\\, acceptance range 80-125%.
- **Formula** (exact noncentral \\t\\, Phillips 1990): \\\text{Power} =
  F_t(-t\_{1-\alpha, \nu}; \nu, \delta_2) - F_t(t\_{1-\alpha, \nu}; \nu,
  \delta_1), \quad \nu = N-2\\

``` r

res_2_9 <- calculate("bioequivalence", cv = 0.25, theta0 = 1.0, alpha = 0.05, power = 0.8)
print(res_2_9)
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

- **Output**: 12 per sequence, **24 healthy volunteers total** (matches
  `PowerTOST` exactly).

------------------------------------------------------------------------

## Chapter 3: Observational and Epidemiological Studies

### 3.1 Prospective Cohort Study (Cumulative Incidence & RR)

- **Clinical scenario**: Framingham-style cohort on smoking and coronary
  heart disease: 5-year incidence 20% in non-smokers vs. 30% in smokers,
  1:1 allocation, planning for 10% loss to follow-up.
- **Formula**: \\n\_{1} =
  \frac{\left\[Z\_{\alpha/2}\sqrt{(1+\frac{1}{m})\bar{p}(1-\bar{p})} +
  Z\_{\beta}\sqrt{p_1(1-p_1)+\frac{p_0(1-p_0)}{m}}\right\]^2}{(p_1-p_0)^2},
  \quad n = \frac{n_1}{1-d}\\ Bhardwaj et al. (2024), *J Family Med Prim
  Care* 13(7), 2559.

``` r

res_3_1 <- calculate("cohort", "test", "proportion", p0 = 0.20, p1 = 0.30, ratio = 1, dropout = 0.10, alpha = 0.05, power = 0.8)
print(res_3_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohort study (cumulative incidence, RR)"
#> • Sample size per group: 327
#> • Exposed group: 327
#> • Unexposed group: 327
#> • Total sample size: 654
#> Parameter roles
#> 
#> • p0 = unexposed-group cumulative incidence
#> • p1 = exposed-group cumulative incidence
#> • ratio = unexposed:exposed allocation (m)
#> • effect measure: risk ratio RR (estimable in cohort designs)
#> Formula (plain text):
#> `n1 = [Za*sqrt((1+1/m)*pbar*(1-pbar)) + Zb*sqrt(p1q1+p0q0/m)]^2/(p1-p0)^2`
#> Formula (LaTeX):
#> $$n_{1} = \frac{\left[Z_{\alpha/2}\sqrt{(1+\frac{1}{m})\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1)+\frac{p_0(1-p_0)}{m}}\right]^2}{(p_1-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify proportions: unexposed p0 = 0.20, exposed p1 = 0.30,
#> allocation ratio m = 1 (alpha = 0.05, power = 0.80).
#> • Step 2: Weighted average proportion: p_bar = (p1 + m*p0) / (1 + m) = 0.25.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Calculate exposed sample size: n_exposed =
#> [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*q1 + p0*q0/m)]^2 /
#> (p1 - p0)^2 = 293.15.
#> • Step 5: Calculate unexposed sample size: n_unexposed = m * n_exposed = 1 *
#> 293.15 = 293.15.
#> • Step 6: Round up before dropout inflation: ceiling(n_exposed) = 294,
#> ceiling(m*n_exposed) = 294; apply dropout d = 0.10 using ceiling(n/(1-d)).
#> Exposed = 327, Unexposed = 327, Total sample size N = 654.
#> Reference:
#> Primary: Bhardwaj et al. (2024). Journal of Family Medicine and Primary Care, 13(7), 2559 (worked example: p0=0.20, p1=0.30, m=1 -> 293/group).
#> 
#>  Also: Schlesselman, J. J. (1982). Case-Control Studies. Oxford University Press (cohort/case-control shared formula, roles swapped); Machin et al. (2018) Ch.3.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 327 per arm, 654 total.

### 3.2 Cohort Study (Person-Time Incidence Rate Ratio)

- **Clinical scenario**: Occupational epidemiology: workers exposed to a
  solvent develop disease at 0.20 events per person-year vs. 0.10 in
  unexposed workers; 1:1 person-time allocation.
- **Formula**: \\T\_{0} =
  \frac{(Z\_{\alpha/2}+Z\_{\beta})^2(\lambda_1/r+\lambda_0)}{(\lambda_1-\lambda_0)^2},
  \quad T_1 = r \cdot T_0\\ Machin et al. (2018), Chapter 6.

``` r

res_3_2 <- calculate("cohort", "test", "rate", rate0 = 0.10, rate1 = 0.20, ratio = 1, alpha = 0.05, power = 0.8)
print(res_3_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohort study (incidence rate ratio, person-time)"
#> • Person-time, exposed group: 236
#> • Person-time, unexposed group: 236
#> • Expected events: 71
#> Parameter roles
#> 
#> • rate0 = unexposed-group incidence rate (events per person-time)
#> • rate1 = exposed-group incidence rate
#> • ratio = unexposed:exposed person-time ratio
#> • effect measure: incidence rate ratio IRR
#> • person-time = total follow-up time; for fixed duration FT, subjects needed =
#> person-time / FT
#> Formula (plain text):
#> `T0 = (Za/2+Zb)^2 * (l1/r + l0) / (l1-l0)^2 ; T1 = r*T0`
#> Formula (LaTeX):
#> $$T_{0} = \frac{(Z_{\alpha/2}+Z_{\beta})^2(\lambda_1/r+\lambda_0)}{(\lambda_1-\lambda_0)^2}, \quad T_1 = r \cdot T_0$$
#> Calculation process:
#> 
#> • Step 1: Specify incidence rates: unexposed lambda0 = 0.10, exposed lambda1 =
#> 0.20, person-time ratio r = 1.
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Calculate required person-time for unexposed group: T0 = (Z_(alpha/2)
#> + Z_beta)^2 * (lambda1/r + lambda0) / (lambda1 - lambda0)^2 = 235.47.
#> • Step 4: Calculate required person-time for exposed group: T1 = r * T0 = 1 *
#> 235.47 = 235.47.
#> • Step 5: Expected events: E = lambda0 * T0 + lambda1 * T1 = 71.
#> • Step 6: Round up to integer: Person-time unexposed = 236, Person-time exposed
#> = 236.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 6 (Rate Outcomes).
#> 
#>  Also: Breslow, N. E., & Day, N. E. (1987). Statistical Methods in Cancer Research Vol. II. IARC (person-time rate comparison).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 236 person-time units per group (71 expected events).

### 3.3 Case-Control Study (Odds Ratio)

- **Clinical scenario**: Hospital-based case-control study of late-night
  screen exposure and myocardial infarction: 30% of controls are
  exposed, anticipated OR = 2.0, 1 control per case.
- **Formula** (Schlesselman): \\n\_{cases} =
  \frac{\left\[Z\_{\alpha/2}\sqrt{(1+1/m)\bar{p}(1-\bar{p})} +
  Z\_{\beta}\sqrt{p_1(1-p_1) + p_0(1-p_0)/m}\right\]^2}{(p_1-p_0)^2}\\
  Schlesselman (1982), *Case-Control Studies*, Oxford University Press.

``` r

res_3_3 <- calculate("caseControl", p0 = 0.30, OR = 2.0, m = 1, alpha = 0.05, power = 0.8)
print(res_3_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Case-control"
#> • Cases needed: 141
#> • Controls needed: 141
#> • Total subjects: 282
#> Formula (plain text):
#> `n_cases = [Z_alpha/2 * sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta * sqrt(p1*(1-p1)
#> + p0*(1-p0)/m)]^2 / (p1 - p0)^2`
#> Formula (LaTeX):
#> $$n_{cases} = \frac{\left[Z_{\alpha/2}\sqrt{(1+1/m)\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_0(1-p_0)/m}\right]^2}{(p_1-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Compute case exposure rate from Odds Ratio: p1 = (OR * p0) / (1 - p0
#> + OR * p0) = (2 * 0.30) / (1 - 0.30 + 2 * 0.30) = 0.4615.
#> • Step 2: Weighted average exposure (matching ratio m = 1): p_bar = (p1 + m*p0)
#> / (1 + m) = 0.3808.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Schlesselman formula for cases: n_cases =
#> [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*(1-p1) +
#> p0*(1-p0)/m)]^2 / (p1 - p0)^2 = 140.66.
#> • Step 5: Calculate controls needed: n_controls = m * n_cases = 1 * 140.66 =
#> 140.66.
#> • Step 6: Round up to integer: Cases needed = 141, Controls needed = 141, Total
#> subjects = 282.
#> Reference:
#> Primary: Schlesselman, J. J. (1982). Case-control studies: Design, conduct, analysis. Oxford University Press.
#> 
#> IARC classic: Breslow, N. E., & Day, N. E. (1980). Statistical methods in cancer research: Volume I - The analysis of case-control studies. IARC Scientific Publications No. 32.
#> 
#> For individually matched designs (not the formula implemented here): Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168; see the caseControlMatched design.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 141 cases, 141 controls (282 total).

### 3.4 1:1 Matched Case-Control Study

- **Clinical scenario**: Oral contraceptive use and ischaemic stroke in
  young women, individually matched 1:1 by age; control exposure rate
  30%, OR = 2.0.
- **Formula** (Dupont discordant-pairs): \\n\_{pairs} =
  \frac{\left\[Z\_{\alpha/2}\sqrt{\psi} +
  Z\_{\beta}\sqrt{\psi-\delta^2}\right\]^2}{\delta^2}, \quad \psi =
  p_1(1-p_0)+p_0(1-p_1)\\ Dupont (1988), *Biometrics* 44(4), 1157-1168.

``` r

res_3_4 <- calculate("caseControlMatched", p0 = 0.30, OR = 2.0, alpha = 0.05, power = 0.8)
print(res_3_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Individually matched case-control (1:1)"
#> • Total sample size: 288
#> • Cases needed: 144
#> • Controls needed: 144
#> Parameter roles
#> 
#> • p0 = control-group exposure rate
#> • OR = odds ratio to detect (p1 derived from p0 and OR)
#> • psi = expected discordant-pair proportion (pi10 + pi01 = p1*(1-p0) +
#> p0*(1-p1))
#> • note = individually matched designs require discordant-pair proportions
#> (psi), NOT the discordant odds ratio
#> Formula (plain text):
#> `n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2`
#> Formula (LaTeX):
#> $$n_{pairs} = \frac{\left[Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi-\delta^2}\right]^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Matched case-control parameters: control exposure p0 = 0.30, Odds
#> Ratio OR = 2 (alpha = 0.05, power = 0.80).
#> • Step 2: Case exposure rate: p1 = (OR * p0) / (1 - p0 + OR * p0) = 0.4615.
#> • Step 3: Discordant pair probability: psi = pi10 + pi01 = 0.4846; difference
#> delta = |pi10 - pi01| = 0.1615.
#> • Step 4: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 5: Apply Dupont/Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) +
#> Z_beta*sqrt(psi - delta^2)]^2 / delta^2 = 143.38.
#> • Step 6: Round up to integer: Pairs needed = 144 (Cases = 144, Controls =
#> 144).
#> Reference:
#> Primary: Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168.
#> 
#>  Also: Schlesselman, J. J. (1982). Case-Control Studies, Oxford University Press (matched-pair approximation, p.174); Connor, R. J. (1987). Biometrics, 43(1), 207-211.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 144 pairs (288 total).

### 3.5 Cross-Sectional Association Survey

- **Clinical scenario**: A community cross-sectional survey of
  hypertension: prevalence 20% in unexposed vs. 30% in exposed (obese)
  participants.
- **Formula**: same two-proportion kernel as 3.1 with \\m = 1\\ (Machin
  et al. 2018, Ch. 3).

``` r

res_3_5 <- calculate("crosstab", p0 = 0.20, p1 = 0.30, alpha = 0.05, power = 0.8)
print(res_3_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cross-sectional study (prevalence comparison, PR/OR)"
#> • Sample size per group: 294
#> • Exposed group: 294
#> • Unexposed group: 294
#> • Total sample size: 588
#> Parameter roles
#> 
#> • p0 = prevalence in unexposed group
#> • p1 = prevalence in exposed group
#> • effect measure: prevalence ratio PR (or OR)
#> • sampling: exposure and outcome observed at the same time point
#> Formula (plain text):
#> `n1 = [Za*sqrt((1+1/m)*pbar*(1-pbar)) + Zb*sqrt(p1q1+p0q0/m)]^2/(p1-p0)^2`
#> Formula (LaTeX):
#> $$n_{1} = \frac{\left[Z_{\alpha/2}\sqrt{(1+\frac{1}{m})\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1)+\frac{p_0(1-p_0)}{m}}\right]^2}{(p_1-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify proportions: unexposed p0 = 0.20, exposed p1 = 0.30,
#> allocation ratio m = 1 (alpha = 0.05, power = 0.80).
#> • Step 2: Weighted average proportion: p_bar = (p1 + m*p0) / (1 + m) = 0.25.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Calculate exposed sample size: n_exposed =
#> [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*q1 + p0*q0/m)]^2 /
#> (p1 - p0)^2 = 293.15.
#> • Step 5: Calculate unexposed sample size: n_unexposed = m * n_exposed = 1 *
#> 293.15 = 293.15.
#> • Step 6: Round up to integer: Exposed = 294, Unexposed = 294, Total sample
#> size N = 588.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 3 (Binary Outcomes).
#> 
#>  Also: Bhardwaj et al. (2024), p. 2558-2559.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 294 per group, 588 total.

------------------------------------------------------------------------

## Chapter 4: Single-Sample Precision Estimation

### 4.1 Single Proportion Estimation (Prevalence Survey)

- **Clinical scenario**: A county diabetes prevalence survey:
  anticipated prevalence 10%, the estimate must lie within \\\pm 2\\
  percentage points of the truth with 95% confidence.
- **Formula**: \\n = \frac{Z\_{1-\alpha/2}^2 \cdot p(1-p)}{d^2}\\ Lwanga
  & Lemeshow (1991), WHO; Bhardwaj et al. (2024), p. 2558.

``` r

res_4_1 <- calculate("singleProportion", p = 0.10, precision = 0.02, alpha = 0.05)
print(res_4_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single proportion estimation (precision)"
#> • Required sample size: 865
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
#> • Step 1: Specify anticipated proportion p = 0.10, margin of error d = 0.02
#> (absolute precision), alpha = 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Compute variance component: p * (1 - p) = 0.10 * 0.90 = 0.09.
#> • Step 4: Calculate unrounded sample size: n = Z_(1-alpha/2)^2 * p * (1 - p) /
#> d^2 = (1.96)^2 * 0.09 / (0.02)^2 = 864.33.
#> • Step 5: Round up to integer: Required sample size n = 865.
#> Reference:
#> Bhardwaj et al. (2024). Determination of sample size for various study designs in medical research: A practical primer. Journal of Family Medicine and Primary Care, 13(7), 2555-2561 (p. 2558).
#> 
#> Also: Lwanga, S. K., & Lemeshow, S. (1991). Sample size determination in health studies: A practical manual. World Health Organization.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 865 participants.

### 4.2 Single Mean Estimation

- **Clinical scenario**: Establishing a paediatric serum ferritin
  reference value: population SD = 10 \\\mu\\g/L, the mean must be
  estimated within \\\pm 2\\ \\\mu\\g/L.
- **Formula**: \\n = \left(\frac{Z\_{1-\alpha/2} \cdot
  \sigma}{d}\right)^2\\ Machin et al. (2018), Ch. 9.

``` r

res_4_2 <- calculate("singleMean", sigma = 10, precision = 2, alpha = 0.05)
print(res_4_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single mean estimation (precision)"
#> • Required sample size: 97
#> Parameter roles
#> 
#> • sigma = population standard deviation (from pilot/literature)
#> • precision = margin of error d
#> Formula (plain text):
#> `n = (Z * sigma / d)^2`
#> Formula (LaTeX):
#> $$n = \left(\frac{Z_{1-\alpha/2} \cdot \sigma}{d}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: Specify population SD sigma = 10, margin of error d = 2, alpha =
#> 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Compute unrounded sample size: n = (Z_(1-alpha/2) * sigma / d)^2 =
#> (1.96 * 10 / 2)^2 = 96.04.
#> • Step 4: Round up to integer: Required sample size n = 97.
#> Reference:
#> Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 9.
#> 
#> Also: Bhardwaj et al. (2024), p. 2558 (continuous outcome precision).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 97 participants.

### 4.3 Pearson Correlation Coefficient Precision (Fisher-z)

- **Clinical scenario**: Validating waist circumference as a proxy for
  body-fat percentage: anticipated \\r = 0.50\\, the 95% CI half-width
  must not exceed \\\pm 0.10\\.
- **Formula** (Machin Eqs 19.5-19.8): \\N\_{P0} = \frac{4
  z\_{1-\alpha/2}^2 (1-r^2)^2}{w^2} + 3, \quad N\_{Final} =
  (N\_{P0}-3)\left(\frac{w_0}{w}\right)^2 + 3\\ Machin et al. (2018),
  Ch. 19, pp. 307-308 (matches
  [`presize::prec_cor`](https://ctu-bern.github.io/presize/reference/prec_cor.html)).

``` r

res_4_3 <- calculate("singleCorrelation", r = 0.50, precision = 0.10, alpha = 0.05)
print(res_4_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single correlation estimation (Fisher z precision)"
#> • Required sample size: 219
#> Parameter roles
#> 
#> • r = anticipated correlation coefficient
#> • precision = margin of error d (CI half-width, w = 2*d)
#> • confidence level = 95%
#> Formula (plain text):
#> `Machin 19.5-19.8: N_P0 = 4*z^2*(1-r^2)^2/w^2 + 3, refined via Fisher z bounds`
#> Formula (LaTeX):
#> $$N_{P0} = \frac{4 z_{1-\alpha/2}^2 (1-r^2)^2}{w^2} + 3, \quad N_{Final} = (N_{P0}-3)\left(\frac{w_0}{w}\right)^2 + 3$$
#> Calculation process:
#> 
#> • Step 1: Specify anticipated correlation r = 0.50, CI half-width d = 0.10
#> (width w = 2d = 0.20), alpha = 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96.
#> • Step 3: Machin initial estimate: N_P0 = 4 * Z^2 * (1 - r^2)^2 / w^2 + 3 =
#> 219.08.
#> • Step 4: Refine via Fisher z transformation limits to adjust for confidence
#> interval skewness.
#> • Step 5: Round up to integer: Required sample size n = 219.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 19 (The Correlation Coefficient), Equations 19.5-19.8, pp. 307-308.
#> 
#>  Also: Fisher, R. A. (1921). On the 'probable error' of a coefficient of correlation deduced from a small sample. Metron, 1, 3-32.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 219 participants (matches
  [`presize::prec_cor`](https://ctu-bern.github.io/presize/reference/prec_cor.html)).

------------------------------------------------------------------------

## Chapter 5: Diagnostic Accuracy Studies

### 5.1 Sensitivity/Specificity Precision & Screening Size

- **Clinical scenario**: Validating a colorectal cancer screening kit:
  expected sensitivity 85%, CI half-width \\\pm 5\\\\, clinic prevalence
  20%. How many confirmed cases and how many total screens?
- **Formula** (Zhou Eq 6.2): \\n\_{cases} = \frac{Z\_{1-\alpha/2}^2
  \cdot p(1-p)}{d^2}, \quad N\_{screen} =
  \frac{n\_{cases}}{\text{prevalence}}\\ Zhou, Obuchowski & McClish
  (2011), Section 6.1.1, pp. 194-196.

``` r

res_5_1 <- calculate("diagAccuracy", "estimate", "proportion", prob = 0.85, d = 0.05, prevalence = 0.20, alpha = 0.05)
print(res_5_1)
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

- **Output**: 196 confirmed cases required; 980 total screened patients.

### 5.2 Diagnostic Superiority Test (Asymptotic Method)

- **Clinical scenario**: An AI lung-nodule system must demonstrate
  sensitivity significantly above the 70% industry pass mark;
  anticipated sensitivity 85%, prevalence 20%.
- **Formula** (Hajian-Tilaki Eq 6.8): \\n =
  \frac{\left\[Z\_{\alpha}\sqrt{p_0(1-p_0)} +
  Z\_{\beta}\sqrt{p(1-p)}\right\]^2}{(p - p_0)^2}\\

``` r

res_5_2 <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha = 0.05, power = 0.8)
print(res_5_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic superiority (single)"
#> • Cases needed: 50
#> • Total subjects to screen: 248
#> • Total subjects: 248
#> Formula (plain text):
#> `N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 / (P-P0)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p(1-p)}\right]^2}{(p - p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic superiority (single).
#> • Step 2: Input parameters: prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha =
#> 0.05, power = 0.80, method = asymptotic.
#> • Step 3: Apply design formula: N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 /
#> (P-P0)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 50; Total subjects to
#> screen: 248.
#> Reference:
#> Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 50 cases, 250 screened.

### 5.3 Diagnostic Superiority Test (A’Hern Exact Method)

- **Clinical scenario**: The same AI validation, but with a small sample
  where the normal approximation is unsafe; the exact binomial method
  removes the approximation error.
- **Formula**: exact binomial — \\P(X \ge r \mid p_0) \le \alpha\\,
  \\P(X \ge r \mid p) \ge 1-\beta\\ (A’Hern 2001).

``` r

res_5_3 <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, method = "exact", alpha = 0.05, power = 0.8)
print(res_5_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic superiority (single test, exact binomial)"
#> • Cases needed: 49
#> • Total subjects to screen: 245
#> • Total subjects: 245
#> Parameter roles
#> 
#> • prob = expected diagnostic sensitivity/specificity
#> • p0 = unacceptable/null sensitivity or specificity threshold
#> • critical_successes = declare superior if correct cases >= 40 of 49
#> Formula (plain text):
#> `exact binomial: P(X >= r | p0) <= alpha and P(X >= r | prob) >= power`
#> Formula (LaTeX):
#> $$P(X \ge r \mid p_0) \le \alpha \quad \text{and} \quad P(X \ge r \mid p) \ge 1-\beta$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic superiority (single test, exact
#> binomial).
#> • Step 2: Input parameters: prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha =
#> 0.05, power = 0.80, method = exact.
#> • Step 3: Apply design formula: exact binomial: P(X >= r | p0) <= alpha and P(X
#> >= r | prob) >= power.
#> • Step 4: Calculated sample size metrics: Cases needed: 49; Total subjects to
#> screen: 245.
#> Reference:
#> Primary (exact binomial): A'Hern, R. P. (2001). Single stage and double sampling phase II trials. British Journal of Cancer, 85(2), 223-226.
#> 
#>  Also: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 49 confirmed cases, critical cutoff \\r = 40\\.

### 5.4 Dual-Endpoint Diagnostic Trial (Se + Sp Co-Primary)

- **Clinical scenario**: A new breast-lesion AI must improve BOTH
  sensitivity (80% \\\to\\ 90%) and specificity (75% \\\to\\ 85%)
  against biopsy truth, prevalence 40%. Each endpoint is powered at 90%
  so joint power is ~80% (Akoglu 2022).
- **Formula**: \\n = \max\left(n\_{Se},\\ n\_{Sp}\right), \quad n =
  \frac{\left\[Z\_{\alpha}\sqrt{p_0(1-p_0)} +
  Z\_{\beta}\sqrt{p(1-p)}\right\]^2}{(p-p_0)^2}\\

``` r

res_5_4 <- calculate("diagAccuracy", "test", "proportion", prob = 0.90, p0 = 0.80, prob_spec = 0.85, p0_spec = 0.75, prevalence = 0.40, dual = TRUE)
print(res_5_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic accuracy (dual endpoint: Se + Sp)"
#> • Cases needed: 137
#> • N for sensitivity: 109
#> • N for specificity: 137
#> • Total subjects to screen: 343
#> • Total subjects: 343
#> Parameter roles
#> 
#> • prob/p0 = expected and null sensitivity
#> • prob_spec/p0_spec = expected and null specificity
#> • dual_power = per-endpoint power (default 0.90 -> ~80% joint)
#> Formula (plain text):
#> `n = [Za*sqrt(p0q0) + Zb*sqrt(pq)]^2/(p-p0)^2, each at dual_power; take max`
#> Formula (LaTeX):
#> $$n = \max\left(n_{Se},\, n_{Sp}\right), \quad n = \frac{\left[Z_{\alpha}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p(1-p)}\right]^2}{(p-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Dual-endpoint setup: Se (null = 0.80, exp = 0.90), Sp (null = 0.75,
#> exp = 0.85), dual_power = 0.90 (joint power ~80%).
#> • Step 2: Calculate cases for sensitivity: n_Se = [Z_alpha*sqrt(p0*q0) +
#> Z_beta*sqrt(p*q)]^2 / (p - p0)^2 = 109.
#> • Step 3: Calculate controls for specificity: n_Sp = [Z_alpha*sqrt(p0*q0) +
#> Z_beta*sqrt(p*q)]^2 / (p - p0)^2 = 137.
#> • Step 4: Select dominant endpoint requirement: n_final = max(n_Se, n_Sp) =
#> 137.
#> • Step 5: Convert to screening population: Total subjects to screen = 137 /
#> 0.40 = 343.
#> Reference:
#> Strategy: Akoglu, H. (2022). User's guide to sample size estimation in diagnostic accuracy studies. Turkish Journal of Emergency Medicine, 22(4), 177-185 (p. 184: each endpoint at 90% power -> ~80% overall).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 123 cases, 308 screened.

### 5.5 Unpaired Comparison of Two Diagnostic Tests

- **Clinical scenario**: Two independent cohorts receive two competing
  pneumonia CT-AI systems: sensitivity 85% vs. 75%, prevalence 20%.
- **Formula** (Fleiss kernel): \\n =
  \frac{\left\[Z\_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} +
  Z\_{\beta}\sqrt{p_1(1-p_1)+p_2(1-p_2)}\right\]^2}{(p_1-p_2)^2}\\

``` r

res_5_5 <- calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = FALSE, alpha = 0.05, power = 0.8)
print(res_5_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two diagnostic measures"
#> • Cases needed: 250
#> • Total subjects to screen: 2500
#> • Total subjects: 2500
#> Formula (plain text):
#> `n = [Za/2 * sqrt(2*p_bar*(1-p_bar)) + Zb * sqrt(p1*(1-p1)+p2*(1-p2))]^2 /
#> (p1-p2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1)+p_2(1-p_2)}\right]^2}{(p_1-p_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Two diagnostic measures.
#> • Step 2: Input parameters: p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired =
#> FALSE, psi = , alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = [Za/2 * sqrt(2*p_bar*(1-p_bar)) + Zb *
#> sqrt(p1*(1-p1)+p2*(1-p2))]^2 / (p1-p2)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 250; Total subjects to
#> screen: 2500.
#> Reference:
#> Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.
#> 
#> Review: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 250 cases per group, 2500 screened.

### 5.6 Paired Comparison of Two Diagnostic Tests (Connor Kernel)

- **Clinical scenario**: The same patients undergo both assays (paired
  design): sensitivities 85% vs. 75%, expected discordant-pair
  proportion \\\psi = 0.10\\ — dramatically fewer cases needed.
- **Formula** (Connor): \\n = \frac{\left\[Z\_{\alpha/2}\sqrt{\psi} +
  Z\_{\beta}\sqrt{\psi-\delta^2}\right\]^2}{\delta^2}\\

``` r

res_5_6 <- calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = TRUE, psi = 0.10, alpha = 0.05, power = 0.8)
print(res_5_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two diagnostic measures (paired, Connor)"
#> • Pairs needed: 77
#> • Total subjects to screen: 381
#> • Cases needed: 77
#> • Total subjects: 381
#> Parameter roles
#> 
#> • p1/p2 = expected sensitivities of the two tests
#> • psi = expected discordant-pair proportion (pi10 + pi01)
#> • output is in PAIRS (cases); screening total = pairs/prevalence
#> Formula (plain text):
#> `n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi-\delta^2}\right]^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Paired binary parameters: p1 = 0.85, p2 = 0.75, discordant pair
#> proportion psi = 0.10, difference delta = |p1 - p2| = 0.10.
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) + Z_beta*sqrt(psi -
#> delta^2)]^2 / delta^2 = 76.09.
#> • Step 4: Round up to integer: Pairs needed = 77.
#> Reference:
#> Primary: Connor, R. J. (1987). Biometrics, 43(1), 207-211.
#> 
#>  Also: Akoglu, H. (2022). Turkish Journal of Emergency Medicine, 22(4), Table 2 Eq 3b + Tables 6A/6B; Zhou et al. (2011) Section 6.2.2.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 77 pairs of cases, 385 screened.

### 5.7 Diagnostic Non-Inferiority (Proportions)

- **Clinical scenario**: A simplified rapid test (sensitivity 90%) must
  be non-inferior to the laboratory reference (88%) within a 5% margin,
  prevalence 30%.
- **Formula**: \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(p_1-p_2+\Delta)^2}\\

``` r

res_5_7 <- calculate("diagAccuracyCompare", "noninferiority", "proportion", p1 = 0.90, p2 = 0.88, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_7)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic non-inferiority (two proportions)"
#> • Sample size per group: 247
#> • Total sample size: 494
#> • Cases needed: 247
#> • Total subjects to screen: 823
#> • Total subjects: 823
#> Parameter roles
#> 
#> • p1/p2 = expected sensitivities (or specificities) of the new/reference test
#> • margin = non-inferiority/equivalence margin Delta
#> • non-inferiority uses one-sided alpha; equivalence uses Z_{beta/2}
#> Formula (plain text):
#> `n = (Za+Zb)^2 * (p1q1+p2q2) / (p1-p2+margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha}+Z_{\beta})^2\left[p_1(1-p_1)+p_2(1-p_2)\right]}{(p_1-p_2+\Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: State non-inferiority hypotheses: H0: p1 - p2 <= -margin vs H1: p1 -
#> p2 > -margin (margin Delta = 0.05, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = p1 - p2 + margin = 0.90 - 0.88 + 0.05
#> = 0.07.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)]
#> / delta_E^2 = 246.80.
#> • Step 5: Round up to integer: n = 247 per group, total sample size N = 494.
#> Reference:
#> Framework: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press (margin designs); Machin et al. (2018) Ch.11.
#> 
#>  Diagnostic application: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.), Section 6.3 (non-inferiority/equivalency of two tests), pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 247 cases, 824 screened.

### 5.8 Diagnostic Equivalence (Proportions)

- **Clinical scenario**: Two benchtop analysers: sensitivity 90%
  vs. 89%, equivalence corridor \\\pm 5\\\\.
- **Formula**: \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta/2})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(\Delta-\|p_1-p_2\|)^2}\\

``` r

res_5_8 <- calculate("diagAccuracyCompare", "equivalence", "proportion", p1 = 0.90, p2 = 0.89, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic equivalence (two proportions)"
#> • Sample size per group: 1006
#> • Total sample size: 2012
#> • Cases needed: 1006
#> • Total subjects to screen: 3353
#> • Total subjects: 3353
#> Parameter roles
#> 
#> • p1/p2 = expected sensitivities (or specificities) of the new/reference test
#> • margin = non-inferiority/equivalence margin Delta
#> • non-inferiority uses one-sided alpha; equivalence uses Z_{beta/2}
#> Formula (plain text):
#> `n = (Za+Zb/2)^2 * (p1q1+p2q2) / (margin-|p1-p2|)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha}+Z_{\beta/2})^2\left[p_1(1-p_1)+p_2(1-p_2)\right]}{(\Delta-|p_1-p_2|)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic equivalence (two proportions).
#> • Step 2: Input parameters: p1 = 0.90, p2 = 0.89, margin = 0.05, task =
#> equivalence, prevalence = 0.30, alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = (Za+Zb/2)^2 * (p1q1+p2q2) /
#> (margin-|p1-p2|)^2.
#> • Step 4: Calculated sample size metrics: Sample size per group: 1006; Total
#> sample size: 2012; Cases needed: 1006; Total subjects to screen: 3353.
#> Reference:
#> Framework: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press (margin designs); Machin et al. (2018) Ch.11.
#> 
#>  Diagnostic application: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.), Section 6.3 (non-inferiority/equivalency of two tests), pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 1006 cases, 3354 screened.

### 5.9 ROC Area Under the Curve (AUC) Precision (Binormal Model)

- **Clinical scenario**: Planning a biomarker validation cohort:
  anticipated AUC = 0.80, 95% CI half-width \\\pm 0.10\\, cases:controls
  1:1.
- **Formula** (Obuchowski 1994 binormal variance, Zhou Eq 6.5):
  \\n\_{cases} = \left(\frac{Z\_{1-\alpha/2}}{d}\right)^2 \cdot V(AUC),
  \quad V = 0.0099\\e^{-a^2/2}\left\[(5a^2+8) +
  \frac{a^2+8}{R}\right\],\\ a = \sqrt{2}\\\Phi^{-1}(A)\\

``` r

res_5_9 <- calculate("diagAUC", "estimate", "auc", auc = 0.80, d = 0.10, ratio = 1, var_method = "binormal", alpha = 0.05)
print(res_5_9)
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

- **Output**: 46 cases, 46 controls (92 total).

### 5.10 ROC-AUC Superiority Test

- **Clinical scenario**: A new miRNA panel must show AUC significantly
  above the 0.70 clinical pass line; anticipated AUC 0.80, prevalence
  30%.
- **Formula**: \\n\_{cases} = \frac{\left(Z\_{\alpha}\sqrt{V(AUC_0)} +
  Z\_{\beta}\sqrt{V(AUC)}\right)^2}{(AUC - AUC_0)^2}\\

``` r

res_5_10 <- calculate("diagAUC", "test", "auc", auc = 0.80, auc0 = 0.70, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_10)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "AUC superiority (single)"
#> • Cases needed: 180
#> • Total subjects to screen: 600
#> • Total subjects: 600
#> Formula (plain text):
#> `n_cases = (Z_alpha * sqrt(V(AUC0)) + Z_beta * sqrt(V(AUC)))^2 / (AUC -
#> AUC0)^2`
#> Formula (LaTeX):
#> $$n_{cases} = \frac{\left(Z_{\alpha}\sqrt{V(AUC_0)} + Z_{\beta}\sqrt{V(AUC)}\right)^2}{(AUC - AUC_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify AUC alternative = 0.80, null AUC0 = 0.70, prevalence = 0.30
#> (one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 3: Evaluate Hanley-McNeil variance under alternative V(AUC) and null
#> V(AUC0).
#> • Step 4: Calculate target cases: n_cases = [Z_alpha*sqrt(V(AUC0)) +
#> Z_beta*sqrt(V(AUC))]^2 / (AUC - AUC0)^2.
#> • Step 5: Round up to integer: Target cases needed = 180, Total subjects to
#> screen = 600.
#> Reference:
#> Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.
#> 
#> Review: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 180 cases, 600 screened.

### 5.11 Two ROC-AUC Comparison

- **Clinical scenario**: CT vs. MRI for liver lesion characterisation:
  anticipated AUCs 0.80 vs. 0.70, correlation between the two AUC
  estimates \\r = 0.50\\ (same patients).
- **Formula**: \\n\_{cases} = \frac{2(Z\_{\alpha/2} + Z\_{\beta})^2
  \cdot V(AUC) \cdot (1-r)}{(AUC_1 - AUC_2)^2}\\ Hajian-Tilaki (2014),
  Eqs 7.6/7.8.

``` r

res_5_11 <- calculate("diagAUCCompare", "test", "auc", auc1 = 0.80, auc2 = 0.70, r = 0.50, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_11)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "AUC comparison (two tests)"
#> • Cases needed: 223
#> • Total subjects to screen: 743
#> • Total subjects: 743
#> Formula (plain text):
#> `n_cases = 2 * (Z_alpha/2 + Z_beta)^2 * V(AUC) * (1 - r) / (AUC1 - AUC2)^2`
#> Formula (LaTeX):
#> $$n_{cases} = \frac{2(Z_{\alpha/2} + Z_{\beta})^2 \cdot V(AUC) \cdot (1-r)}{(AUC_1 - AUC_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify AUC1 = 0.80, AUC2 = 0.70, correlation r = 0.50, prevalence =
#> 0.30 (alpha = 0.05, power = 0.80).
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Evaluate pooled Hanley-McNeil variance V(AUC_avg).
#> • Step 4: Calculate target cases: n_cases = 2 * (Z_(alpha/2) + Z_beta)^2 *
#> V(AUC) * (1 - r) / (AUC1 - AUC2)^2.
#> • Step 5: Round up to integer: Target cases needed = 223, Total subjects to
#> screen = 743.
#> Reference:
#> Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 223 cases, 744 screened.

### 5.12 Two ROC-AUC Non-Inferiority

- **Clinical scenario**: A portable low-cost device (AUC 0.85) must be
  non-inferior to the standard platform (AUC 0.82) within margin 0.05.
- **Formula**: \\n = \frac{2(Z\_{\alpha}+Z\_{\beta})^2
  V(1-r)}{(AUC_1-AUC_2+\Delta)^2}\\

``` r

res_5_12 <- calculate("diagAUCCompare", "noninferiority", "auc", auc1 = 0.85, auc2 = 0.82, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_5_12)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic non-inferiority (two ROC areas)"
#> • Cases needed: 80
#> • Total subjects to screen: 159
#> • Total subjects: 159
#> Parameter roles
#> 
#> • auc1/auc2 = anticipated ROC areas of the new/reference test
#> • r = expected correlation between the two AUC estimates (paired designs)
#> • margin = non-inferiority/equivalence margin on the AUC difference
#> Formula (plain text):
#> `n = 2(Za+Zb)^2 * V * (1-r) / (auc1-auc2+margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{2(Z_{\alpha}+Z_{\beta})^2 V(1-r)}{(AUC_1-AUC_2+\Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic non-inferiority (two ROC areas).
#> • Step 2: Input parameters: auc1 = 0.85, auc2 = 0.82, r = 0.50, margin = 0.05,
#> task = noninferiority, var_method = exponential, alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = 2(Za+Zb)^2 * V * (1-r) /
#> (auc1-auc2+margin)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 80; Total subjects to
#> screen: 159.
#> Reference:
#> Framework: margin designs per Chow et al. (2017); Machin et al. (2018) Ch.11. AUC variance per Zhou et al. (2011) Eq 6.4/6.5/6.6.
#> 
#>  Diagnostic application: Zhou et al. (2011) Section 6.3, pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 80 cases, 160 screened.

### 5.13 Two ROC-AUC Equivalence

- **Clinical scenario**: Two AI vendors claim interchangeable
  performance: AUC 0.85 vs. 0.84, equivalence margin 0.05.
- **Formula**: \\n = \frac{2(Z\_{\alpha}+Z\_{\beta/2})^2
  V(1-r)}{(\Delta-\|AUC_1-AUC_2\|)^2}\\

``` r

res_5_13 <- calculate("diagAUCCompare", "equivalence", "auc", auc1 = 0.85, auc2 = 0.84, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_5_13)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic equivalence (two ROC areas)"
#> • Cases needed: 416
#> • Total subjects to screen: 831
#> • Total subjects: 831
#> Parameter roles
#> 
#> • auc1/auc2 = anticipated ROC areas of the new/reference test
#> • r = expected correlation between the two AUC estimates (paired designs)
#> • margin = non-inferiority/equivalence margin on the AUC difference
#> Formula (plain text):
#> `n = 2(Za+Zb/2)^2 * V * (1-r) / (margin-|auc1-auc2|)^2`
#> Formula (LaTeX):
#> $$n = \frac{2(Z_{\alpha}+Z_{\beta/2})^2 V(1-r)}{(\Delta-|AUC_1-AUC_2|)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic equivalence (two ROC areas).
#> • Step 2: Input parameters: auc1 = 0.85, auc2 = 0.84, r = 0.50, margin = 0.05,
#> task = equivalence, var_method = exponential, alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = 2(Za+Zb/2)^2 * V * (1-r) /
#> (margin-|auc1-auc2|)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 416; Total subjects to
#> screen: 831.
#> Reference:
#> Framework: margin designs per Chow et al. (2017); Machin et al. (2018) Ch.11. AUC variance per Zhou et al. (2011) Eq 6.4/6.5/6.6.
#> 
#>  Diagnostic application: Zhou et al. (2011) Section 6.3, pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 317 cases, 634 screened.

### 5.14 Negative Likelihood Ratio Threshold Precision

- **Clinical scenario**: A D-dimer rule-out pathway requires the upper
  95% CI limit of LR\\^-\\ to stay below 0.40; expected sensitivity 90%,
  specificity 50%.
- **Formula** (Simel 1991 log-CI): \\\log(LR) \pm
  Z\_{1-\alpha/2}\sqrt{\frac{1-Se}{n \cdot Se} + \frac{1-Sp}{n \cdot
  Sp}}\\ Hajian-Tilaki (2014), Section 6.4, Eqs 6.13/6.14.

``` r

res_5_14 <- calculate("diagLR", "estimate", "lr", sens = 0.90, spec = 0.50, target_lr = 0.40, lr_type = "negative", alpha = 0.05)
print(res_5_14)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Likelihood ratio (negative, log-CI method)"
#> • Cases needed: 9
#> • Controls needed: 9
#> • Total subjects: 18
#> Parameter roles
#> 
#> • sens/spec = expected sensitivity/specificity (determine the observed LR)
#> • target_lr = LR boundary the CI must not cross (precision target)
#> • n is computed per group (equal cases and controls)
#> ! Calculates sample size ensuring the log-scale CI does not cross target_lr (threshold precision),
#> ! distinct from fixed-width CI approaches (e.g. prec_lr in presize).
#> 
#> Formula (plain text):
#> `log(LR) +- Z * sqrt((1-Se)/(n*Se) + (1-Sp)/(n*Sp))`
#> Formula (LaTeX):
#> $$\log(LR) \pm Z_{1-\alpha/2}\sqrt{\frac{1-Se}{n \cdot Se} + \frac{1-Sp}{n \cdot Sp}}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Likelihood ratio (negative, log-CI method).
#> • Step 2: Input parameters: sensitivity = 0.90, specificity = 0.50, lr_type =
#> negative, lr_observed = 0.20, target_lr = 0.40, prevalence = 1, alpha = 0.05.
#> • Step 3: Apply design formula: log(LR) +- Z * sqrt((1-Se)/(n*Se) +
#> (1-Sp)/(n*Sp)).
#> • Step 4: Calculated sample size metrics: Total sample size: 18; Cases needed:
#> 9; Controls needed: 9; Total subjects: 18.
#> Reference:
#> Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204 (Section 6.4, Eqs 6.13/6.14; worked example n=80 per group).
#> 
#>  CI method: Simel, D. L., Samsa, G. P., & Matchar, D. B. (1991). Likelihood ratios with confidence: sample size estimation for accuracy of a diagnostic test. Journal of Clinical Epidemiology, 44(11), 1123-1130.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 9 cases, 9 controls (18 total).

### 5.15 Guaranteed Screening Target (`screen_required`)

- **Clinical scenario**: On average, screening 980 patients yields the
  196 confirmed cases needed for Section 5.1 — but that only holds with
  50% probability. To *guarantee* enough cases with 90% probability,
  inflate the screening list.
- **Formula**: \\P(\text{Binomial}(N, \text{prevalence}) \ge n) \ge
  1-\beta\\ Zhou et al. (2011), Eq 6.3.

``` r

safe_n <- screen_required(n = 196, prevalence = 0.20, beta = 0.10)
cat("Average screening target: 980; 90% guaranteed enrollment target:", safe_n, "\n")
#> Average screening target: 980; 90% guaranteed enrollment target: 1061
```

- **Output**: 1058 screened patients to guarantee \\\ge 196\\ cases with
  90% probability.

### 5.16 Multi-Reader Multi-Case (MRMC) Power Analysis

- **Clinical scenario**: A mammography study where 8 radiologists
  independently read 50 cases with two imaging techniques; detect an AUC
  difference of 0.10 using the Obuchowski-Rockette mixed model.
- **Formula** (non-central \\F\\, Zhou Eq 6.32): \\\lambda =
  \frac{J\delta^2}{2\left\[\sigma_b^2(1-\rho_1) + \sigma_w^2/Q +
  \frac{\sigma_c^2(1-\rho_1)}{n} +
  \rho_2\sigma_b^2\left((1-\rho_1)+(J-1)(\rho_2-\rho_3)\right)\right\]},
  \quad \text{power} = P(F\_{1,J-1}(\lambda) \> F\_{1-\alpha})\\ Zhou et
  al. (2011), Section 6.5, p. 225.

``` r

res_5_16 <- mrmc_power(n = 50, J = 8, delta = 0.10, sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.05, rho1 = 0.25, rho2 = 0.20, rho3 = 0.10)
print(res_5_16)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "MRMC (paired-patient, paired-reader, Obuchowski-Rockette)"
#> Parameter roles
#> 
#> • n = cases per test (paired-patient: total cases)
#> • J = readers per test
#> • delta = accuracy difference to detect
#> • sigma_b2/sigma_w2/sigma_c2 = reader/occasion/case variance components
#> • rho1/rho2/rho3 = correlations (same-reader-diff-test / diff-reader-same-test
#> / diff-reader-diff-test)
#> ! MRMC power depends on 6 variance/correlation components estimated from
#> ! pilot data or literature (Zhou Table 6.3); treat results as approximate.
#> ! For reader variability planning: sigma_b2 = (accuracy range / 4)^2 is a
#> ! common heuristic (Zhou p. 223, Beam 1996 mammography example).
#> 
#> Formula (plain text):
#> `lambda = J*delta^2/(2*[sb2(1-r1) + sw2/Q + sc2(1-r1)/n +
#> r2*sb2*((1-r1)+(J-1)(r2-r3))]); power = P(F_{1,J-1}(lambda) > F_{1-alpha})`
#> Formula (LaTeX):
#> $$\lambda = \frac{J \cdot \delta^2}{2\left[\sigma_b^2(1-r_1) + \frac{\sigma_w^2}{Q} + \frac{\sigma_c^2(1-r_1)}{n} + r_2 \sigma_b^2((1-r_1)+(J-1)(r_2-r_3))\right]}, \quad \text{Power} = P(F_{1,J-1}(\lambda) > F_{1-\alpha})$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: MRMC (paired-patient, paired-reader,
#> Obuchowski-Rockette).
#> • Step 2: Input parameters: n = 50, J = 8, delta = 0.10, sigma_b2 = 0.0012,
#> sigma_w2 = 0.0009, sigma_c2 = 0.05, rho1 = 0.25, rho2 = 0.20, rho3 = 0.10,
#> alpha = 0.05, n_repeats = 1, noncentrality_lambda = 13.7969.
#> • Step 3: Apply design formula: lambda = J*delta^2/(2*[sb2(1-r1) + sw2/Q +
#> sc2(1-r1)/n + r2*sb2*((1-r1)+(J-1)(r2-r3))]); power = P(F_{1,J-1}(lambda) >
#> F_{1-alpha}).
#> Reference:
#> Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley. Section 6.5, Eq 6.32, Tables 6.3-6.5, pp. 220-226 (mammography worked example).
#> 
#>  Model: Obuchowski, N. A., & Rockette, H. E. (1995). Hypothesis testing of diagnostic accuracy for multiple readers, multiple tests. Communications in Statistics - Simulation and Computation, 24, 285-308.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 88.8% statistical power (the textbook reports ~89%).

------------------------------------------------------------------------

## Chapter 6: Complex and Modern Trial Designs

### 6.1 Cluster Randomized Trial (Continuous Outcome)

- **Clinical scenario**: ICUs (not patients) are randomized to a new
  catheter-care bundle: complication score 10 \\\to\\ 12, SD = 3,
  average 20 beds per ICU, intra-cluster correlation ICC = 0.05.
- **Formula** (design effect): \\DE = 1 + (m-1) \times ICC = 1.95, \quad
  n\_{clusters} = \left\lceil \frac{n\_{individual} \times DE}{m}
  \right\rceil\\ Donner & Klar (2000); Machin et al. (2018), Ch. 12.

``` r

res_6_1 <- calculate("clusterRCT", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)
print(res_6_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cluster RCT: Two independent samples, mean comparison"
#> • Sample size per group: 80
#> • Total sample size: 160
#> • Clusters per arm: 4
#> Parameter roles
#> 
#> • icc = 0.05, cluster_size = 20 -> DE = 1.95; n_clusters per arm = 4
#> Formula (plain text):
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: Compute individual-level sample size without clustering from standard
#> two-group formulas.
#> • Step 2: Calculate design effect (inflation factor): DE = 1 + (cluster_size -
#> 1) * ICC = 1 + (20 - 1) * 0.05 = 1.95.
#> • Step 3: Inflate sample size for clustering: n_clustered = n_individual * DE.
#> • Step 4: Determine clusters required per arm: n_clusters = ceiling(n_clustered
#> / cluster_size) = 4.
#> • Step 5: Total individuals per arm = 4 * 20 = 80; Total sample size N = 160.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 12 (Cluster Designs); Donner, A., & Klar, N. (2000). Design and Analysis of Cluster Randomisation Trials in Health Research. Arnold.
#> 
#>  Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 4 clusters (80 patients) per arm, 8 clusters (160
  patients) total.

### 6.2 Cluster Randomized Trial (Binary Outcome)

- **Clinical scenario**: Village-level randomization of a
  screening-uptake intervention: uptake 20% \\\to\\ 30%, 20 residents
  per village, ICC = 0.05.
- **Formula**: same design effect applied to the two-proportion kernel.

``` r

res_6_2 <- calculate("clusterRCT", "test", "proportion", p1 = 0.30, p2 = 0.20, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)
print(res_6_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cluster RCT: Two independent proportions"
#> • Sample size per group: 580
#> • Total sample size: 1160
#> • Clusters per arm: 29
#> Parameter roles
#> 
#> • icc = 0.05, cluster_size = 20 -> DE = 1.95; n_clusters per arm = 29
#> Formula (plain text):
#> `n = (Z_a/2 * sqrt(2*p_bar*(1-p_bar)) + Z_b * sqrt(p1*(1-p1)+p2*(1-p2)))^2 /
#> (p1-p2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_2(1-p_2)}\right]^2}{(p_1 - p_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Compute individual-level sample size without clustering from standard
#> two-group formulas.
#> • Step 2: Calculate design effect (inflation factor): DE = 1 + (cluster_size -
#> 1) * ICC = 1 + (20 - 1) * 0.05 = 1.95.
#> • Step 3: Inflate sample size for clustering: n_clustered = n_individual * DE.
#> • Step 4: Determine clusters required per arm: n_clusters = ceiling(n_clustered
#> / cluster_size) = 29.
#> • Step 5: Total individuals per arm = 29 * 20 = 580; Total sample size N =
#> 1160.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 12 (Cluster Designs); Donner, A., & Klar, N. (2000). Design and Analysis of Cluster Randomisation Trials in Health Research. Arnold.
#> 
#>  Primary (formula as implemented, without continuity correction): Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346.
#> 
#> With continuity correction: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-494.
#> 
#> Book: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 29 clusters per arm, 58 clusters (1160 patients) total.

### 6.3 Stepped-Wedge Cluster Randomized Trial

- **Clinical scenario**: 24 counties sequentially adopt a hand-hygiene
  program (6 counties per step, baseline + 4 steps, 100 births per
  county per period); treatment effect \\\theta = -0.016\\ on infection
  risk.
- **Formula** (Hussey & Hughes Eq 8): \\Var(\hat{\theta}) = \frac{I
  \tau^2 (\tau^2 + T\sigma^2)}{(IU - W)\tau^2 + (U^2 + ITU - TW -
  IV)\sigma^2}, \quad \text{power} = \Phi\left(\|\theta\|/SE -
  z\_{1-\alpha/2}\right)\\ Hussey & Hughes (2007), *Contemp Clin Trials*
  28(2), 182-191.

``` r

res_6_3 <- calculate("steppedWedge", "test", "mean", theta = -0.016, tau2 = 2.25e-4, sigma2_ind = 0.0475, m = 100, n_clusters = 24, clusters_per_step = 6, alpha = 0.05)
print(res_6_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Stepped wedge cluster trial (Hussey-Hughes, mean outcome)"
#> • Clusters per arm: 24
#> • Power achieved: 0.908
#> Parameter roles
#> 
#> • theta = treatment effect (additive scale; e.g. risk difference)
#> • tau2 = between-cluster variance (e.g. (CV*mean)^2)
#> • sigma2_ind = individual-level variance (binary: p(1-p))
#> • m = individuals sampled per cluster per time point
#> • clusters_per_step = clusters randomized at each step (full design)
#> ! Hussey & Hughes (2007) Eq 8 assumes no underlying calendar time trends.
#> ! If secular time trends are present, statistical power may be lower;
#> ! consider incorporating time fixed effects via simulation or swCRTdesign.
#> 
#> Formula (plain text):
#> `Var = I*t2*(t2+T*s2)/((I*U-W)*t2 + (U^2+I*T*U-T*W-I*V)*s2); power =
#> Phi(|theta|/se - z)`
#> Formula (LaTeX):
#> $$\text{Var}(\hat{\theta}) = \frac{I \tau^2(\tau^2+T\sigma^2)}{(IU-W)\tau^2 + (U^2+ITU-TW-IV)\sigma^2}, \quad \sigma^2 = \sigma_{ind}^2/m, \quad \text{Power} = \Phi\left(\frac{|\theta|}{\text{SE}} - z_{1-\alpha/2}\right)$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Stepped wedge cluster trial (Hussey-Hughes,
#> mean outcome).
#> • Step 2: Input parameters: theta = -0.016, tau2 = 0.0002, sigma2_ind = 0.0475,
#> m = 100, n_clusters = 24, clusters_per_step = 6, alpha = 0.05.
#> • Step 3: Apply design formula: Var = I*t2*(t2+T*s2)/((I*U-W)*t2 +
#> (U^2+I*T*U-T*W-I*V)*s2); power = Phi(|theta|/se - z).
#> • Step 4: Calculated sample size metrics: Clusters per arm: 24; Power achieved:
#> 0.908.
#> Reference:
#> Primary: Hussey, M. A., & Hughes, J. P. (2007). Design and analysis of stepped wedge cluster randomized trials. Contemporary Clinical Trials, 28(2), 182-191 (Eq 8; EPT worked example I=24, T=5).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 90.8% statistical power.

### 6.4 Ordered Categorical Outcome (Whitehead Model)

- **Clinical scenario**: Knee osteoarthritis pain graded
  mild/moderate/severe with expected distribution 20%/50%/30%; the new
  intra-articular therapy is anticipated to shift the odds of a better
  category by OR = 1.5.
- **Formula** (Whitehead 1993): \\N =
  \frac{3\\(Z\_{\alpha/2}+Z\_{\beta})^2}{(\log OR)^2\\(1-\sum
  \bar{p}\_j^3)}\\

``` r

res_6_4 <- calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.5, 0.3), alpha = 0.05, power = 0.8)
print(res_6_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two-group ordered categorical outcome (Mann-Whitney /
#> proportional odds)"
#> • Sample size per group: 86
#> • Total sample size: 171
#> Parameter roles
#> 
#> • or = anticipated odds ratio (proportional odds)
#> • prop_bar = anticipated average category proportions (sums to 1)
#> • output: total N and per-group n (equal allocation)
#> Formula (plain text):
#> `N = 3(Za/2+Zb)^2 / ((log OR)^2 * (1 - sum(p_bar^3)))`
#> Formula (LaTeX):
#> $$N = \frac{3\,(Z_{\alpha/2}+Z_{\beta})^2}{(\log OR)^2\,(1-\sum \bar{p}_j^3)}$$
#> Calculation process:
#> 
#> • Step 1: Specify odds ratio OR = 1.50, pooled proportion categories = [0.20,
#> 0.50, 0.30].
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Compute Whitehead variance factor: 1 - sum(p_bar_j^3).
#> • Step 4: Whitehead formula: N = 3 * (Z_(alpha/2) + Z_beta)^2 / [(ln OR)^2 * (1
#> - sum(p_bar^3))].
#> • Step 5: Round up to integer: Total sample size N = 171, per group n = 86.
#> Reference:
#> Primary: Whitehead, J. (1993). Sample size calculations for ordered categorical data. Statistics in Medicine, 12(24), 2257-2271.
#> 
#>  Also: Machin et al. (2018) Chapter 4 (Ordered Categorical Outcomes).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 86 per arm, 171 total.

### 6.5 Clinical Prediction Model Development (Riley 2020 BMJ Binary)

- **Clinical scenario**: Developing an ICU mortality prediction model
  with 10 candidate predictors, outcome proportion 30%, anticipated
  Cox-Snell \\R^2\_{CS} = 0.10\\, target shrinkage \\S = 0.90\\.
- **Formula** (Riley 2020, criteria B1 & B3): \\n\_{B1} =
  \left(\frac{z}{\delta}\right)^2 \phi(1-\phi), \quad n\_{B3} =
  \frac{P}{(S-1)\ln(1-R^2\_{CS}/S)}, \quad n = \max(n\_{B1}, n\_{B3})\\
  Riley et al. (2020), *BMJ* 368, m441 (matches `pmsampsize`).

``` r

res_6_5 <- calculate("predictiveModel", "plan", "binary", prev = 0.30, n_parameters = 10, r2_cs = 0.10, shrinkage = 0.90, precision_delta = 0.05, alpha = 0.05)
print(res_6_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Prediction model development (Riley 2020, binary)"
#> • Required sample size: 850
#> • Events required: 255
#> Parameter roles
#> 
#> • prev = anticipated outcome proportion in the target population
#> • n_parameters = candidate predictor parameters (P)
#> • r2_cs = anticipated Cox-Snell R2 (conservative, optimism-adjusted)
#> • shrinkage = target uniform shrinkage factor S (default 0.9)
#> • mape = target mean absolute prediction error (default 0.05)
#> ! B1 (proportion precision, delta=0.050): n = 323
#> ! B3 (shrinkage S=0.90, R2cs=0.1000): n = 850
#> ! B2 (MAPE=0.050, P=10 <= 30): n = 461 (informational)
#> ! B4 (optimism in Nagelkerke R2 <= 0.05) is handled inside B3 via the
#> ! shrinkage target in the pmsampsize implementation; see Riley 2020 Box 1.
#> 
#> Formula (plain text):
#> `B1: n=(z/d)^2*p(1-p); B3: n=P/((S-1)*ln(1-R2cs/S)); n = max(B1, B3)`
#> Formula (LaTeX):
#> $$n_{B1} = \left(\frac{z_{1-\alpha/2}}{\delta}\right)^2 \phi(1-\phi), \quad n_{B3} = \frac{p}{(S-1)\ln(1 - R_{CS}^2/S)}, \quad n = \max(n_{B1}, n_{B3})$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Prediction model development (Riley 2020,
#> binary).
#> • Step 2: Input parameters: prev = 0.30, n_parameters = 10, r2_cs = 0.10,
#> max_r2cs = 0.7053, shrinkage = 0.90, mape = 0.05, precision_delta = 0.05, alpha
#> = 0.05.
#> • Step 3: Apply design formula: B1: n=(z/d)^2*p(1-p); B3:
#> n=P/((S-1)*ln(1-R2cs/S)); n = max(B1, B3).
#> • Step 4: Calculated sample size metrics: Required sample size: 850; Total
#> sample size: 850; Events required: 255.
#> Reference:
#> Primary: Riley, R. D., Ensor, J., Snell, K. I. E., et al. (2020). Calculating the sample size required for developing a clinical prediction model. BMJ, 368, m441 (Box 1, Figures 1-5).
#> 
#>  B2 formula: van Smeden, M., et al. (2019). Stat Methods Med Res, 28, 2455-74. B3 derivation: Riley et al. (2019). Stat Med, 38, 1276-96 (PART II). Software: pmsampsize (Stata/R).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 850 participants and 255 events (matches `pmsampsize`).

### 6.6 Clinical Prediction Model Development (Riley 2020 Rate)

- **Clinical scenario**: A 10-year cardiovascular death prediction
  model: annual event rate 0.10, the cumulative incidence at 10 years
  must be estimated within \\\pm 5\\\\.
- **Formula** (criterion T1): \\F(t) = 1 - e^{-\lambda t}\\; find
  person-years \\T\\ such that both CI margins of \\F(t)\\ stay within
  \\\delta\\.

``` r

res_6_6 <- calculate("predictiveModel", "plan", "rate", rate = 0.10, timepoint = 10, precision_delta = 0.05, alpha = 0.05)
print(res_6_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Prediction model development (Riley 2020, time-to-event)"
#> • Required person-time: 2366
#> Parameter roles
#> 
#> • rate = anticipated event rate per person-year
#> • timepoint = key prediction time point t (years)
#> • precision_delta = maximum margin of error for F(t)
#> • n_parameters/epv = optional EPP cross-check (classic 10 EPV)
#> Formula (plain text):
#> `F(t) = 1-exp(-rate*t); CI: 1-exp(-(rate +- z*sqrt(rate/T))*t); find T with
#> margins <= delta`
#> Formula (LaTeX):
#> $$F(t) = 1 - e^{-\lambda t}, \quad \text{CI: } 1 - \exp\left(-\left(\lambda \pm z_{1-\alpha/2}\sqrt{\frac{\lambda}{T}}\right)t\right)$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Prediction model development (Riley 2020,
#> time-to-event).
#> • Step 2: Input parameters: rate = 0.10, timepoint = 10, precision_delta =
#> 0.05, alpha = 0.05, n_parameters = , epv = .
#> • Step 3: Apply design formula: F(t) = 1-exp(-rate*t); CI: 1-exp(-(rate +-
#> z*sqrt(rate/T))*t); find T with margins <= delta.
#> • Step 4: Calculated sample size metrics: Required person-time: 2366.
#> Reference:
#> Primary: Riley, R. D., Ensor, J., Snell, K. I. E., et al. (2020). Calculating the sample size required for developing a clinical prediction model. BMJ, 368, m441 (Figure 1, time-to-event panel; criterion T1; worked example: rate=0.10/year, t=10y, delta=0.05 -> 2366 person-years).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 2366 person-years.

### 6.7 Prediction Model Development (Classic EPV)

- **Clinical scenario**: Quick grant-proposal rule of thumb for a
  10-predictor logistic model in a population with 30% event prevalence.
- **Formula**: \\n\_{events} = EPV \times k, \quad n\_{subjects} =
  n\_{events} / \pi\\ Peduzzi et al. (1996), *J Clin Epidemiol* 49(12),
  1373-1379.

``` r

res_6_7 <- calculate("predictiveModel", "plan", "events", n_parameters = 10, epv = 10, event_prevalence = 0.30)
print(res_6_7)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Prediction model development (events-per-variable)"
#> • Required sample size: 334
#> • Events required: 100
#> Parameter roles
#> 
#> • n_parameters = candidate predictor parameters (k)
#> • epv = events per variable (classic minimum 10)
#> • event_prevalence = proportion of subjects with the outcome
#> ! EPV >= 10 is a minimum heuristic; Riley et al. (2019, BMJ 364:l951)
#> ! provide a modern precision-based alternative (planned for a later release).
#> 
#> Formula (plain text):
#> `n_events = EPV * k ; n_subjects = n_events / prevalence`
#> Formula (LaTeX):
#> $$n_{events} = EPV \times k, \quad n_{subjects} = n_{events} / \pi$$
#> Calculation process:
#> 
#> • Step 1: Specify candidate predictor parameters k = 10, Events Per Variable
#> target EPV = 10.
#> • Step 2: Calculate required events: n_events = EPV * k = 10 * 10 = 100.
#> • Step 3: Convert to subjects using event prevalence pi = 0.30: n_subjects =
#> n_events / prevalence = 334.
#> • Step 4: Required events = 100, Total subjects = 334.
#> Reference:
#> Primary: Peduzzi, P., Concato, J., Kemper, E., Holford, T. R., & Feinstein, A. R. (1996). A simulation study of the number of events per variable in logistic regression analysis. Journal of Clinical Epidemiology, 49(12), 1373-1379.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 100 events, 334 total participants.

### 6.8 Inter-Rater Reliability: Cohen’s Kappa Precision

- **Clinical scenario**: Two radiologists independently grade 2-view
  mammograms; anticipated \\\kappa = 0.70\\, the 95% CI half-width must
  not exceed \\\pm 0.10\\.
- **Formula** (Cantor 1996): \\n =
  Q\left(\frac{z\_{1-\alpha/2}}{d}\right)^2, \quad Q =
  \frac{p_o(1-p_o)}{(1-p_e)^2}\\

``` r

res_6_8 <- calculate("kappa", "estimate", "proportion", pi1 = 0.30, pi2 = 0.30, kappa = 0.70, d = 0.10, alpha = 0.05)
print(res_6_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohen's kappa estimation (CI precision)"
#> • Required sample size: 165
#> Parameter roles
#> 
#> • pi1/pi2 = expected Rating-1 proportions for rater 1 / rater 2
#> • kappa1 = planning value of kappa
#> • d = desired CI half-width
#> Formula (plain text):
#> `n = Q * (z/d)^2 ; Q = p_o(1-p_o)/(1-p_e)^2`
#> Formula (LaTeX):
#> $$n = Q\left(\frac{z_{1-\alpha/2}}{d}\right)^2, \quad Q = \frac{p_o(1-p_o)}{(1-p_e)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Cohen's kappa estimation (CI precision).
#> • Step 2: Input parameters: pi1 = 0.30, pi2 = 0.30, kappa = 0.70, d = 0.10,
#> alpha = 0.05, Q = 0.4272.
#> • Step 3: Apply design formula: n = Q * (z/d)^2 ; Q = p_o(1-p_o)/(1-p_e)^2.
#> • Step 4: Calculated sample size metrics: Required sample size: 165; Total
#> sample size: 165.
#> Reference:
#> Primary: Cantor, A. B. (1996). Sample-size calculations for Cohen's kappa. Psychological Methods, 1(2), 150-153 (Fleiss-Cohen-Everitt 1969 asymptotic variance; worked examples N=165 and N=214).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 165 participants.

### 6.9 Inter-Rater Reliability: Two Independent Kappa Test

- **Clinical scenario**: Does a new structured reporting checklist
  improve agreement over the old one? Anticipated \\\kappa_1 = 0.70\\
  vs. \\\kappa_2 = 0.50\\ in two independent reader groups.
- **Formula**: \\n = \frac{\left\[z\_{\alpha}\sqrt{2Q_1} +
  z\_{\beta}\sqrt{Q_1+Q_2}\right\]^2}{(K_1-K_2)^2}\\ Cantor (1996),
  *Psychological Methods* 1(2), 150-153.

``` r

res_6_9 <- calculate("kappa", "test", "proportion", pi1 = 0.50, pi2 = 0.50, kappa1 = 0.70, kappa2 = 0.50, alpha = 0.05, power = 0.8)
print(res_6_9)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohen's kappa test (two independent kappas)"
#> • Required sample size: 214
#> Parameter roles
#> 
#> • pi1/pi2 = expected Rating-1 proportions (both raters/groups)
#> • kappa1 = kappa under the null (e.g. questionnaire 1)
#> • kappa2 = kappa under the alternative (e.g. questionnaire 2)
#> • n is per group (two independent kappa estimates)
#> Formula (plain text):
#> `n = (z_a*sqrt(2*Q1) + z_b*sqrt(Q1+Q2))^2/(K1-K2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[z_{\alpha}\sqrt{2Q_1} + z_{\beta}\sqrt{Q_1+Q_2}\right]^2}{(K_1-K_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Cohen's kappa test (two independent kappas).
#> • Step 2: Input parameters: pi1 = 0.50, pi2 = 0.50, kappa1 = 0.70, kappa2 =
#> 0.50, alpha = 0.05, power = 0.80, Q_null = 0.51, Q_alt = 0.75.
#> • Step 3: Apply design formula: n = (z_a*sqrt(2*Q1) +
#> z_b*sqrt(Q1+Q2))^2/(K1-K2)^2.
#> • Step 4: Calculated sample size metrics: Required sample size: 214; Total
#> sample size: 214.
#> Reference:
#> Primary: Cantor, A. B. (1996). Sample-size calculations for Cohen's kappa. Psychological Methods, 1(2), 150-153 (worked example: K1=0.7, K2=0.5, pi=0.5 -> N=214).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 214 participants per group.

### 6.10 Interrupted Time Series (ITS Level Change)

- **Clinical scenario**: A sugar-sweetened beverage tax: monthly
  consumption monitored 12 months before and 12 months after the policy;
  anticipated level jump of 2 outcome-SDs, AR(1) autocorrelation \\\rho
  = 0.30\\.
- **Formula** (AR(1)-adjusted approximation): \\\text{power} =
  \Phi\left(\frac{\delta}{SE} - z\_{\alpha/2}\right), \quad SE =
  \sqrt{\tfrac{1}{n\_{eff}^{pre}} + \tfrac{1}{n\_{eff}^{post}}}, \quad
  n\_{eff} = \frac{n(1-\rho)}{1+\rho}\\ Bernal, Cummins & Gasparrini
  (2017), *Int J Epidemiol* 46(1), 348-355 (experimental approximation).

``` r

res_6_10 <- calculate("its", "test", "rate", effect_sd = 2, n_pre = 12, n_post = 12, rho = 0.3, alpha = 0.05, power = 0.8)
print(res_6_10)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Interrupted time series (level change, AR(1)-adjusted)"
#> • Power achieved: 0.949
#> Parameter roles
#> 
#> • effect_sd = anticipated level change in outcome SD units
#> • n_pre/n_post = number of time points before/after the interruption
#> • rho = AR(1) autocorrelation of the series
#> ! EXPERIMENTAL method: transparent AR(1)-adjusted normal approximation.
#> ! Bernal et al. (2017, Int J Epidemiol) recommend >= 8 time points per segment;
#> ! rigorous ITS power calculations require simulation.
#> 
#> Formula (plain text):
#> `power = Phi(effect/SE - z); SE = sqrt(1/n_eff_pre + 1/n_eff_post); n_eff =
#> n(1-rho)/(1+rho)`
#> Formula (LaTeX):
#> $$\text{power} = \Phi\left(\frac{\delta}{SE} - z_{\alpha/2}\right), \quad SE = \sqrt{\tfrac{1}{n_{eff}^{pre}} + \tfrac{1}{n_{eff}^{post}}}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Interrupted time series (level change,
#> AR(1)-adjusted).
#> • Step 2: Input parameters: effect_sd = 2, n_pre = 12, n_post = 12, rho = 0.30,
#> alpha = 0.05.
#> • Step 3: Apply design formula: power = Phi(effect/SE - z); SE =
#> sqrt(1/n_eff_pre + 1/n_eff_post); n_eff = n(1-rho)/(1+rho).
#> • Step 4: Calculated sample size metrics: Power achieved: 0.949.
#> Reference:
#> Framework: Bernal, J. L., Cummins, S., & Gasparrini, A. (2017). Interrupted time series regression for the evaluation of public health interventions: a tutorial. International Journal of Epidemiology, 46(1), 348-355. Sample-size content is a transparent approximation, not from a validated source.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **Output**: 94.9% statistical power.

------------------------------------------------------------------------

## Chapter 7: Protocol Boilerplate & Visual Diagnostics

Default [`print()`](https://rdrr.io/r/base/print.html) output includes
both formula formats, the calculation process, and references. Use
[`summary()`](https://rdrr.io/r/base/summary.html) to additionally
display all input parameters, design axes, and recorded adjustments:

``` r

summary(res_1_1)
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

``` r

plot(res_1_1, type = "power")
```

![](sampleSizeCalc-guide-en_files/figure-html/plot-power-en-1.png)

``` r

plot(res_1_1, type = "sample_size")
```

![](sampleSizeCalc-guide-en_files/figure-html/plot-effect-en-1.png)
