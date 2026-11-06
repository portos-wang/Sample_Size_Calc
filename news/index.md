# Changelog

## SampleSizeCalc (development version)

- [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  now enforces study design and parameter invariants:
  - `singleMean` precision planning searches for the smallest integer
    \\N \ge 2\\ satisfying the Student \\t\\ CI half-width constraint,
    resolving oscillation between adjacent rounded fixed-point iterates
    and preventing \\N = 1\\ returns.
  - `diagAccuracy` dual-endpoint planning (`dual = TRUE`) evaluates
    diseased-case and non-diseased-control quotas separately. Expected
    screening totals convert the two rounded strata quotas by
    `prevalence` and `1 - prevalence` respectively.
  - `cohort` person-time planning preserves the original `rate0` and
    `rate1` labels and allocation when `rate1 < rate0` (protective
    exposure), maintaining the user’s intended design.
  - `paired` designs default to `pairing = "within_subject"` (counting
    one person per pair, two measurements); specify
    `pairing = "matched_subjects"` for pairs of distinct people.
  - `bioequivalence` integrates exact conditional TOST power over the
    variance distribution and aborts if target power cannot be reached
    within 10,000 subjects.
  - `diagLR` validates target direction (upper limit \> expected for
    LR-; lower limit \< expected for LR+).
  - Kappa planning validates that inputs define a valid joint
    probability table.
  - Result objects now validate count positivity, integer values, and
    that group counts sum to reported totals. Power-curve replay retains
    user-specified `alpha`.
- [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  and
  [`sample_size_calculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md)
  now reject unsupported, misspelled, duplicate, unnamed, and
  inactive-branch design arguments. In particular, `dropout` outside
  cohort proportion planning and `alternative` outside the supported
  diagnostic test raise an error.
- `diagAUC` and `diagAUCCompare` testing now consistently use `ratio` as
  controls per case, independently of `var_method` (default
  `"binormal"`). Supply either a fixed `ratio` or clinical `prevalence`,
  not both. Cases and controls are rounded before summing
  `total_subjects`; `total_subjects_to_screen` is returned only for
  clinical recruitment and meets both quotas in expectation. AUC
  calculation reports use the same variance model, test convention, and
  rounding as the calculation.
- `predictiveModel` binary planning now takes the maximum of Riley B1,
  B3, and B4, including the Nagelkerke R-squared optimism criterion. For
  prevalence 0.05, 10 parameters, Cox-Snell R-squared 0.2, and shrinkage
  0.9, the corrected size is 542 rather than 398, matching `pmsampsize`.
  B2 MAPE remains informational, and its inputs are validated.
- `twoOrdinal` now sums the separately rounded group sizes, including
  unequal allocation. The normalized Machin example needs 31 per arm, 62
  total; Whitehead’s example needs 94 per arm, 188 total.
- Numeric design inputs now require finite scalars (with category
  proportions as the documented vector exception). Missing and infinite
  values produce argument-specific errors, including in
  [`screen_required()`](https://rpackages.portos.wang/sample_size_calc/reference/screen_required.md)
  and
  [`mrmc_power()`](https://rpackages.portos.wang/sample_size_calc/reference/mrmc_power.md).
- Zero-effect planning inputs (`mean1 == mean2`, `p1 == p2`,
  `meanDiff == 0`, and equal expected proportions in an unpaired
  diagnostic comparison) now abort with argument-specific errors instead
  of leaking base-R root-finding failures.
- [`sample_size_calculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md)
  now rejects `...` names that R’s partial matching would silently bind
  to `design`, `alpha`, or `power`: a misspelled `p` used to set `power`
  without warning, and `d` clobbered `design` when the design keyword
  was passed positionally. Exact control names keep working, including
  named `design` calls that pass a design-specific `d`.

## SampleSizeCalc 3.1.1

- The package is named `SampleSizeCalc`; use
  [`library(SampleSizeCalc)`](https://rpackages.portos.wang/sample_size_calc/)
  and
  [`SampleSizeCalc::calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  in new scripts.

### Corrections (P0 series: wrong formulas / wrong citations)

- **`steppedWedge` had `sigma^2` and `tau^2` swapped in Hussey & Hughes
  Eq 8.** The printed equation (p. 187) is
  `Var = I*sigma^2*(sigma^2 + T*tau^2) / [(IU-W)*sigma^2 + (U^2+ITU-TW-IV)*tau^2]`,
  where `sigma^2` is the cluster-mean variance (`sigma2_ind/m`) and
  `tau^2` the between-cluster variance. The previous code had the two
  factors interchanged. For the paper’s own Washington EPT example
  (I=24, T=5, m=100, p=0.05, CV=0.3) it returned SE=0.00486 and
  power=0.959 at RR=0.64, whereas Eq 8 gives SE=0.006638 and
  **power=0.774**, consistent with the paper’s “about 80% power to
  detect a decrease in prevalence of roughly 36%”. The spurious “80%
  crossing at RR=0.73” claim is withdrawn.
- **`twoOrdinal` was missing the allocation factor `(1+phi)^2/phi`.**
  Machin et al. (2018) Eq 4.3 (p. 57) is
  `N = Gamma (1+phi)^2/phi (z_{1-a/2}+z_{1-b})^2/(log OR)^2` with
  `Gamma = 3/(1-sum pbar^3)` (Eq 4.4); Whitehead (1993) Eq 10 (p. 2260)
  is `n = 3(A+1)^2 (u_{a/2}+u_b)^2 / [A theta^2 (1-sum pbar^3)]`. They
  are algebraically identical with `A = phi`, and at `phi = 1` the
  factor is 4. The previous code omitted it and returned one quarter of
  the required size (e.g. 16 instead of 61 for Machin Example 4.1). New
  `allocation` argument (default 1) exposes unequal allocation. Verified
  against Machin Example 4.1 (N4 = 60.09 -\> 60) and Whitehead Example 1
  (n = 187, 94 per group).
- **`kappa_Q()` now implements Cantor (1996) Eq 3 verbatim.** The
  previous `p_o(1-p_o)/(1-p_e)^2` coincides with Cantor’s Q only when
  both marginal rating proportions are 0.5. Cantor’s expression is \`Q =
  (1-pi_e)^(-4) \* { sum_i pi_ii\[(1-pi_e) - (pi_i. +
  pi\_.i)(1-pi_o)\]^2
  - (1-pi_o)^2 \* sum\_{i!=j} pi_ij(pi\_.i + pi_j.)^2 - (pi_o pi_e -
    2pi_e + pi_o)^2
    }`with the Eq 4 identities. The implementation now reproduces **Cantor Table 1** at all 18 spot-checked cells and **Table 2** at all 5 maxima (`(0.3,0.3)
    1.07003 at kappa=0.187`,`(0.4,0.4) 1.00558 at 0.067`,`(0.5,0.5)
    1.00000 at 0`,`(0.7,0.3) 0.52438 at 0`,`(0.9,0.1) 0.04819 at 0\`),
    plus both worked examples (165 and 214). The earlier claim that “pi
    = 0.3 gives Q = 1.0” was arithmetically impossible.
- **AUC variance default is now binormal (Zhou Eq 6.5).** The
  exponential form (Eq 6.4) systematically under-estimates variance for
  ordinal results (Zhou p. 197), and the binormal form is what Zhou’s
  own CTC example (p. 198, n = 46) and Hajian-Tilaki’s Table 7 use.
  `var_method` remains selectable. This makes `diagAUC` reproduce the
  book’s `n = 13` CTC superiority anchor (the previous one-sided
  `Z_alpha` convention gave 10) and `diagAUCCompare` reproduce Hajian’s
  `n = 211` example (was 185).
- **`singleMean` now iterates the Student t quantile** (Machin 2018 Eq
  9.18, p. 152), instead of using the normal z once. Machin explicitly
  requires the iteration when N0 \< 40. sigma=3, d=0.5 now gives 141
  (was 139; Bhardwaj’s z-only arithmetic prints 138.29 -\> 138). The
  `hints` field reports the starting value when it is below 40.
- **`cohort` + `rate` swaps the two rates when `rate1 < rate0`** and
  says so in `hints`, so the exposed/unexposed person-time columns stay
  meaningful. `ratio` is now documented consistently as the
  exposed:unexposed person-time ratio (Machin Eq 6.2, p. 84).
- **`singleArmPhaseII` minimax now matches Simon/clinfun exactly.** The
  tie-break is “minimise N, then minimise EN(p0)”, reproducing Machin
  2018 Example 17.2 `(1/15, 5/25)` and clinfun::ph2simon for both (0.1,
  0.3) and (0.2, 0.4).
- **`clusterRCT` upgraded to Machin (2018) Eq 12.10 (Student t
  correction).** The previous implementation wrapped the
  individually-randomised answer in `DE = 1+(m-1)ICC` and rounded twice
  (once on subjects, once on clusters), which over-stated the cluster
  count. The new implementation follows Eq 12.10 (p. 199): \`N = DE \*
  \[ (1+phi)^2/phi \* (z\_{1-a/2}+z\_{1-b})^(2/(delta/sigma))2
  - z^2\_{1-a/2}/2
    \]`, rounds **once at the cluster level**, and reproduces **Machin Example 12.1 (p. 206) exactly**: delta=3.5, sigma=6.94, m=2, ICC=0.025, 2-sided alpha=0.05, power=0.90 -> **N=172, K=86, 43 per arm** (was 176/44). The ICC sensitivity in the same example is also reproduced (rho=0.1 -> 184, rho=0.2 -> 204). New`cluster_size_inflation()`exposes Eq 12.5 (constant m) and Eq 12.7 (variable m via`cv_m`), and Eq 12.12/12.13 give the binary`sigma_Plan`and`rho_Binary\`.
- **`crossover` reported a double-counted total.** Julious (2004) Eq 6.6
  (Section 6.3 “Cross-over trials”) writes `n` as the **total** sample
  size, so `n_required` is now the per-sequence count and
  `total_n = 2 * n_required`. The previous code used the total as
  `n_required` and then doubled it again. Example: delta=2, sigma_w=3
  now gives 18 per sequence / 36 total (was 36/72). Senn (2002) Section
  9.5.1 (Eq 9.18-9.20, pp. 278-280) confirms the parameterisation
  (`sigma^2 = 2 sigma_w^2`, `Var = sigma^2/n`, `df = n-2`, `n` = total
  with `n/2` per sequence) and refines it with a Student t correction;
  the `hints` field now says so.
- **[`mrmc_power()`](https://rpackages.portos.wang/sample_size_calc/reference/mrmc_power.md)
  now implements Zhou Eq 6.32 verbatim.** The previous code used
  `(1 - rho1)` instead of `(1 - rho_b)`, divided the patient-sampling
  variance `sigma_c2` by `n`, and added a spurious
  `rho2*sigma_b2*((1-rho1)+(J-1)(rho2-rho3))` term. With the book’s own
  mammography parameters it returned 0.979 (the book reports 89%); the
  old “0.888” anchor came from a different parameter set. The function
  now has a `rho_b` argument (Table 6.3 `p_b`), which defaults to `rho1`
  for backward compatibility, and reproduces the book exactly:
  `lambda = 14.0672`, `power = 0.893`.
- **Legacy AUC and likelihood-ratio paths no longer return `Inf`.**
  [`calculate_auc_single()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_auc_single.md),
  [`calculate_auc_superiority()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_auc_superiority.md)
  and
  [`calculate_auc_comparison()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_auc_comparison.md)
  used a mis-expanded Zhou Eq 6.4 variance
  (`A(1-A) + (1/K)(Q1-A^2) + (Q2-A^2)`) and divided by `K = (1-P)/P`,
  which is zero at the historical default `prevalence = 1`. They now use
  the printed Eq 6.4 variance function `Q1/R + Q2 - A^2(1/R + 1)`; when
  `prevalence` is omitted the non-diseased:diseased ratio `R` falls back
  to 1 (a 1:1 case:control quota) and the deviation is reported in
  `hints`.
  [`calculate_likelihood_ratio_test()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_likelihood_ratio_test.md)
  had the same `P/(1-P)` division and now falls back identically. This
  changes previously published numbers:
  `auc_single(auc=0.8, d=0.05, prevalence=0.2)` is 120 (was 366),
  `aucSuperiority` 26 (was 66), `aucComparison` 65 (was 122),
  `likelihoodRatioTest` 35 (was 120).
- **A’Hern (2001) citation corrected** in
  [`calculate_ahern()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_ahern.md),
  [`calculate_diagnostic_superiority_single()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_diagnostic_superiority_single.md)
  and the Chinese guide: the paper is *Statistics in Medicine* 20(6),
  859-866 (<doi:10.1002/sim.721>), not *British Journal of Cancer*
  85(2), 223-226.
- **Two more citation corrections** verified against the source PDFs:
  Obuchowski (1994) is *Investigative Radiology* 29(2), 238-243 (not
  *Medical Decision Making* 14(2), 154-162); Simel et al. (1991) is
  *Journal of Clinical Epidemiology* 44(8), 763-770 (not 44(11),
  1123-1130). Julious (2004) bioequivalence/crossover is Section 6.3
  with Eq 6.1-6.9 (the non-central t power expression is Eq 6.8), not
  “Eq 13, p. 1941”.
- **`alternative` is now a real control argument** of
  [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md).
  It reproduces either Akoglu (2022) Table 2 Eq 2 (one-sided, the
  default that preserves existing numbers) or Hajian-Tilaki (2014) Eq
  6.8 (two-sided). It is currently consumed by `diagAccuracy` + `test` +
  `proportion` only. The unimplemented `sampling` parameter has been
  removed from `inst/reference/DESIGN_MATRIX.md`, and the partial scope
  of `dropout` is now stated explicitly there and in
  [`?calculate`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md).

### Output & Reporting Enhancements

- **Comprehensive Output Display**: Default
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`summary()`](https://rdrr.io/r/base/summary.html) methods now
  consistently output:
  1.  Plain-text mathematical formula (`Formula (plain text)`)
  2.  LaTeX mathematical formula (`Formula (LaTeX)`)
  3.  Step-by-step calculation process (`Calculation process`),
      documenting hypotheses, input parameters, critical values,
      intermediate components, and rounding
  4.  Literature references (`Reference`)
- Calculation reports now respect the selected AUC variance model and
  allocation, retain non-default power for diagnostic CI-width planning,
  and show the rounding used before cohort dropout inflation.
- **Calculation Steps In S3 Object**: All `sample_size_result` objects
  now carry `calculation` and `calculation_steps` fields documenting the
  intermediate steps.

### Numerical Enhancements & Cross-Package Alignments

- `diagLR`: Corrected the log-LR variance to use sensitivity and
  false-positive probability for LR+, and false-negative probability and
  specificity for LR-. The published Se=0.90, Sp=0.50, upper LR-=0.40
  example now requires 80 cases and 80 controls, rather than 9 per
  group. Both formula representations and the clinical guides use the
  corrected calculation.

- `singleCorrelation`: Fixed implementation to strictly match Machin et
  al. (2018, Chapter 19, Equations 19.5-19.8). Now supports both
  `precision` (absolute CI half-width) and `epsilon` (relative
  precision). Produces exact agreement with
  [`presize::prec_cor`](https://ctu-bern.github.io/presize/reference/prec_cor.html)
  (e.g., r=0.5, conf.width=0.10 -\> 867; r=0.5, conf.width=0.20 -\>
  219).

- `bioequivalence`: Upgraded 2x2 crossover TOST from crude normal
  approximation to exact noncentral t distribution (Phillips 1990;
  Julious 2004 Equation 13). Added support for `theta0` (expected
  geometric mean ratio, default 1.0) and custom equivalence bounds
  (`margin_low`, `margin_high`). Results match
  [`PowerTOST::sampleN.TOST`](https://rdrr.io/pkg/PowerTOST/man/sampleN.TOST.html)
  bit-for-bit (e.g., CV=0.25, theta0=1.0 -\> N=24, 12/sequence;
  theta0=0.95 -\> N=28, 14/sequence).

- `diagAccuracy` (test): Added `method = c("asymptotic", "exact")`.
  Setting `method = "exact"` executes an exact binomial search per
  A’Hern (2001), returning critical successes `critical_successes`
  alongside sample size (e.g., prob=0.85, p0=0.70 gives n=49, critical
  cutoff r=40).

- Methodological hints and parameter role clarifications added:

  - `steppedWedge`: Explicit warning regarding the absence of
    calendar-time fixed effects in Hussey & Hughes (2007) Equation 8 and
    potential power loss.
  - `singleArmPhaseII`: Documented that ties in minimax total N are
    broken by minimizing Type I error alpha.
  - `caseControlMatched`: Clarified that `psi` is the discordant pair
    proportion (pi10 + pi01), not the discordant odds ratio.
  - `cohortRate`: Clarified that required subjects = person-time /
    follow-up duration.
  - `diagLR`: Clarified that planning targets the approximate CI limit
    at the anticipated sensitivity and specificity, distinct from
    fixed-width CI estimation or assurance about every realized
    interval.

## SampleSizeCalc 3.1.0

### 3.1 — new designs (mrmcPower, steppedWedge, kappa, Riley prediction models)

- `predictiveModel` + task=“plan” + outcome=“binary”: **Riley 2020 BMJ
  method** for prediction model development sample size (original paper
  obtained and implemented). Criteria B1 (outcome proportion precision),
  B3 (shrinkage target via Cox-Snell R2), and B2 (van Smeden MAPE, P
  \<= 30) with the entropy-based max R2cs helper. Anchors exact: B3
  P=30/R2cs=0.05/S=0.9 -\> 5249 (matches pmsampsize), B1
  phi=0.5/delta=0.05 -\> 385, B2 MAPE=0.05/ phi=0.3/P=10 -\> 461 (Fig 2
  worked example).
- `predictiveModel` + task=“plan” + outcome=“rate”: Riley 2020 criterion
  T1 for time-to-event outcomes — person-years of follow-up needed for
  precise cumulative incidence under an exponential model (exact
  binomial-CI search; anchor: rate=0.10/yr, t=10y, delta=0.05 -\> 2366
  person-years, exactly the paper’s Figure 1 worked example).
- [`mrmc_power()`](https://rpackages.portos.wang/sample_size_calc/reference/mrmc_power.md):
  power calculation for MRMC studies (paired-patient, paired-reader)
  using the Obuchowski-Rockette mixed model / non-central F framework
  (Zhou et al. 2011 Eq 6.32, Tables 6.3-6.4). Verified against the
  book’s mammography worked example (power ~= 0.89 at n=50, J=8,
  delta=0.10).
- `steppedWedge` + task=“test”: Hussey-Hughes Eq 8 WLS Wald power for
  full stepped wedge designs (original paper obtained and Eq 8
  implemented directly; the EPT figure-read anchor discrepancy is
  documented — Eq 8 gives power 0.959 at RR=0.64 and the 80% crossing at
  RR=0.73).
- `kappa` + task=“estimate”/“test”: Cohen’s kappa sample size per Cantor
  (1996), using the Fleiss-Cohen-Everitt variance factor Q =
  po(1-po)/(1-pe)^2. Anchors exact: Q(0.5,0.5,0.7) = 0.510 and the
  two-questionnaire test N = 214. (Table 1/2 QMAX values require the
  full FCE lambda1 term; estimate mode is conditional on the planning
  kappa.)

### Breaking / API

- New unified three-axis entry point
  `calculate(design, task, outcome, ...)`. Combinations are validated
  against a master table; illegal combinations error with the list of
  legal ones. See `inst/reference/DESIGN_MATRIX.md`.
  ([`sample_size_calculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md)
  remains fully and silently compatible: all 17 legacy keywords now
  dispatch through the same shared code path, and golden-master tests
  assert identical results between both APIs.)
- [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  resolves arguments by exact name only. This fixes a latent
  partial-matching bug where design-specific arguments such as `d` could
  be silently swallowed into the `design` formal.

### New features (Phase 5)

- `clusterRCT` + task=“test” + outcome=“mean”/“proportion”:
  design-effect wrapper (DE = 1+(m-1)*ICC) around the
  individually-randomised kernels, with cluster-level rounding
  (n_clusters per arm = ceil(n*DE/m)) (Machin 2018 Ch.12; Donner & Klar
  2000).
- `singleArmPhaseII`: exact Simon two-stage designs (optimal = min
  E\[N\|p0\], minimax = min N) via vectorised exact binomial search
  (Simon 1989), plus A’Hern single-stage (A’Hern 2001). Anchors verified
  against Machin 2018 Chapter 17: optimal (1/10, 5/29) and A’Hern 6/25,
  12/35 reproduced exactly; the book’s minimax (2/15, 5/25) has exact
  power 0.7696 \< 0.80 under the strict definition and is excluded
  (documented discrepancy).
- `rct` + task=“noninferiority” + outcome=“proportion”: fills the legacy
  margin gap (nonInferiorityProportions).
- `twoOrdinal`: ordered categorical two-group comparison via Whitehead’s
  formula N = 3(Za/2+Zb)^(2/((logOR))2(1-sum(p^3))) (Whitehead 1993;
  Machin 2018 Ch.4).
- `predictiveModel` + task=“plan”: events-per-variable rule (EPV \>= 10,
  Peduzzi 1996) with a pointer to Riley et al. (2019).
- `its` + task=“test”: interrupted time series level-change power with
  an AR(1) effective-sample-size correction - marked EXPERIMENTAL in
  output hints (framework: Bernal et al. 2017; transparent
  approximation, not a validated source formula).
- Deferred with documented reasons: `kappa` and `steppedWedge` (Machin
  Ch.20/Ch.13 formulas are OCR-garbled in the available PDF; require
  paper derivation before implementation).

### New features (Phase 4)

- Diagnostic non-inferiority/equivalence (margin designs):
  - `diagAccuracyCompare` + task=“noninferiority”/“equivalence”: two-
    proportion margin framework with one-sided alpha for NI and
    Z\_{beta/2} for equivalence, plus prevalence screening conversion.
  - `diagAUCCompare` + task=“noninferiority”/“equivalence”: margin
    framework on the AUC difference with correlation r and all three
    variance functions (framework per Chow et al. 2017; application per
    Zhou 2011 Section 6.3).
- `diagAccuracyCompare` + paired=TRUE via the three-axis API now uses
  the Connor kernel with psi = discordant-pair PROPORTION (the legacy
  keyword keeps the old sqrt-scale parameterization, locked by test).
- `crossover`: 2x2 crossover with within-subject SD parameterization (n
  = 2(Za/2+Zb)^2 sigma_w^2 / delta^2; Senn 2002).
- `bioequivalence`: 2x2 TOST on the log scale, 80-125% criterion (n =
  2(Z\_{1-a}+Z\_{1-b})^2 log(1+CV^(2)/log(1.25))2; Schuirmann 1987;
  Julious 2004), with a replicate-design hint for CV \> 30%.
- `diagAccuracy` + dual=TRUE: dual-endpoint strategy computing
  sensitivity and specificity requirements each at dual_power (default
  0.90 -\> ~80% joint) and taking the max (Akoglu 2022 p.184).
- Dispatcher gains a `path` flag (“legacy” vs “three-axis”) so upgrades
  can diverge cleanly from locked legacy behavior.

### New features (Phase 3)

- Observational study designs:
  - `cohort` + task=“test” + outcome=“proportion”: exposed vs unexposed
    cumulative incidence with 1:m allocation (`ratio`), optional
    `dropout` inflation, and RR parameter roles (Bhardwaj 2024 p.2559
    anchor; exact-z value 294, paper’s rounded-z 293, ±1 documented).
  - `cohort` + outcome=“rate”: person-time incidence-rate comparison
    with unequal allocation (Machin 2018 Ch.6; IRR roles).
  - `caseControlMatched`: individually matched 1:1 case-control via the
    discordant-pairs formulation with the independence-within-pair
    approximation (Dupont 1988; Schlesselman 1982 p.174).
  - `crosstab`: cross-sectional prevalence comparison (PR/OR roles),
    sharing the two-proportion kernel.
- `paired` + outcome=“proportion”: McNemar/Connor paired binary kernel
  with explicit discordant-pair proportion `psi` (Connor 1987; Akoglu
  2022 Table 6A uncorrected anchor 155 at psi = delta = 0.05, 80%
  power).
- `rctSingleArm` + task=“test”: single-arm vs fixed value for mean
  (Machin Ch.5) and proportion outcomes (Hajian-Tilaki Eq 6.8 anchor
  153).
- `inflate_n()` gains `method = "additive"` (n\*(1+d), matching the
  arithmetic of the Bhardwaj worked examples) alongside the canonical
  “inflate” (n/(1-d)).
- Result objects promote new metric fields: `n_exposed`, `n_unexposed`,
  `person_time_exposed`, `person_time_unexposed`, `expected_events`,
  `n_pairs`.

### New features

- Three estimation designs (task = “estimate”):
  - `singleProportion`: precision-based n = Z^(2\*p(1-p)/d)2 with
    absolute or relative precision and extreme-prevalence convention
    hints (Bhardwaj 2024 p.2558; anchor 323).
  - `singleMean`: n = (Z\*sigma/d)^2 (Machin 2018 Ch.9).
  - `singleCorrelation`: Fisher-z precision n = ((1+r^(2)/(r\*eps)))2 +
    3 (Machin 2018 Ch.19).
- Diagnostic estimation upgrades (three-axis calls only; legacy keywords
  unchanged):
  - `diagAccuracy` + `ci_method`: “precision” (Zhou Eq 6.2) or
    “ci_width_power” (Zhou Eq 6.1, Flahault 2005; anchors 246/503).
  - `diagAUC` + `var_method`: “exponential” (Zhou Eq 6.4), “binormal”
    (Obuchowski 1994, Zhou Eq 6.5; CTC anchor 46/92), “conservative”
    (distribution-free, Zhou Eq 6.6; anchor 62/123); plus explicit case:
    control `ratio` parameter.
  - `diagLR` + `lr_type`/`target_lr`: log-LR CI method (Hajian-Tilaki
    2014 Sections 6.4, Eqs 6.13/6.14) replacing the simplified Se/Sp-max
    formula for new-style calls.
- New exported utility `screen_required(n, prevalence, beta)`: total
  screening enrollment with an exact binomial probability guarantee of
  capturing n cases (Zhou 2011 Eq 6.3; anchor 451 at 350 cases, 80%
  prevalence, 90% guarantee).
- Result objects gain `hints` (methodological warnings surfaced to the
  user) and `n_required` (single-sample estimation results).

### New features (infrastructure)

- New `sample_size_result` internals:
  [`new_sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/new_sample_size_result.md),
  [`validate_sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/validate_sample_size_result.md),
  [`assert_sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/assert_sample_size_result.md)
  (internal three-piece constructor family) with canonical result fields
  (`n_1`, `events`, `cases`, `subjects_to_screen`, …) derived from
  legacy storage fields, preparing for new design modules in 3.0.
- Internal numeric kernels `z_alpha()`, `z_power()`, `inflate_n()`,
  `design_effect()` shared by all future design modules (dropout
  inflation n/(1-d); cluster design effect 1+(m-1)\*ICC).
- `as_sample_size_result()` assembler so each design module can stay a
  plain calculation list.

### Documentation

- `inst/reference/DESIGN_MATRIX.md`: full design x task x outcome
  combination table with formulas, sources, and the 17 legacy-keyword
  mappings.
- `inst/reference/NUMERIC_ANCHORS.md`: published worked examples used as
  numeric test anchors, including documented discrepancies (Bhardwaj
  2024 dropout formula vs its own worked example).

### Tests

- Golden master suite: all 17 legacy keywords asserted identical between
  [`sample_size_calculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md)
  and
  [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  (228 assertions in the calculate suite alone).
