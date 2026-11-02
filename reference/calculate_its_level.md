# Interrupted time series: level-change power (AR(1)-adjusted, experimental)

Transparent normal approximation with the AR(1) effective-sample-size
correction n_eff = n \* (1 - rho) / (1 + rho) per segment. Experimental:
see Bernal et al. (2017) for the methodological framework; rigorous ITS
power requires simulation.

## Usage

``` r
calculate_its_level(effect_sd, n_pre, n_post, rho, alpha, power)
```
