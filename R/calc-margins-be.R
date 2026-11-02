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
      "Sample Size Calculations in Clinical Research (3rd ed.). CRC Press",
      "(margin designs); Machin et al. (2018) Ch.11.\n\n",
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

  list(
    design_type = design_label,
    target_state_cases_needed = as.integer(ceiling(n_cases)),
    total_subjects_to_screen = as.integer(ceiling(n_cases * 2)),
    parameters = list(
      auc1 = auc1, auc2 = auc2, r = r, margin = margin, task = task,
      var_method = var_method, alpha = alpha, power = power
    ),
    formula = formula_ascii,
    formula_latex = if (task == "noninferiority") {
      "$$n = \\frac{2(Z_{\\alpha}+Z_{\\beta})^2 V(1-r)}{(AUC_1-AUC_2+\\Delta)^2}$$"
    } else {
      "$$n = \\frac{2(Z_{\\alpha}+Z_{\\beta/2})^2 V(1-r)}{(\\Delta-|AUC_1-AUC_2|)^2}$$"
    },
    reference = paste(
      "Framework: margin designs per Chow et al. (2017); Machin et al. (2018)",
      "Ch.11. AUC variance per Zhou et al. (2011) Eq 6.4/6.5/6.6.\n\n",
      "Diagnostic application: Zhou et al. (2011) Section 6.3, pp. 214-218."
    ),
    roles = c(
      "auc1/auc2 = anticipated ROC areas of the new/reference test",
      "r = expected correlation between the two AUC estimates (paired designs)",
      "margin = non-inferiority/equivalence margin on the AUC difference"
    )
  )
}

# ----------------------------------------------------- crossover / BE ----

#' 2x2 crossover, continuous outcome (within-subject SD parameterization)
#'
#' Var(within-subject difference) = 2*sigma_w^2 (between-subject variance
#' cancels), so n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2.
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
  n <- 2 * (z_a + z_b)^2 * sigma_within^2 / delta^2

  list(
    design_type = "2x2 crossover trial (continuous)",
    n_required = as.integer(ceiling(n)),
    total_n = as.integer(ceiling(n)) * 2L, # per sequence; total = 2n
    parameters = list(
      delta = delta, sigma_within = sigma_within, alpha = alpha, power = power
    ),
    formula = "n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2 (per sequence)",
    formula_latex = "$$n = \\frac{2(Z_{\\alpha/2}+Z_{\\beta})^2\\sigma_w^2}{\\delta^2}$$",
    reference = paste(
      "Primary: Senn, S. (2002). Cross-over Trials in Clinical Research",
      "(2nd ed.). Wiley.\n\n",
      "Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes",
      "for clinical trials with normal data. Statistics in Medicine, 23,",
      "1921-1986 (crossover section)."
    ),
    roles = c(
      "delta = anticipated treatment difference (mu_T - mu_R)",
      "sigma_within = within-subject standard deviation",
      "n is per sequence; total subjects = 2n (each receives both treatments)"
    )
  )
}

#' Bioequivalence (2x2 crossover, TOST on the log scale, 80-125%)
#'
#' sigma_w^2 = log(1 + CV^2); n = 2 (Z_(1-alpha) + Z_(1-beta))^2 sigma_w^2 /
#' log(1.25)^2 with expected difference 0 (Julious 2004; Schuirmann 1987).
#' @keywords internal
calculate_bioequivalence <- function(cv, alpha, power) {
  if (!is.numeric(cv) || length(cv) != 1 || cv <= 0 || cv >= 1) {
    cli::cli_abort("{.arg cv} (intra-subject CV) must be in (0, 1).")
  }

  sigma_w_sq <- log(1 + cv^2)
  theta <- log(1.25)
  z_a <- stats::qnorm(1 - alpha) # one-sided TOST
  z_b <- z_power(power)
  n <- 2 * (z_a + z_b)^2 * sigma_w_sq / theta^2

  hints <- if (cv > 0.30) {
    "CV > 30%: consider replicate designs (reference-scaled ABE per FDA/EMA guidance)."
  } else {
    character()
  }

  list(
    design_type = "Bioequivalence (2x2 crossover, TOST log-scale)",
    n_required = as.integer(ceiling(n)),
    total_n = as.integer(ceiling(n)) * 2L,
    parameters = list(
      cv = cv, sigma_w_sq = sigma_w_sq,
      margin_log = theta, alpha = alpha, power = power
    ),
    formula = "n = 2 (Z_1-a + Z_1-b)^2 log(1+CV^2) / log(1.25)^2",
    formula_latex = "$$n = \\frac{2\\,(Z_{1-\\alpha}+Z_{1-\\beta})^2\\,\\log(1+CV^2)}{\\log(1.25)^2}$$",
    reference = paste(
      "Primary: Schuirmann, D. J. (1987). A comparison of the two one-sided",
      "tests procedure and the power approach for assessing the equivalence of",
      "average bioavailability. Journal of Pharmacokinetics and Biopharmaceutics,",
      "15(6), 657-680.\n\n",
      "Also: Julious, S. A. (2004). Statistics in Medicine, 23, 1921-1986",
      "(bioequivalence sample sizes); Chow & Liu (2009) Design and Analysis of",
      "Bioavailability and Bioequivalence Studies."
    ),
    roles = c(
      "cv = intra-subject coefficient of variation (log scale implied)",
      "margin = 80-125% average BE criterion (log 1.25)",
      "n is per sequence; total subjects = 2n"
    ),
    hints = hints
  )
}
