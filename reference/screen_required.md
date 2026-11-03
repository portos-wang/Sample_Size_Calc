# Total screening size with probability guarantee (Zhou Eq 6.3)

Given a required number of cases n and a disease prevalence, compute the
total enrollment needed so that, with probability 1-beta, at least n
cases are captured: N satisfies P(Binomial(N, prev) \>= n) \>= 1-beta.

## Usage

``` r
screen_required(n, prevalence, beta = 0.1)
```

## Arguments

- n:

  Required number of cases; positive integer (e.g. the
  `target_state_cases_needed` from a diagnostic accuracy calculation).

- prevalence:

  Disease prevalence in the screening population; scalar in (0, 1) (e.g.
  0.20 for a 20 percent clinic prevalence).

- beta:

  Acceptable probability of falling short; scalar in (0, 1). Default
  0.10, i.e. a 90 percent guarantee of capturing at least `n` cases.

## Value

Integer total enrollment N (screening list size).

## Examples

``` r
# A colon-cancer screening validation needs 196 confirmed cases;
# clinic prevalence is 20%. Enroll enough patients to capture
# 196 cases with 90% probability:
screen_required(n = 196, prevalence = 0.20, beta = 0.10)
#> [1] 1061

# More stringent 95% guarantee:
screen_required(n = 196, prevalence = 0.20, beta = 0.05)
#> [1] 1085
```
