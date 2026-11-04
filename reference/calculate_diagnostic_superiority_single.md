# Diagnostic superiority (single test) calculation

Diagnostic superiority (single test) calculation

## Usage

``` r
calculate_diagnostic_superiority_single(
  prob,
  p0,
  prevalence,
  alpha,
  power,
  method = c("asymptotic", "exact"),
  alternative = c("one.sided", "two.sided")
)
```

## Arguments

- prob:

  Expected accuracy

- p0:

  Null hypothesis accuracy

- prevalence:

  Disease prevalence

- alpha:

  Type I error

- power:

  Statistical power

- method:

  Calculation method: "asymptotic" (Hajian-Tilaki 2014 Eq 6.8) or
  "exact" (A'Hern 2001 exact binomial)

- alternative:

  `"one.sided"` (the historical default of this package and the Akoglu
  2022 Table 2 Eq 2 convention) or `"two.sided"` (the Hajian-Tilaki 2014
  Eq 6.8 convention, which the paper uses throughout, p. 197).

## Value

List with calculation results
