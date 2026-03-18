# Sample Size Calculator for Clinical Research (sampleSizeCalc)
# Main entry point with backward compatibility

#' Sample size calculator for clinical study designs
#'
#' Computes sample size (or events) for two-group or single-group designs:
#' continuous outcomes, proportions, survival (log-rank), diagnostic accuracy,
#' case-control, AUC comparisons, non-inferiority/superiority/equivalence.
#' Uses parameter validation and unified S3 result objects.
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
    design = c("twoMeans", "twoProportions", "pairedMeans",
               "survival", "nonInferiorityMeans", "superiorityMeans",
               "equivalenceMeans", "diagnosticAccuracySingle",
               "caseControl", "superiorityProportions",
               "diagnosticSuperioritySingle", "diagnosticComparisonTwo",
               "likelihoodRatioTest", "auc_single", "aucSuperiority",
               "aucComparison", "equivalenceProportions"),
    alpha = 0.05,
    power = 0.8,
    ...
) {
  design <- rlang::arg_match(design)
  alpha <- validate_alpha(alpha)
  power <- validate_power(power)

  args <- list(...)
  args <- validate_design_args(design, args)

  # Route to appropriate modular calculation function
  calcResult <- switch(design,
    # Drug trial designs - Basic
    "twoMeans" = calculate_two_means(
      mean1 = args$mean1,
      mean2 = args$mean2,
      sd = args$sd,
      alpha = alpha,
      power = power
    ),

    "twoProportions" = calculate_two_proportions(
      p1 = args$p1,
      p2 = args$p2,
      alpha = alpha,
      power = power
    ),

    "pairedMeans" = calculate_paired_means(
      meanDiff = args$meanDiff,
      sdDiff = args$sdDiff,
      alpha = alpha,
      power = power
    ),

    "survival" = calculate_survival(
      hr = args$hr,
      pE = args$pE,
      alpha = alpha,
      power = power
    ),

    # Drug trial designs - Hypothesis tests (means)
    "nonInferiorityMeans" = calculate_non_inferiority_means(
      mean1 = args$mean1,
      mean2 = args$mean2,
      sd = args$sd,
      margin = args$margin,
      alpha = alpha,
      power = power
    ),

    "superiorityMeans" = calculate_superiority_means(
      mean1 = args$mean1,
      mean2 = args$mean2,
      sd = args$sd,
      margin = args$margin,
      alpha = alpha,
      power = power
    ),

    "equivalenceMeans" = calculate_equivalence_means(
      mean1 = args$mean1,
      mean2 = args$mean2,
      sd = args$sd,
      margin = args$margin,
      alpha = alpha,
      power = power
    ),

    # Drug trial designs - Hypothesis tests (proportions)
    "superiorityProportions" = calculate_superiority_proportions(
      p1 = args$p1,
      p2 = args$p2,
      margin = args$margin,
      alpha = alpha,
      power = power
    ),

    "equivalenceProportions" = calculate_equivalence_proportions(
      p1 = args$p1,
      p2 = args$p2,
      margin = args$margin,
      alpha = alpha,
      power = power
    ),

    # Case-control
    "caseControl" = calculate_case_control(
      p0 = args$p0,
      OR = args$OR,
      m = args$m,
      alpha = alpha,
      power = power
    ),

    # Diagnostic designs
    "diagnosticAccuracySingle" = calculate_diagnostic_accuracy_single(
      prob = args$prob,
      d = args$d,
      prevalence = args$prevalence,
      alpha = alpha
    ),

    "diagnosticSuperioritySingle" = calculate_diagnostic_superiority_single(
      prob = args$prob,
      p0 = args$p0,
      prevalence = args$prevalence,
      alpha = alpha,
      power = power
    ),

    "diagnosticComparisonTwo" = calculate_diagnostic_comparison_two(
      p1 = args$p1,
      p2 = args$p2,
      prevalence = args$prevalence,
      paired = args$paired,
      psi = args$psi,
      alpha = alpha,
      power = power
    ),

    "likelihoodRatioTest" = calculate_likelihood_ratio_test(
      sens = args$sens,
      spec = args$spec,
      prevalence = args$prevalence,
      precision = args$precision,
      alpha = alpha
    ),

    "auc_single" = calculate_auc_single(
      auc = args$auc,
      d = args$d,
      prevalence = args$prevalence,
      alpha = alpha
    ),

    "aucSuperiority" = calculate_auc_superiority(
      auc = args$auc,
      auc0 = args$auc0,
      prevalence = args$prevalence,
      alpha = alpha,
      power = power
    ),

    "aucComparison" = calculate_auc_comparison(
      auc1 = args$auc1,
      auc2 = args$auc2,
      r = args$r,
      prevalence = args$prevalence,
      alpha = alpha,
      power = power
    )
  )

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
