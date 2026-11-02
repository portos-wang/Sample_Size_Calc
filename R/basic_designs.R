# Module 2: Drug Trials - Basic Design Calculations

#' Two independent means comparison calculation
#'
#' @param mean1 Group 1 mean
#' @param mean2 Group 2 mean
#' @param sd Common standard deviation
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_two_means <- function(mean1, mean2, sd, alpha, power) {
  result <- power.t.test(
    n = NULL,
    delta = abs(mean1 - mean2),
    sd = sd,
    sig.level = alpha,
    power = power,
    type = "two.sample",
    alternative = "two.sided"
  )

  list(
    design_type = "Two independent samples, mean comparison",
    n_per_group = ceiling(result$n),
    total_n = ceiling(result$n) * 2,
    parameters = list(
      mean1 = mean1,
      mean2 = mean2,
      sd = sd,
      alpha = alpha,
      power = power
    ),
    formula = "n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2",
    formula_latex = "$$n = 2\\left(\\frac{Z_{\\alpha/2} + Z_{\\beta}}{\\delta}\\right)^2 = 2\\left(\\frac{(Z_{\\alpha/2} + Z_{\\beta}) \\cdot \\sigma}{\\mu_1 - \\mu_2}\\right)^2$$",
    reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
  )
}

#' Two independent proportions comparison calculation
#'
#' @param p1 Group 1 proportion
#' @param p2 Group 2 proportion
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_two_proportions <- function(p1, p2, alpha, power) {
  result <- power.prop.test(
    n = NULL,
    p1 = p1,
    p2 = p2,
    sig.level = alpha,
    power = power,
    alternative = "two.sided"
  )

  list(
    design_type = "Two independent proportions",
    n_per_group = ceiling(result$n),
    total_n = ceiling(result$n) * 2,
    parameters = list(
      p1 = p1,
      p2 = p2,
      alpha = alpha,
      power = power
    ),
    formula = "n = (Z_a/2 * sqrt(2*p_bar*(1-p_bar)) + Z_b * sqrt(p1*(1-p1)+p2*(1-p2)))^2 / (p1-p2)^2",
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{2\\bar{p}(1-\\bar{p})} + Z_{\\beta}\\sqrt{p_1(1-p_1) + p_2(1-p_2)}\\right]^2}{(p_1 - p_2)^2}$$",
    reference = "Primary (formula as implemented, without continuity correction): Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346.\n\nWith continuity correction: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-494.\n\nBook: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley."
  )
}

#' Paired means comparison calculation
#'
#' @param meanDiff Mean difference
#' @param sdDiff Standard deviation of differences
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_paired_means <- function(meanDiff, sdDiff, alpha, power) {
  result <- power.t.test(
    n = NULL,
    delta = abs(meanDiff),
    sd = sdDiff,
    sig.level = alpha,
    power = power,
    type = "paired",
    alternative = "two.sided"
  )

  list(
    design_type = "Paired means",
    pairs_count = ceiling(result$n),
    total_individuals = ceiling(result$n) * 2,
    parameters = list(
      mean_diff = meanDiff,
      sd_diff = sdDiff,
      alpha = alpha,
      power = power
    ),
    formula = "n = ((Z_a/2 + Z_b) * sd_diff / mean_diff)^2",
    formula_latex = "$$n = \\left(\\frac{(Z_{\\alpha/2} + Z_{\\beta}) \\cdot \\sigma_d}{\\mu_d}\\right)^2$$",
    reference = "Rosner, B. (2015). *Fundamentals of biostatistics* (8th ed.). Cengage Learning."
  )
}

#' Survival analysis (log-rank test) calculation
#'
#' @param hr Hazard ratio
#' @param pE Allocation ratio (experimental arm)
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_survival <- function(hr, pE, alpha, power) {
  pE_val <- if (is.null(pE)) 0.5 else pE
  zAlpha <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)
  totalEventsNeeded <- ((zAlpha + zBeta)^2) / ((pE_val * (1 - pE_val)) * (log(hr)^2))

  list(
    design_type = "Survival (log-rank)",
    target_events_needed = ceiling(totalEventsNeeded),
    parameters = list(
      hazard_ratio = hr,
      allocation_ratio = pE_val,
      alpha = alpha,
      power = power
    ),
    formula = "E = (Z_a/2 + Z_b)^2 / (pE*(1-pE)*log(HR)^2)",
    formula_latex = "$$E = \\frac{(Z_{\\alpha/2} + Z_{\\beta})^2}{p_E(1-p_E)[\\ln(HR)]^2}$$",
    reference = "Primary: Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. Biometrics, 39(2), 499-503.\n\nExtensions:\n- Hsieh, F. Y., & Lavori, P. W. (2000). Sample-size calculations for the Cox proportional hazards regression model with nonbinary covariates. Controlled Clinical Trials, 21(6), 552-560.\n- Rubinstein, L. V., Gail, M. H., & Santner, T. J. (1981). Planning the duration of a comparative clinical trial with loss to follow-up and a period of continued observation. Journal of Chronic Diseases, 34(9-10), 469-479."
  )
}
