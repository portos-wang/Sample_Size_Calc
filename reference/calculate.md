# Unified sample size calculator (three-axis API)

Computes sample size (or events/cases) for a study design identified by
the triple design / task / outcome. See the installed reference manual
`system.file("reference", "DESIGN_MATRIX.md", package = "sampleSizeCalc")`
for the complete combination table, formulas, and literature sources
(also on the pkgdown site under `reference/`).

## Usage

``` r
calculate(...)
```

## Arguments

- ...:

  ... Control and design arguments, resolved by EXACT name (partial
  matching is deliberately avoided so that design-specific arguments
  such as `d` cannot be swallowed by the `design` slot).

  **Control arguments**

  - `design` (first positional argument): one of `"rct"`, `"paired"`,
    `"rctSingleArm"`, `"crossover"`, `"bioequivalence"`,
    `"singleArmPhaseII"`, `"cohort"`, `"caseControl"`,
    `"caseControlMatched"`, `"crosstab"`, `"singleProportion"`,
    `"singleMean"`, `"singleCorrelation"`, `"diagAccuracy"`,
    `"diagAccuracyCompare"`, `"diagAUC"`, `"diagAUCCompare"`,
    `"diagLR"`, `"clusterRCT"`, `"steppedWedge"`, `"twoOrdinal"`,
    `"predictiveModel"`, `"kappa"`, `"its"` - the study-design axis.

  - `task` (second positional argument): `"test"`, `"estimate"`,
    `"noninferiority"`, `"superiority"`, `"equivalence"`, or `"plan"`;
    optional for unambiguous designs.

  - `outcome` (third positional argument): `"mean"`, `"proportion"`,
    `"rate"`, `"survival"`, `"auc"`, `"lr"`, `"correlation"`,
    `"ordinal"`, or `"events"`; optional for unambiguous designs.

  - `alpha`: scalar in (0, 1), default 0.05. Use 0.025 for one-sided
    non-inferiority trials spending a full two-sided 0.05.

  - `power`: scalar in (0, 1), default 0.8 (80 percent); 0.9 for
    confirmatory trials.

  - `alternative`: `"one.sided"` (the package's historical default and
    the Akoglu 2022 Table 2 Eq 2 convention) or `"two.sided"`
    (Hajian-Tilaki 2014 Eq 6.8 convention), or `NULL` to keep the design
    default. Currently consumed by `diagAccuracy` + `test` +
    `proportion` only; other designs ignore it.

  - `dropout`: anticipated dropout/non-response proportion in \[0, 1),
    inflating by 1/(1-d). Currently applied by `cohort` + `test` +
    `proportion` only; other designs ignore it.

  **Design-specific parameters** (all validated; ranges shown):

  - *RCT, test, mean*: `mean1`, `mean2` real-valued group means (e.g.
    mmHg); `sd` \> 0 pooled standard deviation.

  - *RCT, test, proportion*: `p1`, `p2` in (0, 1) response rates, must
    differ.

  - *RCT, test, survival*: `hr` in (0, 1) anticipated hazard ratio (\<1
    = benefit); `pE` in (0, 1) experimental-arm share (default 0.5).
    Returns **events** required.

  - *RCT, noninferiority/superiority, mean or proportion*: same inputs
    as above plus `margin` \> 0 (NI margin Delta, one-sided alpha; or
    the minimal clinically important difference for superiority).

  - *RCT, equivalence, mean or proportion*: `margin` = corridor
    half-width; must exceed \|mean1 - mean2\| (or \|p1 - p2\|); uses
    Z\_(beta/2).

  - *paired, mean*: `meanDiff` != 0 within-subject mean difference;
    `sdDiff` \> 0 SD of the differences (NOT the pooled SD).

  - *paired, proportion*: `p1`, `p2` in (0, 1); `psi` in (0, 1) expected
    discordant-pair proportion, psi \>= \|p1-p2\|; output in pairs.

  - *rctSingleArm, mean*: `mu0` historical mean, `mu1` anticipated mean,
    `sigma` \> 0.

  - *rctSingleArm, proportion*: `p0` historical rate, `p1` anticipated
    rate, both in (0, 1).

  - *crossover, mean*: `delta` \> 0 treatment difference; `sigma_within`
    \> 0 within-subject SD.

  - *bioequivalence*: `cv` in (0, 1) intra-subject CV; `theta0` GMR
    inside the acceptance range (default 1.0);
    `margin_low`/`margin_high` default 0.8/1.25 (80-125 rule).

  - *singleArmPhaseII*: `p0` unacceptable rate; `p1` \> p0 target rate;
    `optimizer` = "optimal" or "minimax".

  - *cohort, proportion*: `p0`, `p1` in (0, 1); `ratio` \>= 1
    unexposed:exposed; optional `dropout` in \[0, 1) inflates by
    1/(1-d).

  - *cohort, rate*: `rate0`, `rate1` \> 0 events per person-time;
    `ratio` at least 1 person-time ratio.

  - *caseControl*: `p0` in (0, 1) control exposure rate; `OR` \> 0, !=
    1; `m` \>= 1 controls per case (default 1).

  - *caseControlMatched*: `p0`, `OR` as above; 1:1 matching built in.

  - *crosstab*: `p0`, `p1` in (0, 1) prevalence in unexposed/exposed.

  - *singleProportion*: `p` in (0, 1); `precision` \> 0;
    `precision_type` = "absolute" (default) or "relative".

  - *singleMean*: `sigma` \> 0; `precision` \> 0 margin of error.

  - *singleCorrelation*: `r` in (0, 1); exactly one of `precision`
    (absolute CI half-width in (0, 1)) or `epsilon` (relative).

  - *diagAccuracy, estimate*: `prob` in (0, 1) expected Se/Sp; `d` in
    (0, 1) CI half-width; `prevalence` in (0, 1\]; optional `ci_method`
    = "precision" (Zhou Eq 6.2) or "ci_width_power" (Eq 6.1, uses
    `power`).

  - *diagAccuracy, test*: `prob`, `p0` in (0, 1); `method` =
    "asymptotic" or "exact" (A'Hern); dual-endpoint adds `prob_spec`,
    `p0_spec`, `dual = TRUE`, `dual_power` (default 0.90).

  - *diagAccuracyCompare*: `p1`, `p2` in (0, 1); `paired` = TRUE
    requires `psi` in (0, 1); margin tasks add `margin` in (0, 1).

  - *diagAUC, estimate*: `auc` in (0, 1); `d` \> 0; `ratio` \>= 1
    case:control (default 1); `var_method` = "binormal" (recommended),
    "exponential", or "conservative".

  - *diagAUC, test*: `auc`, `auc0` in (0, 1), auc \> auc0.

  - *diagAUCCompare*: `auc1`, `auc2` in (0, 1); `r` in \[0, 1) (default
    0.5); margin tasks add `margin` in (0, 1).

  - *diagLR, estimate*: `sens`, `spec` in (0, 1); `lr_type` = "positive"
    or "negative"; `target_lr` \> 0 the boundary the CI must not cross.

  - *clusterRCT*: base two-group args plus `icc` in \[0, 1) and
    `cluster_size` integer \>= 1 (DE = 1 + (m-1)\*ICC).

  - *steppedWedge*: `theta` != 0; `tau2` \> 0; `sigma2_ind` \> 0; `m`
    \>= 1; `n_clusters` integer \>= 2, a multiple of `clusters_per_step`
    \>= 1.

  - *twoOrdinal*: `or` \> 0, != 1; `prop_bar` positive vector summing to
    1.

  - *predictiveModel, binary*: `prev` in (0, 1); `n_parameters` integer
    at least 1; `r2_cs` within its feasible maximum; `shrinkage` default
    0.9; `mape` default 0.05; `precision_delta` default 0.05.

  - *predictiveModel, rate*: `rate` \> 0 per person-year; `timepoint` \>
    0; `precision_delta` in (0, 1); optional `n_parameters`/`epv`
    cross-check.

  - *predictiveModel, events*: `n_parameters` \>= 1; `epv` \>= 1
    (classic 10); `event_prevalence` in (0, 1).

  - *kappa, estimate*: `pi1`, `pi2` in (0, 1); `kappa` in \[0, 1); `d`
    in (0, 1).

  - *kappa, test*: `kappa1` != `kappa2` in (0, 1); same pi's.

  - *its*: `effect_sd` \> 0; `n_pre`, `n_post` integers \>= 3 (\>= 8
    recommended); `rho` in \[0, 1). Returns achieved power.

## Value

Object of class `sample_size_result` with print, summary, and plot
methods. Default printing shows sample sizes, the plain-text formula
(`formula`), LaTeX source (`formula_latex`), calculation process
(`calculation_steps`, also available as `calculation`), and literature
references (`reference`). New-style objects also carry axis metadata
(`task`, `outcome`, `design_canonical`, `results`, `roles`,
`adjustments`).
[`summary.sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/summary.sample_size_result.md)
additionally lists all input parameters and recorded adjustments.

## Examples

``` r
# Antihypertensive RCT: placebo 10 mmHg vs new drug 12 mmHg SBP reduction,
# pooled SD 3 mmHg, two-sided alpha 0.05, 80% power
calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
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

# Generic vs originator antidiabetic, non-inferiority margin 1 point,
# one-sided alpha 0.05
calculate(
  design = "rct", task = "noninferiority", outcome = "mean",
  mean1 = 10, mean2 = 9.5, sd = 3, margin = 1
)
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
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 3 (Comparing Means), Section 3.2.2 noninferiority, Eq 3.12, p. 50.
#> 
#>  Also: Machin et al. (2018) Eq 11.3, p. 173. 
#> ────────────────────────────────────────────────────────────────────────────────
#> 

# Bioequivalence of a generic amlodipine: intra-subject CV 25%,
# expected GMR 1.0, 80-125% acceptance range (2x2 crossover)
calculate("bioequivalence", cv = 0.25)
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
#>  Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes for clinical trials with normal data. Statistics in Medicine, 23(12), 1921-1986 (Section 6.3 'Cross-over trials', Eq 6.1-6.9; the non-central t power expression is Eq 6.8).
#>  Schuirmann, D. J. (1987). J Pharmacokinet Biopharm, 15(6), 657-680;
#>  Chow & Liu (2009). Design and Analysis of Bioavailability and Bioequivalence Studies. 
#> ────────────────────────────────────────────────────────────────────────────────
#> 

# Colorectal cancer screening kit: expected sensitivity 85%,
# CI half-width +/-5%, clinic prevalence 20%
calculate("diagAccuracy", "estimate", "proportion",
  prob = 0.85, d = 0.05, prevalence = 0.20
)
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

# AUC precision for a biomarker validation cohort: AUC 0.80,
# CI half-width 0.10, 1:1 case:control, binormal variance
calculate("diagAUC", auc = 0.80, d = 0.05, var_method = "binormal")
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-group AUC CI precision"
#> • Cases needed: 184
#> • Total subjects to screen: 368
#> • Total subjects: 368
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
#> • Step 1: Anticipated AUC = 0.80, precision d = 0.05, supplied allocation R =
#> 1, alpha = 0.05.
#> • Step 2: Use the binormal variance model with the supplied allocation: V(AUC)
#> = 0.1195.
#> • Step 3: Calculate cases: n_cases = (Z_(1-alpha/2)/d)^2 * V(AUC) =
#> (1.96/0.05)^2 * 0.1195 = 183.56.
#> • Step 4: Convert using the supplied allocation: total = n_cases*(1+R) =
#> 183.56*(1+1) = 367.12.
#> • Step 5: Round up: Target cases needed = 184, Total subjects to screen = 368.
#> Reference:
#> Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley. Section 6.1.2, pp. 196-199 (Eq 6.4/6.5/6.6; CTC worked example).
#> 
#>  Original variance: Hanley, J. A., & McNeil, B. J. (1982). Radiology, 143(1), 29-36.
#>  Binormal variance: Obuchowski, N. A. (1994). Computing sample size for receiver operating characteristic studies. Investigative Radiology, 29(2), 238-243. 
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```
