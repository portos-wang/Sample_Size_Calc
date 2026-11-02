# sampleSizeCalc 3.0 Architecture and Refactoring Plan

> **Objective**: Upgrade the package from a 17-keyword monolithic interface to a comprehensive sample size calculator spanning Estimation, Hypothesis Testing, and Equivalence/Non-inferiority margins across RCTs, Cohort, Case-Control, Cross-sectional, Diagnostic Accuracy, and Complex Designs.
> **Methodology**: Posit agent principles (`r-package-development`, `r-testthat`, `r-tidyverse-style`, `r-lifecycle`): strict 1:1 file-to-test mirroring, primary-literature worked examples as regression tests, tidy styling, and detailed NEWS records.
> **Evidence Base**: All formulas anchored to primary literature in `references/` (Zhou 2011, Machin 2018, Hajian-Tilaki 2014, Akoglu 2022, Bhardwaj 2024, Riley 2020, Cantor 1996, Hussey & Hughes 2007).

---

## 0. General Principles

| Constraint | Execution Strategy |
|---|---|
| Package Development | Every `R/{name}.R` has a matching `tests/testthat/test-{name}.R`; new features require tests; documentation generated via `roxygen2`; each user-visible change tracked in `NEWS.md`; error states verified with `expect_snapshot(error = TRUE)`. |
| Testing (testthat) | Self-sufficient tests; errors and warnings snapshotted; BDD `describe()` for structural grouping; numeric tolerances asserted with `expect_equal()`. |
| Code Style | snake_case naming; 2-space indentation; base pipe operator; internal helpers annotated with `@noRd`; public API exported via roxygen2. |
| Lifecycle | `sample_size_calculator()` maintained as a silent backward-compatible shim. |

---

## 1. Architectural Architecture

### 1.1 Target Directory Layout

```
R/
├── ssr-result.R              # S3 class definition: new/validate/assert/friendly constructor
├── utils-z.R                 # Normal quantiles, power quantiles, design effects (@noRd)
├── validate_parameters.R     # Parameter range and type validation
├── validate_design_args.R    # Design-specific argument validators
├── calc-estimation.R         # Single-sample estimation: proportion, mean, correlation
├── calc-diagnostic-estimation.R # Diagnostic estimation: Se/Sp, AUC, Likelihood Ratios
├── calc-obs.R                # Observational studies: cohort, case-control, matched
├── calc-paired-single.R      # Paired designs & single-arm trials
├── calc-margins-be.R         # Non-inferiority, superiority, equivalence, bioequivalence
├── calc-complex.R            # Cluster RCT, Simon two-stage, stepped wedge, kappa, predictive models
├── diagnostic_accuracy_single.R # Legacy diagnostic implementations (maintained for compatibility)
├── diagnostic_existing_designs.R
├── auc_calculations.R
├── basic_designs.R
├── means_hypothesis_tests.R
├── proportions_hypothesis_tests.R
├── case_control.R
├── calculate.R               # Three-axis unified API: calculate(design, task, outcome, ...)
├── sample_size_calculator.R  # Backward-compatible shim
├── print_summary_result.R    # print and summary S3 methods
├── plot_sample_size_result.R # plot S3 method & power curve visualization
└── globals.R                 # Global variable declarations for R CMD check
```

### 1.2 Unified Three-Axis API

- **Canonical Entry Point**:
```r
calculate(
  design,                      # Design axis: rct, cohort, caseControl, diagAccuracy, clusterRCT, etc.
  task,                        # Task axis: estimate | test | noninferiority | superiority | equivalence
  outcome,                     # Outcome axis: mean | proportion | rate | survival | auc | lr
  sampling = c("clinical", "caseControl"),   # Diagnostic sampling scheme
  ...
)
```

- **Backward Compatibility**:
  All 17 legacy keywords remain silently supported without warnings.

### 1.3 Result Object (`sample_size_result`)

Returns an S3 object of class `sample_size_result` containing:
- `design`, `task`, `outcome`: Classification axes
- `n_1`, `n_2`, `total_n`, `events`, `pairs`: Computed metrics
- `parameters`: Named list of user inputs
- `roles`: Explanatory parameter-role documentation
- `formula`, `formula_latex`: Plain-text and LaTeX mathematical representation
- `reference`: Precise literature citations down to section and page numbers
- `adjustments`: Audit trail for dropout rate inflation, design effects, etc.

---

## 2. Phased Implementation Roadmap

- **Phase 0: Foundation**: S3 result class, normal quantile utilities, test infrastructure, documentation scaffolding (`DESIGN_MATRIX.md`, `NUMERIC_ANCHORS.md`).
- **Phase 1: Unified API & Backward Compatibility**: Three-axis dispatch table in `calculate()`, legacy shim in `sample_size_calculator()`, golden master tests ensuring exact numerical parity across all 17 legacy designs.
- **Phase 2: Estimation Designs**: Single proportion (precision method), single mean, single correlation (Fisher z), diagnostic Se/Sp estimation with prevalence guarantee (`screen_required()`), single AUC estimation (exponential, binormal, conservative variance models), and diagnostic likelihood ratios.
- **Phase 3: Observational & Paired Designs**: Cohort incidence proportions (1:m ratio), cohort person-time incidence rates, group-matched and matched pair case-control (Dupont 1988), paired binary McNemar/Connor ψ tests, single-arm trials against historical benchmarks.
- **Phase 4: Margins, Comparisons & Bioequivalence**: Non-inferiority, superiority, and equivalence for means and proportions; two-sample diagnostic Se/Sp and AUC comparisons; 2x2 crossover bioequivalence (TOST).
- **Phase 5: Complex Designs**: Cluster randomised trials (design effect inflation), Simon two-stage optimal and minimax designs, A'Hern single-stage designs, Cohen's kappa inter-rater agreement, clinical prediction models (EPV and Riley 2019/2020 multi-criteria methods), and interrupted time series.
- **Phase 6: Presentation & Tooling**: Modernized print/summary/plot methods, reference validation, vignettes, and pkgdown configuration.
- **Phase 7: Quality Verification**: Comprehensive `R CMD check` without warnings or notes, test independence, and documentation review.

---

## 3. Testing Strategy

1. **Mirroring**: Every R source file has a corresponding testthat suite.
2. **Three-Layer Validation**:
   - **Numeric Anchor Layer**: Assert exact or +/-1 agreement against primary published worked examples.
   - **Structural Layer**: Validate S3 class fields and return structure.
   - **Boundary & Condition Layer**: Verify defensive error handling with `expect_snapshot(error = TRUE)`.
3. **Golden Master Parity**: Ensure legacy keywords continue producing identical outputs.
