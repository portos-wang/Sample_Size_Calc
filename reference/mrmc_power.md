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

  Cases per test (paired-patient design: total cases)

- J:

  Number of readers per test

- delta:

  Difference in accuracy to detect

- sigma_b2:

  Between-reader variance component

- sigma_w2:

  Within-reader (occasion) variance component

- sigma_c2:

  Patient-sampling variance component

- rho1:

  Correlation, same reader different tests

- rho2:

  Correlation, different readers same test

- rho3:

  Correlation, different readers different tests

- alpha:

  Type I error (two-sided F test)

- n_repeats:

  Reading occasions per reader-test (Q, usually 1)

## Value

Numeric power (0-1), invisible

## Details

Anchor: Zhou 2011 pp. 225 (mammography example) — n=50 cases, 8 readers,
delta=0.10, sigma_b2=0.00123, sigma_w2=0.00087, sigma_c2 ~= 0.05,
rho1=0.25, rho2=0.2, rho3=0.1 -\> power ~= 0.89 as reported in the book.
