# Internal calculation: prediction model for a time-to-event outcome (Riley 2020 criterion T1: person-years for precise cumulative incidence) Anchor: lambda=0.1/year, t=10, delta=0.05 -\> T \>= 2366 person-years.

Internal calculation: prediction model for a time-to-event outcome
(Riley 2020 criterion T1: person-years for precise cumulative incidence)
Anchor: lambda=0.1/year, t=10, delta=0.05 -\> T \>= 2366 person-years.

## Usage

``` r
calculate_predictive_timetoevent(
  rate,
  timepoint,
  precision_delta,
  alpha,
  n_parameters,
  epv
)
```
