# Likelihood ratio sample size via log(LR) CI (Hajian-Tilaki Eq 6.10-6.14)

Solves the CI-width equation for a target LR: given expected Se and Sp,
the LR+ (or LR-) is determined; n per group is found such that the
log-scale CI half-width does not exceed ln(target / LR_expected).

## Usage

``` r
calculate_likelihood_ratio_v2(
  sens,
  spec,
  prevalence,
  alpha,
  target_lr,
  lr_type
)
```
