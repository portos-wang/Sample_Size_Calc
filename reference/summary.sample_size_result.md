# Summary method for sample_size_result objects

Includes the plain-text formula, LaTeX source, calculation process, and
references shown by
[`print.sample_size_result()`](https://portos-wang.github.io/Sample_Size_Calc/reference/print.sample_size_result.md),
with all input parameters, design axes, and recorded adjustments.

## Usage

``` r
# S3 method for class 'sample_size_result'
summary(object, ...)
```

## Arguments

- object:

  A sample_size_result object

- ...:

  Additional arguments (ignored)

## Value

Invisibly returns the input object

## Examples

``` r
# Full protocol-ready report for the antihypertensive RCT:
res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
summary(res)  # also lists all inputs, design axes, and adjustments
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Summary
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Study Design 
#> • Type: "Two independent samples, mean comparison"
#> • Design: "rct"
#> • Task: "test" | Outcome: "mean"
#> 
#> ── Parameters 
#> • mean1: 10
#> • mean2: 12
#> • sd: 3
#> • alpha: 0.05
#> • power: 0.8
#> 
#> ── Sample Size Results 
#> • Sample size per group: 37
#> • Total sample size: 74
#> 
#> ── Formula 
#> Plain text:
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> LaTeX:
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$ 
#> 
#> ── Calculation Process 
#> • Step 1: State hypotheses: H0: mu1 = mu2 vs H1: mu1 != mu2 (two-sided alpha =
#> 0.05, power = 0.80).
#> • Step 2: Calculate mean difference delta = |mu1 - mu2| = |10 - 12| = 2; common
#> SD sigma = 3.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96 (for two-sided alpha =
#> 0.05), Z_beta = 0.8416 (for power = 0.80).
#> • Step 4: Compute initial sample size via normal approximation: n0 = 2 *
#> ((Z_(alpha/2) + Z_beta) * sigma / delta)^2 = 2 * ((1.96 + 0.8416) * 3 / 2)^2 =
#> 35.32.
#> • Step 5: Refine via exact two-sample Student's t-test power iteration
#> (accounting for degrees of freedom df = 2n - 2).
#> • Step 6: Round up to integer: n = 37 per group, total sample size N = 74.
#> 
#> ── Reference 
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press. 
#> ────────────────────────────────────────────────────────────────────────────────
```
