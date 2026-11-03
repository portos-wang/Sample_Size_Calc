# Phase 2 diagnostic estimation upgrades.
# Anchors: docs/NUMERIC_ANCHORS.md A3/A4/A5.
# Legacy functions (calculate_diagnostic_accuracy_single, calculate_auc_single,
# calculate_likelihood_ratio_test) keep their exact behavior for golden master
# compatibility; the calculate() three-axis path routes to these upgraded
# implementations via the upgrade_diag_estimation hook below.

# ---------------------------------------------------------------- A3 upgrade

#' Upgraded diagnostic accuracy: Zhou Eq 6.1 (CI width + power),
#' Eq 6.2 (precision), Eq 6.3 (prevalence guarantee) — Zhou 2011 pp.194-196
#' @keywords internal
calculate_diagnostic_accuracy_v2 <- function(prob, d, prevalence, alpha, power,
                                             ci_method) {
  p_val <- prob
  d_val <- d
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  ci_method <- rlang::arg_match(ci_method, c("precision", "ci_width_power"))

  if (ci_method == "precision") {
    # Eq 6.2 (matches legacy formula): n = z^2 * p(1-p) / d^2
    z <- stats::qnorm(1 - alpha / 2)
    n_cases <- (z^2 * p_val * (1 - p_val)) / (d_val^2)
    formula_ascii <- "N_cases = (Z_1-a/2)^2 * P*(1-P)/d^2"
    formula_latex <- "$$n_{cases} = \\frac{Z_{1-\\alpha/2}^2 \\cdot p(1-p)}{d^2}$$"
    method_note <- "CI half-width d (precision method, Zhou Eq 6.2)"
  } else {
    # Eq 6.1: with probability 1-beta, CI width <= 2L (Flahault 2005)
    z_a <- stats::qnorm(1 - alpha / 2)
    z_b <- z_power(power)
    n_cases <- ((z_a + z_b)^2 * p_val * (1 - p_val)) / (d_val^2)
    formula_ascii <- "N_cases = (Z_a/2 + Z_b)^2 * P*(1-P)/d^2"
    formula_latex <- "$$n_{cases} = \\frac{(Z_{\\alpha/2} + Z_{\\beta})^2 \\cdot p(1-p)}{d^2}$$"
    method_note <- sprintf(
      "CI half-width d with %d%% probability (Zhou Eq 6.1, Flahault 2005)",
      round(100 * power)
    )
  }

  list(
    design_type = "Diagnostic accuracy (single)",
    target_state_cases_needed = as.integer(ceiling(n_cases)),
    total_subjects_to_screen = as.integer(ceiling(n_cases / prev_val)),
    parameters = list(
      prob = p_val,
      precision = d_val,
      prevalence = prev_val,
      alpha = alpha,
      power = if (ci_method == "ci_width_power") power,
      ci_method = ci_method
    ),
    formula = formula_ascii,
    formula_latex = formula_latex,
    reference = paste(
      "Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011).",
      "Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley.",
      "Section 6.1.1, pp. 194-196 (Eq 6.1/6.2/6.3; SPECT worked example).\n\n",
      "Also: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
      "test studies of biomedical informatics. Journal of Biomedical",
      "Informatics, 48, 193-204 (Section 6.1).\n\n",
      "Also: Akoglu, H. (2022). User's guide to sample size estimation in",
      "diagnostic accuracy studies. Turkish Journal of Emergency Medicine,",
      "22(4), 177-185 (Equations 1, 4a/4b)."
    ),
    roles = c(
      "prob = expected sensitivity or specificity (cases drive Se, non-cases drive Sp)",
      "precision = desired CI half-width L",
      "prevalence = disease prevalence for screening conversion (omit when cases/controls are recruited separately)",
      "ci_method = precision (Eq 6.2) or ci_width_power (Eq 6.1)"
    ),
    method_note = method_note
  )
}

# ---------------------------------------------------------------- A4 upgrade

#' Variance functions for the ROC area (Zhou 2011 Eq 6.4/6.5/6.6)
#' @keywords internal
auc_variance <- function(auc, ratio, var_method) {
  A <- auc
  R <- ratio
  var_method <- rlang::arg_match(var_method, c("exponential", "binormal", "conservative"))

  if (var_method == "exponential") {
    # Eq 6.4: V = Q1/R + Q2 - A^2 * (1/R + 1); Q1 = A/(2-A), Q2 = 2A^2/(1+A)
    Q1 <- A / (2 - A)
    Q2 <- (2 * A^2) / (1 + A)
    V <- Q1 / R + Q2 - A^2 * (1 / R + 1)
  } else if (var_method == "binormal") {
    # Eq 6.5 (Obuchowski 1994): V = 0.0099 * e^(-a^2/2) * ([5a^2+8] + [a^2+8]/R)
    a_param <- stats::qnorm(A) * 1.414
    V <- (0.0099 * exp(-a_param^2 / 2)) * ((5 * a_param^2 + 8) + (a_param^2 + 8) / R)
  } else {
    # Eq 6.6 (distribution-free bound): V = A * (1 - A)
    V <- A * (1 - A)
  }
  V
}

