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
validate_power(0.8)     # OK
#> Error in validate_power(0.8): could not find function "validate_power"
try(validate_power(0))   # structured error
#> Error in validate_power(0) : could not find function "validate_power"
```
