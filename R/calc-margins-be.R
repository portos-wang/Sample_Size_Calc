# Phase 4: diagnostic non-inferiority/equivalence margins (proportion + AUC),
# 2x2 crossover, and bioequivalence (TOST on the log scale).
# Framework: standard margin designs (Chow et al. 2017; Machin 2018 Ch.11);
# Zhou 2011 Section 6.3 discusses the diagnostic-specific application
# (pp. 214-218).

# ------------------------------------------------- diagnostic margins ----

#' Two-proportion margin designs (non-inferiority / equivalence)
#' @keywords internal
calculate_diag_compare_margin_prop <- function(p1, p2, margin, alpha, power,
                                               task, prevalence) {
  if (!is.numeric(p1) || p1 <= 0 || p1 >= 1) cli::cli_abort("{.arg p1} must be in (0, 1).")
  if (!is.numeric(p2) || p2 <= 0 || p2 >= 1) cli::cli_abort("{.arg p2} must be in (0, 1).")
  if (!is.numeric(margin) || margin <= 0 || margin >= 1) {
    cli::cli_abort("{.arg margin} must be in (0, 1).")
  }
  task <- rlang::arg_match(task, c("noninferiority", "equivalence"))

  diff <- p1 - p2
  if (task == "noninferiority") {
    # H0: p1 - p2 <= -margin; one-sided alpha (matches legacy NI convention)
    delta_e <- diff + margin
    if (delta_e <= 0) {
      cli::cli_abort(c(
        "Non-inferiority margin not met.",
        "x" = "p1 - p2 + margin = {.val {delta_e}} <= 0"
      ))
    }
    z_a <- z_alpha(alpha, "one.sided")
    z_b <- z_power(power)
    formula_ascii <- "n = (Za+Zb)^2 * (p1q1+p2q2) / (p1-p2+margin)^2"
    formula_latex <- "$$n = \\frac{(Z_{\\alpha}+Z_{\\beta})^2\\left[p_1(1-p_1)+p_2(1-p_2)\\right]}{(p_1-p_2+\\Delta)^2}$$"
    design_label <- "Diagnostic non-inferiority (two proportions)"
  } else {
    delta_e <- margin - abs(diff)
    if (delta_e <= 0) {
      cli::cli_abort(c(
        "Equivalence margin must exceed |p1 - p2|.",
        "x" = "margin - |p1-p2| = {.val {delta_e}} <= 0"
      ))
    }
    z_a <- z_alpha(alpha, "one.sided")
    z_b <- stats::qnorm(1 - (1 - power) / 2) # Z_{beta/2}
    formula_ascii <- "n = (Za+Zb/2)^2 * (p1q1+p2q2) / (margin-|p1-p2|)^2"
    formula_latex <- "$$n = \\frac{(Z_{\\alpha}+Z_{\\beta/2})^2\\left[p_1(1-p_1)+p_2(1-p_2)\\right]}{(\\Delta-|p_1-p_2|)^2}$$"
    design_label <- "Diagnostic equivalence (two proportions)"
  }

  n_per_group <- (z_a + z_b)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / delta_e^2
  prev_val <- if (is.null(prevalence)) 1 else prevalence

  list(
    design_type = design_label,
    n_per_group = as.integer(ceiling(n_per_group)),
    total_n = as.integer(ceiling(n_per_group)) * 2L,
    target_state_cases_needed = as.integer(ceiling(n_per_group)),
    total_subjects_to_screen = as.integer(ceiling(n_per_group / prev_val)),
    parameters = list(
      p1 = p1, p2 = p2, margin = margin, task = task,
      prevalence = prev_val, alpha = alpha, power = power
    ),
    formula = formula_ascii,
    formula_latex = formula_latex,
    reference = paste(
      "Framework: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017).",
      "Sample Size Calculations in Clinical Research (3rd ed.). CRC Press.",
      "Chapter 4, Section 4.2.2 (noninferiority/superiority) and 4.2.3",
      "(equivalence), Eq 4.8-4.9, pp. 78-79. Machin et al. (2018) Ch.11,",
      "Eq 11.5-11.6, p. 174.\n\n",
      "Diagnostic application: Zhou, X.-H., Obuchowski, N. A., & McClish,",
      "D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.),",
      "Section 6.3 (non-inferiority/equivalency of two tests), pp. 214-218."
    ),
    roles = c(
      "p1/p2 = expected sensitivities (or specificities) of the new/reference test",
      "margin = non-inferiority/equivalence margin Delta",
      "non-inferiority uses one-sided alpha; equivalence uses Z_{beta/2}"
    )
  )
}

