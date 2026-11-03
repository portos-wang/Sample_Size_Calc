# MRMC study power (Obuchowski-Rockette mixed model, paired-patient paired-reader design)

Computes the power of a multi-reader multi-case study to detect a given
difference in accuracy (e.g. ROC area) with J readers, using the
non-central F framework of Zhou et al. (2011) Eq 6.32 with the Table 6.4
parameterisation for the paired-patient, paired-reader design (rho1 \>
rho2 \> rho3 \> 0, rho_b \> 0).

## Usage

``` r
mrmc_power(
  n,
  J,
  delta,
  sigma_b2,
  sigma_w2,
  sigma_c2,
  rho1,
  rho2,
  rho3,
  alpha = 0.05,
  n_repeats = 1
)
```

## Arguments

- n:

  Cases per test; number \>= 1. In the paired-patient design this is the
  total number of patients, each imaged under both tests.

- J:

  Number of readers per test; integer \>= 2 (the F test needs J-1 df).

- delta:

  Difference in accuracy to detect; number \> 0 (on the AUC or accuracy
  metric scale, e.g. 0.10).

- sigma_b2:

  Between-reader variance component; number \>= 0. Planning heuristic:
  (accuracy range / 4)^2 (Zhou p. 223, Beam 1996).

- sigma_w2:

  Within-reader (occasion) variance component; number \>= 0.

- sigma_c2:

  Patient-sampling (case) variance component; number \>= 0 (e.g. 0.05 in
  the Zhou mammography example).

- rho1:

  Correlation, same reader different tests; in \[0, 1).

- rho2:

  Correlation, different readers same test; in \[0, 1).

- rho3:

  Correlation, different readers different tests; in \[0, 1). The
  paired-patient, paired-reader parameterisation expects rho1 \> rho2 \>
  rho3 \> 0 (Zhou Table 6.4); violated orderings warn.

- alpha:

  Type I error of the two-sided F test; in (0, 1), default 0.05.

- n_repeats:

  Reading occasions per reader-test (Q); integer \>= 1, usually 1.

## Value

Numeric power (0-1), invisible. The full result object (parameters,
formula, noncentrality) is attached as a `sample_size_result`.

## Details

Anchor: Zhou 2011 pp. 225 (mammography example) — n=50 cases, 8 readers,
delta=0.10, sigma_b2=0.00123, sigma_w2=0.00087, sigma_c2 ~= 0.05,
rho1=0.25, rho2=0.2, rho3=0.1 -\> power ~= 0.89 as reported in the book.

## Examples

``` r
# Mammography MRMC planning (Zhou 2011 p. 225): 50 cases, 8 readers,
# detect an AUC difference of 0.10 between two imaging techniques
mrmc_power(n = 50, J = 8, delta = 0.10,
  sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.05,
  rho1 = 0.25, rho2 = 0.20, rho3 = 0.10)
```
