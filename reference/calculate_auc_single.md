# AUC single test calculation

AUC single test calculation

## Usage

``` r
calculate_auc_single(
  auc,
  d,
  prevalence,
  alpha,
  ratio = NULL,
  var_method = "binormal"
)
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

- ratio:

  Controls per case; alternative to prevalence.

- var_method:

  AUC variance model (binormal by default).

## Value

List with calculation results