#' AUC margin designs (non-inferiority / equivalence of two ROC areas)
#' @keywords internal
calculate_diag_auc_compare_margin <- function(auc1, auc2, r, margin, alpha,
                                              power, task, var_method) {
  if (!is.numeric(auc1) || auc1 <= 0 || auc1 >= 1) cli::cli_abort("{.arg auc1} must be in (0, 1).")
  if (!is.numeric(auc2) || auc2 <= 0 || auc2 >= 1) cli::cli_abort("{.arg auc2} must be in (0, 1).")
  if (!is.numeric(margin) || margin <= 0 || margin >= 1) {
    cli::cli_abort("{.arg margin} must be in (0, 1).")
  }
  if (!is.numeric(r) || r < 0 || r >= 1) cli::cli_abort("{.arg r} must be in [0, 1).")
  task <- rlang::arg_match(task, c("noninferiority", "equivalence"))

  A_avg <- (auc1 + auc2) / 2
  V <- auc_variance(A_avg, 1, var_method) # R=1 for the variance function
  diff <- auc1 - auc2

  if (task == "noninferiority") {
    delta_e <- diff + margin
    if (delta_e <= 0) {
      cli::cli_abort(c(
        "Non-inferiority margin not met.",
        "x" = "auc1 - auc2 + margin = {.val {delta_e}} <= 0"
      ))
    }
    z_a <- z_alpha(alpha, "one.sided")
    z_b <- z_power(power)
    design_label <- "Diagnostic non-inferiority (two ROC areas)"
    formula_ascii <- "n = 2(Za+Zb)^2 * V * (1-r) / (auc1-auc2+margin)^2"
  } else {
    delta_e <- margin - abs(diff)
    if (delta_e <= 0) {
      cli::cli_abort(c(
        "Equivalence margin must exceed |auc1 - auc2|.",
        "x" = "margin - |auc1-auc2| = {.val {delta_e}} <= 0"
      ))
    }
    z_a <- z_alpha(alpha, "one.sided")
    z_b <- stats::qnorm(1 - (1 - power) / 2)
    design_label <- "Diagnostic equivalence (two ROC areas)"
    formula_ascii <- "n = 2(Za+Zb/2)^2 * V * (1-r) / (margin-|auc1-auc2|)^2"
  }

  n_cases <- 2 * (z_a + z_b)^2 * V * (1 - r) / delta_e^2

  c(list(
    design_type = design_label
  ), auc_sample_sizes(n_cases, auc_sampling(ratio = 1)), list(
    parameters = list(
      auc1 = auc1, auc2 = auc2, r = r, margin = margin, task = task,
      ratio_R = 1, sampling = "case_control",
      var_method = var_method, alpha = alpha, power = power
    ),
    formula = formula_ascii,
    formula_latex = if (task == "noninferiority") {
      "$$n = \\frac{2(Z_{\\alpha}+Z_{\\beta})^2 V(1-r)}{(AUC_1-AUC_2+\\Delta)^2}$$"
    } else {
      "$$n = \\frac{2(Z_{\\alpha}+Z_{\\beta/2})^2 V(1-r)}{(\\Delta-|AUC_1-AUC_2|)^2}$$"
    },
    reference = paste(
      "Framework: margin designs per Chow et al. (2017) Ch.4 Eq 4.8-4.9",
      "(pp. 78-79) and Machin et al. (2018) Ch.11 Eq 11.5-11.6 (p. 174).",
      "AUC variance per Zhou et al. (2011) Eq 6.4/6.5/6.6.\n\n",
      "Diagnostic application: Zhou et al. (2011) Section 6.3, pp. 214-218."
    ),
    roles = c(
      "auc1/auc2 = anticipated ROC areas of the new/reference test",
      "r = expected correlation between the two AUC estimates (paired designs)",
      "margin = non-inferiority/equivalence margin on the AUC difference",
      "equal case and control quotas are rounded before summing total_subjects"
    )
  ))
}

# ----------------------------------------------------- crossover / BE ----

