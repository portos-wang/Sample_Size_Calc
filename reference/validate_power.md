# Validate power parameter

Validate power parameter

## Usage

``` r
validate_power(power)
```

## Arguments

- power:

  Statistical power (1 - beta); single numeric strictly inside (0, 1).
  Typical: 0.8 (80 percent) or 0.9 (90 percent). Values outside (0, 1)
  abort.

## Value

Validated power value (invisible numeric scalar)

## Examples

``` r
sampleSizeCalc:::validate_power(0.8)     # OK
#> [1] 0.8
try(sampleSizeCalc:::validate_power(0))   # structured error
#> Error in sampleSizeCalc:::validate_power(0) : 
#>   `power` must be between 0 and 1, not 0.
#> ℹ Typical values are 0.8, 0.9, or 0.95.
```
