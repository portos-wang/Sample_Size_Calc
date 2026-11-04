# Likelihood ratio test calculation

Legacy precision-based minimum-case rule. Kept for golden-master
compatibility; for the log-CI method of Hajian-Tilaki (2014) Eq
6.10-6.14 use `lr_type`/`target_lr`, which routes to
[`calculate_likelihood_ratio_v2()`](https://portos-wang.github.io/Sample_Size_Calc/reference/calculate_likelihood_ratio_v2.md).

## Usage

``` r
calculate_likelihood_ratio_test(sens, spec, prevalence, precision, alpha)
```

## Arguments

- sens:

  Expected sensitivity

- spec:

  Expected specificity

- prevalence:

  Disease prevalence (used only to derive the non-diseased:diseased
  sampling ratio; omitted or 1 falls back to 1:1)

- precision:

  Desired precision

- alpha:

  Type I error

## Value

List with calculation results
