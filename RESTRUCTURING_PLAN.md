# Restructuring Plan: Two-Module Architecture

## Executive Summary

**Objective**: Restructure `sampleSizeCalc` package into two distinct
modules while maintaining backward compatibility and adding new study
designs.

**Current State**: Monolithic 896-line file with 17 study designs in
single switch statement.

**Target State**: Modular architecture with clear separation between
diagnostic studies and drug trials, plus expanded design coverage.

------------------------------------------------------------------------

## I. Architecture Design

### A. Module Structure (Single Package, Two Modules)

**Decision**: Keep as single R package with two logical modules, NOT two
separate packages.

**Rationale**: - Simpler for users (single installation) - Shared S3
methods and validation functions - Shared dependencies (cli, rlang,
stats) - Easier to maintain - Backward compatibility easier to ensure

### B. File Organization

    R/
    ├── utils/
    │   ├── validate_alpha.R
    │   ├── validate_power.R
    │   └── validate_design_args.R
    │
    ├── diagnostic/ (Module 1)
    │   ├── diagnostic_accuracy_single.R
    │   ├── diagnostic_superiority_single.R
    │   ├── diagnostic_comparison_two.R
    │   ├── likelihood_ratio_test.R
    │   ├── auc_single.R
    │   ├── auc_superiority.R
    │   ├── auc_comparison.R
    │   ├── case_control_diagnostic.R
    │   ├── cross_sectional_diagnostic.R          # NEW
    │   ├── cohort_diagnostic.R                    # NEW
    │   ├── roc_comparison_multiple.R              # NEW
    │   └── observer_agreement.R                   # NEW
    │
    ├── drug_trials/ (Module 2)
    │   ├── two_means.R
    │   ├── two_proportions.R
    │   ├── paired_means.R
    │   ├── survival_logrank.R
    │   ├── non_inferiority_means.R
    │   ├── superiority_means.R
    │   ├── equivalence_means.R
    │   ├── superiority_proportions.R
    │   ├── equivalence_proportions.R
    │   ├── case_control_epidemiologic.R
    │   ├── phase_i_dose_escalation.R              # NEW
    │   ├── phase_ii_single_arm.R                  # NEW
    │   ├── group_sequential.R                     # NEW
    │   ├── bioequivalence.R                       # NEW
    │   ├── dose_response.R                        # NEW
    │   ├── multi_arm_trial.R                      # NEW
    │   ├── adaptive_design.R                      # NEW
    │   └── cluster_randomized.R                   # NEW
    │
    ├── s3_methods/
    │   ├── print_sample_size_result.R
    │   ├── summary_sample_size_result.R
    │   └── plot_sample_size_result.R
    │
    └── sample_size_calculator.R (main entry point)

------------------------------------------------------------------------

## II. Module 1: Diagnostic Studies

### A. Current Designs (7)

1.  `diagnosticAccuracySingle` - Single diagnostic test accuracy
2.  `diagnosticSuperioritySingle` - Diagnostic superiority (single)
3.  `diagnosticComparisonTwo` - Two diagnostic measures comparison
4.  `likelihoodRatioTest` - Likelihood ratio estimation
5.  `auc_single` - Single AUC CI precision
6.  `aucSuperiority` - AUC superiority (single)
7.  `aucComparison` - AUC comparison (two tests)

### B. New Designs to Add (4+)

1.  **crossSectionalDiagnostic** - Cross-sectional diagnostic studies
    - Method: Buderer (1996) precision-based formula
    - Parameters: sensitivity, specificity, prevalence, precision
    - Reference: Buderer NM (1996). Acad Emerg Med 3(9):895-900
2.  **cohortDiagnostic** - Cohort diagnostic studies
    (prospective/retrospective)
    - Method: Prevalence-adjusted formula
    - Parameters: sensitivity, specificity, prevalence, follow-up time
    - Reference: Song & Chung (2010), Akoglu (2022)
