# Phase 5: complex designs.
# clusterRCT (DE wrapper), singleArmPhaseII (Simon/A'Hern), NI proportions,
# twoOrdinal (Whitehead), predictive EPV, ITS (experimental).
# kappa and steppedWedge are deferred: formulas in Machin Ch.20/Ch.13 are
# OCR-garbled in the available PDF and require paper derivation first.

# ------------------------------------------------------- cluster wrapper ----

#' Apply the cluster design effect to an individually-randomised result
#'
#' DE = 1 + (m - 1) * ICC (Machin 2018 Ch.12). Cluster-level rounding:
#' n_clusters = ceiling(n_individuals * DE / m), individuals = n_clusters * m.
#' @keywords internal
apply_cluster_design <- function(base, cluster_size, icc) {
  de <- design_effect(cluster_size, icc)
  n_clusters <- as.integer(ceiling(base$n_per_group * de / cluster_size))
  n_individuals <- as.integer(n_clusters * cluster_size)

  base$n_per_group <- n_individuals
  base$total_n <- n_individuals * 2L
  base$n_clusters <- n_clusters
  base$parameters$icc <- icc
  base$parameters$cluster_size <- cluster_size
  base$parameters$design_effect <- de
  base$roles <- c(base$roles, sprintf(
    "icc = %.2f, cluster_size = %d -> DE = %.2f; n_clusters per arm = %d",
    icc, cluster_size, de, n_clusters
  ))
  base
}

#' Cluster RCT wrapping the two-means kernel
#' @keywords internal
calculate_cluster_mean <- function(mean1, mean2, sd, icc, cluster_size,
                                   alpha, power) {
  base <- calculate_two_means(
    mean1 = mean1, mean2 = mean2, sd = sd,
    alpha = alpha, power = power
  )
  res <- apply_cluster_design(base, cluster_size, icc)
  res$design_type <- paste("Cluster RCT:", res$design_type)
  res$reference <- paste(
    "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
    "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
    "Wiley. Chapter 12 (Cluster Designs); Donner, A., & Klar, N. (2000).",
    "Design and Analysis of Cluster Randomisation Trials in Health Research.",
    "Arnold.\n\n", res$reference
  )
  res
}

#' Cluster RCT wrapping the two-proportions kernel
#' @keywords internal
calculate_cluster_proportion <- function(p1, p2, icc, cluster_size,
                                         alpha, power) {
  base <- calculate_two_proportions(p1 = p1, p2 = p2, alpha = alpha, power = power)
  res <- apply_cluster_design(base, cluster_size, icc)
  res$design_type <- paste("Cluster RCT:", res$design_type)
  res$reference <- paste(
    "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
    "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
    "Wiley. Chapter 12 (Cluster Designs); Donner, A., & Klar, N. (2000).",
    "Design and Analysis of Cluster Randomisation Trials in Health Research.",
    "Arnold.\n\n", res$reference
  )
  res
}

# ------------------------------------------------- single-arm phase II ----

# P(declare effective | p) for design (r1/n1, r/n):
# effective iff X1 + X2 > r (stage 1 stops for futility if X1 <= r1)
simon_power <- function(p, n1, n2, r1, r) {
  x1 <- (r1 + 1):n1
  if (length(x1) == 0) {
    return(0)
  }
  p_x1 <- stats::dbinom(x1, n1, p)
  pass2 <- 1 - stats::pbinom(r - x1, n2, p) # P(X2 > r - x1)
  pass2[r - x1 < 0] <- 1
  sum(p_x1 * pass2)
}

simon_pet <- function(p, n1, r1) {
  stats::pbinom(r1, n1, p) # probability of stopping for futility
}

