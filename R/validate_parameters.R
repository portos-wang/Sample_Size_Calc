# Validation utilities for sample size calculation

#' Validate alpha (type I error) parameter
#'
#' @param alpha Type I error rate; single numeric strictly inside (0, 1).
#'   Convention: 0.05 for two-sided tests; 0.025 or 0.05 for one-sided
#'   non-inferiority/superiority tests. Values outside (0, 1) abort.
#' @return Validated alpha value (invisible numeric scalar)
#' @examples
#' SampleSizeCalc:::validate_alpha(0.05)   # OK
#' try(SampleSizeCalc:::validate_alpha(1.5))  # structured error
#' @keywords internal
validate_alpha <- function(alpha) {
  if (!is.numeric(alpha) || is.complex(alpha) || length(alpha) != 1) {
    cli::cli_abort(c(
      "{.arg alpha} must be a single numeric value.",
      "x" = "You provided {.cls {class(alpha)}} of length {length(alpha)}."
    ))
  }
  if (!is.finite(alpha)) {
    cli::cli_abort("{.arg alpha} must be a single finite numeric value.")
  }
  if (alpha <= 0 || alpha >= 1) {
    cli::cli_abort(c(
      "{.arg alpha} must be between 0 and 1, not {.val {alpha}}.",
      "i" = "Typical values are 0.05 or 0.01."
    ))
  }
  alpha
}

#' Validate the `alternative` argument
#'
#' @param alternative `"two.sided"` or `"one.sided"`; `NULL` means "use the
#'   design's own convention" (each kernel's historical default).
#' @return Validated alternative value (character scalar or NULL)
#' @keywords internal
validate_alternative <- function(alternative) {
  if (is.null(alternative)) {
    return(NULL)
  }
  rlang::arg_match(alternative, c("two.sided", "one.sided"))
}

#' Validate power parameter
#'
#' @param power Statistical power (1 - beta); single numeric strictly inside
#'   (0, 1). Typical: 0.8 (80 percent) or 0.9 (90 percent). Values outside
#'   (0, 1) abort.
#' @return Validated power value (invisible numeric scalar)
#' @examples
#' SampleSizeCalc:::validate_power(0.8)     # OK
#' try(SampleSizeCalc:::validate_power(0))   # structured error
#' @keywords internal
validate_power <- function(power) {
  if (!is.numeric(power) || is.complex(power) || length(power) != 1) {
    cli::cli_abort(c(
      "{.arg power} must be a single numeric value.",
      "x" = "You provided {.cls {class(power)}} of length {length(power)}."
    ))
  }
  if (!is.finite(power)) {
    cli::cli_abort("{.arg power} must be a single finite numeric value.")
  }
  if (power <= 0 || power >= 1) {
    cli::cli_abort(c(
      "{.arg power} must be between 0 and 1, not {.val {power}}.",
      "i" = "Typical values are 0.8, 0.9, or 0.95."
    ))
  }
  power
}

# Shared boundary check for numeric design inputs, before kernel arithmetic.
validate_numeric_scalar <- function(value, arg) {
  if (
    !is.numeric(value) ||
      is.complex(value) ||
      length(value) != 1L ||
      !is.finite(value)
  ) {
    cli::cli_abort("{.arg {arg}} must be a single finite numeric value.")
  }
  invisible(value)
}

validate_numeric_args <- function(args) {
  for (arg in names(args)) {
    if (!is.null(args[[arg]])) {
      validate_numeric_scalar(args[[arg]], arg)
    }
  }
  invisible(args)
}

validate_kappa_joint <- function(pi1, pi2, kappa, arg) {
  pe <- pi1 * pi2 + (1 - pi1) * (1 - pi2)
  po <- kappa * (1 - pe) + pe
  p11 <- (po + pi1 + pi2 - 1) / 2
  cells <- c(p11, pi1 - p11, pi2 - p11, 1 - pi1 - pi2 + p11)
  if (any(cells < -1e-12) || any(cells > 1 + 1e-12)) {
    cli::cli_abort(c(
      "{.arg {arg}} is incompatible with the supplied rater marginal proportions.",
      "i" = "The implied joint rating probabilities must all be between zero and one."
    ))
  }
  invisible(TRUE)
}
