# Case-control study calculation

#' Case-control study calculation
#'
#' @param p0 Proportion in controls (exposure)
#' @param OR Odds ratio
#' @param m Matching ratio (controls:cases)
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_case_control <- function(p0, OR, m, alpha, power) {
  m_val <- if (is.null(m)) 1 else m
  p1 <- (OR * p0) / (1 - p0 + OR * p0)
  pBar <- (p1 + m_val * p0) / (1 + m_val)
  zAlphaHalf <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)
  nCases <- ((zAlphaHalf * sqrt((1 + 1 / m_val) * pBar * (1 - pBar)) + zBeta * sqrt(p1 * (1 - p1) + p0 * (1 - p0) / m_val)) / (p1 - p0))^2

  list(
    design_type = "Case-control",
    cases_needed = ceiling(nCases),
    controls_needed = ceiling(nCases * m_val),
    total_subjects = ceiling(nCases) * (1 + m_val),
    parameters = list(
      p0 = p0,
      odds_ratio = OR,
      matching_ratio = m_val,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n_{cases} = \\frac{\\left[Z_{\\alpha/2}\\sqrt{(1+1/m)\\bar{p}(1-\\bar{p})} + Z_{\\beta}\\sqrt{p_1(1-p_1) + p_0(1-p_0)/m}\\right]^2}{(p_1-p_0)^2}$$",
    reference = "Primary: Schlesselman, J. J. (1982). Case-control studies: Design, conduct, analysis. Oxford University Press.\n\nIARC Classic: Breslow, N. E., & Day, N. E. (1980). Statistical methods in cancer research: Volume 1 - The analysis of case-control studies. IARC Scientific Publications No. 32.\n\nAlternative: Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168."
  )
}
