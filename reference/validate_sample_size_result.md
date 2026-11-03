# Validate a sample_size_result object

Validate a sample_size_result object

## Usage

``` r
validate_sample_size_result(x)
```

## Arguments

- x:

  Object to validate; must inherit "sample_size_result" and carry at
  least `design`, `design_type`, and `parameters` fields; `task` and
  `outcome` (if present) must be character scalars.

## Value

Invisible TRUE, or aborts with a structured error

## Examples

``` r
r <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
sampleSizeCalc:::validate_sample_size_result(r)  # invisible TRUE
```
