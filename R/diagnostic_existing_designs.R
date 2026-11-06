#' Diagnostic superiority (single test) calculation
#'
#' @param prob Expected accuracy
#' @param p0 Null hypothesis accuracy
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @param power Statistical power
#' @param method Calculation method: "asymptotic" (Hajian-Tilaki 2014 Eq 6.8) or "exact" (A'Hern 2001 exact binomial)
#' @param alternative `"one.sided"` (the historical default of this package and
#'   the Akoglu 2022 Table 2 Eq 2 convention) or `"two.sided"` (the
#'   Hajian-Tilaki 2014 Eq 6.8 convention, which the paper uses throughout,
#'   p. 197).
#' @return List with calculation results
#' @name calculate_diagnostic_superiority_single
#' @keywords internal
calculate_diagnostic_superiority_single <- function(
  prob,
  p0,
  prevalence,
  alpha,
  power,
  method = c("asymptotic", "exact"),
  alternative = c("one.sided", "two.sided")
) {
  p_val <- prob
  p0_val <- p0
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  method <- rlang::arg_match(method, c("asymptotic", "exact"))
  alternative <- rlang::arg_match(alternative)

  if (method == "exact" && alternative != "one.sided") {
    cli::cli_abort(c(
      "{.arg method = 'exact'} supports only {.arg alternative = 'one.sided'}.",
      "i" = "Use the asymptotic method for the implemented two-sided convention."
    ))
  }
  if (p_val <= p0_val) {
    cli::cli_abort(
      "{.arg prob} must exceed the null threshold {.arg p0} for diagnostic superiority."
    )
  }

  if (method == "exact") {
    # Exact binomial single-stage design (A'Hern 2001)
    # Find smallest n and cutoff r such that P(X >= r | p0) <= alpha and P(X >= r | prob) >= power
    n_found <- NULL
    r_found <- NULL
    for (n in seq_len(2000)) {
      # Critical value r: smallest integer such that P(X >= r | p0) <= alpha
      # i.e., P(X <= r - 1 | p0) >= 1 - alpha
      r <- stats::qbinom(1 - alpha, size = n, prob = p0_val) + 1L
      if (r <= n) {
        # Check power at alternative prob
        pwr <- stats::pbinom(r - 1L, size = n, prob = p_val, lower.tail = FALSE)
        if (pwr >= power) {
          n_found <- n
          r_found <- r
          break
        }
      }
    }
    if (is.null(n_found)) {
      cli::cli_abort("No feasible exact design found within n = 2000.")
    }

    actual_alpha <- stats::pbinom(
      r_found - 1L,
      size = n_found,
      prob = p0_val,
      lower.tail = FALSE
    )
    actual_power <- stats::pbinom(
      r_found - 1L,
      size = n_found,
      prob = p_val,
      lower.tail = FALSE
    )

    return(list(
      design_type = "Diagnostic superiority (single test, exact binomial)",
      target_state_cases_needed = as.integer(n_found),
      total_subjects_to_screen = as.integer(ceiling(n_found / prev_val)),
      critical_successes = as.integer(r_found),
      actual_alpha = round(actual_alpha, 4),
      actual_power = round(actual_power, 4),
      parameters = list(
        prob = p_val,
        p0 = p0_val,
        prevalence = prev_val,
        alpha = alpha,
        power = power,
        method = "exact",
        alternative = alternative
      ),
      formula = "exact binomial: P(X >= r | p0) <= alpha and P(X >= r | prob) >= power",
      formula_latex = "$$P(X \\ge r \\mid p_0) \\le \\alpha \\quad \\text{and} \\quad P(X \\ge r \\mid p) \\ge 1-\\beta$$",
      reference = paste(
        "Primary (exact binomial): A'Hern, R. P. (2001). Sample size tables for",
        "exact single-stage phase II designs. Statistics in Medicine, 20(6),",
        "859-866. https://doi.org/10.1002/sim.721\n\n",
        "Also: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
        "test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
      ),
      roles = c(
        "prob = expected diagnostic sensitivity/specificity",
        "p0 = unacceptable/null sensitivity or specificity threshold",
        sprintf(
          "critical_successes = declare superior if correct cases >= %d of %d",
          r_found,
          n_found
        )
      )
    ))
  }

  alternative <- rlang::arg_match(alternative)
  # Hajian-Tilaki (2014) p. 197 states that the paper consistently uses
  # two-sided tests (Z_{alpha/2}); Akoglu (2022) Table 2 Eq 2 uses the
  # one-sided Z_alpha. Both conventions are exposed so either source can be
  # reproduced exactly. The default stays one-sided to preserve this package's
  # pre-existing numbers (see inst/reference/NUMERIC_ANCHORS.md).
  zAlpha <- if (alternative == "two.sided") {
    qnorm(1 - alpha / 2)
  } else {
    qnorm(1 - alpha)
  }
  zBeta <- qnorm(power)
  nTargetCases <- ((zAlpha *
    sqrt(p0_val * (1 - p0_val)) +
    zBeta * sqrt(p_val * (1 - p_val))) /
    (p_val - p0_val))^2

  list(
    design_type = "Diagnostic superiority (single)",
    target_state_cases_needed = as.integer(ceiling(nTargetCases)),
    total_subjects_to_screen = as.integer(ceiling(nTargetCases / prev_val)),
    parameters = list(
      prob = p_val,
      p0 = p0_val,
      prevalence = prev_val,
      alpha = alpha,
      power = power,
      method = "asymptotic",
      alternative = alternative
    ),
    formula = "N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 / (P-P0)^2",
    formula_latex = if (alternative == "two.sided") {
      "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p(1-p)}\\right]^2}{(p - p_0)^2}$$"
    } else {
      "$$n = \\frac{\\left[Z_{\\alpha}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p(1-p)}\\right]^2}{(p - p_0)^2}$$"
    },
    reference = paste(
      "Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
      "test studies of biomedical informatics. Journal of Biomedical Informatics,",
      "48, 193-204 (Eq 6.8; the paper uses two-sided Z_alpha/2 throughout, p. 197).",
      "https://doi.org/10.1016/j.jbi.2014.02.013\n\n",
      "One-sided variant: Akoglu, H. (2022). User's guide to sample size estimation",
      "in diagnostic accuracy studies. Turkish Journal of Emergency Medicine,",
      "22(4), 177-185 (Table 2, Eq 2, p. 180; one-sided Z_alpha)."
    )
  )
}

