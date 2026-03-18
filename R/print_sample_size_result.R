# S3 method: print

#' Print method for sample_size_result objects
#'
#' @param x A sample_size_result object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the input object
#' @export
print.sample_size_result <- function(x, ...) {
  cli::cli_rule()
  cli::cli_alert_success("Sample Size Calculation Results")
  cli::cli_li("Design type: {.val {x$design_type}}")

  if (!is.null(x$n_per_group)) {
    cli::cli_li("Sample size per group: {.val {x$n_per_group}}")
  }
  if (!is.null(x$total_n)) {
    cli::cli_li("Total sample size: {.val {x$total_n}}")
  }
  if (!is.null(x$pairs_count)) {
    cli::cli_li("Pairs needed: {.val {x$pairs_count}}")
  }
  if (!is.null(x$target_events_needed)) {
    cli::cli_li("Target events needed: {.val {x$target_events_needed}}")
  }
  if (!is.null(x$target_state_cases_needed)) {
    cli::cli_li("Target state cases: {.val {x$target_state_cases_needed}}")
  }
  if (!is.null(x$total_subjects_to_screen)) {
    cli::cli_li("Total subjects to screen: {.val {x$total_subjects_to_screen}}")
  }
  if (!is.null(x$cases_needed)) {
    cli::cli_li("Cases needed: {.val {x$cases_needed}}")
    cli::cli_li("Controls needed: {.val {x$controls_needed}}")
  }

  cli::cli_rule()
  invisible(x)
}
