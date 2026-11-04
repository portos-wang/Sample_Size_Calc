# Phase 3: observational designs (cohort, caseControlMatched, crosstab) and
# the shared paired-proportion kernel (Connor/McNemar family).
# Anchors: inst/reference/NUMERIC_ANCHORS.md B3/B8.

# ---------------------------------------------------------------- cohort ----

#' Cohort study: exposed vs unexposed cumulative incidence (1:m allocation)
#'
#' `n_exposed = [Z_(a/2) sqrt((1+1/m) pbar(1-pbar)) + Z_b sqrt(p1(1-p1) + p0(1-p0)/m)]^2 / (p1-p0)^2`
#' where pbar = (p1 + m p0)/(1+m) and m is the unexposed:exposed allocation
#' ratio. Anchor: Bhardwaj 2024 p.2559 (p0=0.20, p1=0.30, m=1 -> 293;
#' +10% non-response -> 322/group, total 644).
#' @keywords internal
calculate_cohort_proportion <- function(p0, p1, ratio, alpha, power, dropout) {
  if (!is.numeric(p0) || length(p0) != 1 || p0 <= 0 || p0 >= 1) {
    cli::cli_abort("{.arg p0} (unexposed incidence) must be in (0, 1).")
  }
  if (!is.numeric(p1) || length(p1) != 1 || p1 <= 0 || p1 >= 1) {
    cli::cli_abort("{.arg p1} (exposed incidence) must be in (0, 1).")
  }
  if (abs(p1 - p0) < .Machine$double.eps) {
    cli::cli_abort("{.arg p1} and {.arg p0} must differ.")
  }
  if (!is.numeric(ratio) || length(ratio) != 1 || ratio < 1) {
    cli::cli_abort("{.arg ratio} (unexposed:exposed) must be >= 1.")
  }

  m <- ratio
  pbar <- (p1 + m * p0) / (1 + m)
  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)

  n_exposed <- (z_a * sqrt((1 + 1 / m) * pbar * (1 - pbar)) +
    z_b * sqrt(p1 * (1 - p1) + p0 * (1 - p0) / m))^2 / (p1 - p0)^2

  n1 <- as.integer(ceiling(n_exposed))
  n0 <- as.integer(ceiling(n_exposed * m))

  adjustments <- list()
  if (!is.null(dropout) && dropout > 0) {
    adjustments$dropout <- dropout
    adjustments$inflate_method <- "inflate"
    n1 <- inflate_n(n1, dropout)
    n0 <- inflate_n(n0, dropout)
  }

  list(
    design_type = "Cohort study (cumulative incidence, RR)",
    n_per_group = n1,
    n_exposed = n1,
    n_unexposed = n0,
    total_n = n1 + n0,
    parameters = list(
      p0 = p0, p1 = p1, ratio = m, alpha = alpha, power = power
    ),
    formula = "n1 = [Za*sqrt((1+1/m)*pbar*(1-pbar)) + Zb*sqrt(p1q1+p0q0/m)]^2/(p1-p0)^2",
    formula_latex = "$$n_{1} = \\frac{\\left[Z_{\\alpha/2}\\sqrt{(1+\\frac{1}{m})\\bar{p}(1-\\bar{p})} + Z_{\\beta}\\sqrt{p_1(1-p_1)+\\frac{p_0(1-p_0)}{m}}\\right]^2}{(p_1-p_0)^2}$$",
    reference = paste(
      "Primary: Bhardwaj et al. (2024). Journal of Family Medicine and Primary",
      "Care, 13(7), 2559 (worked example: p0=0.20, p1=0.30, m=1 -> 293/group).\n\n",
      "Also: Schlesselman, J. J. (1982). Case-Control Studies. Oxford University",
      "Press (cohort/case-control shared formula, roles swapped); Machin et al.",
      "(2018) Ch.3."
    ),
    roles = c(
      "p0 = unexposed-group cumulative incidence",
      "p1 = exposed-group cumulative incidence",
      "ratio = unexposed:exposed allocation (m)",
      "effect measure: risk ratio RR (estimable in cohort designs)"
    ),
    adjustments = adjustments
  )
}

