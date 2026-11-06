# sample_size_result S3 class: constructor, validator, assertion
# Storage keeps legacy top-level field names (n_per_group, total_n, ...) so
# existing print/summary/plot methods and user code keep working; new
# canonical fields (n_1, events, cases, ...) are derived automatically.

# New canonical fields derived from legacy storage fields.
# Canonical name -> legacy name(s), first match wins.
ssr_canonical_map <- list(
  n_1 = c(
    "n_exposed",
    "n_standard",
    "n_per_group",
    "pairs_count",
    "cases_needed",
    "target_state_cases_needed",
    "recommended_cases"
  ),
  n_2 = c("n_unexposed", "n_test", "n_per_group", "controls_needed"),
  total_n = c(
    "total_n",
    "n_total",
    "total_subjects",
    "total_individuals",
    "n_required"
  ),
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
#' r <- SampleSizeCalc:::new_sample_size_result(
#'   design = "rct", task = "test", outcome = "mean",
#'   design_type = "Two independent samples, mean comparison",
#'   parameters = list(mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8),
#'   legacy = list(n_per_group = 37L, total_n = 74L),
#'   formula_ascii = "n = 2*((Za/2+Zb)*sd/(mean1-mean2))^2",
#'   reference = "Chow et al. (2017)"
#' )
#' stopifnot(inherits(r, "sample_size_result"))
new_sample_size_result <- function(
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
) {
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

  result <- structure(
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
      n_per_group = legacy[["n_per_group"]],
      n_standard = legacy[["n_standard"]],
      n_test = legacy[["n_test"]],
      total_n = legacy[["total_n"]],
      n_required = legacy[["n_required"]],
      n_sensitivity = legacy[["n_sensitivity"]],
      n_specificity = legacy[["n_specificity"]],
      n_exposed = legacy[["n_exposed"]],
      n_unexposed = legacy[["n_unexposed"]],
      person_time_exposed = legacy[["person_time_exposed"]],
      person_time_unexposed = legacy[["person_time_unexposed"]],
      expected_events = legacy[["expected_events"]],
      n_pairs = legacy[["n_pairs"]],
      n_clusters = legacy[["n_clusters"]],
      n_time_points = legacy[["n_time_points"]],
      n_stage_1 = legacy[["n_stage_1"]],
      r_stage_1 = legacy[["r_stage_1"]],
      n_total = legacy[["n_total"]],
      r_total = legacy[["r_total"]],
      events_required = legacy[["events_required"]],
      power_achieved = legacy[["power_achieved"]],
      person_time_required = legacy[["person_time_required"]],
      epp = legacy[["epp"]],
      pairs_count = legacy[["pairs_count"]],
      total_individuals = legacy[["total_individuals"]],
      n_measurements = legacy[["n_measurements"]],
      power = legacy[["power"]],
      target_events_needed = legacy[["target_events_needed"]],
      target_state_cases_needed = legacy[["target_state_cases_needed"]],
      total_subjects_to_screen = legacy[["total_subjects_to_screen"]],
      cases_needed = legacy[["cases_needed"]],
      controls_needed = legacy[["controls_needed"]],
      total_subjects = legacy[["total_subjects"]],
      recommended_cases = legacy[["recommended_cases"]],
      critical_successes = legacy[["critical_successes"]],
      actual_alpha = legacy[["actual_alpha"]],
      actual_power = legacy[["actual_power"]]
    ),
    class = c("sample_size_result", "list")
  )
  validate_sample_size_result(result)
  result
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
#' SampleSizeCalc:::validate_sample_size_result(r)  # invisible TRUE
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
    if (
      !is.null(x[[axis]]) &&
        (!is.character(x[[axis]]) ||
          length(x[[axis]]) != 1L ||
          is.na(x[[axis]]))
    ) {
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

  if (!is.list(x$parameters)) {
    cli::cli_abort("{.field parameters} must be a list.")
  }
  count_fields <- c(
    "n_1",
    "n_2",
    "total_n",
    "n_required",
    "n_per_group",
    "n_standard",
    "n_test",
    "n_exposed",
    "n_unexposed",
    "n_clusters",
    "n_time_points",
    "n_stage_1",
    "n_total",
    "events",
    "events_required",
    "pairs",
    "pairs_count",
    "n_pairs",
    "total_individuals",
    "n_measurements",
    "target_events_needed",
    "target_state_cases_needed",
    "cases",
    "cases_needed",
    "controls_needed",
    "recommended_cases",
    "total_subjects",
    "total_subjects_to_screen",
    "subjects_to_screen",
    "n_sensitivity",
    "n_specificity",
    "critical_successes",
    "r_stage_1",
    "r_total"
  )
  metrics <- x$results %||% list()
  for (field in intersect(names(x), count_fields)) {
    if (!is.null(x[[field]])) {
      if (
        !is.null(metrics[[field]]) &&
          !isTRUE(all.equal(
            metrics[[field]],
            x[[field]],
            check.attributes = FALSE
          ))
      ) {
        cli::cli_abort(
          "Top-level {.field {field}} disagrees with the stored result field."
        )
      }
      metrics[[field]] <- x[[field]]
    }
  }
  for (field in intersect(names(metrics), count_fields)) {
    value <- metrics[[field]]
    if (is.null(value)) {
      next
    }
    minimum <- if (field %in% c("r_stage_1", "r_total", "critical_successes")) {
      0
    } else {
      1
    }
    if (
      !is.numeric(value) ||
        is.complex(value) ||
        length(value) != 1L ||
        !is.finite(value) ||
        value < minimum ||
        value != floor(value)
    ) {
      cli::cli_abort(
        "{.field {field}} must be a finite integer at least {.val {minimum}}."
      )
    }
  }
  for (groups in list(
    c("n_exposed", "n_unexposed"),
    c("n_standard", "n_test"),
    c("cases_needed", "controls_needed"),
    c("target_state_cases_needed", "controls_needed"),
    c("n_1", "n_2")
  )) {
    if (all(vapply(metrics[groups], is.numeric, logical(1)))) {
      expected <- sum(unlist(metrics[groups], use.names = FALSE))
      for (total in intersect(c("total_n", "total_subjects"), names(metrics))) {
        if (!is.null(metrics[[total]]) && metrics[[total]] != expected) {
          cli::cli_abort(
            "{.field {total}} must equal the sum of {.field {groups}}."
          )
        }
      }
    }
  }
  if (
    !is.null(metrics$n_per_group) &&
      !is.null(metrics$total_n) &&
      is.null(metrics$n_exposed) &&
      metrics$total_n != 2 * metrics$n_per_group
  ) {
    cli::cli_abort(
      "{.field total_n} must equal twice {.field n_per_group} for equal independent groups."
    )
  }
  for (field in c("power_achieved", "actual_alpha", "actual_power", "power")) {
    value <- x[[field]] %||% metrics[[field]]
    if (
      !is.null(value) &&
        (!is.numeric(value) ||
          length(value) != 1L ||
          !is.finite(value) ||
          value < 0 ||
          value > 1)
    ) {
      cli::cli_abort("{.field {field}} must be a finite probability in [0, 1].")
    }
  }
  if (
    all(vapply(
      metrics[c("pairs_count", "total_individuals", "n_measurements")],
      is.numeric,
      logical(1)
    ))
  ) {
    pairing <- x$parameters$pairing %||% "within_subject"
    expected_people <- metrics$pairs_count *
      if (pairing == "within_subject") 1 else 2
    if (
      metrics$total_individuals != expected_people ||
        metrics$n_measurements != 2 * metrics$pairs_count
    ) {
      cli::cli_abort("Paired result counts disagree with the pairing unit.")
    }
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
#' SampleSizeCalc:::assert_sample_size_result(r)
#' @keywords internal
assert_sample_size_result <- function(x) {
  validate_sample_size_result(x)
  invisible(x)
}
