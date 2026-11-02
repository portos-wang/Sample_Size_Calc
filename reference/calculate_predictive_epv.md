# Predictive/prognostic model development: events-per-variable rule

n_events = epv \* n_parameters; n_subjects = n_events /
event_prevalence. Source: Peduzzi et al. (1996); Riley et al. (2019)
offer a modern alternative planned for a later release.

## Usage

``` r
calculate_predictive_epv(n_parameters, epv, event_prevalence)
```
