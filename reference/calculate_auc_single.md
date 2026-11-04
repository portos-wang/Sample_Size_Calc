# AUC single test calculation

AUC single test calculation

## Usage

``` r
calculate_auc_single(auc, d, prevalence, alpha)
```

## Arguments

- auc:

  Expected AUC value

- d:

  Desired precision

- prevalence:

  Disease prevalence (used only to derive the non-diseased:diseased
  sampling ratio R = (1 - prevalence) / prevalence; omitted or 1 falls
  back to a 1:1 quota)

- alpha:

  Type I error

## Value

List with calculation results
