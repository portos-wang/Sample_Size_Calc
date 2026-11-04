# 2x2 crossover, continuous outcome (within-subject SD parameterization)

Var(within-subject difference) = 2\*sigma_w^2 (the between-subject
variance cancels), so the **total** number of subjects is n_total = 2
(Za/2 + Zb)^2 sigma_w^2 / delta^2, and each of the two sequences carries
half of it. Julious (2004) Eq 6.6 writes the same expression with
sigma_w being the within-subject SD on the log scale and n the total
sample size; PowerTOST and Julious both then report the sample size per
sequence (n_total / 2) for a 2x2 design.

## Usage

``` r
calculate_crossover_mean(delta, sigma_within, alpha, power)
```

## Details

Anchor: Julious 2004 Section 3.3.3 equivalence worked example - with
sigma_w^2 = 2 and a 20% acceptance criterion on the log scale, the total
is 106 subjects (53 per sequence) at 2.5% Type I and 10% Type II error.