#' Diagnostic comparison (two tests) calculation
#'
#' @param p1 Test 1 accuracy
#' @param p2 Test 2 accuracy
#' @param prevalence Disease prevalence
#' @param paired Paired design?
#' @param psi Discordant pair proportion (for paired design)
#' @param alpha Type I error
#' @param power Statistical power
#' @return List with calculation results
#' @keywords internal
calculate_diagnostic_comparison_two <- function(
  p1,
  p2,
  prevalence,
  paired,
  psi,
  alpha,
  power
) {
  p1_val <- p1
  p2_val <- p2
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  paired_val <- paired
  psi_val <- psi
  if (p1_val == p2_val) {
    cli::cli_abort("{.arg p1} and {.arg p2} must differ.")
  }

  zAlphaHalf <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)

  if (paired_val) {
    if (is.null(psi_val)) {
      cli::cli_abort(c(
        "Paired comparison requires {.arg psi} parameter.",
        "i" = "psi represents discordant pair proportion."
      ))
    }
    nTargetCases <- ((zAlphaHalf *
      psi_val +
      zBeta * sqrt(psi_val^2 - (p1_val - p2_val)^2 / 4)) /
      (p1_val - p2_val))^2
  } else {
    pBar <- (p1_val + p2_val) / 2
    nTargetCases <- ((zAlphaHalf *
      sqrt(2 * pBar * (1 - pBar)) +
      zBeta * sqrt(p1_val * (1 - p1_val) + p2_val * (1 - p2_val))) /
      (p1_val - p2_val))^2
  }

  list(
    design_type = "Two diagnostic measures",
    target_state_cases_needed = ceiling(nTargetCases),
    total_subjects_to_screen = ceiling(
      nTargetCases / prev_val * ifelse(paired_val, 1, 2)
    ),
    parameters = list(
      p1 = p1_val,
      p2 = p2_val,
      prevalence = prev_val,
      paired = paired_val,
      psi = psi_val,
      alpha = alpha,
      power = power
    ),
    formula = if (paired_val) {
      "n = [Za/2 * psi + Zb * sqrt(psi^2 - (p1-p2)^2/4)]^2 / (p1-p2)^2"
    } else {
      "n = [Za/2 * sqrt(2*p_bar*(1-p_bar)) + Zb * sqrt(p1*(1-p1)+p2*(1-p2))]^2 / (p1-p2)^2"
    },
    formula_latex = if (paired_val) {
      "$$n = \\frac{\\left[Z_{\\alpha/2}\\sigma_{paired} + Z_{\\beta}\\sqrt{\\sigma_{paired}^2 - (p_1-p_2)^2/4}\\right]^2}{(p_1-p_2)^2}$$"
    } else {
      "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{2\\bar{p}(1-\\bar{p})} + Z_{\\beta}\\sqrt{p_1(1-p_1)+p_2(1-p_2)}\\right]^2}{(p_1-p_2)^2}$$"
    },
    reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
  )
}

