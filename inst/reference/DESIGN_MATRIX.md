# Design Matrix

`calculate(design, task, outcome, ...)` currently registers exactly the 46
combinations below. Omit task and outcome together to use a design's default;
an ambiguous partial specification is rejected.

The accompanying `VALIDATION_MATRIX.csv` records the internal dispatch key,
planning unit, numerical evidence, and scope limit for every row. The tests
exercise representative inputs for every combination and validate its result
contract. This coverage does not establish independent statistical validation
across every method's full parameter range.

## Complete Design Matrix Table

| Design | Task | Outcome | Planning unit |
|---|---|---|---|
| `rct` | `test` | `mean` | participants |
| `rct` | `test` | `proportion` | participants |
| `rct` | `test` | `survival` | events |
| `rct` | `noninferiority` | `mean` | participants |
| `rct` | `superiority` | `mean` | participants |
| `rct` | `equivalence` | `mean` | participants |
| `rct` | `superiority` | `proportion` | participants |
| `rct` | `equivalence` | `proportion` | participants |
| `paired` | `test` | `mean` | distinct participants and paired measurements |
| `caseControl` | `test` | `proportion` | participants |
| `diagAccuracy` | `estimate` | `proportion` | target disease-state observations |
| `diagAccuracy` | `test` | `proportion` | target disease-state observations |
| `diagAccuracyCompare` | `test` | `proportion` | participants |
| `diagLR` | `estimate` | `lr` | participants |
| `diagAUC` | `estimate` | `auc` | cases and controls |
| `diagAUC` | `test` | `auc` | cases and controls |
| `diagAUCCompare` | `test` | `auc` | cases and controls |
| `singleProportion` | `estimate` | `proportion` | participants |
| `singleMean` | `estimate` | `mean` | participants |
| `singleCorrelation` | `estimate` | `correlation` | participants |
| `cohort` | `test` | `proportion` | participants |
| `cohort` | `test` | `rate` | person-time |
| `caseControlMatched` | `test` | `proportion` | participants in distinct matched pairs |
| `crosstab` | `test` | `proportion` | participants |
| `paired` | `test` | `proportion` | distinct participants and paired measurements |
| `rctSingleArm` | `test` | `mean` | participants |
| `rctSingleArm` | `test` | `proportion` | participants |
| `diagAccuracyCompare` | `noninferiority` | `proportion` | participants |
| `diagAccuracyCompare` | `equivalence` | `proportion` | participants |
| `diagAUCCompare` | `noninferiority` | `auc` | cases and controls |
| `diagAUCCompare` | `equivalence` | `auc` | cases and controls |
| `crossover` | `test` | `mean` | participants |
| `bioequivalence` | `equivalence` | `mean` | participants |
| `clusterRCT` | `test` | `mean` | participants in clusters |
| `clusterRCT` | `test` | `proportion` | participants in clusters |
| `singleArmPhaseII` | `test` | `proportion` | stage and maximum participants |
| `rct` | `noninferiority` | `proportion` | participants |
| `twoOrdinal` | `test` | `ordinal` | participants |
| `predictiveModel` | `plan` | `events` | participants |
| `its` | `test` | `rate` | achieved power |
| `kappa` | `estimate` | `proportion` | rated specimens or participants |
| `kappa` | `test` | `proportion` | rated specimens or participants per group |
| `steppedWedge` | `test` | `mean` | achieved power |
| `steppedWedge` | `test` | `proportion` | achieved power |
| `predictiveModel` | `plan` | `binary` | participants |
| `predictiveModel` | `plan` | `rate` | person-time |

## Parameters and units

- `alpha` and `power` are general controls. Precision-estimation and achieved-
  power designs need not consume a target power. A power-curve replay retains
  the original alpha.
- `alternative` is supported by the asymptotic single-endpoint diagnostic
  superiority test. The exact binomial method is one-sided and rejects a
  two-sided request. Other designs use their documented test convention.
