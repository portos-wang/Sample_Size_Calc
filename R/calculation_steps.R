# Calculation steps derivation and formatting for sample_size_result objects

#' Format a numeric or vector value for calculation step display
#' @noRd
ssr_fmt_val <- function(x, digits = 4) {
  if (is.null(x) || length(x) == 0) return("")
  if (is.character(x)) return(paste(x, collapse = ", "))
  if (!is.numeric(x)) return(as.character(x))
  if (length(x) > 1) {
    formatted <- vapply(x, ssr_fmt_val, character(1), digits = digits)
    return(paste0("[", paste(formatted, collapse = ", "), "]"))
  }
  if (!is.finite(x)) return(as.character(x))
  if (x == floor(x) && abs(x) < 1e7) {
    return(as.character(as.integer(x)))
  }
  format(round(x, digits), nsmall = min(digits, 2), trim = TRUE, scientific = FALSE)
}

#' Safely extract a parameter by name
#' @noRd
ssr_param <- function(params, key, default = NULL) {
  if (is.null(params) || is.null(params[[key]])) return(default)
  params[[key]]
}

#' Safely extract a metric from a result object
#' @noRd
ssr_metric <- function(x, key, default = NULL) {
  if (!is.null(x$results) && !is.null(x$results[[key]])) {
    return(x$results[[key]])
  }
  if (!is.null(x[[key]])) {
    return(x[[key]])
  }
  default
}

