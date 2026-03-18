# Non-inferiority, Superiority, and Equivalence tests for means

#' Non-inferiority test (means) calculation
#'
#' @param mean1 Group 1 mean
#' @param mean2 Group 2 mean
#' @param sd Common standard deviation
#' @param margin Non-inferiority margin
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_non_inferiority_means <- function(mean1, mean2, sd, margin, alpha, power) {
  zAlpha <- qnorm(1 - alpha)
  zBeta <- qnorm(power)
  deltaE <- mean1 - mean2 + margin

  if (deltaE <= 0) {
    cli::cli_abort(c(
      "Non-inferiority margin not met.",
      "x" = "mean1 - mean2 + margin = {.val {deltaE}} <= 0",
      "i" = "The effect size must be positive for non-inferiority."
    ))
  }

  nPerGroup <- 2 * (zAlpha + zBeta)^2 * (sd^2) / (deltaE^2)

  list(
    design_type = "Non-inferiority (means)",
    n_per_group = ceiling(nPerGroup),
    total_n = ceiling(nPerGroup) * 2,
    parameters = list(
      mean1 = mean1,
      mean2 = mean2,
      sd = sd,
      margin = margin,
      alpha = alpha,
      power = power
    ),
    formula = "n = 2*(Z_a+Z_b)^2*sd^2/(mean1-mean2+margin)^2",
    formula_latex = "$$n = 2\\left(\\frac{(Z_{\\alpha} + Z_{\\beta})\\sigma}{\\mu_1 - \\mu_2 + \\Delta}\\right)^2$$",
    reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
  )
}

#' Superiority test (means) calculation
#'
#' @param mean1 Group 1 mean
#' @param mean2 Group 2 mean
#' @param sd Common standard deviation
#' @param margin Superiority margin
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_superiority_means <- function(mean1, mean2, sd, margin, alpha, power) {
  zAlpha <- qnorm(1 - alpha)
  zBeta <- qnorm(power)
  deltaE <- mean1 - mean2 - margin

  if (deltaE <= 0) {
    cli::cli_abort(c(
      "Superiority margin not met.",
      "x" = "mean1 - mean2 - margin = {.val {deltaE}} <= 0",
      "i" = "The effect size must be positive for superiority."
    ))
  }

  nPerGroup <- 2 * (zAlpha + zBeta)^2 * (sd^2) / (deltaE^2)

  list(
    design_type = "Superiority (means)",
    n_per_group = ceiling(nPerGroup),
    total_n = ceiling(nPerGroup) * 2,
    parameters = list(
      mean1 = mean1,
      mean2 = mean2,
      sd = sd,
      margin = margin,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n = 2\\left(\\frac{(Z_{\\alpha} + Z_{\\beta})\\sigma}{\\mu_1 - \\mu_2 - \\Delta}\\right)^2$$",
    reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
  )
}

#' Equivalence test (means) calculation
#'
#' @param mean1 Group 1 mean
#' @param mean2 Group 2 mean
#' @param sd Common standard deviation
#' @param margin Equivalence margin
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_equivalence_means <- function(mean1, mean2, sd, margin, alpha, power) {
  zAlpha <- qnorm(1 - alpha)
  zBetaHalf <- qnorm(1 - (1 - power) / 2)
  diff <- abs(mean1 - mean2)

  if (margin <= diff) {
    cli::cli_abort(c(
      "Equivalence margin must be greater than the mean difference.",
      "x" = "margin ({.val {margin}}) <= |mean1 - mean2| ({.val {diff}})",
      "i" = "Increase the margin or adjust the means."
    ))
  }

  nPerGroup <- 2 * (zAlpha + zBetaHalf)^2 * (sd^2) / ((margin - diff)^2)

  list(
    design_type = "Equivalence (means)",
    n_per_group = ceiling(nPerGroup),
    total_n = ceiling(nPerGroup) * 2,
    parameters = list(
      mean1 = mean1,
      mean2 = mean2,
      sd = sd,
      margin = margin,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n = 2\\left(\\frac{(Z_{\\alpha} + Z_{\\beta/2})\\sigma}{\\Delta - |\\mu_1 - \\mu_2|}\\right)^2$$",
    reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
  )
}
