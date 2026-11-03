# sampleSizeCalc 3.1.1 (Development)

## Output & Reporting Enhancements

- **Comprehensive Output Display**: Default `print()` and `summary()` methods now
  consistently output:
  1. Plain-text mathematical formula (`Formula (plain text)`)
  2. LaTeX mathematical formula (`Formula (LaTeX)`)
  3. Step-by-step calculation process (`Calculation process`), documenting
     hypotheses, input parameters, critical values, intermediate components, and rounding
  4. Literature references (`Reference`)
- Calculation reports now respect the selected AUC variance model and
  allocation, retain non-default power for diagnostic CI-width planning,
  and show the rounding used before cohort dropout inflation.
- **Calculation Steps In S3 Object**: All `sample_size_result` objects now carry
  `calculation` and `calculation_steps` fields documenting the intermediate steps.

## Numerical Enhancements & Cross-Package Alignments

- `diagLR`: Corrected the log-LR variance to use sensitivity and false-positive
  probability for LR+, and false-negative probability and specificity for LR-.
  The published Se=0.90, Sp=0.50, upper LR-=0.40 example now requires 80 cases
  and 80 controls, rather than 9 per group. Both formula representations and
  the clinical guides use the corrected calculation.

- `singleCorrelation`: Fixed implementation to strictly match Machin et al.
  (2018, Chapter 19, Equations 19.5-19.8). Now supports both `precision`
  (absolute CI half-width) and `epsilon` (relative precision). Produces exact
  agreement with `presize::prec_cor` (e.g., r=0.5, conf.width=0.10 -> 867;
  r=0.5, conf.width=0.20 -> 219).
- `bioequivalence`: Upgraded 2x2 crossover TOST from crude normal approximation
  to exact noncentral t distribution (Phillips 1990; Julious 2004 Equation 13).
  Added support for `theta0` (expected geometric mean ratio, default 1.0) and
  custom equivalence bounds (`margin_low`, `margin_high`). Results match
  `PowerTOST::sampleN.TOST` bit-for-bit (e.g., CV=0.25, theta0=1.0 -> N=24,
  12/sequence; theta0=0.95 -> N=28, 14/sequence).
- `diagAccuracy` (test): Added `method = c("asymptotic", "exact")`. Setting
  `method = "exact"` executes an exact binomial search per A'Hern (2001),
  returning critical successes `critical_successes` alongside sample size
  (e.g., prob=0.85, p0=0.70 gives n=49, critical cutoff r=40).
- Methodological hints and parameter role clarifications added:
  - `steppedWedge`: Explicit warning regarding the absence of calendar-time
    fixed effects in Hussey & Hughes (2007) Equation 8 and potential power loss.
  - `singleArmPhaseII`: Documented that ties in minimax total N are broken by
    minimizing Type I error alpha.
  - `caseControlMatched`: Clarified that `psi` is the discordant pair
    proportion (pi10 + pi01), not the discordant odds ratio.
  - `cohortRate`: Clarified that required subjects = person-time / follow-up duration.
  - `diagLR`: Clarified that planning targets the approximate CI limit at the
    anticipated sensitivity and specificity, distinct from fixed-width CI
    estimation or assurance about every realized interval.

# sampleSizeCalc 3.1.0

## 3.1 — new designs (mrmcPower, steppedWedge, kappa, Riley prediction models)

- `predictiveModel` + task="plan" + outcome="binary": **Riley 2020 BMJ method**
  for prediction model development sample size (original paper obtained and
  implemented). Criteria B1 (outcome proportion precision), B3 (shrinkage
  target via Cox-Snell R2), and B2 (van Smeden MAPE, P <= 30) with the
  entropy-based max R2cs helper. Anchors exact: B3 P=30/R2cs=0.05/S=0.9 ->
  5249 (matches pmsampsize), B1 phi=0.5/delta=0.05 -> 385, B2 MAPE=0.05/
  phi=0.3/P=10 -> 461 (Fig 2 worked example).
