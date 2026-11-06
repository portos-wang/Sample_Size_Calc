# Bioequivalence (2x2 crossover, exact TOST noncentral t, 80-125%)

Evaluates exact joint power of the two one-sided tests (TOST) by
integrating the conditional normal acceptance probability over the
independent chi-square variance estimate (Phillips 1990). Uses balanced
even totals and reports an error if the target power cannot be reached
within 10000 participants. Matches sampleN.TOST in the PowerTOST package
exactly.

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
