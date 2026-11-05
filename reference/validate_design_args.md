# Validate design-specific arguments

Checks that every required argument for the chosen design keyword is
present and aborts with a structured error naming the missing parameters
(e.g. twoMeans requires mean1, mean2, sd).

## Usage

``` r
validate_design_args(design, args)
```

## Arguments

- design:

  Study design keyword (legacy dispatch name, e.g. "twoMeans",
  "cohortProportion", "simonTwoStage")

- args:

  Named list of arguments to validate

## Value

Validated arguments list (invisible)

## Examples

``` r
SampleSizeCalc:::validate_design_args(
  "twoMeans", list(mean1 = 10, mean2 = 12, sd = 3)
)
#> $mean1
#> [1] 10
#> 
#> $mean2
#> [1] 12
#> 
#> $sd
#> [1] 3
#> 
# Error: missing mean2 and sd
try(SampleSizeCalc:::validate_design_args("twoMeans", list(mean1 = 10)))
#> Error in SampleSizeCalc:::validate_design_args("twoMeans", list(mean1 = 10)) : 
#>   `sample_size_calculator()` with design "twoMeans" requires missing
#> arguments:
#> ✖ `mean2, sd`
#> ℹ See `?sample_size_calculator()` for required arguments.
```