- `predictiveModel` + task="plan" + outcome="rate": Riley 2020 criterion T1
  for time-to-event outcomes — person-years of follow-up needed for precise
  cumulative incidence under an exponential model (exact binomial-CI search;
  anchor: rate=0.10/yr, t=10y, delta=0.05 -> 2366 person-years, exactly the
  paper's Figure 1 worked example).
- `mrmc_power()`: power calculation for MRMC studies (paired-patient,
  paired-reader) using the Obuchowski-Rockette mixed model / non-central F
  framework (Zhou et al. 2011 Eq 6.32, Tables 6.3-6.4). Verified against the
  book's mammography worked example (power ~= 0.89 at n=50, J=8, delta=0.10).
- `steppedWedge` + task="test": Hussey-Hughes Eq 8 WLS Wald power for full
  stepped wedge designs (original paper obtained and Eq 8 implemented
  directly; the EPT figure-read anchor discrepancy is documented — Eq 8 gives
  power 0.959 at RR=0.64 and the 80% crossing at RR=0.73).
- `kappa` + task="estimate"/"test": Cohen's kappa sample size per Cantor
  (1996), using the Fleiss-Cohen-Everitt variance factor
  Q = po(1-po)/(1-pe)^2. Anchors exact: Q(0.5,0.5,0.7) = 0.510 and the
  two-questionnaire test N = 214. (Table 1/2 QMAX values require the full FCE
  lambda1 term; estimate mode is conditional on the planning kappa.)

## Breaking / API

- New unified three-axis entry point `calculate(design, task, outcome, ...)`.
  Combinations are validated against a master table; illegal combinations
  error with the list of legal ones. See `docs/DESIGN_MATRIX.md`.
  (`sample_size_calculator()` remains fully and silently compatible: all 17
  legacy keywords now dispatch through the same shared code path, and
  golden-master tests assert identical results between both APIs.)
- `calculate()` resolves arguments by exact name only. This fixes a latent
  partial-matching bug where design-specific arguments such as `d` could be
  silently swallowed into the `design` formal.

## New features (Phase 5)

- `clusterRCT` + task="test" + outcome="mean"/"proportion": design-effect
  wrapper (DE = 1+(m-1)*ICC) around the individually-randomised kernels,
  with cluster-level rounding (n_clusters per arm = ceil(n*DE/m))
  (Machin 2018 Ch.12; Donner & Klar 2000).
- `singleArmPhaseII`: exact Simon two-stage designs (optimal = min E[N|p0],
  minimax = min N) via vectorised exact binomial search (Simon 1989), plus
  A'Hern single-stage (A'Hern 2001). Anchors verified against Machin 2018
  Chapter 17: optimal (1/10, 5/29) and A'Hern 6/25, 12/35 reproduced
  exactly; the book's minimax (2/15, 5/25) has exact power 0.7696 < 0.80
  under the strict definition and is excluded (documented discrepancy).
- `rct` + task="noninferiority" + outcome="proportion": fills the legacy
  margin gap (nonInferiorityProportions).
- `twoOrdinal`: ordered categorical two-group comparison via Whitehead's
  formula N = 3(Za/2+Zb)^2/((logOR)^2(1-sum(p^3))) (Whitehead 1993;
  Machin 2018 Ch.4).
- `predictiveModel` + task="plan": events-per-variable rule (EPV >= 10,
  Peduzzi 1996) with a pointer to Riley et al. (2019).
- `its` + task="test": interrupted time series level-change power with an
  AR(1) effective-sample-size correction - marked EXPERIMENTAL in output
  hints (framework: Bernal et al. 2017; transparent approximation, not a
  validated source formula).
- Deferred with documented reasons: `kappa` and `steppedWedge` (Machin
  Ch.20/Ch.13 formulas are OCR-garbled in the available PDF; require paper
  derivation before implementation).

## New features (Phase 4)

- Diagnostic non-inferiority/equivalence (margin designs):
  - `diagAccuracyCompare` + task="noninferiority"/"equivalence": two-
    proportion margin framework with one-sided alpha for NI and Z_{beta/2}
    for equivalence, plus prevalence screening conversion.
  - `diagAUCCompare` + task="noninferiority"/"equivalence": margin framework
    on the AUC difference with correlation r and all three variance
    functions (framework per Chow et al. 2017; application per Zhou 2011
    Section 6.3).
- `diagAccuracyCompare` + paired=TRUE via the three-axis API now uses the
  Connor kernel with psi = discordant-pair PROPORTION (the legacy keyword
  keeps the old sqrt-scale parameterization, locked by test).
- `crossover`: 2x2 crossover with within-subject SD parameterization
  (n = 2(Za/2+Zb)^2 sigma_w^2 / delta^2; Senn 2002).
- `bioequivalence`: 2x2 TOST on the log scale, 80-125% criterion
  (n = 2(Z_{1-a}+Z_{1-b})^2 log(1+CV^2)/log(1.25)^2; Schuirmann 1987;
  Julious 2004), with a replicate-design hint for CV > 30%.
- `diagAccuracy` + dual=TRUE: dual-endpoint strategy computing sensitivity
  and specificity requirements each at dual_power (default 0.90 -> ~80%
  joint) and taking the max (Akoglu 2022 p.184).
