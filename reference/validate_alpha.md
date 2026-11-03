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
validate_alpha(0.05)   # OK
#> Error in validate_alpha(0.05): could not find function "validate_alpha"
try(validate_alpha(1.5))  # structured error
#> Error in validate_alpha(1.5) : could not find function "validate_alpha"
```
