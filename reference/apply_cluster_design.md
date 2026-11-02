# Apply the cluster design effect to an individually-randomised result

DE = 1 + (m - 1) \* ICC (Machin 2018 Ch.12). Cluster-level rounding:
n_clusters = ceiling(n_individuals \* DE / m), individuals = n_clusters
\* m.

## Usage

``` r
apply_cluster_design(base, cluster_size, icc)
```