#' Upgraded AUC estimation: three variance functions, user-set case:control
#' ratio R — Zhou 2011 pp.196-199
#' @keywords internal
calculate_auc_single_v2 <- function(auc, d, prevalence, alpha, ratio, var_method) {
  A <- auc
  pDis <- if (is.null(prevalence)) 1 else prevalence

  # sampling = "caseControl": R is given directly; "clinical": R derived
  # from prevalence of non-diseased / diseased.
  R_val <- ratio
  sampling_note <- "case:control ratio R supplied directly"

  z <- stats::qnorm(1 - alpha / 2)
  V <- auc_variance(A, R_val, var_method)
  n_cases <- (z^2 * V) / (d^2)

  hints <- character()
  if (var_method == "exponential") {
    hints <- c(hints, paste(
      "The exponential-model variance (Zhou Eq 6.4) can underestimate variance",
      "for ordinal test results; consider var_method = 'binormal' (conservative,",
      "Obuchowski 1994) or 'conservative' (distribution-free)."
    ))
  }

  list(
    design_type = "Single-group AUC CI precision",
    target_state_cases_needed = as.integer(ceiling(n_cases)),
    total_subjects_to_screen = as.integer(ceiling(n_cases * (1 + R_val))),
    parameters = list(
      auc = A,
      precision = d,
      ratio_R = R_val,
      alpha = alpha,
      var_method = var_method
    ),
    formula = "N_cases = (Z_1-a/2 / d)^2 * V(AUC)",
    formula_latex = "$$n_{cases} = \\left(\\frac{Z_{1-\\alpha/2}}{d}\\right)^2 \\cdot V(AUC)$$",
    reference = paste(
      "Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011).",
      "Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley.",
      "Section 6.1.2, pp. 196-199 (Eq 6.4/6.5/6.6; CTC worked example).\n\n",
      "Original variance: Hanley, J. A., & McNeil, B. J. (1982). Radiology, 143(1), 29-36.\n",
      "Binormal variance: Obuchowski, N. A. (1994). Medical Decision Making, 14(2), 154-162."
    ),
    roles = c(
      "auc = anticipated area under the ROC curve",
      "precision = desired CI half-width L",
      "ratio = case:control ratio R (cases:non-cases; default 1)",
      sprintf("var_method = %s variance function", var_method)
    ),
    hints = hints,
    method_note = sampling_note
  )
}

# ---------------------------------------------------------------- A5 rewrite

