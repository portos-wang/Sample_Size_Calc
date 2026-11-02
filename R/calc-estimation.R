# Estimation designs: single-sample precision-based sample size
# (task = "estimate"). Formulas and anchors: docs/NUMERIC_ANCHORS.md A1/A2/A6.

#' Internal calculation: single proportion precision (absolute or relative)
#'
#' n = Z^2 * p(1-p) / d^2 for absolute precision; for relative precision the
#' margin is epsilon * p. Prevalence outside 10-90% triggers a convention
#' hint (Bhardwaj 2024 p.2558).
#'
#' @param p Expected proportion
#' @param precision Margin of error d (absolute) or epsilon (relative)
#' @param precision_type "absolute" or "relative"
#' @param alpha Type I error (two-sided CI)
#' @return List consumed by as_sample_size_result()
#' @keywords internal
calculate_single_proportion <- function(p, precision, precision_type, alpha) {
  if (!is.numeric(p) || length(p) != 1 || p <= 0 || p >= 1) {
    cli::cli_abort(c(
      "{.arg p} must be a single proportion in (0, 1).",
      "x" = "You provided {.val {p}}."
    ))
  }
  if (!is.numeric(precision) || length(precision) != 1 || precision <= 0) {
    cli::cli_abort(c(
      "{.arg precision} must be a single positive number.",
      "x" = "You provided {.val {precision}}."
    ))
  }
  precision_type <- rlang::arg_match(precision_type, c("absolute", "relative"))

  d_val <- if (precision_type == "relative") precision * p else precision

  hints <- character()
  if (p < 0.10) {
    hints <- c(hints, sprintf(
      "Prevalence %.0f%% < 10%%: convention suggests precision of half the prevalence (%.3f).",
      100 * p, p / 2
    ))
  } else if (p > 0.90) {
    hints <- c(hints, sprintf(
      "Prevalence %.0f%% > 90%%: convention suggests precision of 0.5*(1-p) = %.3f.",
      100 * p, 0.5 * (1 - p)
    ))
  }

  z <- z_alpha(alpha, "two.sided")
  n <- (z^2 * p * (1 - p)) / (d_val^2)

  list(
    design_type = "Single proportion estimation (precision)",
    n_required = inflate_n(n),
    parameters = list(
      p = p,
      precision = precision,
      precision_type = precision_type,
      alpha = alpha
    ),
    formula = "n = Z^2 * p(1-p) / d^2",
    formula_latex = if (precision_type == "absolute") {
      "$$n = \\frac{Z_{1-\\alpha/2}^2 \\cdot p(1-p)}{d^2}$$"
    } else {
      "$$n = \\frac{Z_{1-\\alpha/2}^2 \\cdot (1-p)}{\\epsilon^2 p}$$"
    },
    reference = "Bhardwaj et al. (2024). Determination of sample size for various study designs in medical research: A practical primer. Journal of Family Medicine and Primary Care, 13(7), 2555-2561 (p. 2558).\n\nAlso: Lwanga, S. K., & Lemeshow, S. (1991). Sample size determination in health studies: A practical manual. World Health Organization.",
    roles = c(
      "p = expected proportion (e.g. prevalence)",
      "precision = margin of error d (half-width of the CI)",
      sprintf("confidence level = %d%%", round(100 * (1 - alpha)))
    ),
    hints = hints
  )
}

#' Internal calculation: single mean precision
#'
#' n = Z^2 * sigma^2 / d^2 (Bhardwaj 2024 p.2558; Machin 2018 Ch.9).
#' @keywords internal
calculate_single_mean <- function(sigma, precision, alpha) {
  if (!is.numeric(sigma) || length(sigma) != 1 || sigma <= 0) {
    cli::cli_abort(c(
      "{.arg sigma} must be a single positive number.",
      "x" = "You provided {.val {sigma}}."
    ))
  }
  if (!is.numeric(precision) || length(precision) != 1 || precision <= 0) {
    cli::cli_abort(c(
      "{.arg precision} must be a single positive number.",
      "x" = "You provided {.val {precision}}."
    ))
  }

  z <- z_alpha(alpha, "two.sided")
  n <- (z * sigma / precision)^2

  list(
    design_type = "Single mean estimation (precision)",
    n_required = inflate_n(n),
    parameters = list(sigma = sigma, precision = precision, alpha = alpha),
    formula = "n = (Z * sigma / d)^2",
    formula_latex = "$$n = \\left(\\frac{Z_{1-\\alpha/2} \\cdot \\sigma}{d}\\right)^2$$",
    reference = "Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 9.\n\nAlso: Bhardwaj et al. (2024), p. 2558 (continuous outcome precision).",
    roles = c(
      "sigma = population standard deviation (from pilot/literature)",
      "precision = margin of error d"
    )
  )
}

#' Internal calculation: single correlation coefficient precision (Fisher z)
#'
#' n = ((1 + r^2) / (r * epsilon))^2 + 3 for relative precision epsilon
#' (Machin 2018 Ch.19, Eq 19.2); a test-oriented variant uses
#' n = (Z_a/2 + Z_b)^2 / (atanh(r1) - atanh(r0))^2 + 3.
#' @keywords internal
calculate_single_correlation <- function(r, epsilon, alpha, power) {
  if (!is.numeric(r) || length(r) != 1 || r <= 0 || r >= 1) {
    cli::cli_abort(c(
      "{.arg r} must be a single correlation in (0, 1).",
      "x" = "You provided {.val {r}}."
    ))
  }
  if (!is.numeric(epsilon) || length(epsilon) != 1 || epsilon <= 0) {
    cli::cli_abort(c(
      "{.arg epsilon} must be a single positive relative precision.",
      "x" = "You provided {.val {epsilon}}."
    ))
  }

  n <- ((1 + r^2) / (r * epsilon))^2 + 3

  list(
    design_type = "Single correlation estimation (Fisher z precision)",
    n_required = as.integer(ceiling(n)),
    parameters = list(r = r, epsilon = epsilon, alpha = alpha),
    formula = "n = ((1 + r^2)/(r * epsilon))^2 + 3",
    formula_latex = "$$n = \\left(\\frac{1 + r^2}{r \\cdot \\epsilon}\\right)^2 + 3$$",
    reference = "Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 19 (The Correlation Coefficient).",
    roles = c(
      "r = anticipated correlation coefficient",
      "epsilon = relative precision (fraction of r)"
    )
  )
}

# Register estimation combos in the master table (appended by calculate.R).
ssr_estimation_combinations <- list(
  list(
    design = "singleProportion", task = "estimate", outcome = "proportion",
    internal = "singleProportion", default = TRUE
  ),
  list(
    design = "singleMean", task = "estimate", outcome = "mean",
    internal = "singleMean", default = TRUE
  ),
  list(
    design = "singleCorrelation", task = "estimate", outcome = "correlation",
    internal = "singleCorrelation", default = TRUE
  )
)

# Dispatch for estimation designs (called from dispatch_calculation's
# estimation branch).
dispatch_estimation <- function(internal_keyword, args, alpha, power) {
  switch(internal_keyword,
    "singleProportion" = calculate_single_proportion(
      p = args$p,
      precision = args$precision,
      precision_type = args$precision_type %||% "absolute",
      alpha = alpha
    ),
    "singleMean" = calculate_single_mean(
      sigma = args$sigma,
      precision = args$precision,
      alpha = alpha
    ),
    "singleCorrelation" = calculate_single_correlation(
      r = args$r,
      epsilon = args$epsilon,
      alpha = alpha,
      power = power
    ),
    cli::cli_abort("Unknown estimation design {.val {internal_keyword}}.")
  )
}
