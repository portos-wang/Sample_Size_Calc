# Cluster RCT with Machin Eq 12.10 (DE + Student t correction)

Returns the total number of subjects N and the number of clusters per
arm. Rounding is done ONCE, at the cluster level (Machin Ch.12
"Numerical Accuracy"): each extra cluster adds a further m subjects, so
the cluster count must not be derived from an already-rounded subject
count.

## Usage

``` r
cluster_design_from_indiv(
  n_per_arm_indiv,
  cluster_size,
  icc,
  cv_m = NULL,
  alpha = 0.05,
  power = 0.8,
  phi = 1
)
```

## Arguments

- n_per_arm_indiv:

  Subjects per arm from the corresponding individually-randomised
  formula (unrounded).

- cluster_size:

  Cluster size m.

- icc:

  Intra-cluster correlation rho.

- cv_m:

  Optional coefficient of variation of cluster size (Eq 12.7).

- alpha, power:

  Type I and type II error.

- phi:

  Allocation ratio (Machin's phi); default 1.
