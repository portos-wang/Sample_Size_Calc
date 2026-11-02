#' Diagnostic superiority (single test) calculation
#'
#' @param prob Expected accuracy
#' @param p0 Null hypothesis accuracy
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @name calculate_diagnostic_superiority_single
#' @keywords internal
calculate_diagnostic_superiority_single <- function(prob, p0, prevalence, alpha, power) {
  p_val <- prob
  p0_val <- p0
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  zAlpha <- qnorm(1 - alpha)
  zBeta <- qnorm(power)
  nTargetCases <- ((zAlpha * sqrt(p0_val * (1 - p0_val)) + zBeta * sqrt(p_val * (1 - p_val))) / (p_val - p0_val))^2

  list(
    design_type = "Diagnostic superiority (single)",
    target_state_cases_needed = ceiling(nTargetCases),
    total_subjects_to_screen = ceiling(nTargetCases / prev_val),
    parameters = list(
      prob = p_val,
      p0 = p0_val,
      prevalence = prev_val,
      alpha = alpha,
      power = power
    ),
    formula = "N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 / (P-P0)^2",
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p(1-p)}\\right]^2}{(p - p_0)^2}$$",
    reference = "Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
  )
}

#' Diagnostic comparison (two tests) calculation
#'
#' @param p1 Test 1 accuracy
#' @param p2 Test 2 accuracy
#' @param prevalence Disease prevalence
#' @param paired Paired design?
#' @param psi Discordant pair proportion (for paired design)
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_diagnostic_comparison_two <- function(p1, p2, prevalence, paired, psi, alpha, power) {
  p1_val <- p1
  p2_val <- p2
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  paired_val <- paired
  psi_val <- psi

  zAlphaHalf <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)

  if (paired_val) {
    if (is.null(psi_val)) {
      cli::cli_abort(c(
        "Paired comparison requires {.arg psi} parameter.",
        "i" = "psi represents discordant pair proportion."
      ))
    }
    nTargetCases <- ((zAlphaHalf * psi_val + zBeta * sqrt(psi_val^2 - (p1_val - p2_val)^2 / 4)) / (p1_val - p2_val))^2
  } else {
    pBar <- (p1_val + p2_val) / 2
    nTargetCases <- ((zAlphaHalf * sqrt(2 * pBar * (1 - pBar)) + zBeta * sqrt(p1_val * (1 - p1_val) + p2_val * (1 - p2_val))) / (p1_val - p2_val))^2
  }

  list(
    design_type = "Two diagnostic measures",
    target_state_cases_needed = ceiling(nTargetCases),
    total_subjects_to_screen = ceiling(nTargetCases / prev_val * ifelse(paired_val, 1, 2)),
    parameters = list(
      p1 = p1_val,
      p2 = p2_val,
      prevalence = prev_val,
      paired = paired_val,
      psi = psi_val,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sigma_{paired} + Z_{\\beta}\\sqrt{\\sigma_{paired}^2 - (p_1-p_2)^2/4}\\right]^2}{(p_1-p_2)^2}$$",
    reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
  )
}

#' Likelihood ratio test calculation
#'
#' @param sens Expected sensitivity
#' @param spec Expected specificity
#' @param prevalence Disease prevalence
#' @param precision Desired precision
#' @param alpha Type I error
#' @return List with calculation results
#' @keywords internal
calculate_likelihood_ratio_test <- function(sens, spec, prevalence, precision, alpha) {
  precision_val <- if (is.null(precision)) 0.1 else precision

  zAlphaHalf <- qnorm(1 - alpha / 2)
  pDis <- if (is.null(prevalence)) 1 else prevalence
  pNon <- 1 - pDis

  minCases <- max(
    (zAlphaHalf^2 * sens * (1 - sens)) / (precision_val)^2,
    (zAlphaHalf^2 * spec * (1 - spec)) / (precision_val)^2 * (pDis / pNon)
  )

  list(
    design_type = "Likelihood ratio (min sample size)",
    recommended_cases = ceiling(minCases),
    total_subjects_to_screen = ceiling(minCases / pDis),
    parameters = list(
      sensitivity = sens,
      specificity = spec,
      prevalence = pDis,
      precision = precision_val,
      alpha = alpha
    ),
    formula_latex = sprintf("$$n_{cases} = \\max\\left\\{\\frac{Z_{1-\\alpha/2}^2 \\cdot Se(1-Se)}{%.2f^2}, \\frac{Z_{1-\\alpha/2}^2 \\cdot Sp(1-Sp)}{%.2f^2} \\cdot \\frac{P}{1-P}\\right\\}$$", precision_val, precision_val),
    reference = "Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
  )
}
