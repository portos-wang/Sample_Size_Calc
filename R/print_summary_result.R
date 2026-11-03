# S3 methods: print and summary for sample_size_result objects
# Shared metric rendering (new design fields render automatically).

# Human-readable labels for all metric fields, in display order.
ssr_metric_labels <- c(
  n_required = "Required sample size",
  n_per_group = "Sample size per group",
  n_exposed = "Exposed group",
  n_unexposed = "Unexposed group",
  total_n = "Total sample size",
  n_clusters = "Clusters per arm",
  n_stage_1 = "Stage 1 sample size",
  r_stage_1 = "Stage 1 futility boundary (stop if responses <= r1)",
  n_total = "Total sample size (both stages)",
  r_total = "Overall boundary (declare effective if responses > r)",
  events_required = "Events required",
  pairs_count = "Pairs needed",
  total_individuals = "Total individuals",
  target_events_needed = "Events needed",
  target_state_cases_needed = "Cases needed",
  n_sensitivity = "N for sensitivity",
  n_specificity = "N for specificity",
  total_subjects_to_screen = "Total subjects to screen",
  cases_needed = "Cases needed",
  controls_needed = "Controls needed",
  total_subjects = "Total subjects",
  person_time_exposed = "Person-time, exposed group",
  person_time_unexposed = "Person-time, unexposed group",
  person_time_required = "Required person-time",
  expected_events = "Expected events",
  recommended_cases = "Recommended cases",
  power_achieved = "Power achieved"
)

ssr_collect_metrics <- function(x) {
  fields <- intersect(names(ssr_metric_labels), names(x))
  fields[vapply(x[fields], function(v) !is.null(v) && all(is.finite(v)), logical(1))]
}

ssr_render_metrics <- function(x, verbose = FALSE) {
  metrics <- ssr_collect_metrics(x)
  for (m in metrics) {
    cli::cli_li("{.field {ssr_metric_labels[[m]]}}: {.val {x[[m]]}}")
  }
  invisible(metrics)
}

ssr_render_meta <- function(x, verbose = FALSE) {
  if (length(x$roles) > 0) {
    cli::cli_par()
    cli::cli_text("{.emph Parameter roles}")
    for (r in x$roles) cli::cli_li("{r}")
  }
  if (verbose && length(x$adjustments) > 0) {
    cli::cli_par()
    cli::cli_text("{.emph Adjustments applied}")
    for (a in names(x$adjustments)) {
      cli::cli_li("{a}: {.val {x$adjustments[[a]]}}")
    }
  }
  if (length(x$hints) > 0) {
    cli::cli_par()
    for (h in x$hints) {
      cli::cli_alert_warning(h)
    }
  }
}

#' Print method for sample_size_result objects
#'
#' Displays the study design, sample size metrics, plain-text formula,
#' LaTeX source, calculation process, and literature references. Parameter
#' roles and methodological hints are included where available.
#'
#' @param x A sample_size_result object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the input object
#' @examples
#' # Antihypertensive RCT: 37 patients per arm with these assumptions
#' res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' print(res)   # sample sizes, both formulas, calculation process, references
#' @export
print.sample_size_result <- function(x, ...) {
  cli::cli_rule()
  cli::cli_alert_success("Sample Size Calculation Results")
  cli::cli_li("Design type: {.val {x$design_type}}")
  ssr_render_metrics(x)
  ssr_render_meta(x, verbose = FALSE)

  # 1. Formula (plain text)
  if (!is.null(x$formula) && nzchar(x$formula)) {
    cli::cli_par()
    cli::cli_text("{.strong Formula (plain text)}:")
    cli::cli_text("{.code {x$formula}}")
  }

  # 2. Formula (LaTeX)
  if (!is.null(x$formula_latex) && nzchar(x$formula_latex)) {
    cli::cli_par()
    cli::cli_text("{.strong Formula (LaTeX)}:")
    cat(x$formula_latex, "\n")
  }

  # 3. Calculation process
  calc_proc <- ssr_get_calculation(x)
  if (!is.null(calc_proc) && length(calc_proc) > 0) {
    cli::cli_par()
    cli::cli_text("{.strong Calculation process}:")
    for (step in calc_proc) {
      cli::cli_li("{step}")
    }
  }

  # 4. Reference
  if (!is.null(x$reference) && nzchar(x$reference)) {
    cli::cli_par()
    cli::cli_text("{.strong Reference}:")
    cat(x$reference, "\n")
  }

  cli::cli_rule()
  invisible(x)
}

#' Summary method for sample_size_result objects
#'
#' Includes the plain-text formula, LaTeX source, calculation process, and
#' references shown by [print.sample_size_result()], with all input
#' parameters, design axes, and recorded adjustments.
#'
#' @param object A sample_size_result object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the input object
#' @examples
#' # Full protocol-ready report for the antihypertensive RCT:
#' res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' summary(res)  # also lists all inputs, design axes, and adjustments
#' @export
summary.sample_size_result <- function(object, ...) {
  cli::cli_rule()
  cli::cli_alert_success("Sample Size Calculation Summary")
  cli::cli_rule()

  cli::cli_h3("Study Design")
  cli::cli_li("Type: {.val {object$design_type}}")
  if (!is.null(object$design_canonical)) {
    cli::cli_li("Design: {.val {object$design_canonical}}")
  }
  if (!is.null(object$task)) {
    cli::cli_li("Task: {.val {object$task}} | Outcome: {.val {object$outcome}}")
  }

  if (!is.null(object$parameters) && length(object$parameters) > 0) {
    cli::cli_h3("Parameters")
    params <- object$parameters
    for (name in names(params)) {
      val <- params[[name]]
      if (length(val) > 3) {
        val <- paste0("[", paste(round(val, 4), collapse = ", "), "]")
      }
      cli::cli_li("{.field {name}}: {.val {val}}")
    }
  }

  cli::cli_h3("Sample Size Results")
  ssr_render_metrics(object)

  ssr_render_meta(object, verbose = TRUE)

  cli::cli_h3("Formula")
  if (!is.null(object$formula) && nzchar(object$formula)) {
    cli::cli_text("{.strong Plain text}:")
    cli::cli_text("{.code {object$formula}}")
  }
  if (!is.null(object$formula_latex) && nzchar(object$formula_latex)) {
    cli::cli_text("{.strong LaTeX}:")
    cat(object$formula_latex, "\n")
  }

  cli::cli_h3("Calculation Process")
  calc_proc <- ssr_get_calculation(object)
  if (!is.null(calc_proc) && length(calc_proc) > 0) {
    for (step in calc_proc) {
      cli::cli_li("{step}")
    }
  }

  cli::cli_h3("Reference")
  if (!is.null(object$reference)) {
    cat(object$reference, "\n")
  }

  cli::cli_rule()
  invisible(object)
}
