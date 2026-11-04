# Apply the cluster design effect to an individually-randomised result

DE = 1 + (m - 1) \* ICC (Machin 2018 Eq 12.5). Cluster-level rounding:
n_clusters = ceiling(n_individuals_raw \* DE / m), individuals =
n_clusters \* m. The raw (unrounded) individual count is used so that
rounding happens once.

## Usage

``` r
apply_cluster_design(base, cluster_size, icc)
```
