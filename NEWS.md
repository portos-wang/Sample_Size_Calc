# sampleSizeCalc 3.0.0

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
