# Validate alpha (type I error) parameter

Validate alpha (type I error) parameter

## Usage

``` r
validate_alpha(alpha)
```

## Arguments

- alpha:

  Type I error rate; single numeric strictly inside (0, 1). Convention:
  0.05 for two-sided tests; 0.025 or 0.05 for one-sided
  non-inferiority/superiority tests. Values outside (0, 1) abort.

## Value

Validated alpha value (invisible numeric scalar)

## Examples

``` r
sampleSizeCalc:::validate_alpha(0.05)   # OK
#> [1] 0.05
try(sampleSizeCalc:::validate_alpha(1.5))  # structured error
#> Error in sampleSizeCalc:::validate_alpha(1.5) : 
#>   `alpha` must be between 0 and 1, not 1.5.
#> ℹ Typical values are 0.05 or 0.01.
```