#' 2x2 crossover, continuous outcome (within-subject SD parameterization)
#'
#' Var(within-subject difference) = 2*sigma_w^2 (the between-subject variance
#' cancels), so the **total** number of subjects is
#' n_total = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2, and each of the two sequences
#' carries half of it. Julious (2004) Eq 6.6 writes the same expression with
#' sigma_w being the within-subject SD on the log scale and n the total sample
#' size; PowerTOST and Julious both then report the sample size per sequence
#' (n_total / 2) for a 2x2 design.
#'
#' Anchor: Julious 2004 Section 3.3.3 equivalence worked example - with
#' sigma_w^2 = 2 and a 20% acceptance criterion on the log scale, the total is
#' 106 subjects (53 per sequence) at 2.5% Type I and 10% Type II error.
#' @keywords internal
calculate_crossover_mean <- function(delta, sigma_within, alpha, power) {
  if (!is.numeric(delta) || length(delta) != 1 || delta <= 0) {
    cli::cli_abort("{.arg delta} (absolute treatment difference) must be > 0.")
  }
  if (!is.numeric(sigma_within) || length(sigma_within) != 1 || sigma_within <= 0) {
    cli::cli_abort("{.arg sigma_within} must be a single positive number.")
  }

  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  n_total <- 2 * (z_a + z_b)^2 * sigma_within^2 / delta^2
  n_per_sequence <- ceiling(n_total / 2)

  list(
    design_type = "2x2 crossover trial (continuous)",
    n_required = as.integer(n_per_sequence),
    n_per_sequence = as.integer(n_per_sequence),
    total_n = as.integer(2L * n_per_sequence),
    parameters = list(
      delta = delta, sigma_within = sigma_within, alpha = alpha, power = power
    ),
    formula = "n_total = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2 ; n_per_sequence = n_total/2",
    formula_latex = "$$n_{\\text{total}} = \\frac{2(Z_{\\alpha/2}+Z_{\\beta})^2\\sigma_w^2}{\\delta^2}, \\quad n_{\\text{sequence}} = \\frac{n_{\\text{total}}}{2}$$",
    reference = paste(
      "Primary: Senn, S. (2002). Cross-over Trials in Clinical Research",
      "(2nd ed.). Wiley. Section 9.5 'Sample-size issues', Eq 9.18-9.20,",
      "pp. 278-280 (sigma^2 = 2 sigma_w^2 for a basic estimator, Var = sigma^2/n,",
      "df = n - 2, n = total patients with n/2 per sequence).\n\n",
      "Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes",
      "for clinical trials with normal data. Statistics in Medicine, 23(12),",
      "1921-1986 (Section 6.3 'Cross-over trials', Eq 6.3/6.6; n there is the",
      "total sample size, and the reported quantity is per sequence)."
    ),
    roles = c(
      "delta = anticipated treatment difference (mu_T - mu_R)",
      "sigma_within = within-subject standard deviation",
      "n_required/n_per_sequence = subjects per sequence; total_n = 2 x that"
    ),
    hints = c(
      paste(
        "This is the normal-approximation form (Julious 2004 Eq 6.6; Machin",
        "Eq 11.4). Senn (2002) Section 9.5.1, Eq 9.18-9.20, refines it with a",
        "Student t correction (df = n - 2), which typically needs 1-2 extra",
        "subjects; use the returned total as a lower bound and add 2 for exact",
        "80% power."
      )
    )
  )
}