3.  **rocComparisonMultiple** - Multiple ROC curve comparison (multiple
    readers)
    - Method: Obuchowski-McClish for MRMC (Multi-Reader Multi-Case)
    - Parameters: AUC values, number of readers, correlation
    - Reference: Obuchowski NA (1998). Stat Methods Med Res 7(4):359-382
4.  **observerAgreement** - Observer agreement studies (kappa)
    - Method: Kappa coefficient sample size
    - Parameters: expected kappa, number of raters, number of categories
    - Reference: Sim & Wright (2005)

### C. Design Type Parameter Prefix

All diagnostic designs will use prefix `"diagnostic_"`: -
`diagnostic_accuracy_single` - `diagnostic_superiority_single` -
`diagnostic_cross_sectional` - `diagnostic_cohort` -
`diagnostic_roc_mrmc` - `diagnostic_observer_agreement`

------------------------------------------------------------------------

## III. Module 2: Drug Trials

### A. Current Designs (9)

1.  `twoMeans` - Two independent sample means
2.  `twoProportions` - Two independent proportions
3.  `pairedMeans` - Paired sample means
4.  `survival` - Survival analysis (log-rank)
5.  `nonInferiorityMeans` - Non-inferiority test (means)
6.  `superiorityMeans` - Superiority test (means)
7.  `equivalenceMeans` - Equivalence test (means)
8.  `superiorityProportions` - Superiority test (proportions)
9.  `equivalenceProportions` - Equivalence test (proportions)

### B. New Designs to Add (7+)

1.  **phaseIDoseEscalation** - Phase I dose escalation (3+3 design)
    - Method: 3+3 design algorithm
    - Parameters: DLT rate, number of dose levels, target DLT rate
    - Reference: Oncology statistical methods
2.  **phaseIISingleArm** - Phase II single-arm (Simon’s two-stage)
    - Method: Simon’s optimal two-stage design
    - Parameters: p0 (unacceptable), p1 (acceptable), alpha, beta
    - Reference: Simon R (1989). Control Clin Trials 10(1):1-10
3.  **groupSequential** - Group sequential design
    - Method: O’Brien-Fleming or Pocock boundaries
    - Parameters: number of interim analyses, spending function
    - Reference: Jennison & Turnbull (2000)
4.  **bioequivalence** - Average bioequivalence (ABE)
    - Method: Two one-sided tests (TOST)
    - Parameters: CV, theta0 (ratio), design (2x2 crossover)
    - Reference: FDA guidance, Chow & Liu (2009)
5.  **doseResponse** - Dose-response studies (MCP-Mod)
    - Method: Multiple Comparison Procedure - Modeling
    - Parameters: dose levels, model type (Emax, sigEmax, etc.)
    - Reference: Bretz et al. (2005). Biometrics 61:919-929
6.  **multiArmTrial** - Multi-arm trials
    - Method: Dunnett’s test or Bonferroni correction
    - Parameters: number of arms, adjustment method
    - Reference: Dunnett (1955)
7.  **adaptiveDesign** - Adaptive design with sample size re-estimation
    - Method: Conditional power approach
    - Parameters: interim look, conditional power threshold
    - Reference: Wassmer & Brannath (2025)
8.  **clusterRandomized** - Cluster randomized trials
    - Method: ICC-adjusted sample size
    - Parameters: cluster size, ICC, number of clusters
    - Reference: Donner & Klar (2000)

### C. Design Type Parameter Prefix

All drug trial designs will use prefix `"drug_"`: - `drug_two_means` -
`drug_two_proportions` - `drug_survival` -
`drug_phase_i_dose_escalation` - `drug_phase_ii_single_arm` -
`drug_group_sequential` - `drug_bioequivalence` - `drug_dose_response` -
`drug_multi_arm` - `drug_adaptive` - `drug_cluster_randomized`

------------------------------------------------------------------------

## IV. Backward Compatibility Strategy

### A. Keep Original Function

