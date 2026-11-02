# AUC-related diagnostic design calculations

#' AUC single test calculation
#'
#' @param auc Expected AUC value
#' @param d Desired precision
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @return List with calculation results
#' @keywords internal
calculate_auc_single <- function(auc, d, prevalence, alpha) {
  A <- auc
  Q1 <- A / (2 - A)
  Q2 <- (2 * A^2) / (1 + A)
  pDis <- if (is.null(prevalence)) 1 else prevalence
  K <- (1 - pDis) / pDis
  zAlphaHalf <- qnorm(1 - alpha / 2)
  V_factor <- (A * (1 - A) + (1 / K) * (Q1 - A^2) + (1) * (Q2 - A^2))
  nCases <- (zAlphaHalf / d)^2 * V_factor
  nSubjects <- nCases / pDis

  list(
    design_type = "Single-group AUC CI precision",
    target_state_cases_needed = ceiling(nCases),
    total_subjects_to_screen = ceiling(nSubjects),
    parameters = list(
      auc = A,
      precision = d,
      prevalence = pDis,
      alpha = alpha
    ),
    formula = "N_cases = (Z_1-a/2 / d)^2 * Var(AUC)",
    formula_latex = "$$n_{cases} = \\left(\\frac{Z_{1-\\alpha/2}}{d}\\right)^2 \\cdot Var(AUC)$$",
    reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
  )
}

#' AUC superiority test calculation
#'
#' @param auc Expected AUC value
#' @param auc0 Null hypothesis AUC value
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_auc_superiority <- function(auc, auc0, prevalence, alpha, power) {
  A <- auc
  A0 <- auc0
  pDis <- if (is.null(prevalence)) 1 else prevalence
  K <- (1 - pDis) / pDis
  Q1 <- A / (2 - A)
  Q2 <- (2 * A^2) / (1 + A)
  Q1_0 <- A0 / (2 - A0)
  Q2_0 <- (2 * A0^2) / (1 + A0)
  V_A <- (A * (1 - A) + (1 / K) * (Q1 - A^2) + Q2 - A^2)
  V_A0 <- (A0 * (1 - A0) + (1 / K) * (Q1_0 - A0^2) + Q2_0 - A0^2)

  zAlpha <- qnorm(1 - alpha)
  zBeta <- qnorm(power)
  nCases <- ((zAlpha * sqrt(V_A0) + zBeta * sqrt(V_A)) / (A - A0))^2

  list(
    design_type = "AUC superiority (single)",
    target_state_cases_needed = ceiling(nCases),
    total_subjects_to_screen = ceiling(nCases / pDis),
    parameters = list(
      auc = A,
      auc_null = A0,
      prevalence = pDis,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n_{cases} = \\frac{\\left(Z_{\\alpha}\\sqrt{V(AUC_0)} + Z_{\\beta}\\sqrt{V(AUC)}\\right)^2}{(AUC - AUC_0)^2}$$",
    reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
  )
}

#' AUC comparison (two tests) calculation
#'
#' @param auc1 Test 1 AUC value
#' @param auc2 Test 2 AUC value
#' @param r Correlation between tests
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_auc_comparison <- function(auc1, auc2, r, prevalence, alpha, power) {
  A1 <- auc1
  A2 <- auc2
  r_val <- r
  pDis <- if (is.null(prevalence)) 1 else prevalence
  K <- (1 - pDis) / pDis
  A_avg <- (A1 + A2) / 2
  Q1_avg <- A_avg / (2 - A_avg)
  Q2_avg <- (2 * A_avg^2) / (1 + A_avg)
  V_A <- (A_avg * (1 - A_avg) + (1 / K) * (Q1_avg - A_avg^2) + Q2_avg - A_avg^2)

  zAlphaHalf <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)
  nCases <- (2 * (zAlphaHalf + zBeta)^2 * V_A * (1 - r_val)) / (A1 - A2)^2

  list(
    design_type = "AUC comparison (two tests)",
    target_state_cases_needed = ceiling(nCases),
    total_subjects_to_screen = ceiling(nCases / pDis),
    parameters = list(
      auc1 = A1,
      auc2 = A2,
      correlation = r_val,
      prevalence = pDis,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n_{cases} = \\frac{2(Z_{\\alpha/2} + Z_{\\beta})^2 \\cdot V(AUC) \\cdot (1-r)}{(AUC_1 - AUC_2)^2}$$",
    reference = "Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
  )
}
