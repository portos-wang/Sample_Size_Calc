# S3 method: plot

#' Plot sample size calculation result
#'
#' Draw power curve (sample size vs power) or sample size vs effect size ratio.
#' Requires packages \pkg{ggplot2} and \pkg{scales}.
#'
#' @param x Object of class \code{sample_size_result} from \code{\link{calculate}}
#'   or \code{\link{sample_size_calculator}}.
#' @param type \code{"power"} for sample size vs power; \code{"sample_size"} for
#'   sample size vs effect size ratio (supported for twoMeans and twoProportions).
#' @param ... Passed to downstream methods (currently unused).
#' @return Invisibly returns \code{x}. A plot is drawn.
#' @examples
#' # Antihypertensive RCT planning: check how power scales with enrollment
#' res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' plot(res, type = "power")        # sample size vs power curve
#' \donttest{
#' plot(res, type = "sample_size")  # sample size vs effect size
#' }
#' @export
plot.sample_size_result <- function(x, type = c("power", "sample_size"), ...) {
  type <- rlang::arg_match(type)

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg ggplot2} is required for plotting.",
      "i" = "Please install it with {.code install.packages('ggplot2')}"
    ))
  }

  if (!requireNamespace("scales", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg scales} is required for plotting.",
      "i" = "Please install it with {.code install.packages('scales')}"
    ))
  }

  if (is.null(x$design) || is.null(x$parameters)) {
    cli::cli_abort(c(
      "Cannot plot: missing required fields in result object.",
      "x" = "Expected {.field design} and {.field parameters} to exist."
    ))
  }

  if (type == "power") {
    plot_power_curve(x)
  } else {
    plot_sample_size_comparison(x)
  }
}

# Re-run the calculation at an arbitrary power value, preserving the entry
# point and axes of the original result.
ssr_replay_at_power <- function(x, p) {
  replay_args <- x$replay_args %||% {
    va <- x$parameters
    va$alpha <- NULL
    va$power <- NULL
    va
  }
  if (!is.null(x$design_canonical)) {
    do.call(
      calculate,
      c(
        list(
          design = x$design_canonical,
          task = x$task,
          outcome = x$outcome,
          power = p
        ),
        replay_args
      )
    )
  } else {
    do.call(
      sample_size_calculator,
      c(list(design = x$design, power = p), replay_args)
    )
  }
}

# Designs for which a power curve is unavailable or would re-run an expensive
# exact search at every grid point.
ssr_no_power_curve <- c("singleArmPhaseII", "predictiveModel", "its")

#' Plot power curve
#'
#' @param result A sample_size_result object
#' @return Invisibly returns the result object
#' @keywords internal
#' @examples
#' \donttest{
#' res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' SampleSizeCalc:::plot_power_curve(res)
#' }
plot_power_curve <- function(result) {
  if (!is.null(result$design_canonical) &&
    result$design_canonical %in% ssr_no_power_curve) {
    cli::cli_warn(c(
      "Power curve not available for design {.val {result$design_canonical}}.",
      "i" = "This design does not take power as a continuous input (or the",
      "i" = "calculation is an exact search too expensive to replay)."
    ))
    return(invisible(result))
  }

  params <- result$parameters

  if (is.null(params$alpha)) {
    cli::cli_warn("Cannot plot power curve: alpha parameter missing")
    return(invisible(result))
  }

  alpha <- params$alpha
  power_range <- seq(0.5, 0.99, by = 0.01)

  sample_sizes <- vapply(power_range, function(p) {
    res <- tryCatch(ssr_replay_at_power(result, p), error = function(e) NULL)
    if (is.null(res)) {
      return(NA_real_)
    }
    if (!is.null(res$n_per_group)) {
      return(as.numeric(res$n_per_group))
    }
    if (!is.null(res$pairs_count)) {
      return(as.numeric(res$pairs_count))
    }
    if (!is.null(res$target_events_needed)) {
      return(as.numeric(res$target_events_needed))
    }
    if (!is.null(res$target_state_cases_needed)) {
      return(as.numeric(res$target_state_cases_needed))
    }
    if (!is.null(res$cases_needed)) {
      return(as.numeric(res$cases_needed))
    }
    NA_real_
  }, numeric(1))

  if (all(is.na(sample_sizes))) {
    cli::cli_warn(c(
      "No plottable sample-size metric found for this design.",
      "i" = "Power curves require n_per_group / pairs / events / cases outputs."
    ))
    return(invisible(result))
  }

  df <- data.frame(power = power_range, sample_size = sample_sizes)
  df <- df[!is.na(df$sample_size), , drop = FALSE]

  p <- ggplot2::ggplot(df, ggplot2::aes(x = power, y = sample_size)) +
    ggplot2::geom_line(color = "#007BC2", linewidth = 1) +
    ggplot2::geom_point(color = "#007BC2", size = 2) +
    ggplot2::labs(
      title = "Sample Size vs Power",
      subtitle = result$design_type %||% result$design,
      x = "Power (1 - beta)",
      y = "Sample Size"
    ) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 10),
      axis.title = ggplot2::element_text(size = 11),
      panel.grid.minor = ggplot2::element_blank()
    )

  print(p)
  invisible(result)
}

