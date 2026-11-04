# AUC comparison (two tests) calculation

AUC comparison (two tests) calculation

## Usage

``` r
calculate_auc_comparison(auc1, auc2, r, prevalence, alpha, power)
```

## Arguments

- auc1:

  Test 1 AUC value

- auc2:

  Test 2 AUC value

- r:

  Correlation between tests

- prevalence:

  Disease prevalence (used only to derive the non-diseased:diseased
  sampling ratio R; omitted or 1 falls back to 1:1)

- alpha:

  Type I error

- power:

  Statistical power

## Value

List with calculation results
