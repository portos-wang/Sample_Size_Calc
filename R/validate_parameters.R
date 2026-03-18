# Validation utilities for sample size calculation

#' Validate alpha (type I error) parameter
#'
#' @param alpha Type I error rate
#' @return Validated alpha value
#' @name validate_alpha
#' @keywords internal
validate_alpha <- function(alpha) {
  if (!is.numeric(alpha) || length(alpha) != 1) {
    cli::cli_abort(c(
      "{.arg alpha} must be a single numeric value.",
      "x" = "You provided {.cls {class(alpha)}} of length {length(alpha)}."
    ))
  }
  if (alpha <= 0 || alpha >= 1) {
    cli::cli_abort(c(
      "{.arg alpha} must be between 0 and 1, not {.val {alpha}}.",
      "i" = "Typical values are 0.05 or 0.01."
    ))
  }
  alpha
}

#' Validate power parameter
#'
#' @param power Statistical power (1 - beta)
#' @return Validated power value
#' @name validate_power
#' @keywords internal
validate_power <- function(power) {
  if (!is.numeric(power) || length(power) != 1) {
    cli::cli_abort(c(
      "{.arg power} must be a single numeric value.",
      "x" = "You provided {.cls {class(power)}} of length {length(power)}."
    ))
  }
  if (power <= 0 || power >= 1) {
    cli::cli_abort(c(
      "{.arg power} must be between 0 and 1, not {.val {power}}.",
      "i" = "Typical values are 0.8, 0.9, or 0.95."
    ))
  }
  power
}