#' Cohort study: incidence rate comparison (person-time, Poisson)
#'
#' Machin et al. (2018) Eq 6.2 (p. 84): total person-time for a 1:phi
#' allocation is `PU = (z_1-a/2 + z_1-b)^2 (lambda_T + lambda_S/phi) /
#' (lambda_T - lambda_S)^2`. This implementation reports the unexposed (S)
#' and exposed (T) components separately, with \code{r} being the
#' exposed:unexposed person-time ratio.
#'
#' T_unexposed = (Za/2 + Zb)^2 (l1/r + l0) / (l1 - l0)^2, T_exposed = r*T0.
#' @keywords internal
calculate_cohort_rate <- function(rate0, rate1, ratio, alpha, power) {
  if (!is.numeric(rate0) || length(rate0) != 1 || rate0 <= 0) {
    cli::cli_abort("{.arg rate0} (unexposed incidence rate) must be > 0.")
  }
  if (!is.numeric(rate1) || length(rate1) != 1 || rate1 <= 0) {
    cli::cli_abort("{.arg rate1} (exposed incidence rate) must be > 0.")
  }
  if (abs(rate1 - rate0) < .Machine$double.eps) {
    cli::cli_abort("{.arg rate1} and {.arg rate0} must differ.")
  }
  if (!is.numeric(ratio) || length(ratio) != 1 || ratio < 1) {
    cli::cli_abort("{.arg ratio} (exposed:unexposed person-time ratio) must be >= 1.")
  }

  # Machin Eq 6.2 uses (lambda_T - lambda_S)^2, so the arithmetic is
  # symmetric, but the labels "exposed"/"unexposed" only match the intent
  # when rate1 is the higher rate. Swap and say so, rather than silently
  # mislabelling the two person-time columns.
  swapped <- rate1 < rate0
  if (swapped) {
    tmp <- rate0
    rate0 <- rate1
    rate1 <- tmp
  }

  r <- ratio
  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)

  t_unexposed <- (z_a + z_b)^2 * (rate1 / r + rate0) / (rate1 - rate0)^2
  t_exposed <- t_unexposed * r

  list(
    design_type = "Cohort study (incidence rate ratio, person-time)",
    person_time_unexposed = as.integer(ceiling(t_unexposed)),
    person_time_exposed = as.integer(ceiling(t_exposed)),
    expected_events = as.integer(ceiling(rate1 * t_exposed + rate0 * t_unexposed)),
    parameters = list(
      rate0 = rate0, rate1 = rate1, ratio = r, alpha = alpha, power = power
    ),
    formula = "T0 = (Za/2+Zb)^2 * (l1/r + l0) / (l1-l0)^2 ; T1 = r*T0",
    formula_latex = "$$T_{0} = \\frac{(Z_{\\alpha/2}+Z_{\\beta})^2(\\lambda_1/r+\\lambda_0)}{(\\lambda_1-\\lambda_0)^2}, \\quad T_1 = r \\cdot T_0$$",
    reference = paste(
      "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
      "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
      "Wiley. Chapter 6 (Rate Outcomes).\n\n",
      "Also: Breslow, N. E., & Day, N. E. (1987). Statistical Methods in Cancer",
      "Research Vol. II. IARC (person-time rate comparison)."
    ),
    roles = c(
      "rate0 = unexposed-group incidence rate (events per person-time)",
      "rate1 = exposed-group incidence rate",
      "ratio = exposed:unexposed person-time ratio (r >= 1)",
      "effect measure: incidence rate ratio IRR",
      "person-time = total follow-up time; for fixed duration FT, subjects needed = person-time / FT"
    ),
    hints = if (swapped) {
      paste(
        "`rate1` was lower than `rate0`, so the two rates were swapped internally",
        "to keep the exposed/unexposed person-time labels meaningful; the",
        "reported IRR is therefore the larger over the smaller rate."
      )
    } else {
      character()
    }
  )
}

# ------------------------------------------------- caseControlMatched ----

