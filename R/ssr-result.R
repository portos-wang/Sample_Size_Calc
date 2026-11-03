# sample_size_result S3 class: constructor, validator, assertion
# Storage keeps legacy top-level field names (n_per_group, total_n, ...) so
# existing print/summary/plot methods and user code keep working; new
# canonical fields (n_1, events, cases, ...) are derived automatically.

# New canonical fields derived from legacy storage fields.
# Canonical name -> legacy name(s), first match wins.
ssr_canonical_map <- list(
  n_1 = c("n_per_group", "pairs_count", "cases_needed", "recommended_cases"),
  n_2 = c("n_per_group", "controls_needed"),
  total_n = c("total_n", "total_subjects", "n_required"),
  n_required = "n_required",
  pairs = "pairs_count",
  events = "target_events_needed",
  cases = c("target_state_cases_needed", "cases_needed"),
  subjects_to_screen = "total_subjects_to_screen"
)

#' Internal constructor for sample_size_result objects
#'
#' @param design Design keyword (e.g. "rct", "cohort", "diagAccuracy")
#' @param task Statistical task: "estimate", "test", "noninferiority",
#'   "superiority", "equivalence", or "plan"
#' @param outcome Outcome type: "mean", "proportion", "rate", "survival",
#'   "auc", "lr", "correlation", "ordinal", or "events"
#' @param design_type Human-readable design description
#' @param parameters Named list of input parameters. Each entry must be finite
#'   numeric scalar (or vector for `prop_bar`); e.g. `mean1 = 10`, `sd = 3`.
#' @param legacy Legacy result fields (n_per_group, total_n, pairs_count,
#'   target_events_needed, target_state_cases_needed, cases_needed, ...)
#' @param formula_ascii Plain-text formula (single string, e.g.
#'   "n = 2*((Za/2+Zb)*sd/(mean1-mean2))^2")
#' @param formula_latex LaTeX formula wrapped in $$...$$
#' @param calculation Step-by-step calculation explanation (character vector)
#' @param reference Literature reference (section/page precision)
#' @param roles Character vector documenting parameter roles for the design
#' @param adjustments Named list of applied adjustments (dropout, nonresponse)
#' @param hints Character vector of methodological warnings/tips
#' @param calculation_steps Alias for `calculation`
#' @return A sample_size_result object
#' @keywords internal
#' @examples
#' r <- sampleSizeCalc:::new_sample_size_result(
#'   design = "rct", task = "test", outcome = "mean",
#'   design_type = "Two independent samples, mean comparison",
#'   parameters = list(mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8),
#'   legacy = list(n_per_group = 37L, total_n = 74L),
#'   formula_ascii = "n = 2*((Za/2+Zb)*sd/(mean1-mean2))^2",
#'   reference = "Chow et al. (2017)"
#' )
#' stopifnot(inherits(r, "sample_size_result"))
new_sample_size_result <- function(design,
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
                                   calculation_steps = NULL) {
  results <- legacy

  # Derive canonical fields from the first matching legacy field
  for (canonical in names(ssr_canonical_map)) {
    legacy_names <- ssr_canonical_map[[canonical]]
    for (nm in legacy_names) {
      if (is.null(results[[canonical]]) && !is.null(legacy[[nm]])) {
        results[[canonical]] <- legacy[[nm]]
        break
      }
    }
  }

  calc_steps <- calculation %||% calculation_steps
  if (is.null(calc_steps)) {
    calc_steps <- generate_calculation_steps(list(
      design = design,
      task = task,
      outcome = outcome,
      design_type = design_type,
      parameters = parameters,
      results = results,
      formula = formula_ascii,
      formula_latex = formula_latex,
      adjustments = adjustments,
      legacy = legacy,
      reference = reference,
      roles = roles
    ))
  }

  structure(
    list(
      design = design,
      task = task,
      outcome = outcome,
      design_type = design_type,
      parameters = parameters,
      results = results,
      formula = formula_ascii,
      formula_latex = formula_latex,
      calculation = calc_steps,
      calculation_steps = calc_steps,
      reference = reference,
      roles = roles,
      adjustments = adjustments,
      hints = hints,
      # Legacy top-level fields (print/summary/plot and user code rely on these)
      n_per_group = legacy$n_per_group,
      total_n = legacy$total_n,
      n_required = legacy$n_required,
      n_sensitivity = legacy$n_sensitivity,
      n_specificity = legacy$n_specificity,
      n_exposed = legacy$n_exposed,
      n_unexposed = legacy$n_unexposed,
      person_time_exposed = legacy$person_time_exposed,
      person_time_unexposed = legacy$person_time_unexposed,
      expected_events = legacy$expected_events,
      n_pairs = legacy$n_pairs,
      n_clusters = legacy$n_clusters,
      n_time_points = legacy$n_time_points,
      n_stage_1 = legacy$n_stage_1,
      r_stage_1 = legacy$r_stage_1,
      n_total = legacy$n_total,
      r_total = legacy$r_total,
      events_required = legacy$events_required,
      power_achieved = legacy$power_achieved,
      person_time_required = legacy$person_time_required,
      epp = legacy$epp,
      pairs_count = legacy$pairs_count,
      total_individuals = legacy$total_individuals,
      target_events_needed = legacy$target_events_needed,
      target_state_cases_needed = legacy$target_state_cases_needed,
      total_subjects_to_screen = legacy$total_subjects_to_screen,
      cases_needed = legacy$cases_needed,
      controls_needed = legacy$controls_needed,
      total_subjects = legacy$total_subjects,
      recommended_cases = legacy$recommended_cases,
      critical_successes = legacy$critical_successes,
      actual_alpha = legacy$actual_alpha,
      actual_power = legacy$actual_power
    ),
    class = c("sample_size_result", "list")
  )
}