- Dispatcher gains a `path` flag ("legacy" vs "three-axis") so upgrades can
  diverge cleanly from locked legacy behavior.

## New features (Phase 3)

- Observational study designs:
  - `cohort` + task="test" + outcome="proportion": exposed vs unexposed
    cumulative incidence with 1:m allocation (`ratio`), optional `dropout`
    inflation, and RR parameter roles (Bhardwaj 2024 p.2559 anchor; exact-z
    value 294, paper's rounded-z 293, ±1 documented).
  - `cohort` + outcome="rate": person-time incidence-rate comparison with
    unequal allocation (Machin 2018 Ch.6; IRR roles).
  - `caseControlMatched`: individually matched 1:1 case-control via the
    discordant-pairs formulation with the independence-within-pair
    approximation (Dupont 1988; Schlesselman 1982 p.174).
  - `crosstab`: cross-sectional prevalence comparison (PR/OR roles),
    sharing the two-proportion kernel.
- `paired` + outcome="proportion": McNemar/Connor paired binary kernel with
  explicit discordant-pair proportion `psi` (Connor 1987; Akoglu 2022 Table
  6A uncorrected anchor 155 at psi = delta = 0.05, 80% power).
- `rctSingleArm` + task="test": single-arm vs fixed value for mean
  (Machin Ch.5) and proportion outcomes (Hajian-Tilaki Eq 6.8 anchor 153).
- `inflate_n()` gains `method = "additive"` (n*(1+d), matching the arithmetic
  of the Bhardwaj worked examples) alongside the canonical "inflate"
  (n/(1-d)).
- Result objects promote new metric fields: `n_exposed`, `n_unexposed`,
  `person_time_exposed`, `person_time_unexposed`, `expected_events`,
  `n_pairs`.

## New features

- Three estimation designs (task = "estimate"):
  - `singleProportion`: precision-based n = Z^2*p(1-p)/d^2 with absolute or
    relative precision and extreme-prevalence convention hints
    (Bhardwaj 2024 p.2558; anchor 323).
  - `singleMean`: n = (Z*sigma/d)^2 (Machin 2018 Ch.9).
  - `singleCorrelation`: Fisher-z precision n = ((1+r^2)/(r*eps))^2 + 3
    (Machin 2018 Ch.19).
- Diagnostic estimation upgrades (three-axis calls only; legacy keywords
  unchanged):
  - `diagAccuracy` + `ci_method`: "precision" (Zhou Eq 6.2) or
    "ci_width_power" (Zhou Eq 6.1, Flahault 2005; anchors 246/503).
  - `diagAUC` + `var_method`: "exponential" (Zhou Eq 6.4), "binormal"
    (Obuchowski 1994, Zhou Eq 6.5; CTC anchor 46/92), "conservative"
    (distribution-free, Zhou Eq 6.6; anchor 62/123); plus explicit case:
    control `ratio` parameter.
  - `diagLR` + `lr_type`/`target_lr`: log-LR CI method (Hajian-Tilaki 2014
    Sections 6.4, Eqs 6.13/6.14) replacing the simplified Se/Sp-max formula
    for new-style calls.
- New exported utility `screen_required(n, prevalence, beta)`: total
  screening enrollment with an exact binomial probability guarantee of
  capturing n cases (Zhou 2011 Eq 6.3; anchor 451 at 350 cases, 80%
  prevalence, 90% guarantee).
- Result objects gain `hints` (methodological warnings surfaced to the user)
  and `n_required` (single-sample estimation results).

## New features (infrastructure)

- New `sample_size_result` internals: `new_sample_size_result()`,
  `validate_sample_size_result()`, `assert_sample_size_result()` (internal
  three-piece constructor family) with canonical result fields (`n_1`,
  `events`, `cases`, `subjects_to_screen`, ...) derived from legacy storage
  fields, preparing for new design modules in 3.0.
- Internal numeric kernels `z_alpha()`, `z_power()`, `inflate_n()`,
  `design_effect()` shared by all future design modules
  (dropout inflation n/(1-d); cluster design effect 1+(m-1)*ICC).
- `as_sample_size_result()` assembler so each design module can stay a plain
  calculation list.

## Documentation

- `docs/DESIGN_MATRIX.md`: full design x task x outcome combination table
  with formulas, sources, and the 17 legacy-keyword mappings.
- `docs/NUMERIC_ANCHORS.md`: published worked examples used as numeric test
  anchors, including documented discrepancies (Bhardwaj 2024 dropout formula
  vs its own worked example).

## Tests

- Golden master suite: all 17 legacy keywords asserted identical between
  `sample_size_calculator()` and `calculate()` (228 assertions in the
  calculate suite alone).