# Exhaustive exact search over feasible (r1/n1, r/n) designs.
# Vectorized per (n1, n2): power(r; r1) for all r via suffix sums over x1.
simon_search <- function(p0, p1, alpha, power, n_max = 100) {
  feasible <- list()
  for (n1 in 1:(n_max - 1)) {
    p0_x <- stats::dbinom(0:n1, n1, p0)
    p1_x <- stats::dbinom(0:n1, n1, p1)
    for (n2 in 1:(n_max - n1)) {
      n <- n1 + n2
      r_grid <- 0:(n - 1)
      r_minus_x1 <- outer(r_grid, 0:n1, function(r, x) r - x)
      q2_0 <- 1 - stats::pbinom(r_minus_x1, n2, p0) # P(X2 > r-x1 | p0)
      q2_1 <- 1 - stats::pbinom(r_minus_x1, n2, p1)
      A0 <- q2_0 * rep(p0_x, each = length(r_grid))
      A1 <- q2_1 * rep(p1_x, each = length(r_grid))
      # suffix sums over x1 (descending): S[r+1, x1+1] = sum_{x >= x1} A[r+1, x]
      S0 <- A0
      S1 <- A1
      if (n1 > 0) {
        for (j in seq(ncol(S0) - 1, 1)) {
          S0[, j] <- S0[, j] + S0[, j + 1]
          S1[, j] <- S1[, j] + S1[, j + 1]
        }
      }
      for (r1 in 0:(n1 - 1)) {
        power1_vec <- S1[, r1 + 2] # sum over x1 >= r1+1
        # Both power and alpha DECREASE as r grows (larger r = more
        # conservative boundary). Among r > r1 that still reach the target
        # power, the largest r minimises alpha -- take that one.
        ok_r <- which(power1_vec >= power & r_grid > r1)
        if (length(ok_r) == 0) next
        r <- r_grid[ok_r[length(ok_r)]]
        if (S0[r + 1, r1 + 2] <= alpha) {
          pet0 <- stats::pbinom(r1, n1, p0)
          feasible[[length(feasible) + 1]] <- list(
            r1 = r1, n1 = n1, r = r, n = n,
            en_p0 = n1 + (n - n1) * (1 - pet0),
            pet = pet0
          )
        }
      }
    }
  }
  feasible
}

#' Single-arm phase II: Simon two-stage design (exact search)
#'
#' Optimal minimises the expected sample size under p0; minimax minimises
#' the maximum N. Exact type-I error and power computed via binomial
#' probabilities. Anchor: Simon 1989 Table 1; Machin 2018 Example 17.2.
#' @keywords internal
calculate_simon_two_stage <- function(p0, p1, alpha, power, optimizer) {
  if (!is.numeric(p0) || p0 <= 0 || p0 >= 1) cli::cli_abort("{.arg p0} must be in (0, 1).")
  if (!is.numeric(p1) || p1 <= 0 || p1 >= 1) cli::cli_abort("{.arg p1} must be in (0, 1).")
  if (p1 <= p0) cli::cli_abort("{.arg p1} must exceed {.arg p0}.")
  optimizer <- rlang::arg_match(optimizer, c("optimal", "minimax"))

  feasible <- simon_search(p0, p1, alpha, power)
  if (length(feasible) == 0) {
    cli::cli_abort(c(
      "No feasible two-stage design found within n_max = 100.",
      "i" = "Increase the effect size or relax alpha/power."
    ))
  }

  chosen <- if (optimizer == "optimal") {
    feasible[[which.min(vapply(feasible, `[[`, numeric(1), "en_p0"))]]
  } else {
    feasible[[which.min(vapply(feasible, `[[`, numeric(1), "n"))]]
  }

  list(
    design_type = sprintf(
      "Single-arm phase II (Simon two-stage, %s)", optimizer
    ),
    n_stage_1 = chosen$n1,
    r_stage_1 = chosen$r1,
    n_total = chosen$n,
    r_total = chosen$r,
    expected_n_under_h0 = round(chosen$en_p0, 1),
    parameters = list(
      p0 = p0, p1 = p1, alpha = alpha, power = power, optimizer = optimizer
    ),
    formula = "exact binomial: P(effective|p0) <= alpha and P(effective|p1) >= power",
    formula_latex = NULL,
    reference = paste(
      "Primary: Simon, R. (1989). Optimal two-stage designs for phase II",
      "clinical trials. Controlled Clinical Trials, 10(1), 1-10.\n\n",
      "Also: Machin et al. (2018) Chapter 17 (Therapeutic Exploratory Trials)."
    ),
    roles = c(
      "p0 = unacceptable response rate (null)",
      "p1 = desirable response rate (alternative)",
      "stage 1: stop for futility if responses <= r_stage_1 of n_stage_1",
      "overall: declare effective if responses > r_total of n_total"
    )
  )
}

