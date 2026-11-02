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

  Required number of cases

- prevalence:

  Disease prevalence in the screening population

- beta:

  Acceptable probability of falling short (default 0.10, i.e. 90%
  guarantee)

## Value

Integer total enrollment N
