# Internal calculation: Cohen's kappa sample size (Cantor 1996)

Two modes:

- task = "estimate": precision of a single kappa —
  `n = Q * (z_(1-a/2) / d)^2`, with the full Cantor Eq 3 asymptotic
  variance factor Q from the compatible joint rating table. Anchor:
  Cantor 1996 precision example (pi=0.3, kappa unspecified, Q=1.0,
  d=0.1, 80% CI -\> 165).

- task = "test": two independent kappas H0: K1 = K2 —
  `n = (z_a sqrt(2 Q1) + z_b sqrt(Q1 + Q2))^2 / (K1 - K2)^2`. Anchor:
  Cantor 1996 two-questionnaire example (pi=0.5, K1=0.7, K2=0.5, 95%/80%
  -\> 214).

## Usage

``` r
calculate_kappa(pi1, pi2, kappa1, kappa2, d, alpha, power, task)
```