#' Single-arm phase II: A'Hern single-stage design (exact search)
#' @keywords internal
calculate_ahern <- function(p0, p1, alpha, power) {
  if (!is.numeric(p0) || p0 <= 0 || p0 >= 1) cli::cli_abort("{.arg p0} must be in (0, 1).")
  if (!is.numeric(p1) || p1 <= 0 || p1 >= 1) cli::cli_abort("{.arg p1} must be in (0, 1).")
  if (p1 <= p0) cli::cli_abort("{.arg p1} must exceed {.arg p0}.")

  for (n in seq_len(500)) {
    for (r in 0:(n - 1)) {
      # Type-I: P(X > r | p0) <= alpha  <=>  P(X <= r | p0) >= 1 - alpha
      # Power:  P(X > r | p1) >= 1 - beta  <=>  P(X <= r | p1) <= beta
      if (stats::pbinom(r, n, p0) >= 1 - alpha &&
        stats::pbinom(r, n, p1) <= 1 - power) {
        return(list(
          design_type = "Single-arm phase II (A'Hern single-stage)",
          n_required = as.integer(n),
          r_total = as.integer(r),
          parameters = list(p0 = p0, p1 = p1, alpha = alpha, power = power),
          formula = "P(X > r | p0) <= alpha and P(X > r | p1) >= power",
          formula_latex = NULL,
          reference = paste(
            "Primary: A'Hern, R. P. (2001). Single stage and double sampling",
            "phase II trials. British Journal of Cancer, 85(2), 223-226."
          ),
          roles = c(
            "p0 = unacceptable response rate",
            "p1 = desirable response rate",
            "declare effective if responses > r_total of n_required"
          )
        ))
      }
    }
  }
  cli::cli_abort("No feasible single-stage design within n = 500.")
}

# ------------------------------------------------- NI proportions (rct) ----

#' RCT non-inferiority for proportions (fills the legacy margin gap)
#' @keywords internal
calculate_non_inferiority_proportions <- function(p1, p2, margin, alpha, power) {
  if (!is.numeric(p1) || p1 <= 0 || p1 >= 1) cli::cli_abort("{.arg p1} must be in (0, 1).")
  if (!is.numeric(p2) || p2 <= 0 || p2 >= 1) cli::cli_abort("{.arg p2} must be in (0, 1).")
  if (!is.numeric(margin) || margin <= 0 || margin >= 1) {
    cli::cli_abort("{.arg margin} must be in (0, 1).")
  }
  delta_e <- p1 - p2 + margin
  if (delta_e <= 0) {
    cli::cli_abort(c(
      "Non-inferiority margin not met.",
      "x" = "p1 - p2 + margin = {.val {delta_e}} <= 0"
    ))
  }
  z_a <- z_alpha(alpha, "one.sided")
  z_b <- z_power(power)
  n <- (z_a + z_b)^2 * (p1 * (1 - p1) + p2 * (1 - p2)) / delta_e^2

  list(
    design_type = "Non-inferiority (proportions)",
    n_per_group = as.integer(ceiling(n)),
    total_n = as.integer(ceiling(n)) * 2L,
    parameters = list(p1 = p1, p2 = p2, margin = margin, alpha = alpha, power = power),
    formula = "n = (Za+Zb)^2 * (p1q1+p2q2) / (p1-p2+margin)^2",
    formula_latex = "$$n = \\frac{(Z_{\\alpha}+Z_{\\beta})^2\\left[p_1(1-p_1)+p_2(1-p_2)\\right]}{(p_1-p_2+\\Delta)^2}$$",
    reference = paste(
      "Primary: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017).",
      "Sample Size Calculations in Clinical Research (3rd ed.). CRC Press;",
      "Machin et al. (2018) Chapter 11 (Non-inferiority and Equivalence)."
    ),
    roles = c(
      "p1 = experimental-group response rate",
      "p2 = active-control response rate",
      "margin = non-inferiority margin Delta (one-sided alpha)"
    )
  )
}

