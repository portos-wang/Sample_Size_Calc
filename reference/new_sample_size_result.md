# Internal constructor for sample_size_result objects

Internal constructor for sample_size_result objects

## Usage

``` r
new_sample_size_result(
  design,
  task,
  outcome,
  design_type,
  parameters = list(),
  legacy = list(),
  formula_ascii = NULL,
  formula_latex = NULL,
  reference = NULL,
  roles = character(),
  adjustments = list(),
  hints = character()
)
```

## Arguments

- design:

  Design keyword (e.g. "rct", "cohort", "diagAccuracy")

- task:

  Statistical task: estimate/test/noninferiority/superiority/equivalence

- outcome:

  Outcome type: mean/proportion/rate/survival/auc/lr/correlation

- design_type:

  Human-readable design description

- parameters:

  Named list of input parameters

- legacy:

  Legacy result fields (n_per_group, total_n, pairs_count,
  target_events_needed, target_state_cases_needed, cases_needed, ...)

- formula_ascii:

  Plain-text formula

- formula_latex:

  LaTeX formula

- reference:

  Literature reference (section/page precision)

- roles:

  Character vector documenting parameter roles for the design

- adjustments:

  Named list of applied adjustments (dropout, nonresponse)

## Value

A sample_size_result object
