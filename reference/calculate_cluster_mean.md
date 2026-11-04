# Cluster RCT wrapping the two-means kernel

Uses Machin Eq 12.10 (p. 199), i.e. the design effect plus the Student t
correction term `z^2/2`, and rounds ONCE at the cluster level. Anchor:
Machin Example 12.1 (p. 206) - delta=3.5, sigma=6.94, m=2, ICC=0.025,
2-sided alpha=0.05, power=0.90 -\> N=171.35 -\> 172, K=86 (43 per arm).

## Usage

``` r
calculate_cluster_mean(mean1, mean2, sd, icc, cluster_size, alpha, power)
```