#' Bioequivalence (2x2 crossover, exact TOST noncentral t, 80-125%)
#'
#' Evaluates exact joint power of the two one-sided tests (TOST) by
#' integrating the conditional normal acceptance probability over the
#' independent chi-square variance estimate (Phillips 1990).
#' Uses balanced even totals and reports an error if the target power
#' cannot be reached within 10000 participants.
#' Matches sampleN.TOST in the PowerTOST package exactly.
#'
#' @param cv Intra-subject coefficient of variation
#' @param alpha Type I error (one-sided per test, default 0.05)
#' @param power Target power (default 0.80)
#' @param theta0 Anticipated T/R geometric mean ratio (default 1.0)
#' @param margin_low Lower equivalence margin (default 0.80)
#' @param margin_high Upper equivalence margin (default 1.25)
#' @return List with sample size results consumed by as_sample_size_result()
#' @keywords internal
calculate_bioequivalence <- function(cv, alpha, power, theta0 = 1.0,
                                     margin_low = 0.8, margin_high = 1.25) {
  if (!is.numeric(cv) || length(cv) != 1 || cv <= 0 || cv >= 1) {
    cli::cli_abort("{.arg cv} (intra-subject CV) must be in (0, 1).")
  }
  if (!is.numeric(theta0) || length(theta0) != 1 || theta0 <= margin_low || theta0 >= margin_high) {
    cli::cli_abort(c(
      "{.arg theta0} must be strictly within the bioequivalence limits.",
      "x" = "You provided theta0 = {.val {theta0}}, limits = [{.val {margin_low}}, {.val {margin_high}}]."
    ))
  }
  if (!is.numeric(margin_low) || !is.numeric(margin_high) || margin_low >= margin_high) {
    cli::cli_abort("{.arg margin_low} must be less than {.arg margin_high}.")
  }

  sigma_w_sq <- log(1 + cv^2)
  lth1 <- log(margin_low)
  lth2 <- log(margin_high)
  diffm <- log(theta0)

  # Conditional normal probabilities integrated over the variance estimate.
  # The probability transform avoids a sharply concentrated chi-square density.
  tost_power_fn <- function(N) {
    df <- N - 2
    sem <- sqrt(sigma_w_sq * 2 / N)
    tval <- stats::qt(1 - alpha, df)
    variance_bound <- ((lth2 - lth1) / (2 * tval * sem))^2
    upper_probability <- stats::pchisq(df * variance_bound, df)
    if (upper_probability == 0) return(0)
    integrand <- function(u) {
      critical <- tval * sqrt(stats::qchisq(u, df) / df)
      pmax(0, stats::pnorm((lth2 - diffm) / sem - critical) -
        stats::pnorm((lth1 - diffm) / sem + critical))
    }
    stats::integrate(integrand, lower = 0, upper = upper_probability,
      rel.tol = 1e-8, abs.tol = 1e-10, subdivisions = 200L)$value
  }

  upper <- 2L
  while (tost_power_fn(2L * upper) < power && upper < 5000L) {
    upper <- min(2L * upper, 5000L)
  }
  if (tost_power_fn(2L * upper) < power) {
    cli::cli_abort(c(
      "No bioequivalence design reaches the requested power within 10000 participants.",
      "i" = "Power at the search limit is {.val {round(tost_power_fn(2L * upper), 4)}}; target is {.val {power}}."
    ))
  }
  lower <- 2L
  while (lower < upper) {
    middle <- lower + as.integer(floor((upper - lower) / 2))
    if (tost_power_fn(2L * middle) >= power) upper <- middle else lower <- middle + 1L
  }
  n_per_seq <- lower
  n_total <- 2L * n_per_seq
  exact_power <- tost_power_fn(n_total)
  achieved_pow <- round(exact_power, 4)

  hints <- character()
  if (cv > 0.30) {
    hints <- c(hints, "CV > 30%: consider replicate designs (reference-scaled ABE per FDA/EMA guidance).")
  }

  list(
    design_type = "Bioequivalence (2x2 crossover, exact TOST integration)",
    n_required = n_per_seq,
    total_n = n_total,
    power_achieved = achieved_pow,
    power_unrounded = exact_power,
    calculation = c(
      sprintf("Step 1: Log-scale within-subject SD = sqrt(log(1+CV^2)) = %.6f; anticipated log ratio = %.6f.", sqrt(sigma_w_sq), diffm),
      sprintf("Step 2: TOST log limits are [%.6f, %.6f], each with one-sided alpha %.4f.", lth1, lth2, alpha),
      "Step 3: Integrate the conditional normal acceptance probability over the chi-square variance estimate (df = N-2); negative-width acceptance intervals contribute zero.",
      "Step 4: Search balanced even totals for the smallest N meeting the target power.",
      sprintf("Step 5: n = %d per sequence, total N = %d, achieved power = %.6f (target %.4f).", n_per_seq, n_total, exact_power, power)
    ),
    parameters = list(
      cv = cv, sigma_w_sq = sigma_w_sq,
      theta0 = theta0, margin_low = margin_low, margin_high = margin_high,
      alpha = alpha, power = power
    ),
    formula = "power = E[max(0, Phi((U-mu)/SE-t*sqrt(V/df))-Phi((L-mu)/SE+t*sqrt(V/df)))], V ~ chi-square(df), df=N-2",
    formula_latex = "$$\\mathrm{Power}=E\\!\\left[\\max\\!\\left\\{0,\\Phi\\!\\left(\\frac{U-\\mu}{SE}-t\\sqrt{V/\\nu}\\right)-\\Phi\\!\\left(\\frac{L-\\mu}{SE}+t\\sqrt{V/\\nu}\\right)\\right\\}\\right],\\quad V\\sim\\chi^2_\\nu,\\ \\nu=N-2$$",
    reference = paste(
      "Primary: Phillips, K. F. (1990). Power of the two one-sided tests procedure",
      "in bioequivalence. Journal of Pharmacokinetics and Biopharmaceutics, 18(2), 137-144.\n\n",
      "Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes for",
      "clinical trials with normal data. Statistics in Medicine, 23(12), 1921-1986",
      "(Section 6.3 'Cross-over trials', Eq 6.1-6.9; the non-central t power",
      "expression is Eq 6.8).\n",
      "Schuirmann, D. J. (1987). J Pharmacokinet Biopharm, 15(6), 657-680;\n",
      "Chow & Liu (2009). Design and Analysis of Bioavailability and Bioequivalence Studies."
    ),
    roles = c(
      "cv = intra-subject coefficient of variation (log scale implied)",
      "theta0 = anticipated geometric mean ratio (true ratio, default 1.0)",
      sprintf("margin = [%.2f, %.2f] average BE criteria", margin_low, margin_high),
      "n is per sequence; total subjects = 2n"
    ),
    hints = hints
  )
}
