# Plot sample size comparison

Plot sample size comparison

## Usage

``` r
plot_sample_size_comparison(result)
```

## Arguments

- result:

  A sample_size_result object

## Value

Invisibly returns the result object

## Examples

``` r
# \donttest{
res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
SampleSizeCalc:::plot_sample_size_comparison(res)

# }
```