#' Plot sample size comparison
#'
#' @param result A sample_size_result object
#' @return Invisibly returns the result object
#' @keywords internal
#' @examples
#' \donttest{
#' res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' SampleSizeCalc:::plot_sample_size_comparison(res)
#' }
plot_sample_size_comparison <- function(result) {
  params <- result$parameters
  alpha <- params$alpha
  current_power <- params$power

  if (is.null(alpha) || is.null(current_power)) {
    cli::cli_warn("Cannot plot sample size comparison: alpha/power missing")
    return(invisible(result))
  }

  effect_sizes <- NULL
  sample_sizes <- NULL

  if (!is.null(params$mean1) && !is.null(params$mean2) && !is.null(params$sd)) {
    mean1 <- params$mean1
    mean2 <- params$mean2
    sd <- params$sd
    baseline_diff <- abs(mean1 - mean2)

    effect_ratios <- seq(0.5, 2.0, by = 0.1)
    sample_sizes <- vapply(effect_ratios, function(ratio) {
      new_diff <- baseline_diff * ratio
      res <- tryCatch(sample_size_calculator(
        design = "twoMeans",
        mean1 = mean1,
        mean2 = mean1 + new_diff * sign(mean2 - mean1),
        sd = sd,
        alpha = alpha,
        power = current_power
      ), error = function(e) NULL)
      if (is.null(res) || is.null(res$n_per_group)) {
        return(NA_real_)
      }
      as.numeric(res$n_per_group)
    }, numeric(1))
    effect_sizes <- effect_ratios
  } else if (!is.null(params$p1) && !is.null(params$p2)) {
    p1 <- params$p1
    p2 <- params$p2
    baseline_diff <- abs(p1 - p2)

    effect_ratios <- seq(0.5, 2.0, by = 0.1)
    sample_sizes <- vapply(effect_ratios, function(ratio) {
      new_diff <- baseline_diff * ratio
      new_p2 <- p1 + new_diff * sign(p2 - p1)
      if (new_p2 <= 0 || new_p2 >= 1) {
        return(NA_real_)
      }
      res <- tryCatch(sample_size_calculator(
        design = "twoProportions",
        p1 = p1,
        p2 = new_p2,
        alpha = alpha,
        power = current_power
      ), error = function(e) NULL)
      if (is.null(res) || is.null(res$n_per_group)) {
        return(NA_real_)
      }
      as.numeric(res$n_per_group)
    }, numeric(1))
    effect_sizes <- effect_ratios
  } else {
    cli::cli_warn("Sample size comparison plot currently supports twoMeans/twoProportions only")
    return(invisible(result))
  }

  df <- data.frame(effect_ratio = effect_sizes, sample_size = sample_sizes)
  df <- df[!is.na(df$sample_size), , drop = FALSE]

  p <- ggplot2::ggplot(df, ggplot2::aes(x = effect_ratio, y = sample_size)) +
    ggplot2::geom_line(color = "#28A745", linewidth = 1) +
    ggplot2::geom_point(color = "#28A745", size = 2) +
    ggplot2::geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
    ggplot2::labs(
      title = "Sample Size vs Effect Size Ratio",
      subtitle = result$design_type %||% result$design,
      x = "Effect Size Ratio (relative to baseline)",
      y = "Sample Size per Group"
    ) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 10),
      axis.title = ggplot2::element_text(size = 11),
      panel.grid.minor = ggplot2::element_blank()
    )

  print(p)
  invisible(result)
}
