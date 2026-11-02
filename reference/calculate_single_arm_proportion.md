# Single-arm trial: binary outcome vs a fixed reference proportion

`n = [Z_a/2 sqrt(p0(1-p0)) + Z_b sqrt(p1(1-p1))]^2 / (p1-p0)^2` Anchor:
Hajian-Tilaki 2014 Eq 6.8 (P0=0.70, P1=0.80 -\> 153).

## Usage

``` r
calculate_single_arm_proportion(p0, p1, alpha, power)
```