**Maintain**:
[`sample_size_calculator()`](https://portos-wang.github.io/Sample_Size_Calc/reference/sample_size_calculator.md)
with original 17 design names

**Implementation**: Wrapper function that: - Accepts original design
names (e.g., “twoMeans”, “diagnosticAccuracySingle”) - Internally routes
to new modular functions - Returns same S3 object structure - No
breaking changes for existing users

### B. Add New Main Functions

**Provide**: Two new main functions for module-specific access:

``` r

# Module 1: Diagnostic studies
diagnostic_sample_size(
  design = c("accuracy_single", "superiority_single", "comparison_two",
             "likelihood_ratio", "auc_single", "auc_superiority",
             "auc_comparison", "cross_sectional", "cohort",
             "roc_mrmc", "observer_agreement"),
  alpha = 0.05,
  power = 0.8,
  ...
)

# Module 2: Drug trials
drug_trial_sample_size(
  design = c("two_means", "two_proportions", "paired_means",
             "survival", "non_inferiority_means", "superiority_means",
             "equivalence_means", "superiority_proportions",
             "equivalence_proportions", "phase_i", "phase_ii",
             "group_sequential", "bioequivalence", "dose_response",
             "multi_arm", "adaptive", "cluster_randomized"),
  alpha = 0.05,
  power = 0.8,
  ...
)
```

### C. Deprecation Path

**Original function**: Never remove, but add deprecation notice for old
design names

**Timeline**: - Version 3.0: Introduce new functions, keep old working -
Version 4.0: Add deprecation warnings for old design names - Version
5.0: Old design names still work but documented as deprecated

------------------------------------------------------------------------

## V. Implementation Order

### Phase 1: Foundation (Week 1)

1.  Create new file structure (directories, empty files)
2.  Extract validation functions to utils/
3.  Extract S3 methods to s3_methods/
4.  Create module entry points (diagnostic_sample_size,
    drug_trial_sample_size)

### Phase 2: Refactor Existing Code (Week 2)

5.  Move current diagnostic designs to diagnostic/ files
6.  Move current drug trial designs to drug_trials/ files
7.  Update main sample_size_calculator() to call modular functions
8.  Test backward compatibility

### Phase 3: Add Diagnostic Designs (Week 3)

9.  Implement crossSectionalDiagnostic
10. Implement cohortDiagnostic
11. Implement rocComparisonMultiple (basic version)
12. Implement observerAgreement
13. Update documentation

### Phase 4: Add Drug Trial Designs (Week 4)

14. Implement phaseIDoseEscalation (3+3 design)
15. Implement phaseIISingleArm (Simon’s two-stage)
16. Implement bioequivalence (TOST)
17. Implement basic doseResponse (single model)
18. Update documentation

### Phase 5: Testing & Validation (Week 5)

19. Test all existing designs still work
20. Test new designs with known examples
21. Run R CMD check
22. Update vignettes with new designs
23. Update README

### Phase 6: Advanced Features (Future)

24. Complete rocComparisonMultiple (full MRMC)
25. Complete doseResponse (MCP-Mod with multiple models)
26. Implement groupSequential (basic version)
27. Implement adaptiveDesign (basic version)
28. Implement multiArmTrial
29. Implement clusterRandomized

------------------------------------------------------------------------

## VI. Testing Strategy

### A. Unit Tests

**For each design**: - Test parameter validation - Test calculation
against known values (from literature) - Test edge cases (boundary
values) - Test error conditions

### B. Integration Tests

**Backward compatibility**: - Test all 17 original designs produce
identical results - Test S3 methods work with all designs - Test plot
methods work

### C. Validation Tests

**Cross-validation**: - Compare results with other R packages
(TrialSize, PowerTOST, pROC, epiR) - Compare with manual calculations
from published examples - Compare with online calculators

------------------------------------------------------------------------

## VII. Documentation Updates

### A. Man Pages

Create/update: - `sample_size_calculator.Rd` - Add note about new
functions - `diagnostic_sample_size.Rd` - New -
`drug_trial_sample_size.Rd` - New - Individual design function .Rd files
(auto-generated from roxygen2)

### B. Vignettes

Update `sampleSizeCalc.Rmd`: - Add section on two-module architecture -
Add examples of new diagnostic designs - Add examples of new drug trial
designs - Include comparison tables

### C. README

Update README.md: - Add section on module organization - Add quick
examples for each module - Update feature count (17 → 30+) - Add
reference to new functions

### D. Formula Documentation

Update `docs/FORMULA_SUMMARY.md` and
`docs/formula_reference_guide.md`: - Add formulas for new designs - Add
references for new designs - Organize by module

------------------------------------------------------------------------

## VIII. Dependencies

### Current Dependencies (Keep)

- **cli** - Parameter validation error messages
- **rlang** - Argument matching
- **stats** - Core statistical functions (qnorm, power.t.test,
  power.prop.test)

### Optional Dependencies (Keep)

- **ggplot2** - Plot method (Suggests)
- **scales** - Plot formatting (Suggests)

### New Dependencies to Consider

- **None initially** - Implement basic versions first
- Future: Consider specialized packages for advanced designs
  (DoseFinding, rpact, gsDesign) as **Suggests**

------------------------------------------------------------------------

## IX. Namespace Changes

### Current Exports (Keep All)

``` r

export(sample_size_calculator)
export(sampleSizeCalculator)  # deprecated alias
export(print.sample_size_result)
export(summary.sample_size_result)
export(plot.sample_size_result)
```

### New Exports (Add)

``` r

export(diagnostic_sample_size)
export(drug_trial_sample_size)
# Individual design functions (internal, not exported)
```

### Imports (Add)

``` r

importFrom("cli", "cli_abort", "cli_alert_success", "cli_li", "cli_h3", "cli_rule")
importFrom("rlang", "arg_match")
importFrom("stats", "qnorm", "power.t.test", "power.prop.test")
```

------------------------------------------------------------------------

## X. Success Criteria

### Minimum Viable Release (MVR)

All 17 existing designs work identically

File structure refactored into modules

Two new main functions work

Documentation updated

R CMD check passes

Backward compatibility tests pass

### Full Release Target

All MVR criteria met

4+ new diagnostic designs implemented

7+ new drug trial designs implemented

All new designs validated against literature

Comprehensive vignette examples

Cross-package validation completed

------------------------------------------------------------------------

## XI. Risk Mitigation

### Risk 1: Breaking Existing Code

**Mitigation**: Comprehensive backward compatibility tests, never remove
original function

### Risk 2: Incorrect Formulas

**Mitigation**: Validate all new designs against published examples and
other R packages

### Risk 3: Scope Creep

**Mitigation**: Implement basic versions first, advanced features in
future releases

### Risk 4: Documentation Overwhelm

**Mitigation**: Incremental documentation updates, use roxygen2
extensively

------------------------------------------------------------------------

## XII. References Consulted

### Diagnostic Studies

1.  Buderer NM (1996). Acad Emerg Med 3(9):895-900
2.  Obuchowski NA (1998). Stat Methods Med Res 7(4):359-382
3.  Akoglu H (2022). Turk J Emerg Med 22(4):177-185
4.  Hajian-Tilaki K (2014). J Biomed Inform 48:193-204
5.  Hanley & McNeil (1982). Radiology 143(1):29-36

### Drug Trials

1.  Chow et al. (2018). Sample Size Calculations in Clinical Research
    (3rd ed.)
2.  Jennison & Turnbull (2000). Group Sequential Methods
3.  Simon R (1989). Control Clin Trials 10(1):1-10
4.  Bretz et al. (2005). Biometrics 61:919-929
5.  Schoenfeld DA (1983). Biometrics 39(2):499-503

### R Packages

1.  SampleSizeDiagnostics - Diagnostic test sample size
2.  pROC - ROC curve analysis
3.  epiR - Epidemiological functions
4.  TrialSize - Clinical trial sample size
5.  PowerTOST - Bioequivalence
6.  DoseFinding - Dose-response studies
7.  rpact - Group sequential and adaptive designs
8.  gsDesign - Group sequential design

------------------------------------------------------------------------

**Plan Version**: 1.0 **Date**: 2026-03-17 **Status**: Ready for
Implementation
