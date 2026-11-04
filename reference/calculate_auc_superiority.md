# AUC superiority test calculation

AUC superiority test calculation

## Usage

``` r
calculate_auc_superiority(auc, auc0, prevalence, alpha, power)
```

## Arguments

- auc:

  Expected AUC value

- auc0:

  Null hypothesis AUC value

- prevalence:

  Disease prevalence (used only to derive the non-diseased:diseased
  sampling ratio R; omitted or 1 falls back to 1:1)

- alpha:

  Type I error

- power:

  Statistical power

## Value

List with calculation results