# ------------------------------------------------------ ordinal (2 groups) ----

#' Two-group comparison of an ordered categorical outcome (Whitehead)
#'
#' N = 3 (Za/2 + Zb)^2 / ((log OR)^2 (1 - sum(p_bar^3))), where p_bar are the
#' anticipated average category proportions across the two groups.
#' @keywords internal
calculate_two_ordinal <- function(or, prop_bar, alpha, power) {
  if (!is.numeric(or) || length(or) != 1 || or <= 0 || or == 1) {
    cli::cli_abort("{.arg or} must be a positive odds ratio != 1.")
  }
  if (!is.numeric(prop_bar) || any(prop_bar <= 0) || abs(sum(prop_bar) - 1) > 1e-6) {
    cli::cli_abort("{.arg prop_bar} must be positive proportions summing to 1.")
  }

  log_or <- log(or)
  p_bar <- prop_bar / sum(prop_bar)
  sum_cube <- sum(p_bar^3)
  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  n_total <- 3 * (z_a + z_b)^2 / (log_or^2 * (1 - sum_cube))

  list(
    design_type = "Two-group ordered categorical outcome (Mann-Whitney / proportional odds)",
    n_per_group = as.integer(ceiling(n_total / 2)),
    total_n = as.integer(ceiling(n_total)),
    parameters = list(
      or = or, prop_bar = p_bar, alpha = alpha, power = power
    ),
    formula = "N = 3(Za/2+Zb)^2 / ((log OR)^2 * (1 - sum(p_bar^3)))",
    formula_latex = "$$N = \\frac{3\\,(Z_{\\alpha/2}+Z_{\\beta})^2}{(\\log OR)^2\\,(1-\\sum \\bar{p}_j^3)}$$",
    reference = paste(
      "Primary: Whitehead, J. (1993). Sample size calculations for ordered",
      "categorical data. Statistics in Medicine, 12(24), 2257-2271.\n\n",
      "Also: Machin et al. (2018) Chapter 4 (Ordered Categorical Outcomes)."
    ),
    roles = c(
      "or = anticipated odds ratio (proportional odds)",
      "prop_bar = anticipated average category proportions (sums to 1)",
      "output: total N and per-group n (equal allocation)"
    )
  )
}

# --------------------------------------------------- predictive model (EPV) ----

#' Predictive/prognostic model development: events-per-variable rule
#'
#' n_events = epv * n_parameters; n_subjects = n_events / event_prevalence.
#' Source: Peduzzi et al. (1996); Riley et al. (2019) offer a modern
#' alternative planned for a later release.
#' @keywords internal
calculate_predictive_epv <- function(n_parameters, epv, event_prevalence) {
  if (!is.numeric(n_parameters) || length(n_parameters) != 1 || n_parameters < 1) {
    cli::cli_abort("{.arg n_parameters} must be a positive integer.")
  }
  if (!is.numeric(epv) || length(epv) != 1 || epv < 1) {
    cli::cli_abort(c(
      "{.arg epv} must be >= 1 (10 events per variable is the classic rule).",
      "i" = "Peduzzi et al. (1996) recommend EPV >= 10."
    ))
  }
  if (!is.numeric(event_prevalence) || event_prevalence <= 0 || event_prevalence >= 1) {
    cli::cli_abort("{.arg event_prevalence} must be in (0, 1).")
  }

  n_events <- ceiling(epv * n_parameters)
  n_subjects <- ceiling(n_events / event_prevalence)

  hints <- c(
    "EPV >= 10 is a minimum heuristic; Riley et al. (2019, BMJ 364:l951)",
    "provide a modern precision-based alternative (planned for a later release)."
  )

  list(
    design_type = "Prediction model development (events-per-variable)",
    events_required = as.integer(n_events),
    n_required = as.integer(n_subjects),
    parameters = list(
      n_parameters = n_parameters, epv = epv, event_prevalence = event_prevalence
    ),
    formula = "n_events = EPV * k ; n_subjects = n_events / prevalence",
    formula_latex = "$$n_{events} = EPV \\times k, \\quad n_{subjects} = n_{events} / \\pi$$",
    reference = paste(
      "Primary: Peduzzi, P., Concato, J., Kemper, E., Holford, T. R., &",
      "Feinstein, A. R. (1996). A simulation study of the number of events per",
      "variable in logistic regression analysis. Journal of Clinical",
      "Epidemiology, 49(12), 1373-1379."
    ),
    roles = c(
      "n_parameters = candidate predictor parameters (k)",
      "epv = events per variable (classic minimum 10)",
      "event_prevalence = proportion of subjects with the outcome"
    ),
    hints = hints
  )
}

