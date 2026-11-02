# Single-arm phase II: Simon two-stage design (exact search)

Optimal minimises the expected sample size under p0; minimax minimises
the maximum N. Exact type-I error and power computed via binomial
probabilities. Anchor: Simon 1989 Table 1; Machin 2018 Example 17.2.

## Usage

``` r
calculate_simon_two_stage(p0, p1, alpha, power, optimizer)
```
