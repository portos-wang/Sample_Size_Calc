# Estimation designs: single-sample precision-based sample size
# (task = "estimate"). Formulas and anchors: inst/reference/NUMERIC_ANCHORS.md A1/A2/A6.

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
    hints <- c(
      hints,
      sprintf(
        "Prevalence %.0f%% < 10%%: convention suggests precision of half the prevalence (%.3f).",
        100 * p,
        p / 2
      )
    )
  } else if (p > 0.90) {
    hints <- c(
      hints,
      sprintf(
        "Prevalence %.0f%% > 90%%: convention suggests precision of 0.5*(1-p) = %.3f.",
        100 * p,
        0.5 * (1 - p)
      )
    )
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
#' Machin et al. (2018) Eq 9.18 (p. 152):
#'
#' \preformatted{
#'   N = (t_{N-1, 1-a/2} * sigma / d)^2
#' }
#'
#' The right-hand z form is the starting value N0; when N0 < 40 the Student t
#' quantile depends on N and the equation must be iterated (Machin p. 152:
#' "if this is large (>= 40) then this is taken as the sample size. If N0 < 40,
#' then the Student t quantile with N0 - 1 df is obtained ... and a revised
#' sample size N1 obtained"). This implementation searches for the smallest
#' integer N >= 2 whose Student t interval half-width does not exceed d,
#' avoiding oscillation between adjacent rounded fixed-point iterates.
#'
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

  # Search integer n: fixed-point iteration can oscillate after rounding.
  n_initial <- (z * sigma / precision)^2
  upper <- max(2, ceiling(n_initial))
  if (!is.finite(upper) || upper > .Machine$integer.max) {
    cli::cli_abort(
      "The required sample size exceeds the supported integer range."
    )
  }
  half_width <- function(n) stats::qt(1 - alpha / 2, n - 1) * sigma / sqrt(n)
  while (half_width(upper) > precision) {
    if (upper == .Machine$integer.max) {
      cli::cli_abort(
        "The required sample size exceeds the supported integer range."
      )
    }
    upper <- min(2 * upper, .Machine$integer.max)
  }
  lower <- 2
  while (lower < upper) {
    middle <- lower + floor((upper - lower) / 2)
    if (half_width(middle) <= precision) {
      upper <- middle
    } else {
      lower <- middle + 1
    }
  }
  n <- as.integer(lower)
  achieved <- half_width(n)

  list(
    design_type = "Single mean estimation (precision)",
    n_required = n,
    achieved_precision = achieved,
    parameters = list(sigma = sigma, precision = precision, alpha = alpha),
    formula = "smallest integer n >= 2 with t_(n-1, 1-a/2) * sigma / sqrt(n) <= d",
    formula_latex = "$$n = \\min\\left\\{k\\in\\mathbb{N}: k\\ge 2,\\ \\frac{t_{k-1,1-\\alpha/2}\\sigma}{\\sqrt{k}}\\le d\\right\\}$$",
    calculation = c(
      sprintf(
        "Step 1: Plan mean precision with sigma = %s, CI half-width d = %s, alpha = %s.",
        ssr_fmt_val(sigma),
        ssr_fmt_val(precision),
        ssr_fmt_val(alpha)
      ),
      sprintf(
        "Step 2: Normal approximation starting size is %.2f; require at least two observations for a t interval.",
        n_initial
      ),
      "Step 3: Search integers for the smallest n satisfying t_(n-1,1-alpha/2)*sigma/sqrt(n) <= d.",
      sprintf(
        "Step 4: n = %d, df = %d, t critical value = %.6f, achieved half-width = %.6f <= %.6f.",
        n,
        n - 1L,
        stats::qt(1 - alpha / 2, n - 1),
        achieved,
        precision
      )
    ),
    reference = paste(
      "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 9 (Confidence Intervals), Eq 9.18, p. 152 (iterative",
      "Student t form; Eq 9.19 for relative precision).\n\n",
      "Also: Bhardwaj et al. (2024), p. 2558 (continuous outcome precision,",
      "normal approximation)."
    ),
    roles = c(
      "sigma = population standard deviation (from pilot/literature)",
      "precision = margin of error d"
    ),
    hints = if (ceiling(n_initial) < 40) {
      sprintf(
        paste(
          "The normal approximation gives %d; an integer search using",
          "the Student t quantile (Machin Eq 9.18) requires %d observations."
        ),
        ceiling(n_initial),
        ceiling(n)
      )
    } else {
      character()
    }
  )
}

