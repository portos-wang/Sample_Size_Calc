# Validate design-specific arguments

Checks required, supported, and finite design-specific inputs before
dispatch. Arguments not used by the selected calculation path abort.

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