#' Validate a sample_size_result object
#'
#' @param x Object to validate; must inherit "sample_size_result" and carry
#'   at least `design`, `design_type`, and `parameters` fields; `task` and
#'   `outcome` (if present) must be character scalars.
#' @return Invisible TRUE, or aborts with a structured error
#' @keywords internal
#' @examples
#' r <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' sampleSizeCalc:::validate_sample_size_result(r)  # invisible TRUE
validate_sample_size_result <- function(x) {
  if (!inherits(x, "sample_size_result")) {
    cli::cli_abort(c(
      "{.arg x} must be a {.cls sample_size_result} object.",
      "x" = "You provided {.cls {class(x)}}."
    ))
  }

  required <- c("design", "design_type", "parameters")
  missing <- setdiff(required, names(x))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "{.arg x} is missing required fields: {.val {missing}}.",
      "i" = "Construct results with the internal constructor."
    ))
  }

  # Axis metadata is required for new-style objects; legacy results from the
  # pre-3.0 code path carry only the fields below, so validate when present.
  for (axis in c("task", "outcome")) {
    if (!is.null(x[[axis]]) && !is.character(x[[axis]])) {
      cli::cli_abort(c(
        "{.field {axis}} must be a single character value.",
        "x" = "You provided {.cls {class(x[[axis]])}}."
      ))
    }
  }

  if (!is.null(x$roles) && !is.character(x$roles)) {
    cli::cli_abort(c(
      "{.field roles} must be a character vector.",
      "x" = "You provided {.cls {class(x$roles)}}."
    ))
  }

  invisible(TRUE)
}

#' Assert an object is a valid sample_size_result
#'
#' @param x Object to assert; see [validate_sample_size_result()] for the
#'   required structure.
#' @return Invisibly returns x
#' @keywords internal
#' @examples
#' r <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' sampleSizeCalc:::assert_sample_size_result(r)
#' @keywords internal
assert_sample_size_result <- function(x) {
  validate_sample_size_result(x)
  invisible(x)
}
