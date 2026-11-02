# Individually matched (1:1) case-control study

Uses the discordant-pairs (McNemar/Connor) formulation with the
independence-within-pair approximation: pi10 = p1(1-p0), pi01 =
p0(1-p1); psi = pi10 + pi01; delta = \|pi10 - pi01\|;
`n_pairs = [Za/2 sqrt(psi) + Zb sqrt(psi - delta^2)]^2 / delta^2`.
Sources: Dupont 1988 (Biometrics 44(4):1157-1168); Schlesselman 1982.

## Usage

``` r
calculate_case_control_matched(p0, OR, alpha, power)
```
