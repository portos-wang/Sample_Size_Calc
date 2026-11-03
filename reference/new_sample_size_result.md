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
  calculation = NULL,
  reference = NULL,
  roles = character(),
  adjustments = list(),
  hints = character(),
  calculation_steps = NULL
)
```

## Arguments

- design:

  Design keyword (e.g. "rct", "cohort", "diagAccuracy")

- task:

  Statistical task: "estimate", "test", "noninferiority", "superiority",
  "equivalence", or "plan"

- outcome:

  Outcome type: "mean", "proportion", "rate", "survival", "auc", "lr",
  "correlation", "ordinal", or "events"

- design_type:

  Human-readable design description

- parameters:

  Named list of input parameters. Each entry must be finite numeric
  scalar (or vector for `prop_bar`); e.g. `mean1 = 10`, `sd = 3`.

- legacy:

  Legacy result fields (n_per_group, total_n, pairs_count,
  target_events_needed, target_state_cases_needed, cases_needed, ...)

- formula_ascii:

  Plain-text formula (single string, e.g. "n =
  2\*((Za/2+Zb)\*sd/(mean1-mean2))^2")

- formula_latex:

  LaTeX formula wrapped in \$\$...\$\$

- calculation:

  Step-by-step calculation explanation (character vector)

- reference:

  Literature reference (section/page precision)

- roles:

  Character vector documenting parameter roles for the design

- adjustments:

  Named list of applied adjustments (dropout, nonresponse)

- hints:

  Character vector of methodological warnings/tips

- calculation_steps:

  Alias for `calculation`

## Value

A sample_size_result object

## Examples

``` r
r <- new_sample_size_result(
  design = "rct", task = "test", outcome = "mean",
  design_type = "Two independent samples, mean comparison",
  parameters = list(mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8),
  legacy = list(n_per_group = 37L, total_n = 74L),
  formula_ascii = "n = 2*((Za/2+Zb)*sd/(mean1-mean2))^2",
  reference = "Chow et al. (2017)"
)
#> Error in new_sample_size_result(design = "rct", task = "test", outcome = "mean",     design_type = "Two independent samples, mean comparison",     parameters = list(mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05,         power = 0.8), legacy = list(n_per_group = 37L, total_n = 74L),     formula_ascii = "n = 2*((Za/2+Zb)*sd/(mean1-mean2))^2", reference = "Chow et al. (2017)"): could not find function "new_sample_size_result"
stopifnot(inherits(r, "sample_size_result"))
#> Error: object 'r' not found
```
