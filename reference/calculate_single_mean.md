# Internal calculation: single mean precision

Machin et al. (2018) Eq 9.18 (p. 152):

## Usage

``` r
calculate_single_mean(sigma, precision, alpha)
```

## Details


      N = (t_{N-1, 1-a/2} * sigma / d)^2

The right-hand z form is the starting value N0; when N0 \< 40 the
Student t quantile depends on N and the equation must be iterated
(Machin p. 152: "if this is large (\>= 40) then this is taken as the
sample size. If N0 \< 40, then the Student t quantile with N0 - 1 df is
obtained ... and a revised sample size N1 obtained"). This
implementation searches for the smallest integer N \>= 2 whose Student t
interval half-width does not exceed d, avoiding oscillation between
adjacent rounded fixed-point iterates.
