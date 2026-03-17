# Changelog

All notable changes to the sampleSizeCalc package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-03-17

### Added
- **Primary literature citations** for AUC methods (Hanley & McNeil 1982, 1983)
  - Added original ROC analysis methodology papers for `auc_single`
  - Added ROC comparison paper for `aucComparison`
  - Significantly improved academic authority of AUC calculations
- **Supplemental references** for survival analysis
  - Hsieh & Lavori (2000) for Cox model with continuous covariates
  - Rubinstein et al. (1982) for trial duration planning
- **Alternative formula citations** for proportion comparison
  - Casagrande et al. (1978) simplified formula
  - Fleiss et al. (1980) approximation method
- **IARC classic reference** for case-control studies
  - Breslow & Day (1980) Volume 1
  - Dupont (1988) matched design power calculations

### Improved
- **Academic rigor**: All methods now include primary source citations where applicable
- **Reference formatting**: Multi-line reference display in summary output
- **Documentation quality**: More comprehensive literature support for all 17 methods
- **Reviewer confidence**: Primary source citations increase credibility for peer review

### Changed
- Updated reference fields in 9 methods to include primary and supplemental literature
- Reference format now supports multiple citations with clear labeling

### Fixed
- N/A

### Technical Details
- **Methods updated**: 
  - `auc_single`, `aucSuperiority`, `aucComparison`: Added Hanley & McNeil (1982, 1983)
  - `twoProportions`: Added Casagrande (1978), Fleiss (1980)
  - `survival`: Added Hsieh & Lavori (2000), Rubinstein (1982)
  - `caseControl`: Added Breslow & Day (1980), Dupont (1988)
- **Backward compatibility**: Maintained - all existing function calls remain unchanged
- **API changes**: None - only documentation improvements

## [2.0.0] - 2026-03-15

### Added
- Initial release with 17 sample size calculation methods
- Support for continuous variables (twoMeans, pairedMeans)
- Non-inferiority, superiority, and equivalence tests
- Survival analysis (Schoenfeld formula)
- Diagnostic test accuracy studies
- ROC/AUC analysis
- Case-control studies
- S3 methods (print, summary, plot)
- Comprehensive parameter validation
- Structured error handling with cli package

### Features
- `twoMeans`: Two independent sample means comparison
- `pairedMeans`: Paired sample means comparison
- `nonInferiorityMeans`: Non-inferiority test for means
- `superiorityMeans`: Superiority test for means
- `equivalenceMeans`: Equivalence test for means (TOST)
- `twoProportions`: Two independent proportions comparison
- `equivalenceProportions`: Equivalence test for proportions
- `superiorityProportions`: Superiority test for proportions
- `survival`: Survival analysis (log-rank test)
- `diagnosticAccuracySingle`: Diagnostic accuracy estimation
- `diagnosticSuperioritySingle`: Diagnostic superiority test
- `diagnosticComparisonTwo`: Two diagnostic test comparison (paired/unpaired)
- `likelihoodRatioTest`: Likelihood ratio estimation
- `auc_single`: AUC confidence interval estimation
- `aucSuperiority`: AUC superiority test
- `aucComparison`: Two AUC comparison (paired)
- `caseControl`: Case-control study (1:m matching)

### Documentation
- Comprehensive README with examples
- Vignette with quick start guide
- Formula reference guide
- Literature verification report

---

## Citation Guidelines

For package citation:
```bibtex
@software{sampleSizeCalc,
  title = {sampleSizeCalc: Sample Size Calculator for Clinical Research},
  author = {AI Coding Assistant},
  year = {2026},
  version = {2.1.0},
  url = {https://github.com/portos-wang/sampleSizeCalc}
}
```

**Important**: When using specific methods, please cite the original methodology papers listed in the function documentation. This ensures proper attribution to the original authors and increases academic rigor.

Example for AUC methods:
```bibtex
@article{hanley1982,
  title={The meaning and use of the area under a receiver operating characteristic (ROC) curve},
  author={Hanley, James A and McNeil, Barbara J},
  journal={Radiology},
  volume={143},
  number={1},
  pages={29--36},
  year={1982}
}
```

---

## Version Numbering

- **Major version** (2.x.x): Incompatible API changes or major new features
- **Minor version** (2.1.x): Backwards-compatible functionality additions
- **Patch version** (2.1.x): Backwards-compatible bug fixes

---

## Future Plans

### Potential Features for 2.2.0
- [ ] Logistic regression sample size calculation
- [ ] Correlation coefficient comparison
- [ ] Linear regression sample size
- [ ] Crossover design sample size
- [ ] Cluster randomized trials
- [ ] Non-inferiority with time-to-event endpoints
- [ ] Interactive web interface
- [ ] Power curve visualization enhancements

### Under Consideration
- [ ] Bayesian sample size methods
- [ ] Adaptive design sample size re-estimation
- [ ] Multi-arm trial comparisons
- [ ] Sample size for diagnostic accuracy with imperfect reference standard
- [ ] Sample size for agreement studies (kappa, ICC)

---

## Contributing

Contributions are welcome! Please see CONTRIBUTING.md for guidelines.

### Reporting Issues

When reporting bugs or requesting features, please include:
- R version
- package version
- Minimal reproducible example
- Expected vs actual behavior

---

## Acknowledgments

This package is built upon the foundational work of many statisticians and methodologists:

- **Shein-Chung Chow** and colleagues for comprehensive clinical trial methodology
- **David Schoenfeld** for landmark survival analysis sample size methods
- **Joseph Fleiss** and colleagues for rate and proportion methods
- **Karimollah Hajian-Tilaki** for diagnostic test literature review
- **James Hanley** and **Barbara McNeil** for ROC analysis methods
- **James Schlesselman** for case-control methodology
- **Bernard Rosner** for biostatistics fundamentals

We are grateful to the R community and the many contributors to CRAN packages that inspired this work.
