# Non-inferiority, Superiority, and Equivalence tests for proportions

#' Superiority test (proportions) calculation
#'
#' @param p1 Group 1 proportion
#' @param p2 Group 2 proportion
#' @param margin Superiority margin
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_superiority_proportions <- function(p1, p2, margin, alpha, power) {
  zAlpha <- qnorm(1 - alpha)
  zBeta <- qnorm(power)
  deltaE <- p1 - p2 - margin

  if (deltaE <= 0) {
    cli::cli_abort(c(
      "Superiority margin not met.",
      "x" = "p1 - p2 - margin = {.val {deltaE}} <= 0",
      "i" = "The effect size must be positive for superiority."
    ))
  }

  nPerGroup <- (zAlpha + zBeta)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / (deltaE^2)

  list(
    design_type = "Superiority (proportions)",
    n_per_group = ceiling(nPerGroup),
    total_n = ceiling(nPerGroup) * 2,
    parameters = list(
      p1 = p1,
      p2 = p2,
      margin = margin,
      alpha = alpha,
      power = power
    ),
    formula = "n = (Z_alpha + Z_beta)^2 * (p1*(1-p1) + p2*(1-p2)) / (p1 - p2 - margin)^2",
    formula_latex = "$$n = \\frac{(Z_{\\alpha} + Z_{\\beta})^2[p_1(1-p_1) + p_2(1-p_2)]}{(p_1 - p_2 - \\Delta)^2}$$",
    reference = paste(
      "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size",
      "Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 4",
      "(Large Sample Tests for Proportions), Section 4.2.2 noninferiority/",
      "superiority, Eq 4.8 (p. 78).\n\n",
      "Also: Machin et al. (2018) Eq 11.5-11.6, p. 174; Fleiss, Tytun & Ury",
      "(1980), Biometrics 36(2), 343-346."
    )
  )
}

#' Equivalence test (proportions) calculation
#'
#' @param p1 Group 1 proportion
#' @param p2 Group 2 proportion
#' @param margin Equivalence margin
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_equivalence_proportions <- function(p1, p2, margin, alpha, power) {
  zAlpha <- qnorm(1 - alpha)
  zBetaHalf <- qnorm(1 - (1 - power) / 2)
  diff <- abs(p1 - p2)

  if (margin <= diff) {
    cli::cli_abort(c(
      "Equivalence margin must be greater than the proportion difference.",
      "x" = "margin ({.val {margin}}) <= |p1 - p2| ({.val {diff}})",
      "i" = "Increase the margin or adjust the proportions."
    ))
  }

  nPerGroup <- (zAlpha + zBetaHalf)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / ((margin - diff)^2)

  list(
    design_type = "Equivalence (proportions)",
    n_per_group = ceiling(nPerGroup),
    total_n = ceiling(nPerGroup) * 2,
    parameters = list(
      p1 = p1,
      p2 = p2,
      margin = margin,
      alpha = alpha,
      power = power
    ),
    formula = "n = (Z_alpha + Z_beta/2)^2 * (p1*(1-p1) + p2*(1-p2)) / (margin - |p1 - p2|)^2",
    formula_latex = "$$n = \\frac{(Z_{\\alpha} + Z_{\\beta/2})^2[p_1(1-p_1) + p_2(1-p_2)]}{(\\Delta - |p_1-p_2|)^2}$$",
    reference = paste(
      "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size",
      "Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 4",
      "(Large Sample Tests for Proportions), Section 4.2.3 equivalence, Eq 4.9",
      "(p. 79).\n\n",
      "Also: Machin et al. (2018) Eq 11.5-11.6, p. 174."
    )
  )
}