#' Likelihood ratio sample size via log(LR) CI (Hajian-Tilaki Eq 6.13/6.14)
#'
#' Solves the CI-width equation for a target LR: given expected Se and Sp,
#' the LR+ (or LR-) is determined; n per group is found such that the
#' log-scale CI half-width does not exceed ln(target / LR_expected).
#' @keywords internal
calculate_likelihood_ratio_v2 <- function(sens, spec, prevalence, alpha,
                                          target_lr, lr_type) {
  lr_type <- rlang::arg_match(lr_type, c("positive", "negative"))
  prev_val <- if (is.null(prevalence)) 1 else prevalence

  if (lr_type == "positive") {
    lr_obs <- sens / (1 - spec)
  } else {
    lr_obs <- (1 - sens) / spec
  }
  if (lr_obs <= 0) {
    cli::cli_abort("Computed {.val {lr_type}} LR is non-positive; check sens/spec.")
  }

  # log(LR) CI: log(LR) +- z * sqrt( (1-Se)/(n1*Se) + (1-Sp)/(n2*Sp) )
  # with n1 = n2 = n (equal cases and controls per Hajian-Tilaki's examples).
  z <- stats::qnorm(1 - alpha / 2)
  target <- if (is.null(target_lr)) {
    cli::cli_abort(c(
      "{.arg target_lr} is required: the LR boundary value the CI must not cross.",
      "i" = "E.g. for LR- use the clinically acceptable upper limit (0.4 in the",
      "Hajian-Tilaki 2014 example)."
    ))
  } else {
    target_lr
  }

  log_half_width <- abs(log(target) - log(lr_obs))
  if (log_half_width == 0) {
    cli::cli_abort(
      "target_lr equals the observed LR; no sample size can separate them."
    )
  }

  var_term <- (1 - sens) / sens + (1 - spec) / spec
  n_per_group <- (z / log_half_width)^2 * var_term

  list(
    design_type = sprintf("Likelihood ratio (%s, log-CI method)", lr_type),
    cases_needed = as.integer(ceiling(n_per_group)),
    controls_needed = as.integer(ceiling(n_per_group)),
    total_subjects = as.integer(ceiling(n_per_group)) * 2,
    parameters = list(
      sensitivity = sens,
      specificity = spec,
      lr_type = lr_type,
      lr_observed = lr_obs,
      target_lr = target,
      prevalence = prev_val,
      alpha = alpha
    ),
    formula = "log(LR) +- Z * sqrt((1-Se)/(n*Se) + (1-Sp)/(n*Sp))",
    formula_latex = "$$\\log(LR) \\pm Z_{1-\\alpha/2}\\sqrt{\\frac{1-Se}{n \\cdot Se} + \\frac{1-Sp}{n \\cdot Sp}}$$",
    reference = paste(
      "Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
      "test studies of biomedical informatics. Journal of Biomedical Informatics,",
      "48, 193-204 (Section 6.4, Eqs 6.13/6.14; worked example n=80 per group).\n\n",
      "CI method: Simel, D. L., Samsa, G. P., & Matchar, D. B. (1991).",
      "Likelihood ratios with confidence: sample size estimation for accuracy",
      "of a diagnostic test. Journal of Clinical Epidemiology, 44(11), 1123-1130."
    ),
    roles = c(
      "sens/spec = expected sensitivity/specificity (determine the observed LR)",
      "target_lr = LR boundary the CI must not cross (precision target)",
      "n is computed per group (equal cases and controls)"
    ),
    hints = c(
      "Calculates sample size ensuring the log-scale CI does not cross target_lr (threshold precision),",
      "distinct from fixed-width CI approaches (e.g. prec_lr in presize)."
    )
  )
}

# ---------------------------------------------------------------- F5 utility

#' Total screening size with probability guarantee (Zhou Eq 6.3)
#'
#' Given a required number of cases n and a disease prevalence, compute the
#' total enrollment needed so that, with probability 1-beta, at least n
#' cases are captured: N satisfies P(Binomial(N, prev) >= n) >= 1-beta.
#' @param n Required number of cases; positive integer (e.g. the
#'   `target_state_cases_needed` from a diagnostic accuracy calculation).
#' @param prevalence Disease prevalence in the screening population; scalar
#'   in (0, 1) (e.g. 0.20 for a 20 percent clinic prevalence).
#' @param beta Acceptable probability of falling short; scalar in (0, 1).
#'   Default 0.10, i.e. a 90 percent guarantee of capturing at least `n` cases.
#' @return Integer total enrollment N (screening list size).
#' @examples
#' # A colon-cancer screening validation needs 196 confirmed cases;
#' # clinic prevalence is 20%. Enroll enough patients to capture
#' # 196 cases with 90% probability:
#' screen_required(n = 196, prevalence = 0.20, beta = 0.10)
#'
#' # More stringent 95% guarantee:
#' screen_required(n = 196, prevalence = 0.20, beta = 0.05)
#' @export
screen_required <- function(n, prevalence, beta = 0.10) {
  if (!is.numeric(n) || length(n) != 1 || n < 1) {
    cli::cli_abort("{.arg n} must be a positive integer number of cases.")
  }
  if (!is.numeric(prevalence) || length(prevalence) != 1 ||
    prevalence <= 0 || prevalence >= 1) {
    cli::cli_abort("{.arg prevalence} must be in (0, 1).")
  }
  if (!is.numeric(beta) || length(beta) != 1 || beta <= 0 || beta >= 1) {
    cli::cli_abort("{.arg beta} must be in (0, 1).")
  }

  n_int <- ceiling(n)
  # Normal-approximation starting point (Zhou Eq 6.3), then exact binomial
  # search. The guarantee is P(X >= n_int) >= 1 - beta, i.e.
  # P(X <= n_int - 1) <= beta. As N grows the guarantee tightens.
  z_beta <- stats::qnorm(1 - beta)
  N <- as.integer(ceiling((n_int + z_beta^2 / 2 +
    z_beta * sqrt(n_int + z_beta^2 / 4)) / prevalence))

  # Upward safety loop: if the approximation underestimates (possible for
  # extreme prevalences), grow N until the guarantee holds.
  while (stats::pbinom(n_int - 1, N, prevalence) > beta) {
    N <- N + 1L
  }
  # Downward minimisation: shrink N while the guarantee still holds at N-1.
  while (N > n_int &&
    stats::pbinom(n_int - 1, N - 1L, prevalence) <= beta) {
    N <- N - 1L
  }
  N
}
