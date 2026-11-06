# Paired binary outcomes (McNemar/Connor family) and single-arm vs fixed value.
# Anchors: inst/reference/NUMERIC_ANCHORS.md B8/B4.

#' Paired-proportion kernel (Connor 1987 / Akoglu Table 6 parameterization)
#'
#' `n = [Z_(a/2) sqrt(psi) + Z_b sqrt(psi - (p1-p2)^2)]^2 / (p1-p2)^2`
#' where psi = pi10 + pi01 is the discordant-pair proportion.
#' Anchor: Akoglu 2022 Table 6A (uncorrected): psi=0.05 (= delta at minimum),
#' diff=0.05, 80% power -> 154.5 -> 155.
#' @keywords internal
paired_proportion_n <- function(p1, p2, psi, alpha, power) {
  delta <- abs(p1 - p2)
  if (delta == 0) {
    cli::cli_abort("{.arg p1} and {.arg p2} must differ.")
  }
  if (!is.numeric(psi) || length(psi) != 1 || psi <= 0 || psi >= 1) {
    cli::cli_abort("{.arg psi} (discordant-pair proportion) must be in (0, 1).")
  }
  if (psi > min(p1 + p2, 2 - p1 - p2) + 1e-12) {
    cli::cli_abort(
      "{.arg psi} is incompatible with {.arg p1} and {.arg p2}: the implied joint probabilities must be non-negative."
    )
  }
  if (psi < delta - 1e-12 || psi - delta^2 <= 0) {
    cli::cli_abort(c(
      "Inconsistent inputs: need psi >= delta (or psi > delta^2).",
      "x" = "psi = {.val {psi}}, |p1-p2| = {.val {delta}}.",
      "i" = "psi is the expected proportion of discordant pairs"
    ))
  }

  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  (z_a * sqrt(psi) + z_b * sqrt(psi - delta^2))^2 / delta^2
}

#' Paired binary outcomes (McNemar test sample size)
#' @keywords internal
calculate_paired_proportions <- function(
  p1,
  p2,
  psi,
  alpha,
  power,
  pairing = "within_subject"
) {
  pairing <- rlang::arg_match(pairing, c("within_subject", "matched_subjects"))
  n <- paired_proportion_n(p1, p2, psi, alpha, power)
  pairs <- as.integer(ceiling(n))
  individuals <- if (pairing == "within_subject") pairs else 2L * pairs

  list(
    design_type = "Paired binary outcomes (McNemar / Connor)",
    pairs_count = pairs,
    total_n = individuals,
    total_individuals = individuals,
    n_measurements = 2L * pairs,
    parameters = list(
      p1 = p1,
      p2 = p2,
      psi = psi,
      alpha = alpha,
      power = power,
      pairing = pairing
    ),
    formula = "n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2",
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{\\psi} + Z_{\\beta}\\sqrt{\\psi-\\delta^2}\\right]^2}{\\delta^2}$$",
    reference = paste(
      "Primary: Connor, R. J. (1987). Sample size for testing differences in",
      "proportions for the paired-sample design. Biometrics, 43(1), 207-211.\n\n",
      "Also: Akoglu, H. (2022). Turkish Journal of Emergency Medicine, 22(4),",
      "Table 2 Eq 3b + Tables 6A/6B (uncorrected and Yates-corrected values)."
    ),
    roles = c(
      "p1/p2 = expected proportions (or sensitivities) in pairs",
      "psi = expected discordant-pair proportion (pi10 + pi01)",
      "output is in PAIRS of observations; within_subject uses one person per pair, matched_subjects uses two",
      "n_measurements = 2 x pairs; total_individuals counts distinct people"
    )
  )
}

#' Single-arm trial: continuous outcome vs a fixed reference value
#' n = (Z_a/2 + Z_b)^2 * sigma^2 / delta^2 (Machin Ch.5, single-sample)
#' @keywords internal
calculate_single_arm_mean <- function(mu0, mu1, sigma, alpha, power) {
  if (!is.numeric(sigma) || length(sigma) != 1 || sigma <= 0) {
    cli::cli_abort("{.arg sigma} must be a single positive number.")
  }
  delta <- abs(mu1 - mu0)
  if (delta == 0) {
    cli::cli_abort("{.arg mu1} and {.arg mu0} must differ.")
  }

  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  n <- (z_a + z_b)^2 * sigma^2 / delta^2

  list(
    design_type = "Single-arm trial (continuous, vs fixed value)",
    n_required = as.integer(ceiling(n)),
    parameters = list(
      mu0 = mu0,
      mu1 = mu1,
      sigma = sigma,
      alpha = alpha,
      power = power
    ),
    formula = "n = (Za/2 + Zb)^2 * sigma^2 / (mu1-mu0)^2",
    formula_latex = "$$n = \\frac{(Z_{\\alpha/2} + Z_{\\beta})^2 \\sigma^2}{(\\mu_1 - \\mu_0)^2}$$",
    reference = paste(
      "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 5 (Continuous Outcomes, single-sample comparison)."
    ),
    roles = c(
      "mu0 = reference/historical control mean (the null value)",
      "mu1 = anticipated treatment mean",
      "sigma = population standard deviation"
    )
  )
}

#' Single-arm trial: binary outcome vs a fixed reference proportion
#'
#' `n = [Z_a/2 sqrt(p0(1-p0)) + Z_b sqrt(p1(1-p1))]^2 / (p1-p0)^2`
#' Anchor: Hajian-Tilaki 2014 Eq 6.8 (P0=0.70, P1=0.80 -> 153).
#' @keywords internal
calculate_single_arm_proportion <- function(p0, p1, alpha, power) {
  if (!is.numeric(p0) || length(p0) != 1 || p0 <= 0 || p0 >= 1) {
    cli::cli_abort("{.arg p0} must be a proportion in (0, 1).")
  }
  if (!is.numeric(p1) || length(p1) != 1 || p1 <= 0 || p1 >= 1) {
    cli::cli_abort("{.arg p1} must be a proportion in (0, 1).")
  }
  if (p1 == p0) {
    cli::cli_abort("{.arg p1} and {.arg p0} must differ.")
  }

  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  n <- (z_a * sqrt(p0 * (1 - p0)) + z_b * sqrt(p1 * (1 - p1)))^2 / (p1 - p0)^2

  list(
    design_type = "Single-arm trial (binary, vs fixed value)",
    n_required = as.integer(ceiling(n)),
    parameters = list(p0 = p0, p1 = p1, alpha = alpha, power = power),
    formula = "n = [Za*sqrt(p0q0) + Zb*sqrt(p1q1)]^2/(p1-p0)^2",
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p_1(1-p_1)}\\right]^2}{(p_1 - p_0)^2}$$",
    reference = paste(
      "Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
      "test studies of biomedical informatics. Journal of Biomedical Informatics,",
      "48, 193-204 (Eq 6.8; worked example 0.70 vs 0.80 -> n=153).\n\n",
      "Also: Akoglu, H. (2022). Table 2, Equation 2; Machin et al. (2018) Ch.3."
    ),
    roles = c(
      "p0 = null/historical control proportion",
      "p1 = anticipated treatment proportion"
    )
  )
}
