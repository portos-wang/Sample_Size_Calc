# Module 1: Diagnostic Studies - Design Calculation Functions

# This file contains the calculation logic for diagnostic study designs.
# Each function returns a list with the standardized result structure.

#' Diagnostic accuracy (single test) calculation
#'
#' @param prob Expected accuracy (sensitivity or specificity)
#' @param d Desired precision (half-width of CI)
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @return List with calculation results
#' @keywords internal
calculate_diagnostic_accuracy_single <- function(prob, d, prevalence, alpha) {
  p_val <- prob
  d_val <- d
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  zAlphaHalf <- qnorm(1 - alpha / 2)
  nTargetCases <- (zAlphaHalf^2 * p_val * (1 - p_val)) / (d_val^2)

  list(
    design_type = "Diagnostic accuracy (single)",
    target_state_cases_needed = ceiling(nTargetCases),
    total_subjects_to_screen = ceiling(nTargetCases / prev_val),
    parameters = list(
      prob = p_val,
      precision = d_val,
      prevalence = prev_val,
      alpha = alpha
    ),
    formula = "N_cases = (Z_1-a/2)^2 * P*(1-P)/d^2",
    formula_latex = "$$n_{{{cases}}} = \\frac{Z_{1-\\alpha/2}^2 \\cdot p(1-p)}{d^2}$$",
    reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
  )
}
