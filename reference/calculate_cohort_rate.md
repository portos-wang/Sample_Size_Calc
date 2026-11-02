# Cohort study: incidence rate comparison (person-time, Poisson)

Equal person-time: T = (Za/2 + Zb)^2 (l1 + l2) / (l1 - l2)^2 per group.
Unequal allocation r = T_exposed/T_unexposed: T_unexposed = (Za/2 +
Zb)^2 (l1/r + l2) / (l1 - l2)^2.

## Usage

``` r
calculate_cohort_rate(rate0, rate1, ratio, alpha, power)
```