#' Internal calculation: single correlation coefficient precision (Fisher z / Machin)
#'
#' Sample size for estimating a Pearson correlation coefficient with pre-specified
#' confidence interval width w = 2*d (Machin et al. 2018, Ch.19, Equations 19.5-19.8).
#' Matches prec_cor in the presize package for identical parameters.
#'
#' @param r Anticipated correlation coefficient
#' @param epsilon Relative precision (margin d = epsilon * r)
#' @param precision Absolute margin of error d (half-width of CI)
#' @param alpha Type I error (two-sided CI, default 0.05)
#' @param power Ignored (estimation design)
#' @return List consumed by as_sample_size_result()
#' @keywords internal
calculate_single_correlation <- function(
  r,
  epsilon = NULL,
  precision = NULL,
  alpha = 0.05,
  power = NULL
) {
  if (!is.numeric(r) || length(r) != 1 || r <= 0 || r >= 1) {
    cli::cli_abort(c(
      "{.arg r} must be a single correlation in (0, 1).",
      "x" = "You provided {.val {r}}."
    ))
  }
  if (is.null(epsilon) && is.null(precision)) {
    cli::cli_abort(
      "Either {.arg epsilon} (relative precision) or {.arg precision} (CI half-width) must be provided."
    )
  }

  if (!is.null(epsilon)) {
    if (!is.numeric(epsilon) || length(epsilon) != 1 || epsilon <= 0) {
      cli::cli_abort(c(
        "{.arg epsilon} must be a single positive relative precision.",
        "x" = "You provided {.val {epsilon}}."
      ))
    }
    d_val <- epsilon * r
    prec_type <- "relative"
  } else {
    if (
      !is.numeric(precision) ||
        length(precision) != 1 ||
        precision <= 0 ||
        precision >= 1
    ) {
      cli::cli_abort(c(
        "{.arg precision} must be a single positive CI half-width in (0, 1).",
        "x" = "You provided {.val {precision}}."
      ))
    }
    d_val <- precision
    prec_type <- "absolute"
  }

  w <- 2 * d_val
  z <- z_alpha(alpha, "two.sided")

  # Machin 2018 Chapter 19, Equation 19.5 (initial estimate N_P0)
  n_p0 <- 4 * (z^2) * ((1 - r^2)^2) / (w^2) + 3

  # Machin 2018 Equations 19.6 - 19.8 (refined estimate N_Pfinal)
  u_val <- atanh(r) + z / sqrt(n_p0 - 3)
  l_val <- atanh(r) - z / sqrt(n_p0 - 3)
  w0 <- tanh(u_val) - tanh(l_val)
  n_final <- (n_p0 - 3) * (w0 / w)^2 + 3

  list(
    design_type = "Single correlation estimation (Fisher z precision)",
    n_required = as.integer(ceiling(n_final)),
    parameters = list(
      r = r,
      precision = d_val,
      precision_type = prec_type,
      epsilon = epsilon,
      alpha = alpha
    ),
    formula = "Machin 19.5-19.8: N_P0 = 4*z^2*(1-r^2)^2/w^2 + 3, refined via Fisher z bounds",
    formula_latex = "$$N_{P0} = \\frac{4 z_{1-\\alpha/2}^2 (1-r^2)^2}{w^2} + 3, \\quad N_{Final} = (N_{P0}-3)\\left(\\frac{w_0}{w}\\right)^2 + 3$$",
    reference = paste(
      "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 19 (The Correlation Coefficient), Equations 19.5-19.8, pp. 307-308.\n\n",
      "Also: Fisher, R. A. (1921). On the 'probable error' of a coefficient of",
      "correlation deduced from a small sample. Metron, 1, 3-32."
    ),
    roles = c(
      "r = anticipated correlation coefficient",
      if (prec_type == "relative") {
        "epsilon = relative precision (margin d = epsilon * r)"
      } else {
        "precision = margin of error d (CI half-width, w = 2*d)"
      },
      sprintf("confidence level = %d%%", round(100 * (1 - alpha)))
    )
  )
}

# Register estimation combos in the master table (appended by calculate.R).
ssr_estimation_combinations <- list(
  list(
    design = "singleProportion",
    task = "estimate",
    outcome = "proportion",
    internal = "singleProportion",
    default = TRUE
  ),
  list(
    design = "singleMean",
    task = "estimate",
    outcome = "mean",
    internal = "singleMean",
    default = TRUE
  ),
  list(
    design = "singleCorrelation",
    task = "estimate",
    outcome = "correlation",
    internal = "singleCorrelation",
    default = TRUE
  )
)

# Dispatch for estimation designs (called from dispatch_calculation's
# estimation branch).
dispatch_estimation <- function(internal_keyword, args, alpha, power) {
  switch(
    internal_keyword,
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
      precision = args$precision,
      alpha = alpha,
      power = power
    ),
    cli::cli_abort("Unknown estimation design {.val {internal_keyword}}.")
  )
}