#' Individually matched (1:1) case-control study
#'
#' Uses the discordant-pairs (McNemar/Connor) formulation with the
#' independence-within-pair approximation: pi10 = p1(1-p0),
#' pi01 = p0(1-p1); psi = pi10 + pi01; delta = |pi10 - pi01|;
#' `n_pairs = [Za/2 sqrt(psi) + Zb sqrt(psi - delta^2)]^2 / delta^2`.
#' Sources: Dupont 1988 (Biometrics 44(4):1157-1168); Schlesselman 1982.
#' @keywords internal
calculate_case_control_matched <- function(p0, OR, alpha, power) {
  if (!is.numeric(p0) || length(p0) != 1 || p0 <= 0 || p0 >= 1) {
    cli::cli_abort("{.arg p0} (control-group exposure rate) must be in (0, 1).")
  }
  if (!is.numeric(OR) || length(OR) != 1 || OR <= 0 || OR == 1) {
    cli::cli_abort("{.arg OR} must be a positive number != 1.")
  }

  p1 <- (OR * p0) / (1 - p0 + OR * p0)
  # Independence-within-pair approximation for discordant probabilities
  pi10 <- p1 * (1 - p0) # case exposed, control unexposed
  pi01 <- p0 * (1 - p1) # case unexposed, control exposed
  psi <- pi10 + pi01
  delta <- abs(pi10 - pi01)
  if (psi <= delta || delta == 0) {
    cli::cli_abort(
      "Degenerate discordance for p0={.val {p0}}, OR={.val {OR}}; adjust inputs."
    )
  }

  z_a <- z_alpha(alpha, "two.sided")
  z_b <- z_power(power)
  n_pairs <- (z_a * sqrt(psi) + z_b * sqrt(psi - delta^2))^2 / delta^2

  list(
    design_type = "Individually matched case-control (1:1)",
    n_pairs = as.integer(ceiling(n_pairs)),
    cases_needed = as.integer(ceiling(n_pairs)),
    controls_needed = as.integer(ceiling(n_pairs)),
    total_n = as.integer(ceiling(n_pairs)) * 2,
    parameters = list(
      p0 = p0, OR = OR,
      expected_p1 = p1,
      expected_psi = psi,
      expected_OR_pair = pi10 / pi01,
      alpha = alpha, power = power
    ),
    formula = "n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2",
    formula_latex = "$$n_{pairs} = \\frac{\\left[Z_{\\alpha/2}\\sqrt{\\psi} + Z_{\\beta}\\sqrt{\\psi-\\delta^2}\\right]^2}{\\delta^2}$$",
    reference = paste(
      "Primary: Dupont, W. D. (1988). Power calculations for matched",
      "case-control studies. Biometrics, 44(4), 1157-1168.\n\n",
      "Also: Schlesselman, J. J. (1982). Case-Control Studies, Oxford",
      "University Press (matched-pair approximation, p.174); Connor, R. J.",
      "(1987). Biometrics, 43(1), 207-211."
    ),
    roles = c(
      "p0 = control-group exposure rate",
      "OR = odds ratio to detect (p1 derived from p0 and OR)",
      "psi = expected discordant-pair proportion (pi10 + pi01 = p1*(1-p0) + p0*(1-p1))",
      "note = individually matched designs require discordant-pair proportions (psi), NOT the discordant odds ratio"
    )
  )
}

# ------------------------------------------------------------- crosstab ----

#' Cross-sectional study: association between exposure and prevalence
#'
#' Same two-proportion kernel as the cohort design; parameter roles reflect
#' prevalence comparison in a cross-sectional sample.
#' @keywords internal
calculate_crosstab_association <- function(p0, p1, alpha, power) {
  res <- calculate_cohort_proportion(
    p0 = p0, p1 = p1, ratio = 1,
    alpha = alpha, power = power, dropout = NULL
  )
  res$design_type <- "Cross-sectional study (prevalence comparison, PR/OR)"
  res$roles <- c(
    "p0 = prevalence in unexposed group",
    "p1 = prevalence in exposed group",
    "effect measure: prevalence ratio PR (or OR)",
    "sampling: exposure and outcome observed at the same time point"
  )
  res$reference <- paste(
    "Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018).",
    "Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.).",
    "Wiley. Chapter 3 (Binary Outcomes).\n\n",
    "Also: Bhardwaj et al. (2024), p. 2558-2559."
  )
  res$parameters$ratio <- NULL
  res
}
