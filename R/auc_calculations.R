# AUC-related diagnostic design calculations

# Control:non-diseased sampling ratio R for the legacy AUC / LR kernels.
# Zhou et al. (2011, Eq 6.4) parameterises the variance function by R, the ratio
# of non-diseased to diseased subjects in the study sample. The legacy API
# exposes the clinical disease prevalence instead, and translates it with
# R = (1 - prevalence) / prevalence.
#
# A prevalence of exactly 1 (the historical default, i.e. "prevalence omitted")
# would make R = 0 and every variance term infinite. Rather than emit Inf, we
# fall back to a 1:1 case:control quota (R = 1), which is the default design
# documented for diagnostic accuracy studies (Zhou 2011, Section 3.3: quota
# sampling by disease status). This is a documented deviation from the literal
# formula, reported through `hints`.
legacy_auc_ratio <- function(prevalence) {
  pDis <- if (is.null(prevalence)) 1 else prevalence
  if (pDis >= 1) {
    return(list(R = 1, prevalence = 1, fallback = TRUE))
  }
  list(R = (1 - pDis) / pDis, prevalence = pDis, fallback = FALSE)
}

legacy_auc_ratio_hint <- function(prevalence, ratio) {
  if (!isTRUE(ratio$fallback)) {
    return(character())
  }
  paste(
    "`prevalence` was omitted (or 1), so the non-diseased:diseased sampling ratio",
    "R fell back to 1 (a 1:1 case:control quota). Supply `prevalence` in (0, 1)",
    "or use `ratio` with `var_method` to set the case:control allocation explicitly."
  )
}

#' AUC single test calculation
#'
#' @param auc Expected AUC value
#' @param d Desired precision
#' @param prevalence Disease prevalence (used only to derive the
#'   non-diseased:diseased sampling ratio R = (1 - prevalence) / prevalence;
#'   omitted or 1 falls back to a 1:1 quota)
#' @param alpha Type I error
#' @param ratio Controls per case; alternative to prevalence.
#' @param var_method AUC variance model (binormal by default).
#' @return List with calculation results
#' @keywords internal
calculate_auc_single <- function(
  auc,
  d,
  prevalence,
  alpha,
  ratio = NULL,
  var_method = "binormal"
) {
  calculate_auc_single_v2(auc, d, prevalence, alpha, ratio, var_method)
}

#' AUC superiority test calculation
#'
#' @param auc Expected AUC value
#' @param auc0 Null hypothesis AUC value
#' @param prevalence Disease prevalence (used only to derive the
#'   non-diseased:diseased sampling ratio R; omitted or 1 falls back to 1:1)
#' @param alpha Type I error
#' @param power Statistical power
#' @param ratio Controls per case; alternative to prevalence.
#' @param var_method AUC variance model (binormal by default).
#' @return List with calculation results
#' @keywords internal
calculate_auc_superiority <- function(
  auc,
  auc0,
  prevalence,
  alpha,
  power,
  ratio = NULL,
  var_method = "binormal"
) {
  validate_numeric_args(list(auc = auc, auc0 = auc0))
  if (auc0 <= 0 || auc0 >= 1 || auc <= auc0 || auc >= 1) {
    cli::cli_abort(
      "AUC testing requires {.arg auc0} and {.arg auc} in (0, 1), with auc > auc0."
    )
  }
  A <- auc
  A0 <- auc0
  sampling <- auc_sampling(prevalence, ratio)
  var_method <- rlang::arg_match(
    var_method,
    c("binormal", "exponential", "conservative")
  )
  V_A <- auc_variance(A, sampling$R, var_method)
  V_A0 <- auc_variance(A0, sampling$R, var_method)

  zAlpha <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)
  nCases <- ((zAlpha * sqrt(V_A0) + zBeta * sqrt(V_A)) / (A - A0))^2

  c(
    list(
      design_type = "AUC superiority (single)"
    ),
    auc_sample_sizes(nCases, sampling),
    list(
      parameters = list(
        auc = A,
        auc_null = A0,
        prevalence = sampling$prevalence,
        ratio_R = sampling$R,
        sampling = sampling$sampling,
        var_method = var_method,
        alpha = alpha,
        power = power
      ),
      formula = "n_cases = (Z_alpha/2 * sqrt(V(AUC0)) + Z_beta * sqrt(V(AUC)))^2 / (AUC - AUC0)^2",
      formula_latex = "$$n_{cases} = \\frac{\\left(Z_{\\alpha/2}\\sqrt{V(AUC_0)} + Z_{\\beta}\\sqrt{V(AUC)}\\right)^2}{(AUC - AUC_0)^2}$$",
      reference = paste(
        "Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011).",
        "Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley.",
        "Section 6.1.4, Eq 6.8, pp. 199-200 (V(AUC) from Eq 6.5; the CTC",
        "worked example on p. 200 reports n = 13 with a two-tailed 5% test).\n\n",
        "Variance function: Obuchowski, N. A. (1994). Investigative Radiology,",
        "29(2), 238-243.\n\n",
        "Review: Hajian-Tilaki, K. (2014). Journal of Biomedical Informatics,",
        "48, 193-204 (Eq 7.5)."
      ),
      roles = c(
        "ratio = controls per case; prevalence is an alternative clinical recruitment assumption"
      ),
      hints = sampling$hints
    )
  )
}