- `dropout` is implemented for `cohort` + `test` + `proportion` only.
  Unknown, misspelled, duplicate, unnamed, and unused design arguments error.
- `pairing = "within_subject"` (default) means one person per complete pair of
  observations. `pairing = "matched_subjects"` means two distinct people per
  pair. `total_n`/`total_individuals` count people; `n_measurements` counts
  observations. This option applies to the two `paired` outcomes.
- A cohort proportion `ratio` is unexposed:exposed. A cohort rate `ratio` is
  exposed:unexposed person-time. Protective exposures retain their original
  rates and group identities. Case-control `m` means controls per case.
- Integer participant, cluster, pair, and event counts must be positive and
  group totals must agree. Futility/response boundaries may be zero.
  Expected counts and person-time are different planning quantities.

## Diagnostic recruitment

For AUC estimation and testing, `ratio` is controls per case (default 1).
Alternatively supply clinical `prevalence` in (0, 1), implying
`R = (1-prevalence)/prevalence`; specifying both is an error. `var_method`
defaults to `"binormal"`, independently of allocation. Cases and controls are
rounded before summing `total_subjects`. Screening volume is returned only
for clinical recruitment, meets both quotas in expectation, and is not an
assurance probability. Historical AUC `prevalence = 1` selects a 1:1 quota.
AUC margin designs currently use equal case and control quotas.

For a dual sensitivity/specificity test, sensitivity drives the diseased-case
quota and specificity drives the non-diseased-control quota. With clinical
prevalence P, the expected screening requirement is
`max(ceiling(n_Se/P), ceiling(n_Sp/(1-P)))` after rounding each stratum.
Omit prevalence when recruiting the two strata separately. The default
`dual_power = 0.90` is a per-endpoint planning value.

For log-LR CI planning, `lr_type` and `target_lr` select the new method. A
negative LR requires an upper limit above the anticipated LR; a positive LR
requires a lower limit below it. This method plans approximate CI precision
at anticipated sensitivity/specificity, rather than assurance over every
realized interval. Omitting these arguments retains the legacy precision rule.

## Method scope

Binary Riley planning returns `max(B1, B3, B4)`: overall-risk precision,
uniform shrinkage, and Nagelkerke R-squared optimism at most 0.05. B4 uses
`S4 = R2cs/(R2cs + 0.05*max_R2cs)` in the shrinkage sample-size formula.
B2 MAPE is informational for at most 30 parameters. The time-to-event branch
covers baseline-risk precision T1 under an exponential model, not every
model-development requirement. EPV planning remains a heuristic.

Bioequivalence uses exact joint TOST power integrated over the variance
estimate, searching balanced even totals. It errors if the target cannot be
reached within 10000 participants. The ordinary crossover kernel remains a
normal approximation with a documented t-correction limitation.

Stepped-wedge power uses the simplified Hussey-Hughes model without explicit
calendar-time fixed effects. ITS power is an experimental AR(1) level-shift
approximation. Simon two-stage search is bounded at maximum N=100.
Variable cluster-size inflation is available as an internal helper; the public
cluster-RCT entry currently plans constant integer cluster sizes.

## Separate exported calculation

`mrmc_power()` is the exported MRMC achieved-power function, using the
Obuchowski-Rockette framework and supplied variance/correlation components.
Its result follows the common result/display contract. It is not a registered
`calculate("diagMRMC", ...)` combination. Likewise, use `predictiveModel`,
not `predictive`, for the registered prediction-model designs.

## Legacy entry point

`sample_size_calculator()` retains the 17 legacy keywords documented in its
help page. The CSV dispatch keys are internal identifiers; not all are public
legacy keywords. Shared calculation paths are checked for agreement between
the two entry points. The legacy paired diagnostic-comparison kernel retains
its historical psi parameterization; the three-axis paired path uses a
discordant-pair proportion. Numerical identity is not promised for that branch.
