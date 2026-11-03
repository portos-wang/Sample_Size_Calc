# Assert an object is a valid sample_size_result

Assert an object is a valid sample_size_result

## Usage

``` r
assert_sample_size_result(x)
```

## Arguments

- x:

  Object to assert; see
  [`validate_sample_size_result()`](https://portos-wang.github.io/Sample_Size_Calc/reference/validate_sample_size_result.md)
  for the required structure.

## Value

Invisibly returns x

## Examples

``` r
r <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
sampleSizeCalc:::assert_sample_size_result(r)
```
