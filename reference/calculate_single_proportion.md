# Internal calculation: single proportion precision (absolute or relative)

n = Z^2 \* p(1-p) / d^2 for absolute precision; for relative precision
the margin is epsilon \* p. Prevalence outside 10-90% triggers a
convention hint (Bhardwaj 2024 p.2558).

## Usage

``` r
calculate_single_proportion(p, precision, precision_type, alpha)
```

## Arguments

- p:

  Expected proportion

- precision:

  Margin of error d (absolute) or epsilon (relative)

- precision_type:

  "absolute" or "relative"

- alpha:

  Type I error (two-sided CI)

## Value

List consumed by as_sample_size_result()
