# Two-group comparison of an ordered categorical outcome (Whitehead)

Whitehead (1993) Eq 10 (p. 2260) with allocation ratio A:

## Usage

``` r
calculate_two_ordinal(or, prop_bar, alpha, power, allocation = 1)
```

## Arguments

- or:

  Anticipated odds ratio (proportional odds); \> 0, != 1.

- prop_bar:

  Anticipated average category proportions; positive, summing to 1.

- allocation:

  Allocation ratio phi = n_Test / n_Standard (Whitehead's A); number \>
  0, default 1 (equal groups).

## Details


      n = 3 (A + 1)^2 (u_{a/2} + u_b)^2 / [ A theta^2 (1 - sum pbar_i^3) ]

and Machin et al. (2018) Eq 4.3 (p. 57) with allocation ratio phi:


      N = Gamma (1 + phi)^2 / phi * (z_{1-a/2} + z_{1-b})^2 / (log OR)^2,
      Gamma = 3 / (1 - sum pbar_i^3)                          (Eq 4.4)

The two are algebraically identical when A = phi. The allocation
multiplier (1+phi)^2/phi equals 4 for equal groups.

Anchors: Machin Example 4.1 (p. 59): kappa = 4, phi = 1, OR = 3.65, pbar
is normalised from (0.2564, 0.2792, 0.2056, 0.2619), which sum to 1.0031
in the printed example; 2-sided alpha = 0.05, power = 0.80 gives 31 per
arm, 62 total. Whitehead Example 1 (p. 2261): log(OR) = 0.887, pbar =
(0.289, 0.486, 0.153, 0.072), alpha = 0.05, power = 0.90 -\> continuous
n = 186.98, rounded to 94 per group / 188 total.
