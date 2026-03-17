# sampleSizeCalc

> Sample Size Calculator for Clinical Research

A comprehensive R package for calculating sample sizes across various clinical study designs. Built following Tidy R design principles with comprehensive parameter validation and structured error handling. **Now with enhanced literature support including primary methodology citations.**

## Installation

```r
# Install from GitHub
devtools::install_github("portos-wang/sampleSizeCalc")

# Or install local version
devtools::install_local("1_sample_size_determination")
```

## Features

- **17 Study Design Types**: 
  - Two independent means
  - Paired means
  - Two proportions
  - Survival analysis (Log-rank test)
  - Non-inferiority, superiority, and equivalence tests
  - Diagnostic test accuracy
  - Case-control studies
  - AUC comparisons
  - And more...

- **Comprehensive Literature Support**:
  - Primary methodology citations for all methods
  - Includes landmark papers (Hanley & McNeil 1982, Schoenfeld 1983, etc.)
  - Review articles for additional context
  - Multiple references for major methods

- **Robust Validation**: Comprehensive parameter validation with clear error messages
- **Modern Design**: Follows Tidy R principles with S3 classes and methods

## Quick Start

### Basic Usage

```r
library(sampleSizeCalc)

# Two independent means comparison
result <- sample_size_calculator(
  design = "twoMeans",
  mean1 = 10,
  mean2 = 12,
  sd = 3,
  alpha = 0.05,
  power = 0.8
)

# View results
print(result)
summary(result)
```

### Survival Analysis

```r
result <- sample_size_calculator(
  design = "survival",
  hr = 0.7,
  alpha = 0.05,
  power = 0.8
)
```

### Diagnostic Test

```r
result <- sample_size_calculator(
  design = "diagnosticAccuracySingle",
  prob = 0.85,
  d = 0.05,
  prevalence = 0.2,
  alpha = 0.05
)
```

## Study Designs

The package supports the following study designs:

| Design Type | Description | Key Parameters |
|-------------|-------------|----------------|
| `twoMeans` | Two independent sample means | `mean1`, `mean2`, `sd` |
| `twoProportions` | Two independent proportions | `p1`, `p2` |
| `pairedMeans` | Paired sample means | `meanDiff`, `sdDiff` |
| `survival` | Survival analysis (Log-rank) | `hr` |
| `nonInferiorityMeans` | Non-inferiority test (means) | `mean1`, `mean2`, `sd`, `margin` |
| `superiorityMeans` | Superiority test (means) | `mean1`, `mean2`, `sd`, `margin` |
| `equivalenceMeans` | Equivalence test (means) | `mean1`, `mean2`, `sd`, `margin` |
| `diagnosticAccuracySingle` | Diagnostic test accuracy | `prob`, `d`, `prevalence` |
| `caseControl` | Case-control study | `p0`, `OR`, `m` |
| `likelihoodRatioTest` | Likelihood ratio estimation | `sens`, `spec`, `prevalence` |

See the documentation for complete details on all supported designs.

## Output

The function returns an S3 object of class `sample_size_result` with methods:

- `print()`: Brief summary
- `summary()`: Detailed results with formulas and **complete literature references**
- `plot()`: Power curves and sample size comparisons (requires ggplot2)

### Literature References

All methods include proper literature citations. Use `summary()` to view references for each method.

```r
result <- sample_size_calculator("auc_single", auc = 0.80, d = 0.05)
summary(result)  # Shows formula and complete references
```

**Important**: When using specific methods in your research, please cite the original methodology papers. The summary output provides all necessary citation information.

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md).

## License

MIT © 2026 AI Coding Assistant

## Citation

If you use this package in your research, please cite:

```bibtex
@software{sampleSizeCalc,
  title = {sampleSizeCalc: Sample Size Calculator for Clinical Research},
  author = {AI Coding Assistant},
  year = {2026},
  version = {2.1.0},
  url = {https://github.com/portos-wang/sampleSizeCalc}
}
```

### Method-Specific Citations

**When using specific methods, please also cite the original methodology papers**:

| Method | Primary Citation | Year |
|--------|-----------------|------|
| AUC methods | Hanley & McNeil (Radiology) | 1982 |
| Survival analysis | Schoenfeld (Biometrics) | 1983 |
| Proportions | Fleiss et al. (Wiley) | 2003 |
| Case-control | Schlesselman (Oxford) | 1982 |

See `summary()` output for complete reference lists.
