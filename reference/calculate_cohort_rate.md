# Cohort study: incidence rate comparison (person-time, Poisson)

Machin et al. (2018) Eq 6.2 (p. 84): total person-time for a 1:phi
allocation is
`PU = (z_1-a/2 + z_1-b)^2 (lambda_T + lambda_S/phi) / (lambda_T - lambda_S)^2`.
This implementation reports the unexposed (S) and exposed (T) components
separately, with `r` being the exposed:unexposed person-time ratio.

## Usage

``` r
calculate_cohort_rate(rate0, rate1, ratio, alpha, power)
```

## Details

T_unexposed = (Za/2 + Zb)^2 (l1/r + l0) / (l1 - l0)^2, T_exposed =
r\*T0.
