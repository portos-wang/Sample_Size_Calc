# Internal calculation: single correlation coefficient precision (Fisher z / Machin)

Sample size for estimating a Pearson correlation coefficient with
pre-specified confidence interval width w = 2\*d (Machin et al. 2018,
Ch.19, Equations 19.5-19.8). Matches prec_cor in the presize package for
identical parameters.

## Usage

``` r
calculate_single_correlation(
  r,
  epsilon = NULL,
  precision = NULL,
  alpha = 0.05,
  power = NULL
)
```

## Arguments

- r:

  Anticipated correlation coefficient

- epsilon:

  Relative precision (margin d = epsilon \* r)

- precision:

  Absolute margin of error d (half-width of CI)

- alpha:

  Type I error (two-sided CI, default 0.05)

- power:

  Ignored (estimation design)

## Value

List consumed by as_sample_size_result()
