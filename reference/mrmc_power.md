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
  rho_b = NULL,
  alpha = 0.05,
  n_repeats = 1
)
```

## Arguments

- n:

  Patients with the condition (paired-patient design: the same patients
  are imaged under both tests)

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

  Patient-sampling (case) variance component; number \>= 0. This is the
  variance of the accuracy estimate attributable to sampling patients,
  i.e. V(A)/n (Zhou p. 221), so it already carries the sample size. For
  the mammography example it is 0.00196 at n = 50.

- rho1:

  Correlation, same reader different tests; in \[0, 1).

- rho2:

  Correlation, different readers same test; in \[0, 1).

- rho3:

  Correlation, different readers different tests; in \[0, 1). The
  paired-patient, paired-reader parameterisation expects rho1 \> rho2 \>
  rho3 \> 0 (Zhou Table 6.4); violated orderings warn.

- rho_b:

  Correlation between the same readers' accuracies on the two tests
  (Zhou Table 6.3 `p_b`); in \[0, 1). Defaults to `rho1`, which is the
  value implied when a single "same reader, different test" correlation
  is supplied. For the Zhou mammography example the book sets rho_b =
  0.75.

- alpha:

  Type I error of the two-sided F test; in (0, 1), default 0.05.

- n_repeats:

  Reading occasions per reader-test (Q); integer \>= 1, usually 1.

## Value

Invisibly returns a `sample_size_result` object with `power` (legacy
alias), `power_achieved`, parameters, formula, and report fields.

## Details

Eq 6.32 as printed (Zhou 2011, p. 221):


      lambda = J (v1 - v2)^2 / (2 * {
        sigma_b2 (1 - rho_b) + sigma_w2 / Q +
        sigma_c2 [(1 - rho1) + (J - 1)(rho2 - rho3)] })

Note the two features that distinguish it from simpler MRMC formulae:
the between-reader term is weighted by `(1 - rho_b)`, the correlation
between the same readers' accuracies on the two tests, and the
patient-sampling term `sigma_c2` is NOT divided by `n` (sigma_c2 is
already the patient-sampling variance component, computed as V(A)/n; see
Zhou p. 221).

Anchor: Zhou 2011 p. 225 (mammography example) - n = 50 malignant and 50
benign patients, J = 8 readers, delta = 0.10, sigma_b2 = 0.00123,
sigma_w2 = 0.00087, sigma_c2 = 0.00196 (from Eq 6.5 with n = 50), rho1 =
0.5, rho2 = 0.3, rho3 = 0.25, rho_b = 0.75 -\> power = 0.893, which
reproduces the book's "89% power".

## Examples

``` r
# Mammography MRMC planning (Zhou 2011 pp. 221-225): 50 malignant plus 50
# benign patients, 8 readers, detect an AUC difference of 0.10. Power
# reproduces the book's 89%.
mrmc_power(
  n = 50, J = 8, delta = 0.10,
  sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.00196,
  rho1 = 0.50, rho2 = 0.30, rho3 = 0.25, rho_b = 0.75
)
```