# ------------------------------------------------------------ ITS (experimental) ----

#' Interrupted time series: level-change power (AR(1)-adjusted, experimental)
#'
#' Transparent normal approximation with the AR(1) effective-sample-size
#' correction n_eff = n * (1 - rho) / (1 + rho) per segment. Experimental:
#' see Bernal et al. (2017) for the methodological framework; rigorous ITS
#' power requires simulation.
#' @keywords internal
calculate_its_level <- function(effect_sd, n_pre, n_post, rho, alpha, power) {
  if (!is.numeric(effect_sd) || effect_sd <= 0) {
    cli::cli_abort("{.arg effect_sd} (level change in outcome SD units) must be > 0.")
  }
  if (!is.numeric(n_pre) || n_pre < 3 || n_pre != floor(n_pre)) {
    cli::cli_abort("{.arg n_pre} must be an integer >= 3 (Bernal 2017: >= 8 recommended).")
  }
  if (!is.numeric(n_post) || n_post < 3 || n_post != floor(n_post)) {
    cli::cli_abort("{.arg n_post} must be an integer >= 3 (Bernal 2017: >= 8 recommended).")
  }
  if (!is.numeric(rho) || rho < 0 || rho >= 1) {
    cli::cli_abort("{.arg rho} (AR(1) autocorrelation) must be in [0, 1).")
  }

  n_eff_pre <- n_pre * (1 - rho) / (1 + rho)
  n_eff_post <- n_post * (1 - rho) / (1 + rho)
  se <- sqrt(1 / n_eff_pre + 1 / n_eff_post)
  z_a <- z_alpha(alpha, "two.sided")
  achieved_power <- stats::pnorm(effect_sd / se - z_a)

  hints <- c(
    "EXPERIMENTAL method: transparent AR(1)-adjusted normal approximation.",
    "Bernal et al. (2017, Int J Epidemiol) recommend >= 8 time points per segment;",
    "rigorous ITS power calculations require simulation."
  )
  if (n_pre < 8 || n_post < 8) {
    hints <- c(hints, sprintf(
      "Segments of %d/%d points are below the >= 8 rule of thumb.", n_pre, n_post
    ))
  }

  list(
    design_type = "Interrupted time series (level change, AR(1)-adjusted)",
    power_achieved = round(achieved_power, 3),
    n_eff_pre = round(n_eff_pre, 1),
    n_eff_post = round(n_eff_post, 1),
    parameters = list(
      effect_sd = effect_sd, n_pre = n_pre, n_post = n_post,
      rho = rho, alpha = alpha
    ),
    formula = "power = Phi(effect/SE - z); SE = sqrt(1/n_eff_pre + 1/n_eff_post); n_eff = n(1-rho)/(1+rho)",
    formula_latex = "$$\\text{power} = \\Phi\\left(\\frac{\\delta}{SE} - z_{\\alpha/2}\\right), \\quad SE = \\sqrt{\\tfrac{1}{n_{eff}^{pre}} + \\tfrac{1}{n_{eff}^{post}}}$$",
    reference = paste(
      "Framework: Bernal, J. L., Cummins, S., & Gasparrini, A. (2017).",
      "Interrupted time series regression for the evaluation of public health",
      "interventions: a tutorial. International Journal of Epidemiology, 46(1),",
      "348-355. Sample-size content is a transparent approximation, not from",
      "a validated source."
    ),
    roles = c(
      "effect_sd = anticipated level change in outcome SD units",
      "n_pre/n_post = number of time points before/after the interruption",
      "rho = AR(1) autocorrelation of the series"
    ),
    hints = hints
  )
}