#' Likelihood ratio test calculation
#'
#' Legacy precision-based minimum-case rule. Kept for golden-master
#' compatibility; for the log-CI method of Hajian-Tilaki (2014) Eq 6.10-6.14
#' use `lr_type`/`target_lr`, which routes to [calculate_likelihood_ratio_v2()].
#'
#' @param sens Expected sensitivity
#' @param spec Expected specificity
#' @param prevalence Disease prevalence (used only to derive the
#'   non-diseased:diseased sampling ratio; omitted or 1 falls back to 1:1)
#' @param precision Desired precision
#' @param alpha Type I error
#' @return List with calculation results
#' @keywords internal
calculate_likelihood_ratio_test <- function(
  sens,
  spec,
  prevalence,
  precision,
  alpha
) {
  precision_val <- if (is.null(precision)) 0.1 else precision

  zAlphaHalf <- qnorm(1 - alpha / 2)
  ratio <- legacy_auc_ratio(prevalence)
  pDis <- ratio$prevalence
  pNon <- 1 - pDis

  # The control multiplier (pDis / pNon = 1/R) is only meaningful when both
  # disease states are actually sampled. When prevalence is omitted (or 1)
  # the 1:1 quota fallback makes it 1, instead of dividing by zero.
  control_multiplier <- if (ratio$fallback) 1 else pDis / pNon

  minCases <- max(
    (zAlphaHalf^2 * sens * (1 - sens)) / (precision_val)^2,
    (zAlphaHalf^2 * spec * (1 - spec)) / (precision_val)^2 * control_multiplier
  )

  list(
    design_type = "Likelihood ratio (min sample size)",
    recommended_cases = ceiling(minCases),
    total_subjects_to_screen = ceiling(minCases / pDis),
    parameters = list(
      sensitivity = sens,
      specificity = spec,
      prevalence = pDis,
      ratio_R = ratio$R,
      precision = precision_val,
      alpha = alpha
    ),
    formula = "n_cases = max(Z_1-a/2^2 * Se*(1-Se)/d^2, Z_1-a/2^2 * Sp*(1-Sp)/d^2 * (P/(1-P)))",
    formula_latex = sprintf(
      "$$n_{cases} = \\max\\left\\{\\frac{Z_{1-\\alpha/2}^2 \\cdot Se(1-Se)}{%.2f^2}, \\frac{Z_{1-\\alpha/2}^2 \\cdot Sp(1-Sp)}{%.2f^2} \\cdot \\frac{P}{1-P}\\right\\}$$",
      precision_val,
      precision_val
    ),
    reference = paste(
      "Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
      "test studies of biomedical informatics. *Journal of Biomedical Informatics*,",
      "48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013 (Section 6.4).\n\n",
      "CI method: Simel, D. L., Samsa, G. P., & Matchar, D. B. (1991).",
      "Likelihood ratios with confidence: sample size estimation for diagnostic",
      "test studies. Journal of Clinical Epidemiology, 44(8), 763-770."
    ),
    hints = c(
      legacy_auc_ratio_hint(prevalence, ratio),
      "This is the legacy precision rule; for the log(LR) CI method supply `lr_type` and `target_lr`."
    )
  )
}