#' Derive step-by-step calculation explanation for a sample size result
#'
#' Inspects the design type, parameters, formulas, and computed metrics to
#' produce an ordered character vector documenting the exact calculation steps.
#'
#' @param x A sample_size_result object or intermediate calculation list
#' @return A character vector of calculation steps
#' @noRd
generate_calculation_steps <- function(x) {
  dtype <- x$design_type %||% ""
  p <- x$parameters %||% list()
  alpha <- ssr_param(p, "alpha", 0.05)
  power <- ssr_param(p, "power", 0.8)

  # 1. Two independent samples, mean comparison (RCT)
  if (dtype == "Two independent samples, mean comparison" ||
      (grepl("mean comparison", dtype, ignore.case = TRUE) && !grepl("Cluster", dtype))) {
    m1 <- ssr_param(p, "mean1")
    m2 <- ssr_param(p, "mean2")
    sd_val <- ssr_param(p, "sd")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    diff <- abs(m1 - m2)
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n0 <- 2 * ((z_a + z_b) * sd_val / diff)^2

    return(c(
      sprintf("Step 1: State hypotheses: H0: mu1 = mu2 vs H1: mu1 != mu2 (two-sided alpha = %s, power = %s).",
              ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Calculate mean difference delta = |mu1 - mu2| = |%s - %s| = %s; common SD sigma = %s.",
              ssr_fmt_val(m1), ssr_fmt_val(m2), ssr_fmt_val(diff), ssr_fmt_val(sd_val)),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s (for two-sided alpha = %s), Z_beta = %s (for power = %s).",
              ssr_fmt_val(z_a), ssr_fmt_val(alpha), ssr_fmt_val(z_b), ssr_fmt_val(power)),
      sprintf("Step 4: Compute initial sample size via normal approximation: n0 = 2 * ((Z_(alpha/2) + Z_beta) * sigma / delta)^2 = 2 * ((%s + %s) * %s / %s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(sd_val), ssr_fmt_val(diff), ssr_fmt_val(n0, 2)),
      "Step 5: Refine via exact two-sample Student's t-test power iteration (accounting for degrees of freedom df = 2n - 2).",
      sprintf("Step 6: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 2. Two independent proportions
  if (dtype == "Two independent proportions" && !grepl("Cluster", dtype)) {
    p1 <- ssr_param(p, "p1")
    p2 <- ssr_param(p, "p2")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    p_bar <- (p1 + p2) / 2
    diff <- abs(p1 - p2)
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    term1 <- z_a * sqrt(2 * p_bar * (1 - p_bar))
    term2 <- z_b * sqrt(p1 * (1 - p1) + p2 * (1 - p2))
    n_raw <- ((term1 + term2) / diff)^2

    return(c(
      sprintf("Step 1: State hypotheses: H0: p1 = p2 vs H1: p1 != p2 (two-sided alpha = %s, power = %s).",
              ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Compute pooled proportion: p_bar = (p1 + p2) / 2 = (%s + %s) / 2 = %s.",
              ssr_fmt_val(p1), ssr_fmt_val(p2), ssr_fmt_val(p_bar)),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Compute Fleiss formula numerator components: Z_(alpha/2)*sqrt(2*p_bar*(1-p_bar)) = %s; Z_beta*sqrt(p1(1-p1)+p2(1-p2)) = %s.",
              ssr_fmt_val(term1), ssr_fmt_val(term2)),
      sprintf("Step 5: Calculate unrounded sample size per group: n = (%s + %s)^2 / (%s - %s)^2 = %s.",
              ssr_fmt_val(term1), ssr_fmt_val(term2), ssr_fmt_val(p1), ssr_fmt_val(p2), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 6: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 3. Paired means
  if (dtype == "Paired means") {
    diff <- ssr_param(p, "mean_diff") %||% ssr_param(p, "meanDiff")
    sd_d <- ssr_param(p, "sd_diff") %||% ssr_param(p, "sdDiff")
    pairs <- ssr_metric(x, "pairs_count") %||% ssr_metric(x, "pairs")
    total_ind <- ssr_metric(x, "total_individuals", if (!is.null(pairs)) 2L * pairs)

    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n0 <- ((z_a + z_b) * sd_d / abs(diff))^2

    return(c(
      sprintf("Step 1: State paired difference hypotheses: H0: mu_d = 0 vs H1: mu_d != 0 (alpha = %s, power = %s).",
              ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Expected paired difference mu_d = %s, SD of differences sigma_d = %s.",
              ssr_fmt_val(diff), ssr_fmt_val(sd_d)),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Normal approximation: n0 = ((Z_(alpha/2) + Z_beta) * sigma_d / mu_d)^2 = ((%s + %s) * %s / %s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(sd_d), ssr_fmt_val(abs(diff)), ssr_fmt_val(n0, 2)),
      "Step 5: Exact paired Student's t-test degrees of freedom iteration.",
      sprintf("Step 6: Round up to integer: n = %s pairs (total individuals = %s).",
              ssr_fmt_val(pairs), ssr_fmt_val(total_ind))
    ))
  }

  # 4. Survival (log-rank)
  if (dtype == "Survival (log-rank)") {
    hr <- ssr_param(p, "hazard_ratio") %||% ssr_param(p, "hr")
    pE <- ssr_param(p, "allocation_ratio") %||% ssr_param(p, "pE", 0.5)
    events <- ssr_metric(x, "target_events_needed") %||% ssr_metric(x, "events")

    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    e_raw <- ((z_a + z_b)^2) / ((pE * (1 - pE)) * (log(hr)^2))

    return(c(
      sprintf("Step 1: State survival parameters: Hazard Ratio HR = %s, experimental arm allocation pE = %s (alpha = %s, power = %s).",
              ssr_fmt_val(hr), ssr_fmt_val(pE), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Compute log hazard ratio: ln(HR) = ln(%s) = %s.",
              ssr_fmt_val(hr), ssr_fmt_val(log(hr))),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Apply Schoenfeld formula: E = (Z_(alpha/2) + Z_beta)^2 / [pE * (1 - pE) * (ln HR)^2] = (%s + %s)^2 / [%s * %s * (%s)^2] = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(pE), ssr_fmt_val(1 - pE), ssr_fmt_val(log(hr)), ssr_fmt_val(e_raw, 2)),
      sprintf("Step 5: Round up to integer: Target events needed E = %s.",
              ssr_fmt_val(events))
    ))
  }

  # 5. Non-inferiority (means)
  if (dtype == "Non-inferiority (means)") {
    m1 <- ssr_param(p, "mean1")
    m2 <- ssr_param(p, "mean2")
    sd_val <- ssr_param(p, "sd")
    margin <- ssr_param(p, "margin")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    delta_e <- m1 - m2 + margin
    z_a <- stats::qnorm(1 - alpha)
    z_b <- stats::qnorm(power)
    n_raw <- 2 * (z_a + z_b)^2 * (sd_val^2) / (delta_e^2)

    return(c(
      sprintf("Step 1: State non-inferiority hypotheses: H0: mu1 - mu2 <= -margin vs H1: mu1 - mu2 > -margin (margin Delta = %s, one-sided alpha = %s, power = %s).",
              ssr_fmt_val(margin), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Effective difference: delta_E = mu1 - mu2 + margin = %s - %s + %s = %s; SD sigma = %s.",
              ssr_fmt_val(m1), ssr_fmt_val(m2), ssr_fmt_val(margin), ssr_fmt_val(delta_e), ssr_fmt_val(sd_val)),
      sprintf("Step 3: Determine critical values: one-sided Z_alpha = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Compute sample size: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 / delta_E^2 = 2 * (%s + %s)^2 * %s^2 / (%s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(sd_val), ssr_fmt_val(delta_e), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 6. Superiority (means)
  if (dtype == "Superiority (means)") {
    m1 <- ssr_param(p, "mean1")
    m2 <- ssr_param(p, "mean2")
    sd_val <- ssr_param(p, "sd")
    margin <- ssr_param(p, "margin")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    delta_e <- m1 - m2 - margin
    z_a <- stats::qnorm(1 - alpha)
    z_b <- stats::qnorm(power)
    n_raw <- 2 * (z_a + z_b)^2 * (sd_val^2) / (delta_e^2)

    return(c(
      sprintf("Step 1: State superiority hypotheses: H0: mu1 - mu2 <= margin vs H1: mu1 - mu2 > margin (margin Delta = %s, one-sided alpha = %s, power = %s).",
              ssr_fmt_val(margin), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Effective difference: delta_E = mu1 - mu2 - margin = %s - %s - %s = %s; SD sigma = %s.",
              ssr_fmt_val(m1), ssr_fmt_val(m2), ssr_fmt_val(margin), ssr_fmt_val(delta_e), ssr_fmt_val(sd_val)),
      sprintf("Step 3: Determine critical values: one-sided Z_alpha = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Compute sample size: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 / delta_E^2 = 2 * (%s + %s)^2 * %s^2 / (%s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(sd_val), ssr_fmt_val(delta_e), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 7. Equivalence (means)
  if (dtype == "Equivalence (means)") {
    m1 <- ssr_param(p, "mean1")
    m2 <- ssr_param(p, "mean2")
    sd_val <- ssr_param(p, "sd")
    margin <- ssr_param(p, "margin")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    diff <- abs(m1 - m2)
    clearance <- margin - diff
    z_a <- stats::qnorm(1 - alpha)
    z_b_half <- stats::qnorm(1 - (1 - power) / 2)
    n_raw <- 2 * (z_a + z_b_half)^2 * (sd_val^2) / (clearance^2)

    return(c(
      sprintf("Step 1: State equivalence hypotheses (TOST): H0: |mu1 - mu2| >= margin vs H1: |mu1 - mu2| < margin (margin Delta = %s, alpha = %s, power = %s).",
              ssr_fmt_val(margin), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Margin clearance: Delta - |mu1 - mu2| = %s - |%s - %s| = %s; SD sigma = %s.",
              ssr_fmt_val(margin), ssr_fmt_val(m1), ssr_fmt_val(m2), ssr_fmt_val(clearance), ssr_fmt_val(sd_val)),
      sprintf("Step 3: Determine critical values: one-sided Z_alpha = %s, Z_(beta/2) = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b_half)),
      sprintf("Step 4: Compute sample size: n = 2 * (Z_alpha + Z_(beta/2))^2 * sigma^2 / (Delta - |mu1 - mu2|)^2 = 2 * (%s + %s)^2 * %s^2 / (%s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b_half), ssr_fmt_val(sd_val), ssr_fmt_val(clearance), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 8. Superiority (proportions)
  if (dtype == "Superiority (proportions)") {
    p1 <- ssr_param(p, "p1")
    p2 <- ssr_param(p, "p2")
    margin <- ssr_param(p, "margin")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    delta_e <- p1 - p2 - margin
    z_a <- stats::qnorm(1 - alpha)
    z_b <- stats::qnorm(power)
    n_raw <- (z_a + z_b)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / (delta_e^2)

    return(c(
      sprintf("Step 1: State superiority hypotheses: H0: p1 - p2 <= margin vs H1: p1 - p2 > margin (margin Delta = %s, one-sided alpha = %s, power = %s).",
              ssr_fmt_val(margin), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Effective difference: delta_E = p1 - p2 - margin = %s - %s - %s = %s.",
              ssr_fmt_val(p1), ssr_fmt_val(p2), ssr_fmt_val(margin), ssr_fmt_val(delta_e)),
      sprintf("Step 3: Determine critical values: one-sided Z_alpha = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)] / delta_E^2 = (%s + %s)^2 * [%s + %s] / (%s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(p1 * (1 - p1)), ssr_fmt_val(p2 * (1 - p2)), ssr_fmt_val(delta_e), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 9. Equivalence (proportions)
  if (dtype == "Equivalence (proportions)") {
    p1 <- ssr_param(p, "p1")
    p2 <- ssr_param(p, "p2")
    margin <- ssr_param(p, "margin")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    diff <- abs(p1 - p2)
    clearance <- margin - diff
    z_a <- stats::qnorm(1 - alpha)
    z_b_half <- stats::qnorm(1 - (1 - power) / 2)
    n_raw <- (z_a + z_b_half)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / (clearance^2)

    return(c(
      sprintf("Step 1: State equivalence hypotheses (TOST): H0: |p1 - p2| >= margin vs H1: |p1 - p2| < margin (margin Delta = %s, alpha = %s, power = %s).",
              ssr_fmt_val(margin), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Margin clearance: Delta - |p1 - p2| = %s - |%s - %s| = %s.",
              ssr_fmt_val(margin), ssr_fmt_val(p1), ssr_fmt_val(p2), ssr_fmt_val(clearance)),
      sprintf("Step 3: Determine critical values: one-sided Z_alpha = %s, Z_(beta/2) = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b_half)),
      sprintf("Step 4: Compute sample size: n = (Z_alpha + Z_(beta/2))^2 * [p1(1-p1) + p2(1-p2)] / (Delta - |p1 - p2|)^2 = %s.",
              ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 10. Non-inferiority (proportions)
  if (dtype == "Non-inferiority (proportions)" || dtype == "Diagnostic non-inferiority (two proportions)") {
    p1 <- ssr_param(p, "p1")
    p2 <- ssr_param(p, "p2")
    margin <- ssr_param(p, "margin")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_per_group)) 2L * n_per_group)

    delta_e <- p1 - p2 + margin
    z_a <- stats::qnorm(1 - alpha)
    z_b <- stats::qnorm(power)
    n_raw <- (z_a + z_b)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / (delta_e^2)

    return(c(
      sprintf("Step 1: State non-inferiority hypotheses: H0: p1 - p2 <= -margin vs H1: p1 - p2 > -margin (margin Delta = %s, one-sided alpha = %s, power = %s).",
              ssr_fmt_val(margin), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Effective difference: delta_E = p1 - p2 + margin = %s - %s + %s = %s.",
              ssr_fmt_val(p1), ssr_fmt_val(p2), ssr_fmt_val(margin), ssr_fmt_val(delta_e)),
      sprintf("Step 3: Determine critical values: one-sided Z_alpha = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)] / delta_E^2 = %s.",
              ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: n = %s per group, total sample size N = %s.",
              ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 11. Case-control study
  if (dtype == "Case-control") {
    p0 <- ssr_param(p, "p0")
    OR <- ssr_param(p, "odds_ratio") %||% ssr_param(p, "OR")
    m_val <- ssr_param(p, "matching_ratio") %||% ssr_param(p, "m", 1)
    cases_needed <- ssr_metric(x, "cases_needed")
    controls_needed <- ssr_metric(x, "controls_needed")
    total_subjects <- ssr_metric(x, "total_subjects")

    p1 <- (OR * p0) / (1 - p0 + OR * p0)
    p_bar <- (p1 + m_val * p0) / (1 + m_val)
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n_cases_raw <- ((z_a * sqrt((1 + 1 / m_val) * p_bar * (1 - p_bar)) +
      z_b * sqrt(p1 * (1 - p1) + p0 * (1 - p0) / m_val)) / (p1 - p0))^2

    return(c(
      sprintf("Step 1: Compute case exposure rate from Odds Ratio: p1 = (OR * p0) / (1 - p0 + OR * p0) = (%s * %s) / (1 - %s + %s * %s) = %s.",
              ssr_fmt_val(OR), ssr_fmt_val(p0), ssr_fmt_val(p0), ssr_fmt_val(OR), ssr_fmt_val(p0), ssr_fmt_val(p1)),
      sprintf("Step 2: Weighted average exposure (matching ratio m = %s): p_bar = (p1 + m*p0) / (1 + m) = %s.",
              ssr_fmt_val(m_val), ssr_fmt_val(p_bar)),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Schlesselman formula for cases: n_cases = [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*(1-p1) + p0*(1-p0)/m)]^2 / (p1 - p0)^2 = %s.",
              ssr_fmt_val(n_cases_raw, 2)),
      sprintf("Step 5: Calculate controls needed: n_controls = m * n_cases = %s * %s = %s.",
              ssr_fmt_val(m_val), ssr_fmt_val(n_cases_raw, 2), ssr_fmt_val(n_cases_raw * m_val, 2)),
      sprintf("Step 6: Round up to integer: Cases needed = %s, Controls needed = %s, Total subjects = %s.",
              ssr_fmt_val(cases_needed), ssr_fmt_val(controls_needed), ssr_fmt_val(total_subjects))
    ))
  }

  # 12. Diagnostic accuracy single
  if (dtype == "Diagnostic accuracy (single)") {
    prob <- ssr_param(p, "prob")
    d_val <- ssr_param(p, "precision") %||% ssr_param(p, "d")
    prev_val <- ssr_param(p, "prevalence", 1)
    cases <- ssr_metric(x, "target_state_cases_needed") %||% ssr_metric(x, "cases")
    screen <- ssr_metric(x, "total_subjects_to_screen") %||% ssr_metric(x, "subjects_to_screen")

    z_val <- stats::qnorm(1 - alpha / 2)
    z_sum <- z_val
    critical_step <- sprintf(
      "Step 2: Determine critical value: Z_(1-alpha/2) = %s (confidence level = %s%%).",
      ssr_fmt_val(z_val), ssr_fmt_val(round((1 - alpha) * 100))
    )
    if (identical(p$ci_method, "ci_width_power")) {
      z_b <- stats::qnorm(power)
      z_sum <- z_val + z_b
      critical_step <- sprintf(
        "Step 2: CI-width power method: Z_(1-alpha/2) = %s, Z_beta = %s (power = %s); sum = %s.",
        ssr_fmt_val(z_val), ssr_fmt_val(z_b), ssr_fmt_val(power), ssr_fmt_val(z_sum)
      )
    }
    n_cases_raw <- (z_sum^2 * prob * (1 - prob)) / (d_val^2)

    return(c(
      sprintf("Step 1: Specify diagnostic accuracy prob (Se or Sp) = %s, margin of error d = %s, prevalence = %s (alpha = %s).",
              ssr_fmt_val(prob), ssr_fmt_val(d_val), ssr_fmt_val(prev_val), ssr_fmt_val(alpha)),
      critical_step,
      sprintf("Step 3: Calculate target cases required: n_cases = Z_sum^2 * prob * (1 - prob) / d^2 = (%s)^2 * %s * %s / (%s)^2 = %s.",
              ssr_fmt_val(z_sum), ssr_fmt_val(prob), ssr_fmt_val(1 - prob), ssr_fmt_val(d_val), ssr_fmt_val(n_cases_raw, 2)),
      sprintf("Step 4: Adjust for disease prevalence: total subjects to screen = n_cases / prevalence = %s / %s = %s.",
              ssr_fmt_val(n_cases_raw, 2), ssr_fmt_val(prev_val), ssr_fmt_val(n_cases_raw / prev_val, 2)),
      sprintf("Step 5: Round up to integer: Target cases needed = %s, Total subjects to screen = %s.",
              ssr_fmt_val(cases), ssr_fmt_val(screen))
    ))
  }

  # 13. Diagnostic accuracy dual endpoint
  if (dtype == "Diagnostic accuracy (dual endpoint: Se + Sp)") {
    p_se <- ssr_param(p, "prob"); p0_se <- ssr_param(p, "p0")
    p_sp <- ssr_param(p, "prob_spec"); p0_sp <- ssr_param(p, "p0_spec")
    prev_val <- ssr_param(p, "prevalence", 1)
    dual_pwr <- ssr_param(p, "dual_power", 0.9)
    n_se <- ssr_metric(x, "n_sensitivity")
    n_sp <- ssr_metric(x, "n_specificity")
    cases <- ssr_metric(x, "target_state_cases_needed")
    screen <- ssr_metric(x, "total_subjects_to_screen")

    return(c(
      sprintf("Step 1: Dual-endpoint setup: Se (null = %s, exp = %s), Sp (null = %s, exp = %s), dual_power = %s (joint power ~80%%).",
              ssr_fmt_val(p0_se), ssr_fmt_val(p_se), ssr_fmt_val(p0_sp), ssr_fmt_val(p_sp), ssr_fmt_val(dual_pwr)),
      sprintf("Step 2: Calculate cases for sensitivity: n_Se = [Z_alpha*sqrt(p0*q0) + Z_beta*sqrt(p*q)]^2 / (p - p0)^2 = %s.",
              ssr_fmt_val(n_se)),
      sprintf("Step 3: Calculate controls for specificity: n_Sp = [Z_alpha*sqrt(p0*q0) + Z_beta*sqrt(p*q)]^2 / (p - p0)^2 = %s.",
              ssr_fmt_val(n_sp)),
      sprintf("Step 4: Select dominant endpoint requirement: n_final = max(n_Se, n_Sp) = %s.",
              ssr_fmt_val(cases)),
      sprintf("Step 5: Convert to screening population: Total subjects to screen = %s / %s = %s.",
              ssr_fmt_val(cases), ssr_fmt_val(prev_val), ssr_fmt_val(screen))
    ))
  }

  # 14. Single proportion estimation precision
  if (dtype == "Single proportion estimation (precision)") {
    p_val <- ssr_param(p, "p")
    d_val <- ssr_param(p, "precision")
    prec_type <- ssr_param(p, "precision_type", "absolute")
    n_req <- ssr_metric(x, "n_required") %||% ssr_metric(x, "total_n")

    z_val <- stats::qnorm(1 - alpha / 2)
    d_eff <- if (prec_type == "relative") d_val * p_val else d_val
    n_raw <- (z_val^2 * p_val * (1 - p_val)) / (d_eff^2)

    return(c(
      sprintf("Step 1: Specify anticipated proportion p = %s, margin of error d = %s (%s precision), alpha = %s.",
              ssr_fmt_val(p_val), ssr_fmt_val(d_val), prec_type, ssr_fmt_val(alpha)),
      sprintf("Step 2: Determine critical value: Z_(1-alpha/2) = %s (confidence level = %s%%).",
              ssr_fmt_val(z_val), ssr_fmt_val(round((1 - alpha) * 100))),
      sprintf("Step 3: Compute variance component: p * (1 - p) = %s * %s = %s.",
              ssr_fmt_val(p_val), ssr_fmt_val(1 - p_val), ssr_fmt_val(p_val * (1 - p_val))),
      sprintf("Step 4: Calculate unrounded sample size: n = Z_(1-alpha/2)^2 * p * (1 - p) / d^2 = (%s)^2 * %s / (%s)^2 = %s.",
              ssr_fmt_val(z_val), ssr_fmt_val(p_val * (1 - p_val)), ssr_fmt_val(d_eff), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: Required sample size n = %s.",
              ssr_fmt_val(n_req))
    ))
  }

  # 15. Single mean estimation precision
  if (dtype == "Single mean estimation (precision)") {
    sigma <- ssr_param(p, "sigma")
    d_val <- ssr_param(p, "precision")
    n_req <- ssr_metric(x, "n_required") %||% ssr_metric(x, "total_n")

    z_val <- stats::qnorm(1 - alpha / 2)
    n_raw <- (z_val * sigma / d_val)^2

    return(c(
      sprintf("Step 1: Specify population SD sigma = %s, margin of error d = %s, alpha = %s.",
              ssr_fmt_val(sigma), ssr_fmt_val(d_val), ssr_fmt_val(alpha)),
      sprintf("Step 2: Determine critical value: Z_(1-alpha/2) = %s (confidence level = %s%%).",
              ssr_fmt_val(z_val), ssr_fmt_val(round((1 - alpha) * 100))),
      sprintf("Step 3: Compute unrounded sample size: n = (Z_(1-alpha/2) * sigma / d)^2 = (%s * %s / %s)^2 = %s.",
              ssr_fmt_val(z_val), ssr_fmt_val(sigma), ssr_fmt_val(d_val), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 4: Round up to integer: Required sample size n = %s.",
              ssr_fmt_val(n_req))
    ))
  }

  # 16. Single correlation estimation
  if (dtype == "Single correlation estimation (Fisher z precision)") {
    r_val <- ssr_param(p, "r")
    d_val <- ssr_param(p, "precision") %||% (ssr_param(p, "epsilon") * r_val)
    n_req <- ssr_metric(x, "n_required") %||% ssr_metric(x, "total_n")
    w <- 2 * d_val
    z_val <- stats::qnorm(1 - alpha / 2)
    n_p0 <- 4 * (z_val^2) * ((1 - r_val^2)^2) / (w^2) + 3

    return(c(
      sprintf("Step 1: Specify anticipated correlation r = %s, CI half-width d = %s (width w = 2d = %s), alpha = %s.",
              ssr_fmt_val(r_val), ssr_fmt_val(d_val), ssr_fmt_val(w), ssr_fmt_val(alpha)),
      sprintf("Step 2: Determine critical value: Z_(1-alpha/2) = %s.",
              ssr_fmt_val(z_val)),
      sprintf("Step 3: Machin initial estimate: N_P0 = 4 * Z^2 * (1 - r^2)^2 / w^2 + 3 = %s.",
              ssr_fmt_val(n_p0, 2)),
      "Step 4: Refine via Fisher z transformation limits to adjust for confidence interval skewness.",
      sprintf("Step 5: Round up to integer: Required sample size n = %s.",
              ssr_fmt_val(n_req))
    ))
  }

  # 17. Cohort study (cumulative incidence)
  if (dtype == "Cohort study (cumulative incidence, RR)" ||
      dtype == "Cross-sectional study (prevalence comparison, PR/OR)") {
    p0 <- ssr_param(p, "p0")
    p1 <- ssr_param(p, "p1")
    m_val <- ssr_param(p, "ratio", 1)
    n1 <- ssr_metric(x, "n_exposed") %||% ssr_metric(x, "n_per_group")
    n0 <- ssr_metric(x, "n_unexposed")
    total_n <- ssr_metric(x, "total_n")

    p_bar <- (p1 + m_val * p0) / (1 + m_val)
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n1_raw <- (z_a * sqrt((1 + 1 / m_val) * p_bar * (1 - p_bar)) +
      z_b * sqrt(p1 * (1 - p1) + p0 * (1 - p0) / m_val))^2 / (p1 - p0)^2

    return(c(
      sprintf("Step 1: Specify proportions: unexposed p0 = %s, exposed p1 = %s, allocation ratio m = %s (alpha = %s, power = %s).",
              ssr_fmt_val(p0), ssr_fmt_val(p1), ssr_fmt_val(m_val), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Weighted average proportion: p_bar = (p1 + m*p0) / (1 + m) = %s.",
              ssr_fmt_val(p_bar)),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Calculate exposed sample size: n_exposed = [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*q1 + p0*q0/m)]^2 / (p1 - p0)^2 = %s.",
              ssr_fmt_val(n1_raw, 2)),
      sprintf("Step 5: Calculate unexposed sample size: n_unexposed = m * n_exposed = %s * %s = %s.",
              ssr_fmt_val(m_val), ssr_fmt_val(n1_raw, 2), ssr_fmt_val(n1_raw * m_val, 2)),
      if (!is.null(x$adjustments$dropout)) {
        sprintf("Step 6: Round up before dropout inflation: ceiling(n_exposed) = %s, ceiling(m*n_exposed) = %s; apply dropout d = %s using ceiling(n/(1-d)). Exposed = %s, Unexposed = %s, Total sample size N = %s.",
                ssr_fmt_val(ceiling(n1_raw)), ssr_fmt_val(ceiling(n1_raw * m_val)),
                ssr_fmt_val(x$adjustments$dropout), ssr_fmt_val(n1), ssr_fmt_val(n0), ssr_fmt_val(total_n))
      } else {
        sprintf("Step 6: Round up to integer: Exposed = %s, Unexposed = %s, Total sample size N = %s.",
                ssr_fmt_val(n1), ssr_fmt_val(n0), ssr_fmt_val(total_n))
      }
    ))
  }

  # 18. Cohort study (person-time rates)
  if (dtype == "Cohort study (incidence rate ratio, person-time)") {
    r0 <- ssr_param(p, "rate0")
    r1 <- ssr_param(p, "rate1")
    r_ratio <- ssr_param(p, "ratio", 1)
    t0 <- ssr_metric(x, "person_time_unexposed")
    t1 <- ssr_metric(x, "person_time_exposed")
    events <- ssr_metric(x, "expected_events")

    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    t0_raw <- (z_a + z_b)^2 * (r1 / r_ratio + r0) / (r1 - r0)^2

    return(c(
      sprintf("Step 1: Specify incidence rates: unexposed lambda0 = %s, exposed lambda1 = %s, person-time ratio r = %s.",
              ssr_fmt_val(r0), ssr_fmt_val(r1), ssr_fmt_val(r_ratio)),
      sprintf("Step 2: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 3: Calculate required person-time for unexposed group: T0 = (Z_(alpha/2) + Z_beta)^2 * (lambda1/r + lambda0) / (lambda1 - lambda0)^2 = %s.",
              ssr_fmt_val(t0_raw, 2)),
      sprintf("Step 4: Calculate required person-time for exposed group: T1 = r * T0 = %s * %s = %s.",
              ssr_fmt_val(r_ratio), ssr_fmt_val(t0_raw, 2), ssr_fmt_val(t0_raw * r_ratio, 2)),
      sprintf("Step 5: Expected events: E = lambda0 * T0 + lambda1 * T1 = %s.",
              ssr_fmt_val(events)),
      sprintf("Step 6: Round up to integer: Person-time unexposed = %s, Person-time exposed = %s.",
              ssr_fmt_val(t0), ssr_fmt_val(t1))
    ))
  }

  # 19. Individually matched case-control (1:1)
  if (dtype == "Individually matched case-control (1:1)") {
    p0 <- ssr_param(p, "p0")
    OR <- ssr_param(p, "OR") %||% ssr_param(p, "odds_ratio")
    p1 <- ssr_param(p, "expected_p1", if (!is.null(OR) && !is.null(p0)) (OR * p0) / (1 - p0 + OR * p0) else NULL)
    psi <- ssr_param(p, "expected_psi", if (!is.null(p1) && !is.null(p0)) p1 * (1 - p0) + p0 * (1 - p1) else NULL)
    delta <- if (!is.null(p1) && !is.null(p0)) abs(p1 * (1 - p0) - p0 * (1 - p1)) else NULL
    pairs <- ssr_metric(x, "n_pairs") %||% ssr_metric(x, "cases_needed")

    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n_raw <- if (!is.null(psi) && !is.null(delta) && delta > 0 && psi > delta^2) {
      ((z_a * sqrt(psi) + z_b * sqrt(psi - delta^2)) / delta)^2
    } else {
      NULL
    }

    return(c(
      sprintf("Step 1: Matched case-control parameters: control exposure p0 = %s, Odds Ratio OR = %s (alpha = %s, power = %s).",
              ssr_fmt_val(p0), ssr_fmt_val(OR), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Case exposure rate: p1 = (OR * p0) / (1 - p0 + OR * p0) = %s.",
              ssr_fmt_val(p1)),
      sprintf("Step 3: Discordant pair probability: psi = pi10 + pi01 = %s; difference delta = |pi10 - pi01| = %s.",
              ssr_fmt_val(psi), ssr_fmt_val(delta)),
      sprintf("Step 4: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 5: Apply Dupont/Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) + Z_beta*sqrt(psi - delta^2)]^2 / delta^2%s.",
              if (!is.null(n_raw)) sprintf(" = %s", ssr_fmt_val(n_raw, 2)) else ""),
      sprintf("Step 6: Round up to integer: Pairs needed = %s (Cases = %s, Controls = %s).",
              ssr_fmt_val(pairs), ssr_fmt_val(pairs), ssr_fmt_val(pairs))
    ))
  }

  # 20. Paired binary outcomes (McNemar / Connor)
  if (dtype == "Paired binary outcomes (McNemar / Connor)" ||
      dtype == "Two diagnostic measures (paired, Connor)") {
    p1 <- ssr_param(p, "p1")
    p2 <- ssr_param(p, "p2")
    psi <- ssr_param(p, "psi")
    pairs <- ssr_metric(x, "pairs_count") %||% ssr_metric(x, "cases_needed")

    diff <- if (!is.null(p1) && !is.null(p2)) abs(p1 - p2) else NULL
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n_raw <- if (!is.null(psi) && !is.null(diff) && diff > 0 && psi > diff^2) {
      ((z_a * sqrt(psi) + z_b * sqrt(psi - diff^2)) / diff)^2
    } else {
      NULL
    }

    return(c(
      sprintf("Step 1: Paired binary parameters: p1 = %s, p2 = %s, discordant pair proportion psi = %s, difference delta = |p1 - p2| = %s.",
              ssr_fmt_val(p1), ssr_fmt_val(p2), ssr_fmt_val(psi), ssr_fmt_val(diff)),
      sprintf("Step 2: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 3: Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) + Z_beta*sqrt(psi - delta^2)]^2 / delta^2%s.",
              if (!is.null(n_raw)) sprintf(" = %s", ssr_fmt_val(n_raw, 2)) else ""),
      sprintf("Step 4: Round up to integer: Pairs needed = %s.",
              ssr_fmt_val(pairs))
    ))
  }

  # 21. Single-arm trial (continuous)
  if (dtype == "Single-arm trial (continuous, vs fixed value)") {
    mu0 <- ssr_param(p, "mu0")
    mu1 <- ssr_param(p, "mu1")
    sigma <- ssr_param(p, "sigma")
    n_req <- ssr_metric(x, "n_required")
    delta <- abs(mu1 - mu0)
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n_raw <- (z_a + z_b)^2 * sigma^2 / delta^2

    return(c(
      sprintf("Step 1: Single-arm continuous hypotheses: H0: mu = %s vs H1: mu = %s, SD sigma = %s (alpha = %s, power = %s).",
              ssr_fmt_val(mu0), ssr_fmt_val(mu1), ssr_fmt_val(sigma), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Effect size delta = |mu1 - mu0| = |%s - %s| = %s.",
              ssr_fmt_val(mu1), ssr_fmt_val(mu0), ssr_fmt_val(delta)),
      sprintf("Step 3: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 4: Sample size: n = (Z_(alpha/2) + Z_beta)^2 * sigma^2 / delta^2 = (%s + %s)^2 * %s^2 / (%s)^2 = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b), ssr_fmt_val(sigma), ssr_fmt_val(delta), ssr_fmt_val(n_raw, 2)),
      sprintf("Step 5: Round up to integer: Required sample size n = %s.",
              ssr_fmt_val(n_req))
    ))
  }

  # 22. Single-arm trial (binary)
  if (dtype == "Single-arm trial (binary, vs fixed value)") {
    p0 <- ssr_param(p, "p0")
    p1 <- ssr_param(p, "p1")
    n_req <- ssr_metric(x, "n_required")
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)
    n_raw <- (z_a * sqrt(p0 * (1 - p0)) + z_b * sqrt(p1 * (1 - p1)))^2 / (p1 - p0)^2

    return(c(
      sprintf("Step 1: Single-arm binary hypotheses: H0: p = %s vs H1: p = %s (alpha = %s, power = %s).",
              ssr_fmt_val(p0), ssr_fmt_val(p1), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      sprintf("Step 3: Sample size: n = [Z_(alpha/2)*sqrt(p0*q0) + Z_beta*sqrt(p1*q1)]^2 / (p1 - p0)^2 = %s.",
              ssr_fmt_val(n_raw, 2)),
      sprintf("Step 4: Round up to integer: Required sample size n = %s.",
              ssr_fmt_val(n_req))
    ))
  }

  # 23. Single AUC estimation
  if (dtype == "Single-group AUC CI precision") {
    auc_val <- ssr_param(p, "auc")
    d_val <- ssr_param(p, "precision") %||% ssr_param(p, "d")
    prev_val <- ssr_param(p, "prevalence", 1)
    cases <- ssr_metric(x, "target_state_cases_needed")
    screen <- ssr_metric(x, "total_subjects_to_screen")

    if (!is.null(p$var_method)) {
      ratio <- p$ratio_R
      variance <- auc_variance(auc_val, ratio, p$var_method)
      z_val <- stats::qnorm(1 - alpha / 2)
      n_raw <- (z_val / d_val)^2 * variance
      return(c(
        sprintf("Step 1: Anticipated AUC = %s, precision d = %s, supplied allocation R = %s, alpha = %s.",
                ssr_fmt_val(auc_val), ssr_fmt_val(d_val), ssr_fmt_val(ratio), ssr_fmt_val(alpha)),
        sprintf("Step 2: Use the %s variance model with the supplied allocation: V(AUC) = %s.",
                p$var_method, ssr_fmt_val(variance)),
        sprintf("Step 3: Calculate cases: n_cases = (Z_(1-alpha/2)/d)^2 * V(AUC) = (%s/%s)^2 * %s = %s.",
                ssr_fmt_val(z_val), ssr_fmt_val(d_val), ssr_fmt_val(variance), ssr_fmt_val(n_raw, 2)),
        sprintf("Step 4: Convert using the supplied allocation: total = n_cases*(1+R) = %s*(1+%s) = %s.",
                ssr_fmt_val(n_raw, 2), ssr_fmt_val(ratio), ssr_fmt_val(n_raw * (1 + ratio), 2)),
        sprintf("Step 5: Round up: Target cases needed = %s, Total subjects to screen = %s.",
                ssr_fmt_val(cases), ssr_fmt_val(screen))
      ))
    }

    q1 <- auc_val / (2 - auc_val)
    q2 <- (2 * auc_val^2) / (1 + auc_val)
    k <- (1 - prev_val) / prev_val
    v_a <- auc_val * (1 - auc_val) + (1 / k) * (q1 - auc_val^2) + (q2 - auc_val^2)
    z_val <- stats::qnorm(1 - alpha / 2)
    n_cases_raw <- (z_val / d_val)^2 * v_a

    return(c(
      sprintf("Step 1: Specify anticipated AUC = %s, desired precision d = %s, prevalence = %s (alpha = %s).",
              ssr_fmt_val(auc_val), ssr_fmt_val(d_val), ssr_fmt_val(prev_val), ssr_fmt_val(alpha)),
      sprintf("Step 2: Hanley-McNeil variance components: Q1 = AUC/(2-AUC) = %s, Q2 = 2*AUC^2/(1+AUC) = %s.",
              ssr_fmt_val(q1), ssr_fmt_val(q2)),
      sprintf("Step 3: Compute variance factor: V(AUC) = %s.",
              ssr_fmt_val(v_a)),
      sprintf("Step 4: Calculate cases needed: n_cases = (Z_(1-alpha/2) / d)^2 * V(AUC) = (%s / %s)^2 * %s = %s.",
              ssr_fmt_val(z_val), ssr_fmt_val(d_val), ssr_fmt_val(v_a), ssr_fmt_val(n_cases_raw, 2)),
      sprintf("Step 5: Adjust for prevalence: screening total = n_cases / prevalence = %s / %s = %s.",
              ssr_fmt_val(n_cases_raw, 2), ssr_fmt_val(prev_val), ssr_fmt_val(n_cases_raw / prev_val, 2)),
      sprintf("Step 6: Round up to integer: Target cases needed = %s, Total subjects to screen = %s.",
              ssr_fmt_val(cases), ssr_fmt_val(screen))
    ))
  }

  # 24. AUC superiority
  if (dtype == "AUC superiority (single)") {
    auc_val <- ssr_param(p, "auc")
    auc0 <- ssr_param(p, "auc_null") %||% ssr_param(p, "auc0")
    prev_val <- ssr_param(p, "prevalence", 1)
    cases <- ssr_metric(x, "target_state_cases_needed")
    screen <- ssr_metric(x, "total_subjects_to_screen")

    z_a <- stats::qnorm(1 - alpha)
    z_b <- stats::qnorm(power)

    return(c(
      sprintf("Step 1: Specify AUC alternative = %s, null AUC0 = %s, prevalence = %s (one-sided alpha = %s, power = %s).",
              ssr_fmt_val(auc_val), ssr_fmt_val(auc0), ssr_fmt_val(prev_val), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Determine critical values: one-sided Z_alpha = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      "Step 3: Evaluate Hanley-McNeil variance under alternative V(AUC) and null V(AUC0).",
      "Step 4: Calculate target cases: n_cases = [Z_alpha*sqrt(V(AUC0)) + Z_beta*sqrt(V(AUC))]^2 / (AUC - AUC0)^2.",
      sprintf("Step 5: Round up to integer: Target cases needed = %s, Total subjects to screen = %s.",
              ssr_fmt_val(cases), ssr_fmt_val(screen))
    ))
  }

  # 25. AUC comparison
  if (dtype == "AUC comparison (two tests)") {
    auc1 <- ssr_param(p, "auc1")
    auc2 <- ssr_param(p, "auc2")
    r_val <- ssr_param(p, "correlation") %||% ssr_param(p, "r")
    prev_val <- ssr_param(p, "prevalence", 1)
    cases <- ssr_metric(x, "target_state_cases_needed")
    screen <- ssr_metric(x, "total_subjects_to_screen")

    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)

    return(c(
      sprintf("Step 1: Specify AUC1 = %s, AUC2 = %s, correlation r = %s, prevalence = %s (alpha = %s, power = %s).",
              ssr_fmt_val(auc1), ssr_fmt_val(auc2), ssr_fmt_val(r_val), ssr_fmt_val(prev_val), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      "Step 3: Evaluate pooled Hanley-McNeil variance V(AUC_avg).",
      "Step 4: Calculate target cases: n_cases = 2 * (Z_(alpha/2) + Z_beta)^2 * V(AUC) * (1 - r) / (AUC1 - AUC2)^2.",
      sprintf("Step 5: Round up to integer: Target cases needed = %s, Total subjects to screen = %s.",
              ssr_fmt_val(cases), ssr_fmt_val(screen))
    ))
  }

  # 26. Cluster RCT
  if (grepl("Cluster RCT", dtype)) {
    icc <- ssr_param(p, "icc")
    m_val <- ssr_param(p, "cluster_size")
    de <- ssr_param(p, "design_effect") %||% (1 + (m_val - 1) * icc)
    k <- ssr_metric(x, "n_clusters")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n")

    return(c(
      "Step 1: Compute individual-level sample size without clustering from standard two-group formulas.",
      sprintf("Step 2: Calculate design effect (inflation factor): DE = 1 + (cluster_size - 1) * ICC = 1 + (%s - 1) * %s = %s.",
              ssr_fmt_val(m_val), ssr_fmt_val(icc), ssr_fmt_val(de)),
      "Step 3: Inflate sample size for clustering: n_clustered = n_individual * DE.",
      sprintf("Step 4: Determine clusters required per arm: n_clusters = ceiling(n_clustered / cluster_size) = %s.",
              ssr_fmt_val(k)),
      sprintf("Step 5: Total individuals per arm = %s * %s = %s; Total sample size N = %s.",
              ssr_fmt_val(k), ssr_fmt_val(m_val), ssr_fmt_val(n_per_group), ssr_fmt_val(total_n))
    ))
  }

  # 27. Bioequivalence
  if (grepl("Bioequivalence", dtype)) {
    cv <- ssr_param(p, "cv")
    theta0 <- ssr_param(p, "theta0", 1.0)
    low <- ssr_param(p, "margin_low", 0.8)
    high <- ssr_param(p, "margin_high", 1.25)
    n_seq <- ssr_metric(x, "n_required") %||% ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n", if (!is.null(n_seq)) 2L * n_seq)
    pwr_ach <- ssr_metric(x, "power_achieved")
    sigma_w <- sqrt(log(1 + cv^2))

    return(c(
      sprintf("Step 1: Intra-subject variance on log scale: sigma_w = sqrt(ln(1 + CV^2)) = sqrt(ln(1 + %s^2)) = %s.",
              ssr_fmt_val(cv), ssr_fmt_val(sigma_w)),
      sprintf("Step 2: Standard BE log-scale boundaries: [ln(%s), ln(%s)] = [%s, %s].",
              ssr_fmt_val(low), ssr_fmt_val(high), ssr_fmt_val(log(low)), ssr_fmt_val(log(high))),
      sprintf("Step 3: Two One-Sided Tests (TOST) under assumed geometric mean ratio theta0 = %s.",
              ssr_fmt_val(theta0)),
      "Step 4: Search sequence sample size n by evaluating the difference of noncentral t distribution probabilities (Phillips 1990; df = 2n - 2).",
      sprintf("Step 5: Required sample size: n = %s per sequence (achieved power = %s, Total N = %s).",
              ssr_fmt_val(n_seq), ssr_fmt_val(pwr_ach), ssr_fmt_val(total_n))
    ))
  }

  # 28. Simon two-stage
  if (grepl("Simon", dtype)) {
    p0 <- ssr_param(p, "p0")
    p1 <- ssr_param(p, "p1")
    opt <- ssr_param(p, "optimizer", "optimal")
    n1 <- ssr_metric(x, "n_stage_1")
    r1 <- ssr_metric(x, "r_stage_1")
    n_tot <- ssr_metric(x, "n_total")
    r_tot <- ssr_metric(x, "r_total")
    en0 <- ssr_metric(x, "expected_n_under_h0")

    return(c(
      sprintf("Step 1: State phase II hypotheses: H0: p <= %s (unacceptable) vs H1: p >= %s (promising) (alpha = %s, power = %s).",
              ssr_fmt_val(p0), ssr_fmt_val(p1), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      sprintf("Step 2: Exhaustive exact binomial search under '%s' criterion.", opt),
      sprintf("Step 3: Stage 1: Accrue n1 = %s patients; stop early for futility if responses <= r1 = %s.",
              ssr_fmt_val(n1), ssr_fmt_val(r1)),
      sprintf("Step 4: Stage 2: If > %s responses observed, accrue additional %s patients up to total n = %s.",
              ssr_fmt_val(r1), ssr_fmt_val(n_tot - n1), ssr_fmt_val(n_tot)),
      sprintf("Step 5: Final decision: Declare effective if total responses > r = %s (Expected sample size under H0 = %s).",
              ssr_fmt_val(r_tot), ssr_fmt_val(en0))
    ))
  }

  # 29. A'Hern single stage
  if (grepl("A'Hern", dtype)) {
    p0 <- ssr_param(p, "p0")
    p1 <- ssr_param(p, "p1")
    n_req <- ssr_metric(x, "n_required") %||% ssr_metric(x, "target_state_cases_needed")
    r_crit <- ssr_metric(x, "r_total") %||% ssr_metric(x, "critical_successes")
    act_a <- ssr_metric(x, "actual_alpha")
    act_p <- ssr_metric(x, "actual_power")

    return(c(
      sprintf("Step 1: State phase II hypotheses: H0: p <= %s vs H1: p >= %s (alpha = %s, power = %s).",
              ssr_fmt_val(p0), ssr_fmt_val(p1), ssr_fmt_val(alpha), ssr_fmt_val(power)),
      "Step 2: Exact binomial search for smallest n and cutoff r such that P(X >= r | p0) <= alpha and P(X >= r | p1) >= power.",
      sprintf("Step 3: Minimum sample size: n = %s patients.", ssr_fmt_val(n_req)),
      sprintf("Step 4: Decision rule: Declare treatment promising if >= %s responses observed (actual alpha = %s, power = %s).",
              ssr_fmt_val(r_crit), ssr_fmt_val(act_a), ssr_fmt_val(act_p))
    ))
  }

  # 30. Ordered categorical (Whitehead)
  if (grepl("ordered categorical", dtype, ignore.case = TRUE)) {
    or_val <- ssr_param(p, "or")
    prop_bar <- ssr_param(p, "prop_bar")
    n_per_group <- ssr_metric(x, "n_per_group")
    total_n <- ssr_metric(x, "total_n")
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- stats::qnorm(power)

    return(c(
      sprintf("Step 1: Specify odds ratio OR = %s, pooled proportion categories = %s.",
              ssr_fmt_val(or_val), ssr_fmt_val(prop_bar)),
      sprintf("Step 2: Determine critical values: Z_(alpha/2) = %s, Z_beta = %s.",
              ssr_fmt_val(z_a), ssr_fmt_val(z_b)),
      "Step 3: Compute Whitehead variance factor: 1 - sum(p_bar_j^3).",
      "Step 4: Whitehead formula: N = 3 * (Z_(alpha/2) + Z_beta)^2 / [(ln OR)^2 * (1 - sum(p_bar^3))].",
      sprintf("Step 5: Round up to integer: Total sample size N = %s, per group n = %s.",
              ssr_fmt_val(total_n), ssr_fmt_val(n_per_group))
    ))
  }

  # 31. Prediction EPV
  if (grepl("events-per-variable", dtype, ignore.case = TRUE) ||
      grepl("EPV", dtype, ignore.case = TRUE)) {
    k <- ssr_param(p, "n_parameters")
    epv <- ssr_param(p, "epv", 10)
    prev <- ssr_param(p, "event_prevalence")
    events <- ssr_metric(x, "events_required")
    tot <- ssr_metric(x, "total_n")

    return(c(
      sprintf("Step 1: Specify candidate predictor parameters k = %s, Events Per Variable target EPV = %s.",
              ssr_fmt_val(k), ssr_fmt_val(epv)),
      sprintf("Step 2: Calculate required events: n_events = EPV * k = %s * %s = %s.",
              ssr_fmt_val(epv), ssr_fmt_val(k), ssr_fmt_val(events)),
      if (!is.null(prev)) {
        sprintf("Step 3: Convert to subjects using event prevalence pi = %s: n_subjects = n_events / prevalence = %s.",
                ssr_fmt_val(prev), ssr_fmt_val(tot))
      } else {
        "Step 3: Overall subject count depends on event prevalence in target population."
      },
      sprintf("Step 4: Required events = %s%s.",
              ssr_fmt_val(events),
              if (!is.null(tot)) sprintf(", Total subjects = %s", ssr_fmt_val(tot)) else "")
    ))
  }

  # Generic fallback: informative structured summary of calculation
  steps <- character()
  steps <- c(steps, sprintf("Step 1: Identify study design: %s.", dtype))
  if (length(p) > 0) {
    p_strs <- vapply(names(p), function(nm) sprintf("%s = %s", nm, ssr_fmt_val(p[[nm]])), character(1))
    steps <- c(steps, sprintf("Step 2: Input parameters: %s.", paste(p_strs, collapse = ", ")))
  }
  if (!is.null(x$formula) && nzchar(x$formula)) {
    steps <- c(steps, sprintf("Step 3: Apply design formula: %s.", x$formula))
  }
  metric_values <- x$results %||% x
  metrics <- ssr_collect_metrics(metric_values)
  if (length(metrics) > 0) {
    m_strs <- vapply(metrics, function(m) sprintf("%s: %s", ssr_metric_labels[[m]], ssr_fmt_val(metric_values[[m]])), character(1))
    steps <- c(steps, sprintf("Step 4: Calculated sample size metrics: %s.", paste(m_strs, collapse = "; ")))
  }
  steps
}

#' Retrieve calculation steps from an object or generate them dynamically
#' @noRd
ssr_get_calculation <- function(x) {
  if (!is.null(x$calculation_steps) && length(x$calculation_steps) > 0) {
    return(x$calculation_steps)
  }
  if (!is.null(x$calculation) && length(x$calculation) > 0) {
    return(x$calculation)
  }
  generate_calculation_steps(x)
}
