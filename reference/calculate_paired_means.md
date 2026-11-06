# Paired means comparison calculation

Paired means comparison calculation

## Usage

``` r
calculate_paired_means(
  meanDiff,
  sdDiff,
  alpha,
  power,
  pairing = "within_subject"
)
```

## Arguments

- meanDiff:

  Mean difference

- sdDiff:

  Standard deviation of differences

- alpha:

  Type I error

- power:

  Statistical power

- pairing:

  `"within_subject"` for two observations per person, or
  `"matched_subjects"` for pairs of distinct people.

## Value

List with calculation results
