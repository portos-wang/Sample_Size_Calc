# Phase 5: complex designs.
# clusterRCT (DE wrapper), singleArmPhaseII (Simon/A'Hern), NI proportions,
# twoOrdinal (Whitehead), predictive EPV, ITS (experimental).
# kappa and steppedWedge are deferred: formulas in Machin Ch.20/Ch.13 are
# OCR-garbled in the available PDF and require paper derivation first.

# ------------------------------------------------------- cluster wrapper ----

# ----------------------------------------------- cluster designs (Ch.12) ----

#' Design effect for a cluster randomised trial (Machin Eq 12.5 / 12.7)
#'
#' With a constant cluster size `m` this is Machin et al. (2018) Eq 12.5,
#' `DE = 1 + (m - 1) * rho`. Supplying `cv_m` (the coefficient of variation of
#' cluster size) switches to Eq 12.7, which allows for variable cluster sizes
#' before the number of clusters is known:
#'
#' \preformatted{
#'   DE = 1 + [(CV(m)^2 + 1) * mbar - 1] * rho
#' }
#'
#' @param cluster_size Number of subjects per cluster (mbar if sizes vary).
#' @param icc Intra-cluster correlation rho; in [0, 1).
#' @param cv_m Optional coefficient of variation of cluster size (Eq 12.7);
#'   non-negative. `NULL` (default) gives the constant-size Eq 12.5.
#' @return The design effect (numeric scalar >= 1).
#' @keywords internal
#' @examples
#' sampleSizeCalc:::cluster_size_inflation(20, 0.05) # 1.95 (Eq 12.5)
#' sampleSizeCalc:::cluster_size_inflation(20, 0.05, cv_m = 0.35) # Eq 12.7
cluster_size_inflation <- function(cluster_size, icc, cv_m = NULL) {
  if (is.null(cv_m)) {
    # Eq 12.5: constant cluster size.
    return(1 + (cluster_size - 1) * icc)
  }
  # Eq 12.7: allow for cluster size variation (K unknown at planning stage).
  # DE = 1 + [(CV(m)^2 + 1) * mbar - 1] * rho
  if (!is.numeric(cv_m) || length(cv_m) != 1 || cv_m < 0) {
    cli::cli_abort("{.arg cv_m} (cluster-size CV) must be a non-negative number.")
  }
  1 + ((cv_m^2 + 1) * cluster_size - 1) * icc
}

#' Cluster RCT with Machin Eq 12.10 (DE + Student t correction)
#'
#' Returns the total number of subjects N and the number of clusters per arm.
#' Rounding is done ONCE, at the cluster level (Machin Ch.12 "Numerical
#' Accuracy"): each extra cluster adds a further m subjects, so the cluster
#' count must not be derived from an already-rounded subject count.
#'
#' @param n_per_arm_indiv Subjects per arm from the corresponding
#'   individually-randomised formula (unrounded).
#' @param cluster_size Cluster size m.
#' @param icc Intra-cluster correlation rho.
#' @param cv_m Optional coefficient of variation of cluster size (Eq 12.7).
#' @param alpha,power Type I and type II error.
#' @param phi Allocation ratio (Machin's phi); default 1.
#' @keywords internal
cluster_design_from_indiv <- function(n_per_arm_indiv, cluster_size, icc,
                                      cv_m = NULL, alpha = 0.05, power = 0.8,
                                      phi = 1) {
  de <- cluster_size_inflation(cluster_size, icc, cv_m)
  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)

  # Eq 12.10. n_per_arm_indiv is the (z+z)^2/(delta/sigma)^2 term for the
  # two-sample case, i.e. per-arm; the t correction applies once per arm.
  n_total <- de * ((1 + phi)^2 / phi * n_per_arm_indiv + z_a^2 / 2)
  n_per_arm <- n_total / (1 + phi)

  n_clusters_per_arm <- as.integer(ceiling(n_per_arm / cluster_size))
  list(
    design_effect = de,
    n_total_raw = n_total,
    n_per_arm_raw = n_per_arm,
    n_clusters_per_arm = n_clusters_per_arm,
    n_per_arm = as.integer(n_clusters_per_arm * cluster_size),
    total_n = as.integer(2L * n_clusters_per_arm * cluster_size)
  )
}

