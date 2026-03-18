# S3 method: summary

#' Summary method for sample_size_result objects
#'
#' @param object A sample_size_result object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the input object
#' @export
summary.sample_size_result <- function(object, ...) {
  cli::cli_rule()
  cli::cli_alert_success("Sample Size Calculation Summary")
  cli::cli_rule()

  cli::cli_h3("Study Design")
  cli::cli_li("Type: {.val {object$design_type}}")

  if (!is.null(object$parameters)) {
    cli::cli_h3("Parameters")
    params <- object$parameters
    for (name in names(params)) {
      cli::cli_li("{.field {name}}: {.val {params[[name]]}}")
    }
  }

  cli::cli_h3("Sample Size Results")
  if (!is.null(object$n_per_group)) {
    cli::cli_li("Per group: {.val {object$n_per_group}}")
  }
  if (!is.null(object$total_n)) {
    cli::cli_li("Total: {.val {object$total_n}}")
  }
  if (!is.null(object$pairs_count)) {
    cli::cli_li("Pairs: {.val {object$pairs_count}}")
  }
  if (!is.null(object$target_events_needed)) {
    cli::cli_li("Events needed: {.val {object$target_events_needed}}")
  }
  if (!is.null(object$target_state_cases_needed)) {
    cli::cli_li("Target cases: {.val {object$target_state_cases_needed}}")
  }
  if (!is.null(object$total_subjects_to_screen)) {
    cli::cli_li("Subjects to screen: {.val {object$total_subjects_to_screen}}")
  }
  if (!is.null(object$cases_needed)) {
    cli::cli_li("Cases: {.val {object$cases_needed}}")
    cli::cli_li("Controls: {.val {object$controls_needed}}")
  }

  cli::cli_h3("Formula")
  if (!is.null(object$formula_latex)) {
    cat(object$formula_latex, "\n")
  }

  cli::cli_h3("Reference")
  if (!is.null(object$reference)) {
    cat(object$reference, "\n")
  }

  cli::cli_rule()
  invisible(object)
}

# Null coalescing operator (internal helper, no documentation needed)
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
