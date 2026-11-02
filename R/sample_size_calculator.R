# Legacy entry point: silently compatible shim over calculate().
# The 17 keywords map to the three-axis API as documented in
# docs/DESIGN_MATRIX.md; dispatch_calculation() shares one code path so
# legacy and new calls produce identical results (golden master tests).

#' Sample size calculator for clinical study designs (legacy API)
#'
#' Computes sample size (or events) for two-group or single-group designs:
#' continuous outcomes, proportions, survival (log-rank), diagnostic accuracy,
#' case-control, AUC comparisons, non-inferiority/superiority/equivalence.
#' Uses parameter validation and unified S3 result objects.
#'
#' `sample_size_calculator()` is the legacy single-keyword API retained for
#' backward compatibility. New code should prefer the three-axis
#' [calculate()] entry point; see docs/DESIGN_MATRIX.md for the keyword
#' mapping. Results are identical between the two entry points.
#'
#' @param design Study design type (see list in usage).
#' @param alpha Type I error (default 0.05).
#' @param power Target power (default 0.8).
#' @param ... Design-specific arguments (e.g. mean1, mean2, sd for twoMeans).
#'
#' @return Object of class \code{sample_size_result} with \code{print}, \code{summary}, \code{plot} methods.
#'
#' @importFrom stats power.t.test power.prop.test qnorm
#' @export
#'
#' @examples
#' sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
#' sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
sample_size_calculator <- function(
  design = c(
    "twoMeans", "twoProportions", "pairedMeans",
    "survival", "nonInferiorityMeans", "superiorityMeans",
    "equivalenceMeans", "diagnosticAccuracySingle",
    "caseControl", "superiorityProportions",
    "diagnosticSuperioritySingle", "diagnosticComparisonTwo",
    "likelihoodRatioTest", "auc_single", "aucSuperiority",
    "aucComparison", "equivalenceProportions"
  ),
  alpha = 0.05,
  power = 0.8,
  ...
) {
  design <- rlang::arg_match(design)
  alpha <- validate_alpha(alpha)
  power <- validate_power(power)

  args <- validate_design_args(design, list(...))
  calcResult <- dispatch_calculation(design, args, alpha, power, path = "legacy")
  calcResult$replay_args <- args

  calcResult$design <- design
  structure(calcResult, class = c("sample_size_result", "list"))
}

# Back-compatibility wrapper

#' @describeIn sample_size_calculator Deprecated alias; use \code{sample_size_calculator}.
#' @export
sampleSizeCalculator <- function(design, alpha = 0.05, power = 0.8, ...) {
  cli::cli_warn(c(
    "{.fn sampleSizeCalculator} is deprecated as of version 2.0.0.",
    "i" = "Please use {.fn sample_size_calculator} instead.",
    ">" = "This function will be removed in a future version."
  ))

  sample_size_calculator(design = design, alpha = alpha, power = power, ...)
}
