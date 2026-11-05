# Plot power curve

Plot power curve

## Usage

``` r
plot_power_curve(result)
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
SampleSizeCalc:::plot_power_curve(res)

# }
```
