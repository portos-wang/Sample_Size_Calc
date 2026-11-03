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
validate_design_args("twoMeans", list(mean1 = 10, mean2 = 12, sd = 3))
#> Error in validate_design_args("twoMeans", list(mean1 = 10, mean2 = 12,     sd = 3)): could not find function "validate_design_args"
try(validate_design_args("twoMeans", list(mean1 = 10)))  # error: missing mean2, sd
#> Error in validate_design_args("twoMeans", list(mean1 = 10)) : 
#>   could not find function "validate_design_args"
```
