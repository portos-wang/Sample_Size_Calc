# 2x2 crossover, continuous outcome (within-subject SD parameterization)

Var(within-subject difference) = 2\*sigma_w^2 (between-subject variance
cancels), so n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2.

## Usage

``` r
calculate_crossover_mean(delta, sigma_within, alpha, power)
```
