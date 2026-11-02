# Bioequivalence (2x2 crossover, exact TOST noncentral t, 80-125%)

Evaluates the exact power of the two one-sided tests (TOST) procedure
using the noncentral t distribution (Phillips 1990; Julious 2004 Eq 13).
Matches sampleN.TOST in the PowerTOST package exactly.

## Usage

``` r
calculate_bioequivalence(
  cv,
  alpha,
  power,
  theta0 = 1,
  margin_low = 0.8,
  margin_high = 1.25
)
```

## Arguments

- cv:

  Intra-subject coefficient of variation

- alpha:

  Type I error (one-sided per test, default 0.05)

- power:

  Target power (default 0.80)

- theta0:

  Anticipated T/R geometric mean ratio (default 1.0)

- margin_low:

  Lower equivalence margin (default 0.80)

- margin_high:

  Upper equivalence margin (default 1.25)

## Value

List with sample size results consumed by as_sample_size_result()