#' Apply the cluster design effect to an individually-randomised result
#'
#' DE = 1 + (m - 1) * ICC (Machin 2018 Eq 12.5). Cluster-level rounding:
#' n_clusters = ceiling(n_individuals_raw * DE / m), individuals = n_clusters * m.
#' The raw (unrounded) individual count is used so that rounding happens once.
#' @keywords internal
apply_cluster_design <- function(base, cluster_size, icc) {
  de <- cluster_size_inflation(cluster_size, icc)
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
#'
#' Uses Machin Eq 12.10 (p. 199), i.e. the design effect plus the Student t
#' correction term `z^2/2`, and rounds ONCE at the cluster level. Anchor:
#' Machin Example 12.1 (p. 206) - delta=3.5, sigma=6.94, m=2, ICC=0.025,
#' 2-sided alpha=0.05, power=0.90 -> N=171.35 -> 172, K=86 (43 per arm).
#' @keywords internal
calculate_cluster_mean <- function(mean1, mean2, sd, icc, cluster_size,
                                   alpha, power) {
  delta <- abs(mean1 - mean2)
  if (delta == 0) {
    cli::cli_abort("{.arg mean1} and {.arg mean2} must differ.")
  }

  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  de <- cluster_size_inflation(cluster_size, icc)

  # Per-arm (z+z)^2 / (delta/sigma)^2 term of Eq 12.10.
  n_per_arm_indiv <- 2 * (z_a + z_b)^2 * sd^2 / delta^2 / 2
  clus <- cluster_design_from_indiv(
    n_per_arm_indiv = n_per_arm_indiv,
    cluster_size = cluster_size, icc = icc,
    alpha = alpha, power = power
  )

  list(
    design_type = "Cluster RCT: two independent samples, mean comparison",
    n_per_group = clus$n_per_arm,
    total_n = clus$total_n,
    n_clusters = clus$n_clusters_per_arm,
    parameters = list(
      mean1 = mean1, mean2 = mean2, sd = sd,
      icc = icc, cluster_size = cluster_size,
      design_effect = de, alpha = alpha, power = power
    ),
    formula = "N = DE*[(1+phi)^2/phi*(Za/2+Zb)^2/(delta/sigma)^2 + Za/2^2/2], DE = 1+(m-1)*ICC",
    formula_latex = "$$N = DE\\left[\\frac{(1+\\varphi)^2}{\\varphi}\\cdot\\frac{(Z_{\\alpha/2}+Z_{\\beta})^2}{(\\delta/\\sigma)^2} + \\frac{Z^2_{\\alpha/2}}{2}\\right], \\quad DE = 1+(m-1)\\rho$$",
    reference = paste(
      "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 12 (Cluster Designs): Eq 12.4 (ICC), Eq 12.5 (DE),",
      "Eq 12.9-12.10 (sample size with the Student t correction), pp. 197-199;",
      "Example 12.1, p. 206 (N=171.35 -> 172, K=86).\n\n",
      "Also: Donner, A., & Klar, N. (2000). Design and Analysis of Cluster",
      "Randomisation Trials in Health Research. Arnold."
    ),
    roles = c(
      "mean1/mean2 = group means; sd = common SD (individual level)",
      "icc = intra-cluster correlation rho (Machin Eq 12.4)",
      "cluster_size = subjects per cluster m",
      sprintf("DE = 1+(m-1)*ICC = %.4f; n_clusters per arm = %d", de, clus$n_clusters_per_arm)
    ),
    hints = c(
      "Machin Eq 12.10 includes the Student t correction z^2/2 and rounds once",
      "at the cluster level; each extra cluster adds a further m subjects.",
      "For variable cluster sizes use Eq 12.6-12.7 (cv_m) and Eq 12.8."
    )
  )
}

#' Cluster RCT wrapping the two-proportions kernel
#'
#' Machin Eq 12.10 with Eq 12.12 (binary sigma_Plan = sqrt(pbar(1-pbar))) and
#' Eq 12.13 (rho_Binary). Rounds once at the cluster level.
#' @keywords internal
calculate_cluster_proportion <- function(p1, p2, icc, cluster_size,
                                         alpha, power) {
  if (!is.numeric(p1) || p1 <= 0 || p1 >= 1) cli::cli_abort("{.arg p1} must be in (0, 1).")
  if (!is.numeric(p2) || p2 <= 0 || p2 >= 1) cli::cli_abort("{.arg p2} must be in (0, 1).")
  if (abs(p1 - p2) < .Machine$double.eps) {
    cli::cli_abort("{.arg p1} and {.arg p2} must differ.")
  }

  pbar <- (p1 + p2) / 2
  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  de <- cluster_size_inflation(cluster_size, icc)

  # Eq 12.12: sigma_Plan = sqrt(pbar(1-pbar)); per-arm two-sample term.
  sigma_plan <- sqrt(pbar * (1 - pbar))
  n_per_arm_indiv <- 2 * (z_a + z_b)^2 * sigma_plan^2 / (p1 - p2)^2 / 2
  clus <- cluster_design_from_indiv(
    n_per_arm_indiv = n_per_arm_indiv,
    cluster_size = cluster_size, icc = icc,
    alpha = alpha, power = power
  )

  list(
    design_type = "Cluster RCT: two independent proportions",
    n_per_group = clus$n_per_arm,
    total_n = clus$total_n,
    n_clusters = clus$n_clusters_per_arm,
    parameters = list(
      p1 = p1, p2 = p2, pbar = pbar,
      icc = icc, cluster_size = cluster_size,
      design_effect = de, alpha = alpha, power = power
    ),
    formula = "N = DE*[(1+phi)^2/phi*(Za/2+Zb)^2/(delta/sigma_Plan)^2 + Za/2^2/2], sigma_Plan = sqrt(pbar(1-pbar))",
    formula_latex = "$$N = DE\\left[\\frac{(1+\\varphi)^2}{\\varphi}\\cdot\\frac{(Z_{\\alpha/2}+Z_{\\beta})^2}{(\\delta/\\sigma_{Plan})^2} + \\frac{Z^2_{\\alpha/2}}{2}\\right], \\quad \\sigma_{Plan}=\\sqrt{\\bar{p}(1-\\bar{p})}$$",
    reference = paste(
      "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 12 (Cluster Designs): Eq 12.5 (DE), Eq 12.10 (sample",
      "size with the Student t correction), Eq 12.12 (sigma_Plan for a binary",
      "outcome), Eq 12.13 (rho_Binary), pp. 197-200; Example 12.4, p. 208.\n\n",
      "Also: Donner, A., & Klar, N. (2000). Design and Analysis of Cluster",
      "Randomisation Trials in Health Research. Arnold."
    ),
    roles = c(
      "p1/p2 = group proportions; pbar = (p1+p2)/2",
      "icc = intra-cluster correlation rho_Binary (Machin Eq 12.13)",
      "cluster_size = subjects per cluster m",
      sprintf("DE = 1+(m-1)*ICC = %.4f; n_clusters per arm = %d", de, clus$n_clusters_per_arm)
    ),
    hints = c(
      "Machin Eq 12.10 includes the Student t correction z^2/2 and rounds once",
      "at the cluster level; each extra cluster adds a further m subjects."
    )
  )
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
        # power, the largest r minimises alpha -- take that one. This is the
        # convention Simon (1989) and clinfun::ph2simon use; it also
        # determines the minimax tie-break (see calculate_simon_two_stage).
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

  # Simon (1989) selection rules, as implemented by clinfun::ph2simon:
  #  - optimal: minimise the expected sample size under p0, EN(p0).
  #  - minimax: minimise the maximum trial size N, then break ties by the
  #    smallest EN(p0). (Verified against clinfun for p0/p1 = 0.1/0.3 and
  #    0.2/0.4: both reproduce (1/15, 5/25) and (4/18, 10/33), and the former
  #    matches Machin 2018 Example 17.2.)
  chosen <- if (optimizer == "optimal") {
    feasible[[which.min(vapply(feasible, `[[`, numeric(1), "en_p0"))]]
  } else {
    n_vals <- vapply(feasible, `[[`, numeric(1), "n")
    en_vals <- vapply(feasible, `[[`, numeric(1), "en_p0")
    ord <- order(n_vals, en_vals)
    feasible[[ord[1]]]
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
    formula_latex = "$$P(\\text{reject } H_0 \\mid p_0) \\le \\alpha \\quad \\text{and} \\quad P(\\text{reject } H_0 \\mid p_1) \\ge 1-\\beta$$",
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
    ),
    hints = if (optimizer == "minimax") {
      c(
        "Multiple designs may achieve the minimum total sample size N;",
        "this implementation selects the design minimizing Type I error (alpha) among ties."
      )
    } else {
      character()
    }
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
          formula_latex = "$$P(X > r \\mid p_0) \\le \\alpha \\quad \\text{and} \\quad P(X > r \\mid p_1) \\ge 1-\\beta$$",
          reference = paste(
            "Primary: A'Hern, R. P. (2001). Sample size tables for exact single-stage",
            "phase II designs. Statistics in Medicine, 20(6), 859-866.",
            "https://doi.org/10.1002/sim.721"
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
      "Sample Size Calculations in Clinical Research (3rd ed.). CRC Press.",
      "Chapter 4 (Large Sample Tests for Proportions), Section 4.2.2",
      "noninferiority/superiority, Eq 4.8 (p. 78).\n\n",
      "Also: Machin et al. (2018) Chapter 11, Eq 11.5-11.6, p. 174."
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
#' Whitehead (1993) Eq 10 (p. 2260) with allocation ratio A:
#'
#' \preformatted{
#'   n = 3 (A + 1)^2 (u_{a/2} + u_b)^2 / [ A theta^2 (1 - sum pbar_i^3) ]
#' }
#'
#' and Machin et al. (2018) Eq 4.3 (p. 57) with allocation ratio phi:
#'
#' \preformatted{
#'   N = Gamma (1 + phi)^2 / phi * (z_{1-a/2} + z_{1-b})^2 / (log OR)^2,
#'   Gamma = 3 / (1 - sum pbar_i^3)                          (Eq 4.4)
#' }
#'
#' The two are algebraically identical when A = phi: Whitehead's numerator
#' `3 (A+1)^2` and Machin's `Gamma (1+phi)^2/phi` differ only by the allocation
#' factor, which is 1 when the groups are equal.
#'
#' Anchors: Machin Example 4.1 (p. 59): kappa = 4, phi = 1, OR = 3.65,
#' pbar = (0.2564, 0.2792, 0.2056, 0.2619), 2-sided alpha = 0.05, power = 0.80
#' -> N = 60.09 -> 60 total. Whitehead Example 1 (p. 2261): OR = 0.887,
#' pbar = (0.289, 0.486, 0.153, 0.072), alpha = 0.05, power = 0.90
#' -> n = 187 total (94 per group).
#'
#' @param or Anticipated odds ratio (proportional odds); > 0, != 1.
#' @param prop_bar Anticipated average category proportions; positive,
#'   summing to 1.
#' @param allocation Allocation ratio phi = n_Test / n_Standard (Whitehead's A);
#'   number > 0, default 1 (equal groups).
#' @keywords internal
calculate_two_ordinal <- function(or, prop_bar, alpha, power, allocation = 1) {
  if (!is.numeric(or) || length(or) != 1 || or <= 0 || or == 1) {
    cli::cli_abort("{.arg or} must be a positive odds ratio != 1.")
  }
  if (!is.numeric(prop_bar) || any(prop_bar <= 0) || abs(sum(prop_bar) - 1) > 1e-6) {
    cli::cli_abort("{.arg prop_bar} must be positive proportions summing to 1.")
  }
  if (!is.numeric(allocation) || length(allocation) != 1 || allocation <= 0) {
    cli::cli_abort("{.arg allocation} must be a positive allocation ratio.")
  }

  log_or <- log(or)
  p_bar <- prop_bar / sum(prop_bar)
  sum_cube <- sum(p_bar^3)
  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)

  # Machin Eq 4.3 / 4.4 == Whitehead Eq 10 with A = phi.
  gamma <- 3 / (1 - sum_cube)
  n_total <- gamma * (1 + allocation)^2 / allocation * (z_a + z_b)^2 / log_or^2
  n_standard <- n_total / (1 + allocation)
  n_test <- allocation * n_total / (1 + allocation)

  list(
    design_type = "Two-group ordered categorical outcome (Mann-Whitney / proportional odds)",
    n_per_group = as.integer(ceiling(n_test)),
    n_standard = as.integer(ceiling(n_standard)),
    n_test = as.integer(ceiling(n_test)),
    total_n = as.integer(ceiling(n_total)),
    parameters = list(
      or = or, prop_bar = p_bar, alpha = alpha, power = power,
      allocation = allocation, gamma = gamma
    ),
    formula = "N = Gamma*(1+phi)^2/phi*(Za/2+Zb)^2/(log OR)^2 ; Gamma = 3/(1 - sum(p_bar^3))",
    formula_latex = "$$N = \\frac{\\Gamma\\,(1+\\phi)^2}{\\phi}\\cdot\\frac{(Z_{\\alpha/2}+Z_{\\beta})^2}{(\\log OR)^2}, \\quad \\Gamma = \\frac{3}{1-\\sum_j \\bar{p}_j^3}$$",
    reference = paste(
      "Primary: Whitehead, J. (1993). Sample size calculations for ordered",
      "categorical data. Statistics in Medicine, 12(24), 2257-2271 (Eq 9-10,",
      "p. 2260; Example 1, p. 2261).\n\n",
      "Book: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 4, Eq 4.3-4.4, p. 57; Example 4.1, p. 59."
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

# ------------------------------------------------------------ MRMC (power) ----

#' MRMC study power (Obuchowski-Rockette mixed model, paired-patient
#' paired-reader design)
#'
#' Computes the power of a multi-reader multi-case study to detect a given
#' difference in accuracy (e.g. ROC area) with J readers, using the
#' non-central F framework of Zhou et al. (2011) Eq 6.32 with the Table 6.4
#' parameterisation for the paired-patient, paired-reader design
#' (rho1 > rho2 > rho3 > 0, rho_b > 0).
#'
#' @details
#' Eq 6.32 as printed (Zhou 2011, p. 221):
#'
#' \preformatted{
#'   lambda = J (v1 - v2)^2 / (2 * {
#'     sigma_b2 (1 - rho_b) + sigma_w2 / Q +
#'     sigma_c2 [(1 - rho1) + (J - 1)(rho2 - rho3)] })
#' }
#'
#' Note the two features that distinguish it from simpler MRMC formulae:
#' the between-reader term is weighted by `(1 - rho_b)`, the correlation between
#' the same readers' accuracies on the two tests, and the patient-sampling
#' term `sigma_c2` is NOT divided by `n` (sigma_c2 is already the
#' patient-sampling variance component, computed as V(A)/n; see Zhou p. 221).
#'
#' Anchor: Zhou 2011 p. 225 (mammography example) - n = 50 malignant and 50
#' benign patients, J = 8 readers, delta = 0.10, sigma_b2 = 0.00123,
#' sigma_w2 = 0.00087, sigma_c2 = 0.00196 (from Eq 6.5 with n = 50),
#' rho1 = 0.5, rho2 = 0.3, rho3 = 0.25, rho_b = 0.75 -> power = 0.893, which
#' reproduces the book's "89% power".
#'
#' @param n Patients with the condition (paired-patient design: the same
#'   patients are imaged under both tests)
#' @param J Number of readers per test; integer >= 2 (the F test needs J-1 df).
#' @param delta Difference in accuracy to detect; number > 0 (on the AUC or
#'   accuracy metric scale, e.g. 0.10).
#' @param sigma_b2 Between-reader variance component; number >= 0. Planning
#'   heuristic: (accuracy range / 4)^2 (Zhou p. 223, Beam 1996).
#' @param sigma_w2 Within-reader (occasion) variance component; number >= 0.
#' @param sigma_c2 Patient-sampling (case) variance component; number >= 0.
#'   This is the variance of the accuracy estimate attributable to sampling
#'   patients, i.e. V(A)/n (Zhou p. 221), so it already carries the sample
#'   size. For the mammography example it is 0.00196 at n = 50.
#' @param rho1 Correlation, same reader different tests; in [0, 1).
#' @param rho2 Correlation, different readers same test; in [0, 1).
#' @param rho3 Correlation, different readers different tests; in [0, 1).
#'   The paired-patient, paired-reader parameterisation expects
#'   rho1 > rho2 > rho3 > 0 (Zhou Table 6.4); violated orderings warn.
#' @param rho_b Correlation between the same readers' accuracies on the two
#'   tests (Zhou Table 6.3 `p_b`); in [0, 1). Defaults to `rho1`, which is the
#'   value implied when a single "same reader, different test" correlation is
#'   supplied. For the Zhou mammography example the book sets rho_b = 0.75.
#' @param alpha Type I error of the two-sided F test; in (0, 1), default 0.05.
#' @param n_repeats Reading occasions per reader-test (Q); integer >= 1,
#'   usually 1.
#' @return Numeric power (0-1), invisible. The full result object (parameters,
#'   formula, noncentrality) is attached as a `sample_size_result`.
#' @examples
#' # Mammography MRMC planning (Zhou 2011 pp. 221-225): 50 malignant plus 50
#' # benign patients, 8 readers, detect an AUC difference of 0.10. Power
#' # reproduces the book's 89%.
#' mrmc_power(
#'   n = 50, J = 8, delta = 0.10,
#'   sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.00196,
#'   rho1 = 0.50, rho2 = 0.30, rho3 = 0.25, rho_b = 0.75
#' )
#' @export
mrmc_power <- function(n, J, delta, sigma_b2, sigma_w2, sigma_c2,
                       rho1, rho2, rho3, rho_b = NULL,
                       alpha = 0.05, n_repeats = 1) {
  if (!is.numeric(n) || n < 1) cli::cli_abort("{.arg n} must be >= 1.")
  if (!is.numeric(J) || J < 2 || J != floor(J)) {
    cli::cli_abort("{.arg J} must be an integer >= 2 (the F test needs J-1 df).")
  }
  if (!is.numeric(delta) || delta <= 0) {
    cli::cli_abort("{.arg delta} must be a positive accuracy difference.")
  }
  for (v in c("sigma_b2", "sigma_w2", "sigma_c2")) {
    val <- get(v)
    if (!is.numeric(val) || length(val) != 1 || val < 0) {
      cli::cli_abort("{.arg {v}} must be a non-negative variance component.")
    }
  }
  for (v in c("rho1", "rho2", "rho3")) {
    val <- get(v)
    if (!is.numeric(val) || length(val) != 1 || val < 0 || val >= 1) {
      cli::cli_abort("{.arg {v}} must be a correlation in [0, 1).")
    }
  }

  # rho_b (Table 6.3 `p_b`) is the same-reader, different-test correlation.
  # When omitted we take rho1, which is what a single "same reader, different
  # test" correlation implies. When it is supplied and differs from rho1, the
  # two entries are distinct components and both are used as printed in
  # Eq 6.32.
  rho_b_missing <- is.null(rho_b)
  if (rho_b_missing) {
    rho_b <- rho1
  } else if (!is.numeric(rho_b) || length(rho_b) != 1 || rho_b < 0 || rho_b >= 1) {
    cli::cli_abort("{.arg rho_b} must be a correlation in [0, 1).")
  }

  if (!(rho1 > rho2 && rho2 > rho3)) {
    cli::cli_warn(c(
      "Paired-patient, paired-reader design expects rho1 > rho2 > rho3 > 0",
      "(Zhou Table 6.4); got rho1 = {.val {rho1}}, rho2 = {.val {rho2}}, rho3 = {.val {rho3}}."
    ))
  }

  # Zhou et al. (2011) Eq 6.32, verbatim.
  denom <- 2 * (
    sigma_b2 * (1 - rho_b) +
      sigma_w2 / n_repeats +
      sigma_c2 * ((1 - rho1) + (J - 1) * (rho2 - rho3))
  )
  lambda <- J * delta^2 / denom
  crit <- stats::qf(1 - alpha, 1, J - 1)
  power <- 1 - stats::pf(crit, 1, J - 1, ncp = lambda)

  hints <- c(
    "MRMC power depends on 6 variance/correlation components estimated from",
    "pilot data or literature (Zhou Table 6.3); treat results as approximate.",
    "sigma_c2 is the patient-sampling variance component V(A)/n (Zhou p. 221),",
    "so it already reflects the patient sample size; it is not divided by n again.",
    "rho_b is the same-reader, different-test correlation (Table 6.3 `p_b`);",
    "when omitted it defaults to rho1.",
    "For reader variability planning: sigma_b2 = (accuracy range / 4)^2 is a",
    "common heuristic (Zhou p. 223, Beam 1996 mammography example)."
  )

  out <- structure(
    list(
      design_type = "MRMC (paired-patient, paired-reader, Obuchowski-Rockette)",
      power = round(power, 3),
      parameters = list(
        n = n, J = J, delta = delta,
        sigma_b2 = sigma_b2, sigma_w2 = sigma_w2, sigma_c2 = sigma_c2,
        rho1 = rho1, rho2 = rho2, rho3 = rho3, rho_b = rho_b,
        rho_b_defaulted = rho_b_missing,
        alpha = alpha, n_repeats = n_repeats,
        noncentrality_lambda = round(lambda, 4)
      ),
      formula = "lambda = J*delta^2/(2*[sb2(1-rho_b) + sw2/Q + sc2*((1-rho1)+(J-1)(rho2-rho3))]); power = P(F_{1,J-1}(lambda) > F_{1-alpha})",
      formula_latex = "$$\\lambda = \\frac{J \\delta^2}{2\\left[\\sigma_b^2(1-\\rho_b) + \\frac{\\sigma_w^2}{Q} + \\sigma_c^2\\left((1-\\rho_1) + (J-1)(\\rho_2-\\rho_3)\\right)\\right]}, \\quad \\text{Power} = P(F_{1,J-1}(\\lambda) > F_{1-\\alpha})$$",
      reference = paste(
        "Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011).",
        "Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley.",
        "Section 6.5, Eq 6.32, Tables 6.3-6.5, pp. 220-226 (mammography",
        "worked example: 89% power).\n\n",
        "Model: Obuchowski, N. A., & Rockette, H. E. (1995). Hypothesis testing",
        "of diagnostic accuracy for multiple readers and multiple tests: an",
        "ANOVA approach with dependent observations. Communications in",
        "Statistics - Simulation and Computation, 24(2), 285-308.\n\n",
        "Method review: Obuchowski, N. A., Beiden, S. V., Berbaum, K. S.,",
        "Hillis, S. L., Ishwaran, H., Song, H. H., & Wagner, R. F. (2004).",
        "Multireader, multicase receiver operating characteristic analysis:",
        "an empirical comparison of five methods. Academic Radiology,",
        "11(9), 980-995."
      ),
      roles = c(
        "n = patients with the condition (paired-patient: imaged under both tests)",
        "J = readers per test",
        "delta = accuracy difference to detect",
        "sigma_b2/sigma_w2/sigma_c2 = reader/occasion/patient-sampling variance components",
        "rho1/rho2/rho3 = correlations (same-reader-diff-test / diff-reader-same-test / diff-reader-diff-test)",
        "rho_b = same-reader, different-test correlation (Table 6.3 p_b)"
      ),
      hints = hints
    ),
    class = c("sample_size_result", "list")
  )
  invisible(out)
}

# ------------------------------------------------------ kappa (Cantor 1996) ----

# Cantor (1996) large-sample variance factor for kappa-hat.
#
# Cantor Eq 3 (Psychological Methods 1996;1(2):150-153, p. 151) with the pi_ij
# identities of Eq 4:
#
#   Q = (1 - pi_e)^(-4) * { sum_i pi_ii [ (1 - pi_e) - (pi_i. + pi_.i)(1 - pi_o) ]^2
#                          + (1 - pi_o)^2 * sum_{i != j} pi_ij (pi_.i + pi_j.)^2
#                          - (pi_o pi_e - 2 pi_e + pi_o)^2 }
#
# This is NOT the simpler Fleiss-Cohen-Everitt form p_o(1-p_o)/(1-p_e)^2: it
# reduces to that only when pi1. = pi.1 = 0.5 (Cantor Table 1 gives Q = 1.000
# at kappa = 0, 0.960 at 0.2 and 0.750 at 0.5, matching this expression).
# Reproduces Cantor Table 1 at 23 spot-checked cells and Table 2 maxima
# exactly (e.g. Q_MAX = 1.07003 at kappa = 0.187 for pi1. = pi.1 = 0.3).
kappa_Q <- function(pi1, pi2, kappa) {
  pi_2 <- 1 - pi2
  # pi_e = pi_1. * pi_.1 + pi_2. * pi_.2
  pe <- pi1 * pi2 + (1 - pi1) * pi_2 # expected agreement (pi_e)
  po <- kappa * (1 - pe) + pe # observed agreement (pi_o)

  # Eq 4 identities. Note Cantor computes pi_22 FIRST, then pi_11 = pi_o - pi_22.
  pi22 <- (po - pi1 + pi_2) / 2
  pi11 <- po - pi22
  pi12 <- pi1 - pi11
  pi21 <- pi2 - pi11

  # Eq 3.
  s1 <- pi11 * ((1 - pe) - (pi2 + pi1) * (1 - po))^2 +
    pi22 * ((1 - pe) - (pi_2 + (1 - pi1)) * (1 - po))^2
  s2 <- (1 - po)^2 * (pi12 * (pi2 + (1 - pi1))^2 + pi21 * (pi_2 + pi1)^2)
  s3 <- (po * pe - 2 * pe + po)^2

  (1 - pe)^(-4) * (s1 + s2 - s3)
}

#' Internal calculation: Cohen's kappa sample size (Cantor 1996)
#'
#' Two modes:
#' * task = "estimate": precision of a single kappa —
#'   `n = Q * (z_(1-a/2) / d)^2` with `Q = p_o(1-p_o)/(1-p_e)^2`.
#'   Anchor: Cantor 1996 precision example (pi=0.3, kappa unspecified,
#'   Q=1.0, d=0.1, 80% CI -> 165).
#' * task = "test": two independent kappas H0: K1 = K2 —
#'   `n = (z_a sqrt(2 Q1) + z_b sqrt(Q1 + Q2))^2 / (K1 - K2)^2`.
#'   Anchor: Cantor 1996 two-questionnaire example (pi=0.5, K1=0.7,
#'   K2=0.5, 95%/80% -> 214).
#'
#' @keywords internal
calculate_kappa <- function(pi1, pi2, kappa1, kappa2, d, alpha, power, task) {
  if (!is.numeric(pi1) || pi1 <= 0 || pi1 >= 1) cli::cli_abort("{.arg pi1} must be in (0, 1).")
  if (!is.numeric(pi2) || pi2 <= 0 || pi2 >= 1) cli::cli_abort("{.arg pi2} must be in (0, 1).")
  task <- rlang::arg_match(task, c("estimate", "test"))

  if (task == "estimate") {
    if (!is.numeric(kappa1) || length(kappa1) != 1 || kappa1 < 0 || kappa1 >= 1) {
      cli::cli_abort("{.arg kappa1} (planning kappa) must be in [0, 1).")
    }
    if (!is.numeric(d) || d <= 0 || d >= 1) {
      cli::cli_abort("{.arg d} (CI half-width) must be in (0, 1).")
    }
    q_val <- kappa_Q(pi1, pi2, kappa1)
    z <- z_alpha(alpha, "two.sided")
    n <- q_val * (z / d)^2
    list(
      design_type = "Cohen's kappa estimation (CI precision)",
      n_required = as.integer(ceiling(n)),
      parameters = list(
        pi1 = pi1,
        pi2 = pi2,
        kappa = kappa1,
        d = d,
        alpha = alpha,
        Q = round(q_val, 4)
      ),
      formula = "n = Q * (z/d)^2 ; Q = p_o(1-p_o)/(1-p_e)^2",
      formula_latex = "$$n = Q\\left(\\frac{z_{1-\\alpha/2}}{d}\\right)^2, \\quad Q = \\frac{p_o(1-p_o)}{(1-p_e)^2}$$",
      reference = paste(
        "Primary: Cantor, A. B. (1996). Sample-size calculations for Cohen's",
        "kappa. Psychological Methods, 1(2), 150-153 (Fleiss-Cohen-Everitt",
        "1969 asymptotic variance; worked examples N=165 and N=214)."
      ),
      roles = c(
        "pi1/pi2 = expected Rating-1 proportions for rater 1 / rater 2",
        "kappa1 = planning value of kappa",
        "d = desired CI half-width"
      )
    )
  } else {
    if (!is.numeric(kappa1) || kappa1 <= 0 || kappa1 >= 1) {
      cli::cli_abort("{.arg kappa1} (null kappa) must be in (0, 1).")
    }
    if (!is.numeric(kappa2) || kappa2 <= 0 || kappa2 >= 1 || kappa2 == kappa1) {
      cli::cli_abort("{.arg kappa2} (alternative kappa) must differ from kappa1 and be in (0, 1).")
    }
    q1 <- kappa_Q(pi1, pi2, kappa1)
    q2 <- kappa_Q(pi1, pi2, kappa2)
    za <- z_alpha(alpha, "two.sided")
    zb <- z_power(power)
    n <- (za * sqrt(2 * q1) + zb * sqrt(q1 + q2))^2 / (kappa1 - kappa2)^2
    list(
      design_type = "Cohen's kappa test (two independent kappas)",
      n_required = as.integer(ceiling(n)),
      parameters = list(
        pi1 = pi1,
        pi2 = pi2,
        kappa1 = kappa1,
        kappa2 = kappa2,
        alpha = alpha,
        power = power,
        Q_null = round(q1, 4),
        Q_alt = round(q2, 4)
      ),
      formula = "n = (z_a*sqrt(2*Q1) + z_b*sqrt(Q1+Q2))^2/(K1-K2)^2",
      formula_latex = "$$n = \\frac{\\left[z_{\\alpha}\\sqrt{2Q_1} + z_{\\beta}\\sqrt{Q_1+Q_2}\\right]^2}{(K_1-K_2)^2}$$",
      reference = paste(
        "Primary: Cantor, A. B. (1996). Sample-size calculations for Cohen's",
        "kappa. Psychological Methods, 1(2), 150-153 (worked example: K1=0.7,",
        "K2=0.5, pi=0.5 -> N=214)."
      ),
      roles = c(
        "pi1/pi2 = expected Rating-1 proportions (both raters/groups)",
        "kappa1 = kappa under the null (e.g. questionnaire 1)",
        "kappa2 = kappa under the alternative (e.g. questionnaire 2)",
        "n is per group (two independent kappa estimates)"
      )
    )
  }
}

# ------------------------------------------ stepped wedge (H&H 2007) ----

# Internal: X matrix for a full SWD (Hussey-Hughes design)
# I clusters; T time points (t=1 baseline, all control); clusters switch in
# groups of n_per_step at times 2..T.
swd_design_matrix <- function(I, T, n_per_step) {
  X <- matrix(0, nrow = I, ncol = T)
  idx <- 1
  for (t in 2:T) {
    X[idx:(idx + n_per_step - 1), t:T] <- 1
    idx <- idx + n_per_step
  }
  X
}

#' Internal calculation: stepped wedge power (Hussey & Hughes 2007 Eq 8)
#'
#' WLS-based Wald power for the treatment effect in a full CS stepped wedge
#' design. Requires (I, T, cluster_size m, tau2, sigma2_ind) - the variance
#' of the treatment effect estimate is computed from the design matrix
#' quadratic forms U/W/V, then power = Phi(|theta|/se - z_(1-a/2)).
#'
#' Eq 8 as printed (Hussey & Hughes 2007, p. 187):
#'
#' \preformatted{
#'   Var(theta_hat) = I * sigma^2 * (sigma^2 + T * tau^2) /
#'     [ (IU - W) * sigma^2 + (U^2 + ITU - TW - IV) * tau^2 ]
#' }
#'
#' where sigma^2 is the variance of the cluster-level mean response
#' (sigma^2_ind / m) and tau^2 is the between-cluster variance.
#'
#' Anchor: H&H EPT example - I = 24 counties, T = 5 (baseline + 4 steps of
#' 6), m = 100, binary outcome p = 0.05 (sigma2_ind = p(1-p) = 0.0475),
#' CV = 0.3 -> tau2 = (0.3*0.05)^2 = 2.25e-4. Eq 8 returns power = 0.774 at
#' RR = 0.64, matching the paper's "about 80% power to detect a decrease in
#' prevalence of roughly 36% (from 0.05 to 0.032)".
#' @keywords internal
calculate_stepped_wedge <- function(theta, tau2, sigma2_ind, m, n_clusters,
                                    clusters_per_step, alpha, outcome = "mean") {
  if (!is.numeric(theta) || theta == 0) {
    cli::cli_abort("{.arg theta} must be a non-zero treatment effect on the additive scale.")
  }
  if (!is.numeric(tau2) || tau2 <= 0) cli::cli_abort("{.arg tau2} must be > 0.")
  if (!is.numeric(sigma2_ind) || sigma2_ind <= 0) {
    cli::cli_abort("{.arg sigma2_ind} must be > 0 (individual-level variance).")
  }
  if (!is.numeric(m) || m < 1) cli::cli_abort("{.arg m} (subjects per cluster per period) must be >= 1.")
  if (!is.numeric(clusters_per_step) || clusters_per_step < 1 ||
    clusters_per_step != floor(clusters_per_step)) {
    cli::cli_abort("{.arg clusters_per_step} must be a positive integer.")
  }

  # H&H EPT structure: steps = I / clusters_per_step (baseline at t=1);
  # I and clusters_per_step are the user-facing design quantities.
  if (!is.numeric(n_clusters) || n_clusters < 2 || n_clusters != floor(n_clusters)) {
    cli::cli_abort("{.arg n_clusters} must be a positive integer >= 2.")
  }
  n_steps <- n_clusters / clusters_per_step
  if (n_steps != floor(n_steps) || n_steps < 1) {
    cli::cli_abort(c(
      "{.arg n_clusters} must be a multiple of {.arg clusters_per_step}.",
      "x" = "n_clusters = {.val {n_clusters}}, clusters_per_step = {.val {clusters_per_step}}"
    ))
  }
  T <- n_steps + 1
  I <- as.integer(n_clusters)
  sigma2 <- sigma2_ind / m
  X <- swd_design_matrix(I, T, clusters_per_step)
  U <- sum(X)
  W <- sum(colSums(X)^2)
  V <- sum(rowSums(X)^2)

  # Hussey & Hughes (2007) Eq 8, verbatim (p. 187).
  var_theta <- I * sigma2 * (sigma2 + T * tau2) /
    ((I * U - W) * sigma2 + (U^2 + I * T * U - T * W - I * V) * tau2)
  se <- sqrt(var_theta)
  achieved_power <- stats::pnorm(abs(theta) / se - z_alpha(alpha, "two.sided"))

  list(
    design_type = sprintf(
      "Stepped wedge cluster trial (Hussey-Hughes, %s outcome)", outcome
    ),
    power_achieved = round(achieved_power, 3),
    n_clusters = as.integer(I),
    n_time_points = as.integer(T),
    se_theta = signif(se, 4),
    parameters = list(
      theta = theta,
      tau2 = tau2,
      sigma2_ind = sigma2_ind,
      m = m,
      n_clusters = I,
      clusters_per_step = clusters_per_step,
      alpha = alpha
    ),
    formula = "Var = I*s2*(s2 + T*t2)/((I*U-W)*s2 + (U^2+I*T*U-T*W-I*V)*t2); power = Phi(|theta|/se - z)",
    formula_latex = "$$\\text{Var}(\\hat{\\theta}) = \\frac{I \\sigma^2(\\sigma^2+T\\tau^2)}{(IU-W)\\sigma^2 + (U^2+ITU-TW-IV)\\tau^2}, \\quad \\sigma^2 = \\sigma_{ind}^2/m, \\quad \\text{Power} = \\Phi\\left(\\frac{|\\theta|}{\\text{SE}} - z_{1-\\alpha/2}\\right)$$",
    reference = paste(
      "Primary: Hussey, M. A., & Hughes, J. P. (2007). Design and analysis of",
      "stepped wedge cluster randomized trials. Contemporary Clinical Trials,",
      "28(2), 182-191 (Eq 8, p. 187; EPT worked example I=24, T=5, m=100,",
      "p=0.05, CV=0.3 -> ~80% power at a 36% relative reduction)."
    ),
    roles = c(
      "theta = treatment effect (additive scale; e.g. risk difference)",
      "tau2 = between-cluster variance (e.g. (CV*mean)^2)",
      "sigma2_ind = individual-level variance (binary: p(1-p))",
      "m = individuals sampled per cluster per time point",
      "clusters_per_step = clusters randomized at each step (full design)"
    ),
    hints = c(
      "Hussey & Hughes (2007) Eq 8 assumes no underlying calendar time trends.",
      "If secular time trends are present, statistical power may be lower;",
      "consider incorporating time fixed effects via simulation or swCRTdesign."
    )
  )
}

# ------------------------------------------------ predictive (Riley 2020) ----

# Max Cox-Snell R2 for a binary outcome with proportion prev (entropy form,
# Riley 2020 Fig 4 / supplementary S5): max_R2cs = 1 - exp(-2*H(φ))
# Anchor: prev=0.05 -> 0.3277 ≈ 0.33 (paper example 1).
max_r2cs_binary <- function(prev) {
  phi <- min(prev, 1 - prev) # symmetric handling
  1 - exp(2 * (phi * log(phi) + (1 - phi) * log(1 - phi)))
}

#' Internal calculation: prediction model development (Riley 2020 BMJ method)
#'
#' Binary outcome: criteria B1 (overall proportion precision), B3 (shrinkage
#' target S), with B2 (mean absolute prediction error, van Smeden formula)
#' reported for P <= 30. Sample size = max(B1, B3).
#' Anchors (exact): B1 φ=0.5,δ=0.05 -> 385; B3 P=30,R2cs=0.05,S=0.9 -> 5249;
#' B2 MAPE=0.05,φ=0.3,P=10 -> 461.
#' @keywords internal
calculate_predictive_riley_binary <- function(prev, n_parameters, r2_cs,
                                              shrinkage, mape, precision_delta,
                                              alpha) {
  if (!is.numeric(prev) || prev <= 0 || prev >= 1) {
    cli::cli_abort("{.arg prev} (anticipated outcome proportion) must be in (0, 1).")
  }
  if (!is.numeric(n_parameters) || n_parameters < 1 || n_parameters != floor(n_parameters)) {
    cli::cli_abort("{.arg n_parameters} (candidate predictor parameters) must be a positive integer.")
  }
  phi <- min(prev, 1 - prev)
  max_r2cs <- max_r2cs_binary(prev)
  if (!is.numeric(r2_cs) || r2_cs <= 0 || r2_cs >= max_r2cs) {
    cli::cli_abort(c(
      "{.arg r2_cs} must be in (0, max R2cs = {.val {round(max_r2cs, 4)}})",
      "i" = "For prev = {.val {prev}}, max R2cs = 1 - exp(-2H(phi)) = {.val {round(max_r2cs, 4)}}."
    ))
  }
  shrinkage <- shrinkage %||% 0.9
  mape <- mape %||% 0.05
  precision_delta <- precision_delta %||% 0.05

  # B1: outcome proportion precision (Fig 1)
  z <- z_alpha(alpha, "two.sided")
  n_b1 <- (z / precision_delta)^2 * prev * (1 - prev)

  # B3: shrinkage target (Fig 3)
  n_b3 <- n_parameters / ((shrinkage - 1) * log(1 - r2_cs / shrinkage))

  # B2: MAPE / van Smeden formula (Fig 2), P <= 30 only
  n_b2 <- NULL
  if (n_parameters <= 30) {
    n_b2 <- exp((-0.508 + 0.259 * log(phi) + 0.504 * log(n_parameters) -
      log(mape)) / 0.544)
  }

  n_final <- ceiling(max(n_b1, n_b3))
  events <- ceiling(n_final * prev)

  hints <- c(
    sprintf("B1 (proportion precision, delta=%.3f): n = %d", precision_delta, ceiling(n_b1)),
    sprintf("B3 (shrinkage S=%.2f, R2cs=%.4f): n = %d", shrinkage, r2_cs, ceiling(n_b3)),
    if (!is.null(n_b2)) {
      sprintf("B2 (MAPE=%.3f, P=%d <= 30): n = %d (informational)", mape, n_parameters, ceiling(n_b2))
    } else {
      "B2 (MAPE) requires P <= 30; use the van Smeden interactive tool for larger P"
    },
    "B4 (optimism in Nagelkerke R2 <= 0.05) is handled inside B3 via the",
    "shrinkage target in the pmsampsize implementation; see Riley 2020 Box 1."
  )

  list(
    design_type = "Prediction model development (Riley 2020, binary)",
    n_required = as.integer(n_final),
    events_required = as.integer(events),
    epp = round(events / n_parameters, 2),
    parameters = list(
      prev = prev, n_parameters = n_parameters, r2_cs = r2_cs,
      max_r2cs = round(max_r2cs, 4), shrinkage = shrinkage,
      mape = mape, precision_delta = precision_delta, alpha = alpha
    ),
    formula = "B1: n=(z/d)^2*p(1-p); B3: n=P/((S-1)*ln(1-R2cs/S)); n = max(B1, B3)",
    formula_latex = "$$n_{B1} = \\left(\\frac{z_{1-\\alpha/2}}{\\delta}\\right)^2 \\phi(1-\\phi), \\quad n_{B3} = \\frac{p}{(S-1)\\ln(1 - R_{CS}^2/S)}, \\quad n = \\max(n_{B1}, n_{B3})$$",
    reference = paste(
      "Primary: Riley, R. D., Ensor, J., Snell, K. I. E., et al. (2020).",
      "Calculating the sample size required for developing a clinical prediction",
      "model. BMJ, 368, m441 (Box 1, Figures 1-5).\n\n",
      "B2 formula: van Smeden, M., et al. (2019). Stat Methods Med Res, 28,",
      "2455-74. B3 derivation: Riley et al. (2019). Stat Med, 38, 1276-96",
      "(PART II). Software: pmsampsize (Stata/R)."
    ),
    roles = c(
      "prev = anticipated outcome proportion in the target population",
      "n_parameters = candidate predictor parameters (P)",
      "r2_cs = anticipated Cox-Snell R2 (conservative, optimism-adjusted)",
      "shrinkage = target uniform shrinkage factor S (default 0.9)",
      "mape = target mean absolute prediction error (default 0.05)"
    ),
    hints = hints
  )
}

#' Internal calculation: prediction model for a time-to-event outcome
#' (Riley 2020 criterion T1: person-years for precise cumulative incidence)
#' Anchor: lambda=0.1/year, t=10, delta=0.05 -> T >= 2366 person-years.
#' @keywords internal
calculate_predictive_timetoevent <- function(rate, timepoint, precision_delta,
                                             alpha, n_parameters, epv) {
  if (!is.numeric(rate) || rate <= 0) cli::cli_abort("{.arg rate} must be > 0.")
  if (!is.numeric(timepoint) || timepoint <= 0) {
    cli::cli_abort("{.arg timepoint} must be > 0.")
  }
  if (!is.numeric(precision_delta) || precision_delta <= 0 || precision_delta >= 1) {
    cli::cli_abort("{.arg precision_delta} must be in (0, 1).")
  }

  f_t <- 1 - exp(-rate * timepoint)
  z <- z_alpha(alpha, "two.sided")
  # margin(t) = z * sqrt(rate/T) * t * (1 - F(t)); search T for both margins <= delta
  T_person_years <- 1
  repeat {
    lam_hi <- rate + z * sqrt(rate / T_person_years)
    lam_lo <- max(rate - z * sqrt(rate / T_person_years), 0)
    f_hi <- 1 - exp(-lam_hi * timepoint)
    f_lo <- 1 - exp(-lam_lo * timepoint)
    if ((f_hi - f_t) <= precision_delta && (f_t - f_lo) <= precision_delta) break
    T_person_years <- T_person_years + 1
    if (T_person_years > 1e7) {
      cli::cli_abort("Person-years search exceeded 1e7; check inputs.")
    }
  }

  n_events_required <- NULL
  if (!is.null(n_parameters) && !is.null(epv)) {
    n_events_required <- as.integer(ceiling(epv * n_parameters))
  }

  list(
    design_type = "Prediction model development (Riley 2020, time-to-event)",
    person_time_required = as.integer(T_person_years),
    n_required = if (!is.null(n_events_required)) as.integer(ceiling(n_events_required / f_t)),
    events_required = n_events_required,
    cumulative_incidence = round(f_t, 4),
    parameters = list(
      rate = rate, timepoint = timepoint,
      precision_delta = precision_delta, alpha = alpha,
      n_parameters = n_parameters, epv = epv
    ),
    formula = "F(t) = 1-exp(-rate*t); CI: 1-exp(-(rate +- z*sqrt(rate/T))*t); find T with margins <= delta",
    formula_latex = "$$F(t) = 1 - e^{-\\lambda t}, \\quad \\text{CI: } 1 - \\exp\\left(-\\left(\\lambda \\pm z_{1-\\alpha/2}\\sqrt{\\frac{\\lambda}{T}}\\right)t\\right)$$",
    reference = paste(
      "Primary: Riley, R. D., Ensor, J., Snell, K. I. E., et al. (2020).",
      "Calculating the sample size required for developing a clinical prediction",
      "model. BMJ, 368, m441 (Figure 1, time-to-event panel; criterion T1;",
      "worked example: rate=0.10/year, t=10y, delta=0.05 -> 2366 person-years)."
    ),
    roles = c(
      "rate = anticipated event rate per person-year",
      "timepoint = key prediction time point t (years)",
      "precision_delta = maximum margin of error for F(t)",
      "n_parameters/epv = optional EPP cross-check (classic 10 EPV)"
    )
  )
}

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
