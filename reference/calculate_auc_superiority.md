# AUC superiority test calculation

AUC superiority test calculation

## Usage

``` r
calculate_auc_superiority(
  auc,
  auc0,
  prevalence,
  alpha,
  power,
  ratio = NULL,
  var_method = "binormal"
)
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

- ratio:

  Controls per case; alternative to prevalence.

- var_method:

  AUC variance model (binormal by default).

## Value

List with calculation results
