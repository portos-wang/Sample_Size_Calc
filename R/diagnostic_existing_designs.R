#' Diagnostic superiority (single test) calculation
#'
#' @param prob Expected accuracy
#' @param p0 Null hypothesis accuracy
#' @param prevalence Disease prevalence
#' @param alpha Type I error
#' @param power Statistical power
#' @param method Calculation method: "asymptotic" (Hajian-Tilaki 2014 Eq 6.8) or "exact" (A'Hern 2001 exact binomial)
#' @return List with calculation results
#' @name calculate_diagnostic_superiority_single
#' @keywords internal
calculate_diagnostic_superiority_single <- function(prob, p0, prevalence, alpha, power,
                                                   method = c("asymptotic", "exact")) {
  p_val <- prob
  p0_val <- p0
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  method <- rlang::arg_match(method, c("asymptotic", "exact"))

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

    actual_alpha <- stats::pbinom(r_found - 1L, size = n_found, prob = p0_val, lower.tail = FALSE)
    actual_power <- stats::pbinom(r_found - 1L, size = n_found, prob = p_val, lower.tail = FALSE)

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
        method = "exact"
      ),
      formula = "exact binomial: P(X >= r | p0) <= alpha and P(X >= r | prob) >= power",
      formula_latex = "$$P(X \\ge r \\mid p_0) \\le \\alpha \\quad \\text{and} \\quad P(X \\ge r \\mid p) \\ge 1-\\beta$$",
      reference = paste(
        "Primary (exact binomial): A'Hern, R. P. (2001). Single stage and double",
        "sampling phase II trials. British Journal of Cancer, 85(2), 223-226.\n\n",
        "Also: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
        "test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
      ),
      roles = c(
        "prob = expected diagnostic sensitivity/specificity",
        "p0 = unacceptable/null sensitivity or specificity threshold",
        sprintf("critical_successes = declare superior if correct cases >= %d of %d", r_found, n_found)
      )
    ))
  }

  zAlpha <- qnorm(1 - alpha)
  zBeta <- qnorm(power)
  nTargetCases <- ((zAlpha * sqrt(p0_val * (1 - p0_val)) + zBeta * sqrt(p_val * (1 - p_val))) / (p_val - p0_val))^2

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
      method = "asymptotic"
    ),
    formula = "N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 / (P-P0)^2",
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p(1-p)}\\right]^2}{(p - p_0)^2}$$",
    reference = "Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
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
calculate_diagnostic_comparison_two <- function(p1, p2, prevalence, paired, psi, alpha, power) {
  p1_val <- p1
  p2_val <- p2
  prev_val <- if (is.null(prevalence)) 1 else prevalence
  paired_val <- paired
  psi_val <- psi

  zAlphaHalf <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)

  if (paired_val) {
    if (is.null(psi_val)) {
      cli::cli_abort(c(
        "Paired comparison requires {.arg psi} parameter.",
        "i" = "psi represents discordant pair proportion."
      ))
    }
    nTargetCases <- ((zAlphaHalf * psi_val + zBeta * sqrt(psi_val^2 - (p1_val - p2_val)^2 / 4)) / (p1_val - p2_val))^2
  } else {
    pBar <- (p1_val + p2_val) / 2
    nTargetCases <- ((zAlphaHalf * sqrt(2 * pBar * (1 - pBar)) + zBeta * sqrt(p1_val * (1 - p1_val) + p2_val * (1 - p2_val))) / (p1_val - p2_val))^2
  }

  list(
    design_type = "Two diagnostic measures",
    target_state_cases_needed = ceiling(nTargetCases),
    total_subjects_to_screen = ceiling(nTargetCases / prev_val * ifelse(paired_val, 1, 2)),
    parameters = list(
      p1 = p1_val,
      p2 = p2_val,
      prevalence = prev_val,
      paired = paired_val,
      psi = psi_val,
      alpha = alpha,
      power = power
    ),
    formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sigma_{paired} + Z_{\\beta}\\sqrt{\\sigma_{paired}^2 - (p_1-p_2)^2/4}\\right]^2}{(p_1-p_2)^2}$$",
    reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204."
  )
}

#' Likelihood ratio test calculation
#'
#' @param sens Expected sensitivity
#' @param spec Expected specificity
#' @param prevalence Disease prevalence
#' @param precision Desired precision
#' @param alpha Type I error
#' @return List with calculation results
#' @keywords internal
calculate_likelihood_ratio_test <- function(sens, spec, prevalence, precision, alpha) {
  precision_val <- if (is.null(precision)) 0.1 else precision

  zAlphaHalf <- qnorm(1 - alpha / 2)
  pDis <- if (is.null(prevalence)) 1 else prevalence
  pNon <- 1 - pDis

  minCases <- max(
    (zAlphaHalf^2 * sens * (1 - sens)) / (precision_val)^2,
    (zAlphaHalf^2 * spec * (1 - spec)) / (precision_val)^2 * (pDis / pNon)
  )

  list(
    design_type = "Likelihood ratio (min sample size)",
    recommended_cases = ceiling(minCases),
    total_subjects_to_screen = ceiling(minCases / pDis),
    parameters = list(
      sensitivity = sens,
      specificity = spec,
      prevalence = pDis,
      precision = precision_val,
      alpha = alpha
    ),
    formula_latex = sprintf("$$n_{cases} = \\max\\left\\{\\frac{Z_{1-\\alpha/2}^2 \\cdot Se(1-Se)}{%.2f^2}, \\frac{Z_{1-\\alpha/2}^2 \\cdot Sp(1-Sp)}{%.2f^2} \\cdot \\frac{P}{1-P}\\right\\}$$", precision_val, precision_val),
    reference = "Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
  )
}
