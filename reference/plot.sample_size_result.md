# Plot sample size calculation result

Draw power curve (sample size vs power) or sample size vs effect size
ratio. Requires packages ggplot2 and scales.

## Usage

``` r
# S3 method for class 'sample_size_result'
plot(x, type = c("power", "sample_size"), ...)
```

## Arguments

- x:

  Object of class `sample_size_result` from
  [`calculate`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  or
  [`sample_size_calculator`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md).

- type:

  `"power"` for sample size vs power; `"sample_size"` for sample size vs
  effect size ratio (supported for twoMeans and twoProportions).

- ...:

  Passed to downstream methods (currently unused).

## Value

Invisibly returns `x`. A plot is drawn.

## Examples

``` r
# Antihypertensive RCT planning: check how power scales with enrollment
res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
plot(res, type = "power")        # sample size vs power curve

# \donttest{
plot(res, type = "sample_size")  # sample size vs effect size

# }
```
