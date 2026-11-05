# Design effect for a cluster randomised trial (Machin Eq 12.5 / 12.7)

With a constant cluster size `m` this is Machin et al. (2018) Eq 12.5,
`DE = 1 + (m - 1) * rho`. Supplying `cv_m` (the coefficient of variation
of cluster size) switches to Eq 12.7, which allows for variable cluster
sizes before the number of clusters is known:

## Usage

``` r
cluster_size_inflation(cluster_size, icc, cv_m = NULL)
```

## Arguments

- cluster_size:

  Number of subjects per cluster (mbar if sizes vary).

- icc:

  Intra-cluster correlation rho; in \[0, 1).

- cv_m:

  Optional coefficient of variation of cluster size (Eq 12.7);
  non-negative. `NULL` (default) gives the constant-size Eq 12.5.

## Value

The design effect (numeric scalar \>= 1).

## Details


      DE = 1 + [(CV(m)^2 + 1) * mbar - 1] * rho

## Examples

``` r
SampleSizeCalc:::cluster_size_inflation(20, 0.05) # 1.95 (Eq 12.5)
#> [1] 1.95
SampleSizeCalc:::cluster_size_inflation(20, 0.05, cv_m = 0.35) # Eq 12.7
#> [1] 2.0725
```
