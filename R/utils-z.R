# Internal numeric kernels shared by all design modules (all @noRd, internal)

# Two-sided vs one-sided z quantile for alpha
z_alpha <- function(alpha, alternative = c("two.sided", "one.sided")) {
  alternative <- rlang::arg_match(alternative)
  stats::qnorm(if (alternative == "two.sided") 1 - alpha / 2 else 1 - alpha)
}

# z quantile for target power
z_power <- function(power) {
  stats::qnorm(power)
}

# Inflate a sample size for dropout / non-response.
# method = "inflate":  n * = n / (1 - d)  (canonical; retains powered sample)
# method = "additive": n * = n * (1 + d)  (common quick practice; the formula
#   Bhardwaj 2024 p.2557 states, and the arithmetic its worked examples use)
inflate_n <- function(n, dropout = 0, method = c("inflate", "additive")) {
  method <- rlang::arg_match(method, c("inflate", "additive"))
  if (!is.numeric(dropout) || length(dropout) != 1 || dropout < 0 || dropout >= 1) {
    cli::cli_abort(c(
      "{.arg dropout} must be a single proportion in [0, 1).",
      "x" = "You provided {.val {dropout}}."
    ))
  }
  if (dropout == 0) {
    return(as.integer(ceiling(n)))
  }
  inflated <- if (method == "inflate") n / (1 - dropout) else n * (1 + dropout)
  as.integer(ceiling(inflated))
}

# Design effect for cluster designs: DE = 1 + (m - 1) * ICC
# Source: Machin & Campbell 2018 Ch.12; Donner & Klar 2000
design_effect <- function(cluster_size, icc) {
  if (!is.numeric(cluster_size) || length(cluster_size) != 1 || cluster_size < 1) {
    cli::cli_abort(c(
      "{.arg cluster_size} must be a single number >= 1.",
      "x" = "You provided {.val {cluster_size}}."
    ))
  }
  if (!is.numeric(icc) || length(icc) != 1 || icc < 0 || icc >= 1) {
    cli::cli_abort(c(
      "{.arg icc} must be a single number in [0, 1).",
      "x" = "You provided {.val {icc}}."
    ))
  }
  1 + (cluster_size - 1) * icc
}

# Standardized result assembler: wraps a calculate_* list into the S3 object.
# Design modules return (design_type, legacy fields, parameters, formula*,
# reference, roles); this adds axis metadata and applies the constructor.
as_sample_size_result <- function(design,
                                  task,
                                  outcome,
                                  calc) {
  # [[ ]] exact extraction: calc$formula would partially match formula_latex
  # when the ASCII formula field is absent (e.g. superiorityMeans).
  new_sample_size_result(
    design = design,
    task = task,
    outcome = outcome,
    design_type = calc$design_type,
    parameters = calc$parameters %||% list(),
    legacy = calc[setdiff(names(calc), c("design_type", "parameters", "formula", "formula_latex", "calculation", "calculation_steps", "reference", "roles", "adjustments", "hints", "replay_args"))],
    formula_ascii = calc[["formula"]],
    formula_latex = calc[["formula_latex"]],
    calculation = calc[["calculation"]] %||% calc[["calculation_steps"]],
    reference = calc[["reference"]],
    roles = calc$roles %||% character(),
    adjustments = calc$adjustments %||% list(),
    hints = calc$hints %||% character()
  )
}

# Null coalescing operator (moved here from summary_sample_size_result.R;
# single source of truth for all modules)
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
