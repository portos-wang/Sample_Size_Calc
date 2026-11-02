# Paired-proportion kernel (Connor 1987 / Akoglu Table 6 parameterization)

`n = [Z_(a/2) sqrt(psi) + Z_b sqrt(psi - (p1-p2)^2)]^2 / (p1-p2)^2`
where psi = pi10 + pi01 is the discordant-pair proportion. Anchor:
Akoglu 2022 Table 6A (uncorrected): psi=0.05 (= delta at minimum),
diff=0.05, 80% power -\> 154.5 -\> 155.

## Usage

``` r
paired_proportion_n(p1, p2, psi, alpha, power)
```