#' AUC comparison (two tests) calculation
#'
#' @param auc1 Test 1 AUC value
#' @param auc2 Test 2 AUC value
#' @param r Correlation between tests
#' @param prevalence Disease prevalence (used only to derive the
#'   non-diseased:diseased sampling ratio R; omitted or 1 falls back to 1:1)
#' @param alpha Type I error
#' @param power Statistical power
#' @param ratio Controls per case; alternative to prevalence.
#' @param var_method AUC variance model (binormal by default).
#' @return List with calculation results
#' @keywords internal
calculate_auc_comparison <- function(
  auc1,
  auc2,
  r,
  prevalence,
  alpha,
  power,
  ratio = NULL,
  var_method = "binormal"
) {
  validate_numeric_args(list(auc1 = auc1, auc2 = auc2, r = r))
  if (auc1 <= 0 || auc1 >= 1 || auc2 <= 0 || auc2 >= 1 || auc1 == auc2) {
    cli::cli_abort(
      "{.arg auc1} and {.arg auc2} must be different values in (0, 1)."
    )
  }
  if (r < 0 || r >= 1) {
    cli::cli_abort("{.arg r} must be in [0, 1).")
  }
  A1 <- auc1
  A2 <- auc2
  r_val <- r
  sampling <- auc_sampling(prevalence, ratio)
  var_method <- rlang::arg_match(
    var_method,
    c("binormal", "exponential", "conservative")
  )
  A_avg <- (A1 + A2) / 2
  V_A <- auc_variance(A_avg, sampling$R, var_method)

  zAlphaHalf <- qnorm(1 - alpha / 2)
  zBeta <- qnorm(power)
  nCases <- (2 * (zAlphaHalf + zBeta)^2 * V_A * (1 - r_val)) / (A1 - A2)^2

  c(
    list(
      design_type = "AUC comparison (two tests)"
    ),
    auc_sample_sizes(nCases, sampling),
    list(
      parameters = list(
        auc1 = A1,
        auc2 = A2,
        correlation = r_val,
        prevalence = sampling$prevalence,
        ratio_R = sampling$R,
        sampling = sampling$sampling,
        var_method = var_method,
        alpha = alpha,
        power = power
      ),
      formula = "n_cases = 2 * (Z_alpha/2 + Z_beta)^2 * V(AUC) * (1 - r) / (AUC1 - AUC2)^2",
      formula_latex = "$$n_{cases} = \\frac{2(Z_{\\alpha/2} + Z_{\\beta})^2 \\cdot V(AUC) \\cdot (1-r)}{(AUC_1 - AUC_2)^2}$$",
      reference = paste(
        "Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic",
        "test studies of biomedical informatics. Journal of Biomedical Informatics,",
        "48, 193-204 (Eq 7.6-7.8, paired/independent two-AUC comparison; the",
        "worked example on p. 199 gives n = 211 with the binormal variance).",
        "https://doi.org/10.1016/j.jbi.2014.02.013\n\n",
        "Variance function: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K.",
        "(2011). Statistical Methods in Diagnostic Medicine (2nd ed.), Eq 6.5."
      ),
      roles = c(
        "ratio = controls per case; prevalence is an alternative clinical recruitment assumption"
      ),
      hints = sampling$hints
    )
  )
}
