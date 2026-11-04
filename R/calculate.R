# Unified three-axis entry point: calculate(design, task, outcome, ...)
# Axis decisions documented in inst/reference/DESIGN_MATRIX.md:
#   1. RCT family collapsed into a single `rct` design (task x outcome orthogonal)
#   2. Diagnostic designs use explicit names (diagAccuracy, diagAUC, ...)
#   3. Estimation tasks live under single* designs
#   4. Legacy keywords stay silently compatible (no warnings)

# Master combination table: one row per legal (design, task, outcome) combo.
# `legacy` is the dispatch keyword used by the internal calculation modules;
# `required` mirrors validate_design_args() entries for early, clearer errors.
ssr_combinations <- list(
  # --- Trial family (rct collapsed) ---
  list(
    design = "rct", task = "test", outcome = "mean",
    legacy = "twoMeans", default = TRUE
  ),
  list(
    design = "rct", task = "test", outcome = "proportion",
    legacy = "twoProportions"
  ),
  list(
    design = "rct", task = "test", outcome = "survival",
    legacy = "survival"
  ),
  list(
    design = "rct", task = "noninferiority", outcome = "mean",
    legacy = "nonInferiorityMeans"
  ),
  list(
    design = "rct", task = "superiority", outcome = "mean",
    legacy = "superiorityMeans"
  ),
  list(
    design = "rct", task = "equivalence", outcome = "mean",
    legacy = "equivalenceMeans"
  ),
  list(
    design = "rct", task = "superiority", outcome = "proportion",
    legacy = "superiorityProportions"
  ),
  list(
    design = "rct", task = "equivalence", outcome = "proportion",
    legacy = "equivalenceProportions"
  ),
  # --- Paired ---
  list(
    design = "paired", task = "test", outcome = "mean",
    legacy = "pairedMeans", default = TRUE
  ),
  # --- Observational ---
  list(
    design = "caseControl", task = "test", outcome = "proportion",
    legacy = "caseControl", default = TRUE
  ),
  # --- Diagnostic family (explicit names) ---
  list(
    design = "diagAccuracy", task = "estimate", outcome = "proportion",
    legacy = "diagnosticAccuracySingle", default = TRUE
  ),
  list(
    design = "diagAccuracy", task = "test", outcome = "proportion",
    legacy = "diagnosticSuperioritySingle"
  ),
  list(
    design = "diagAccuracyCompare", task = "test", outcome = "proportion",
    legacy = "diagnosticComparisonTwo", default = TRUE
  ),
  list(
    design = "diagLR", task = "estimate", outcome = "lr",
    legacy = "likelihoodRatioTest", default = TRUE
  ),
  list(
    design = "diagAUC", task = "estimate", outcome = "auc",
    legacy = "auc_single", default = TRUE
  ),
  list(
    design = "diagAUC", task = "test", outcome = "auc",
    legacy = "aucSuperiority"
  ),
  list(
    design = "diagAUCCompare", task = "test", outcome = "auc",
    legacy = "aucComparison", default = TRUE
  ),
  # --- Estimation family (decision 3: single* designs) ---
  list(
    design = "singleProportion", task = "estimate", outcome = "proportion",
    legacy = "singleProportion", default = TRUE
  ),
  list(
    design = "singleMean", task = "estimate", outcome = "mean",
    legacy = "singleMean", default = TRUE
  ),
  list(
    design = "singleCorrelation", task = "estimate", outcome = "correlation",
    legacy = "singleCorrelation", default = TRUE
  ),
  # --- Phase 3: observational family + paired binary + single-arm ---
  list(
    design = "cohort", task = "test", outcome = "proportion",
    legacy = "cohortProportion", default = TRUE
  ),
  list(
    design = "cohort", task = "test", outcome = "rate",
    legacy = "cohortRate"
  ),
  list(
    design = "caseControlMatched", task = "test", outcome = "proportion",
    legacy = "caseControlMatched", default = TRUE
  ),
  list(
    design = "crosstab", task = "test", outcome = "proportion",
    legacy = "crosstab", default = TRUE
  ),
  list(
    design = "paired", task = "test", outcome = "proportion",
    legacy = "pairedProportions"
  ),
  list(
    design = "rctSingleArm", task = "test", outcome = "mean",
    legacy = "singleArmMean", default = TRUE
  ),
  list(
    design = "rctSingleArm", task = "test", outcome = "proportion",
    legacy = "singleArmProportion"
  ),
  # --- Phase 4: diagnostic margins + crossover/BE ---
  list(
    design = "diagAccuracyCompare", task = "noninferiority", outcome = "proportion",
    legacy = "diagCompareNI"
  ),
  list(
    design = "diagAccuracyCompare", task = "equivalence", outcome = "proportion",
    legacy = "diagCompareEquiv"
  ),
  list(
    design = "diagAUCCompare", task = "noninferiority", outcome = "auc",
    legacy = "diagAUCCompareNI"
  ),
  list(
    design = "diagAUCCompare", task = "equivalence", outcome = "auc",
    legacy = "diagAUCCompareEquiv"
  ),
  list(
    design = "crossover", task = "test", outcome = "mean",
    legacy = "crossoverMean", default = TRUE
  ),
  list(
    design = "bioequivalence", task = "equivalence", outcome = "mean",
    legacy = "bioequivalence", default = TRUE
  ),
  # --- Phase 5: complex designs ---
  list(
    design = "clusterRCT", task = "test", outcome = "mean",
    legacy = "clusterMean", default = TRUE
  ),
  list(
    design = "clusterRCT", task = "test", outcome = "proportion",
    legacy = "clusterProportion"
  ),
  list(
    design = "singleArmPhaseII", task = "test", outcome = "proportion",
    legacy = "simonTwoStage", default = TRUE
  ),
  list(
    design = "rct", task = "noninferiority", outcome = "proportion",
    legacy = "nonInferiorityProportions"
  ),
  list(
    design = "twoOrdinal", task = "test", outcome = "ordinal",
    legacy = "twoOrdinalWhitehead", default = TRUE
  ),
  list(
    design = "predictiveModel", task = "plan", outcome = "events",
    legacy = "predictiveEPV", default = TRUE
  ),
  list(
    design = "its", task = "test", outcome = "rate",
    legacy = "itsLevel", default = TRUE
  ),
  # --- 3.1: observer agreement (Cantor 1996) ---
  list(
    design = "kappa", task = "estimate", outcome = "proportion",
    legacy = "kappaEstimate", default = TRUE
  ),
  list(
    design = "kappa", task = "test", outcome = "proportion",
    legacy = "kappaTest"
  ),
  # --- 3.1: stepped wedge (Hussey & Hughes 2007, Eq 8) ---
  list(
    design = "steppedWedge", task = "test", outcome = "mean",
    legacy = "steppedWedgeMean", default = TRUE
  ),
  list(
    design = "steppedWedge", task = "test", outcome = "proportion",
    legacy = "steppedWedgeProportion"
  ),
  # --- 3.1: prediction model (Riley 2020) ---
  list(
    design = "predictiveModel", task = "plan", outcome = "binary",
    legacy = "predictiveRileyBinary"
  ),
  list(
    design = "predictiveModel", task = "plan", outcome = "rate",
    legacy = "predictiveRileyTimetoevent"
  )
)

ssr_design_names <- unique(vapply(ssr_combinations, `[[`, character(1), "design"))

# Index: legacy keyword -> combination row (for the compatibility shim)
ssr_legacy_index <- list()
for (row in ssr_combinations) {
  ssr_legacy_index[[row$legacy]] <- row
}

# Resolve a (design, task, outcome) triple to its combination row.
# - Unknown design: error listing valid designs
# - Legal design, NULL task/outcome: default row (marked default = TRUE)
# - Illegal combination: error listing legal combos for that design
ssr_resolve <- function(design, task = NULL, outcome = NULL) {
  if (!is.character(design) || length(design) != 1 || is.na(design)) {
    cli::cli_abort(c(
      "{.arg design} must be a single character value.",
      "i" = "Valid designs: {.val {ssr_design_names}}"
    ))
  }

  rows <- Filter(function(r) identical(r$design, design), ssr_combinations)
  if (length(rows) == 0) {
    cli::cli_abort(c(
      "Unknown design {.val {design}}.",
      "i" = "Valid designs: {.val {ssr_design_names}}",
      "i" = "See the reference manual 'DESIGN_MATRIX.md' (system.file(\"reference\", \"DESIGN_MATRIX.md\", package = \"sampleSizeCalc\")) for the full combination table."
    ))
  }

  if (is.null(task) && is.null(outcome)) {
    defaults <- Filter(function(r) isTRUE(r$default), rows)
    if (length(defaults) == 0) {
      cli::cli_abort(c(
        "Design {.val {design}} requires explicit {.arg task} and {.arg outcome}.",
        "i" = "Legal combinations: {ssr_format_combos(rows)}"
      ))
    }
    return(defaults[[1]])
  }

  if (!is.null(task)) {
    rows <- Filter(function(r) identical(r$task, task), rows)
  }
  if (!is.null(outcome)) {
    rows <- Filter(function(r) identical(r$outcome, outcome), rows)
  }

  if (length(rows) == 0) {
    cli::cli_abort(c(
      "Illegal combination: design {.val {design}}, task {.val {task %||% '*'}}, outcome {.val {outcome %||% '*'}}.",
      "i" = "Legal combinations: {ssr_format_combos(Filter(function(r) identical(r$design, design), ssr_combinations))}"
    ))
  }
  if (length(rows) > 1) {
    # Ambiguous partial specification: never guess silently.
    cli::cli_abort(c(
      "Ambiguous combination: design {.val {design}} with task {.val {task %||% '*'}} and outcome {.val {outcome %||% '*'}} matches {length(rows)} rows.",
      "i" = "Legal combinations: {ssr_format_combos(rows)}",
      "i" = "Specify {.arg task} and {.arg outcome} (or omit both for the default)."
    ))
  }
  rows[[1]]
}

ssr_format_combos <- function(rows) {
  paste(
    vapply(
      rows, function(r) sprintf("(%s, %s, %s)", r$design, r$task, r$outcome),
      character(1)
    ),
    collapse = ", "
  )
}

# Dispatch to the internal calculation module by legacy keyword.
# Extracted verbatim from the pre-3.0 sample_size_calculator() switch so both
# API paths share one dispatch (golden master requirement).
# `path` distinguishes the entry point: "legacy" (sample_size_calculator)
# keeps pre-3.0 behavior byte-for-byte; "three-axis" (calculate) may upgrade
# specific designs (e.g. diagnosticComparisonTwo paired -> Connor kernel).
dispatch_calculation <- function(legacy_keyword, args, alpha, power,
                                 path = c("legacy", "three-axis")) {
  path <- rlang::arg_match(path, c("legacy", "three-axis"))
  switch(legacy_keyword,
    "twoMeans" = calculate_two_means(
      mean1 = args$mean1, mean2 = args$mean2, sd = args$sd,
      alpha = alpha, power = power
    ),
    "twoProportions" = calculate_two_proportions(
      p1 = args$p1, p2 = args$p2, alpha = alpha, power = power
    ),
    "pairedMeans" = calculate_paired_means(
      meanDiff = args$meanDiff, sdDiff = args$sdDiff,
      alpha = alpha, power = power
    ),
    "survival" = calculate_survival(
      hr = args$hr, pE = args$pE, alpha = alpha, power = power
    ),
    "nonInferiorityMeans" = calculate_non_inferiority_means(
      mean1 = args$mean1, mean2 = args$mean2, sd = args$sd, margin = args$margin,
      alpha = alpha, power = power
    ),
    "superiorityMeans" = calculate_superiority_means(
      mean1 = args$mean1, mean2 = args$mean2, sd = args$sd, margin = args$margin,
      alpha = alpha, power = power
    ),
    "equivalenceMeans" = calculate_equivalence_means(
      mean1 = args$mean1, mean2 = args$mean2, sd = args$sd, margin = args$margin,
      alpha = alpha, power = power
    ),
    "superiorityProportions" = calculate_superiority_proportions(
      p1 = args$p1, p2 = args$p2, margin = args$margin,
      alpha = alpha, power = power
    ),
    "equivalenceProportions" = calculate_equivalence_proportions(
      p1 = args$p1, p2 = args$p2, margin = args$margin,
      alpha = alpha, power = power
    ),
    "caseControl" = calculate_case_control(
      p0 = args$p0, OR = args$OR, m = args$m, alpha = alpha, power = power
    ),
    "diagnosticAccuracySingle" = {
      # Legacy calls (sample_size_calculator) keep the exact legacy behavior;
      # three-axis calls with ci_method/power use the Zhou 6.1/6.2 upgrade.
      if (!is.null(args$ci_method) || !is.null(args$power)) {
        calculate_diagnostic_accuracy_v2(
          prob = args$prob, d = args$d, prevalence = args$prevalence,
          alpha = alpha, power = power,
          ci_method = args$ci_method %||% "precision"
        )
      } else {
        calculate_diagnostic_accuracy_single(
          prob = args$prob, d = args$d, prevalence = args$prevalence,
          alpha = alpha
        )
      }
    },
    "diagnosticSuperioritySingle" = {
      if (isTRUE(args$dual)) {
        # Dual-endpoint strategy (Akoglu 2022 p.184): power EACH endpoint
        # (sensitivity and specificity) at dual_power so the joint power is
        # ~80%; take the max of the two requirements.
        dual_power <- args$dual_power %||% 0.90
        compute_one <- function(prob, p0) {
          z_a <- z_alpha(alpha, "one.sided")
          z_b <- z_power(dual_power)
          prev_val <- if (is.null(args$prevalence)) 1 else args$prevalence
          n_cases <- ((z_a * sqrt(p0 * (1 - p0)) +
            z_b * sqrt(prob * (1 - prob))) / (prob - p0))^2
          list(n_cases = n_cases, n_screen = n_cases / prev_val)
        }
        sens_res <- compute_one(args$prob, args$p0)
        spec_res <- compute_one(args$prob_spec, args$p0_spec)
        n_final <- max(sens_res$n_cases, spec_res$n_cases)
        prev_val <- if (is.null(args$prevalence)) 1 else args$prevalence
        list(
          design_type = "Diagnostic accuracy (dual endpoint: Se + Sp)",
          n_sensitivity = as.integer(ceiling(sens_res$n_cases)),
          n_specificity = as.integer(ceiling(spec_res$n_cases)),
          target_state_cases_needed = as.integer(ceiling(n_final)),
          total_subjects_to_screen = as.integer(ceiling(n_final / prev_val)),
          parameters = list(
            prob = args$prob, p0 = args$p0,
            prob_spec = args$prob_spec, p0_spec = args$p0_spec,
            prevalence = prev_val, alpha = alpha,
            dual = TRUE, dual_power = dual_power
          ),
          formula = "n = [Za*sqrt(p0q0) + Zb*sqrt(pq)]^2/(p-p0)^2, each at dual_power; take max",
          formula_latex = "$$n = \\max\\left(n_{Se},\\, n_{Sp}\\right), \\quad n = \\frac{\\left[Z_{\\alpha}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p(1-p)}\\right]^2}{(p-p_0)^2}$$",
          reference = paste(
            "Strategy: Akoglu, H. (2022). User's guide to sample size estimation",
            "in diagnostic accuracy studies. Turkish Journal of Emergency Medicine,",
            "22(4), 177-185 (p. 184: each endpoint at 90% power -> ~80% overall)."
          ),
          roles = c(
            "prob/p0 = expected and null sensitivity",
            "prob_spec/p0_spec = expected and null specificity",
            "dual_power = per-endpoint power (default 0.90 -> ~80% joint)"
          )
        )
      } else {
        calculate_diagnostic_superiority_single(
          prob = args$prob, p0 = args$p0, prevalence = args$prevalence,
          alpha = alpha, power = power,
          method = args$method %||% "asymptotic",
          alternative = args$alternative %||% "one.sided"
        )
      }
    },
    "diagnosticComparisonTwo" = {
      if (isTRUE(args$paired) && path == "three-axis") {
        # Upgrade (Phase 4): paired branch now uses the Connor kernel with
        # psi = discordant-pair PROPORTION (legacy keyword keeps the old
        # sqrt-scale psi parameterization, locked by golden master).
        n_pairs_calc <- paired_proportion_n(
          p1 = args$p1, p2 = args$p2, psi = args$psi, alpha = alpha, power = power
        )
        prev_val <- if (is.null(args$prevalence)) 1 else args$prevalence
        list(
          design_type = "Two diagnostic measures (paired, Connor)",
          pairs_count = as.integer(ceiling(n_pairs_calc)),
          cases_needed = as.integer(ceiling(n_pairs_calc)),
          total_subjects_to_screen = as.integer(ceiling(n_pairs_calc / prev_val)),
          parameters = list(
            p1 = args$p1, p2 = args$p2, prevalence = prev_val,
            paired = TRUE, psi = args$psi,
            psi_type = "discordant-pair proportion", alpha = alpha, power = power
          ),
          formula = "n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2",
          formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{\\psi} + Z_{\\beta}\\sqrt{\\psi-\\delta^2}\\right]^2}{\\delta^2}$$",
          reference = paste(
            "Primary: Connor, R. J. (1987). Biometrics, 43(1), 207-211.\n\n",
            "Also: Akoglu, H. (2022). Turkish Journal of Emergency Medicine,",
            "22(4), Table 2 Eq 3b + Tables 6A/6B; Zhou et al. (2011) Section 6.2.2."
          ),
          roles = c(
            "p1/p2 = expected sensitivities of the two tests",
            "psi = expected discordant-pair proportion (pi10 + pi01)",
            "output is in PAIRS (cases); screening total = pairs/prevalence"
          )
        )
      } else {
        calculate_diagnostic_comparison_two(
          p1 = args$p1, p2 = args$p2, prevalence = args$prevalence,
          paired = args$paired, psi = args$psi, alpha = alpha, power = power
        )
      }
    },
    "likelihoodRatioTest" = {
      # log-LR rewrite (Hajian-Tilaki 6.4) for three-axis calls specifying
      # lr_type or target_lr; legacy keyword keeps the simplified Se/Sp-max
      # formula (golden master).
      if (!is.null(args$lr_type) || !is.null(args$target_lr)) {
        calculate_likelihood_ratio_v2(
          sens = args$sens, spec = args$spec, prevalence = args$prevalence,
          alpha = alpha, target_lr = args$target_lr,
          lr_type = args$lr_type %||% "negative"
        )
      } else {
        calculate_likelihood_ratio_test(
          sens = args$sens, spec = args$spec, prevalence = args$prevalence,
          precision = args$precision, alpha = alpha
        )
      }
    },
    "auc_single" = {
      # Upgrade path for three-axis calls; legacy keyword keeps old behavior.
      if (!is.null(args$var_method)) {
        calculate_auc_single_v2(
          auc = args$auc, d = args$d, prevalence = args$prevalence,
          alpha = alpha, ratio = args$ratio %||% 1,
          var_method = args$var_method
        )
      } else {
        calculate_auc_single(
          auc = args$auc, d = args$d, prevalence = args$prevalence,
          alpha = alpha
        )
      }
    },
    "aucSuperiority" = calculate_auc_superiority(
      auc = args$auc, auc0 = args$auc0, prevalence = args$prevalence,
      alpha = alpha, power = power
    ),
    "aucComparison" = calculate_auc_comparison(
      auc1 = args$auc1, auc2 = args$auc2, r = args$r,
      prevalence = args$prevalence, alpha = alpha, power = power
    ),
    "singleProportion" = ,
    "singleMean" = ,
    "singleCorrelation" =
      dispatch_estimation(legacy_keyword, args, alpha, power),
    "cohortProportion" = calculate_cohort_proportion(
      p0 = args$p0,
      p1 = args$p1,
      ratio = args$ratio %||% 1,
      alpha = alpha,
      power = power,
      dropout = args$dropout
    ),
    "cohortRate" = calculate_cohort_rate(
      rate0 = args$rate0,
      rate1 = args$rate1,
      ratio = args$ratio %||% 1,
      alpha = alpha,
      power = power
    ),
    "caseControlMatched" = calculate_case_control_matched(
      p0 = args$p0, OR = args$OR, alpha = alpha, power = power
    ),
    "crosstab" = calculate_crosstab_association(
      p0 = args$p0, p1 = args$p1, alpha = alpha, power = power
    ),
    "pairedProportions" = calculate_paired_proportions(
      p1 = args$p1, p2 = args$p2, psi = args$psi,
      alpha = alpha, power = power
    ),
    "singleArmMean" = calculate_single_arm_mean(
      mu0 = args$mu0, mu1 = args$mu1, sigma = args$sigma,
      alpha = alpha, power = power
    ),
    "singleArmProportion" = calculate_single_arm_proportion(
      p0 = args$p0, p1 = args$p1, alpha = alpha, power = power
    ),
    "diagCompareNI" = calculate_diag_compare_margin_prop(
      p1 = args$p1, p2 = args$p2, margin = args$margin,
      alpha = alpha, power = power, task = "noninferiority",
      prevalence = args$prevalence
    ),
    "diagCompareEquiv" = calculate_diag_compare_margin_prop(
      p1 = args$p1, p2 = args$p2, margin = args$margin,
      alpha = alpha, power = power, task = "equivalence",
      prevalence = args$prevalence
    ),
    "diagAUCCompareNI" = calculate_diag_auc_compare_margin(
      auc1 = args$auc1, auc2 = args$auc2, r = args$r %||% 0.5,
      margin = args$margin, alpha = alpha, power = power,
      task = "noninferiority", var_method = args$var_method %||% "binormal"
    ),
    "diagAUCCompareEquiv" = calculate_diag_auc_compare_margin(
      auc1 = args$auc1, auc2 = args$auc2, r = args$r %||% 0.5,
      margin = args$margin, alpha = alpha, power = power,
      task = "equivalence", var_method = args$var_method %||% "binormal"
    ),
    "crossoverMean" = calculate_crossover_mean(
      delta = args$delta, sigma_within = args$sigma_within,
      alpha = alpha, power = power
    ),
    "bioequivalence" = calculate_bioequivalence(
      cv = args$cv, alpha = alpha, power = power,
      theta0 = args$theta0 %||% 1.0,
      margin_low = args$margin_low %||% 0.8,
      margin_high = args$margin_high %||% 1.25
    ),
    "clusterMean" = calculate_cluster_mean(
      mean1 = args$mean1, mean2 = args$mean2, sd = args$sd,
      icc = args$icc, cluster_size = args$cluster_size,
      alpha = alpha, power = power
    ),
    "clusterProportion" = calculate_cluster_proportion(
      p1 = args$p1, p2 = args$p2, icc = args$icc,
      cluster_size = args$cluster_size, alpha = alpha, power = power
    ),
    "simonTwoStage" = calculate_simon_two_stage(
      p0 = args$p0, p1 = args$p1, alpha = alpha, power = power,
      optimizer = args$optimizer %||% "optimal"
    ),
    "nonInferiorityProportions" = calculate_non_inferiority_proportions(
      p1 = args$p1, p2 = args$p2, margin = args$margin,
      alpha = alpha, power = power
    ),
    "twoOrdinalWhitehead" = calculate_two_ordinal(
      or = args$or, prop_bar = args$prop_bar, alpha = alpha, power = power,
      allocation = args$allocation %||% 1
    ),
    "predictiveEPV" = calculate_predictive_epv(
      n_parameters = args$n_parameters, epv = args$epv %||% 10,
      event_prevalence = args$event_prevalence
    ),
    "itsLevel" = calculate_its_level(
      effect_sd = args$effect_sd, n_pre = args$n_pre, n_post = args$n_post,
      rho = args$rho, alpha = alpha, power = power
    ),
    "predictiveRileyBinary" = calculate_predictive_riley_binary(
      prev = args$prev, n_parameters = args$n_parameters,
      r2_cs = args$r2_cs, shrinkage = args$shrinkage,
      mape = args$mape, precision_delta = args$precision_delta,
      alpha = alpha
    ),
    "predictiveRileyTimetoevent" = calculate_predictive_timetoevent(
      rate = args$rate, timepoint = args$timepoint,
      precision_delta = args$precision_delta, alpha = alpha,
      n_parameters = args$n_parameters, epv = args$epv
    ),
    "kappaEstimate" = calculate_kappa(
      pi1 = args$pi1, pi2 = args$pi2, kappa1 = args$kappa,
      d = args$d, alpha = alpha, power = power, task = "estimate"
    ),
    "kappaTest" = calculate_kappa(
      pi1 = args$pi1, pi2 = args$pi2, kappa1 = args$kappa1,
      kappa2 = args$kappa2, d = NULL, alpha = alpha, power = power,
      task = "test"
    ),
    "steppedWedgeMean" = calculate_stepped_wedge(
      theta = args$theta, tau2 = args$tau2, sigma2_ind = args$sigma2_ind,
      m = args$m, n_clusters = args$n_clusters,
      clusters_per_step = args$clusters_per_step, alpha = alpha,
      outcome = "mean"
    ),
    "steppedWedgeProportion" = calculate_stepped_wedge(
      theta = args$theta, tau2 = args$tau2, sigma2_ind = args$sigma2_ind,
      m = args$m, n_clusters = args$n_clusters,
      clusters_per_step = args$clusters_per_step, alpha = alpha,
      outcome = "proportion"
    ),
    cli::cli_abort("No calculation module for legacy keyword {.val {legacy_keyword}}.")
  )
}

#' Unified sample size calculator (three-axis API)
#'
#' Computes sample size (or events/cases) for a study design identified by the
#' triple design / task / outcome. See the installed reference manual
#' `system.file("reference", "DESIGN_MATRIX.md", package = "sampleSizeCalc")`
#' for the complete combination table, formulas, and literature sources
#' (also on the pkgdown site under `reference/`).
#'
#' @param ... ...
#'   Control and design arguments, resolved by EXACT name (partial
#'     matching is deliberately avoided so that design-specific arguments such
#'     as `d` cannot be swallowed by the `design` slot).
#'   
#'     **Control arguments**
#'   
#'     * `design` (first positional argument): one of `"rct"`, `"paired"`,
#'       `"rctSingleArm"`, `"crossover"`, `"bioequivalence"`,
#'       `"singleArmPhaseII"`, `"cohort"`, `"caseControl"`,
#'       `"caseControlMatched"`, `"crosstab"`, `"singleProportion"`,
#'       `"singleMean"`, `"singleCorrelation"`, `"diagAccuracy"`,
#'       `"diagAccuracyCompare"`, `"diagAUC"`, `"diagAUCCompare"`, `"diagLR"`,
#'       `"clusterRCT"`, `"steppedWedge"`, `"twoOrdinal"`, `"predictiveModel"`,
#'       `"kappa"`, `"its"` - the study-design axis.
#'     * `task` (second positional argument): `"test"`, `"estimate"`,
#'       `"noninferiority"`, `"superiority"`, `"equivalence"`, or `"plan"`;
#'       optional for unambiguous designs.
#'     * `outcome` (third positional argument): `"mean"`, `"proportion"`,
#'       `"rate"`, `"survival"`, `"auc"`, `"lr"`, `"correlation"`, `"ordinal"`,
#'       or `"events"`; optional for unambiguous designs.
#'     * `alpha`: scalar in (0, 1), default 0.05. Use 0.025 for one-sided
#'       non-inferiority trials spending a full two-sided 0.05.
#'     * `power`: scalar in (0, 1), default 0.8 (80 percent); 0.9 for
#'       confirmatory trials.
#'     * `alternative`: `"one.sided"` (the package's historical default and the
#'       Akoglu 2022 Table 2 Eq 2 convention) or `"two.sided"` (Hajian-Tilaki
#'       2014 Eq 6.8 convention), or `NULL` to keep the design default.
#'       Currently consumed by `diagAccuracy` + `test` + `proportion` only;
#'       other designs ignore it.
#'     * `dropout`: anticipated dropout/non-response proportion in &lbrack;0, 1),
#'       inflating by 1/(1-d). Currently applied by `cohort` + `test` +
#'       `proportion` only; other designs ignore it.
#'   
#'     **Design-specific parameters** (all validated; ranges shown):
#'   
#'     * *RCT, test, mean*: `mean1`, `mean2` real-valued group means (e.g.
#'       mmHg); `sd` > 0 pooled standard deviation.
#'     * *RCT, test, proportion*: `p1`, `p2` in (0, 1) response rates, must
#'       differ.
#'     * *RCT, test, survival*: `hr` in (0, 1) anticipated hazard ratio
#'       (<1 = benefit); `pE` in (0, 1) experimental-arm share (default 0.5).
#'       Returns **events** required.
#'     * *RCT, noninferiority/superiority, mean or proportion*: same inputs as
#'       above plus `margin` > 0 (NI margin Delta, one-sided alpha; or the
#'       minimal clinically important difference for superiority).
#'     * *RCT, equivalence, mean or proportion*: `margin` = corridor
#'       half-width; must exceed |mean1 - mean2| (or |p1 - p2|); uses
#'       Z_(beta/2).
#'     * *paired, mean*: `meanDiff` != 0 within-subject mean difference;
#'       `sdDiff` > 0 SD of the differences (NOT the pooled SD).
#'     * *paired, proportion*: `p1`, `p2` in (0, 1); `psi` in (0, 1) expected
#'       discordant-pair proportion, psi >= |p1-p2|; output in pairs.
#'     * *rctSingleArm, mean*: `mu0` historical mean, `mu1` anticipated mean,
#'       `sigma` > 0.
#'     * *rctSingleArm, proportion*: `p0` historical rate, `p1` anticipated
#'       rate, both in (0, 1).
#'     * *crossover, mean*: `delta` > 0 treatment difference; `sigma_within` > 0
#'       within-subject SD.
#'     * *bioequivalence*: `cv` in (0, 1) intra-subject CV; `theta0` GMR inside
#'       the acceptance range (default 1.0); `margin_low`/`margin_high` default
#'       0.8/1.25 (80-125 rule).
#'     * *singleArmPhaseII*: `p0` unacceptable rate; `p1` > p0 target rate;
#'       `optimizer` = "optimal" or "minimax".
#'     * *cohort, proportion*: `p0`, `p1` in (0, 1); `ratio` >= 1
#'       unexposed:exposed; optional `dropout` in &lbrack;0, 1) inflates by 1/(1-d).
#'     * *cohort, rate*: `rate0`, `rate1` > 0 events per person-time; `ratio`
#'       at least  1 person-time ratio.
#'     * *caseControl*: `p0` in (0, 1) control exposure rate; `OR` > 0, != 1;
#'       `m` >= 1 controls per case (default 1).
#'     * *caseControlMatched*: `p0`, `OR` as above; 1:1 matching built in.
#'     * *crosstab*: `p0`, `p1` in (0, 1) prevalence in unexposed/exposed.
#'     * *singleProportion*: `p` in (0, 1); `precision` > 0; `precision_type` =
#'       "absolute" (default) or "relative".
#'     * *singleMean*: `sigma` > 0; `precision` > 0 margin of error.
#'     * *singleCorrelation*: `r` in (0, 1); exactly one of `precision`
#'       (absolute CI half-width in (0, 1)) or `epsilon` (relative).
#'     * *diagAccuracy, estimate*: `prob` in (0, 1) expected Se/Sp; `d` in
#'       (0, 1) CI half-width; `prevalence` in (0, 1&rbrack;; optional `ci_method` =
#'       "precision" (Zhou Eq 6.2) or "ci_width_power" (Eq 6.1, uses `power`).
#'     * *diagAccuracy, test*: `prob`, `p0` in (0, 1); `method` = "asymptotic"
#'       or "exact" (A'Hern); dual-endpoint adds `prob_spec`, `p0_spec`,
#'       `dual = TRUE`, `dual_power` (default 0.90).
#'     * *diagAccuracyCompare*: `p1`, `p2` in (0, 1); `paired` = TRUE requires
#'       `psi` in (0, 1); margin tasks add `margin` in (0, 1).
#'     * *diagAUC, estimate*: `auc` in (0, 1); `d` > 0; `ratio` >= 1
#'       case:control (default 1); `var_method` = "binormal" (recommended),
#'       "exponential", or "conservative".
#'     * *diagAUC, test*: `auc`, `auc0` in (0, 1), auc > auc0.
#'     * *diagAUCCompare*: `auc1`, `auc2` in (0, 1); `r` in &lbrack;0, 1) (default
#'       0.5); margin tasks add `margin` in (0, 1).
#'     * *diagLR, estimate*: `sens`, `spec` in (0, 1); `lr_type` = "positive"
#'       or "negative"; `target_lr` > 0 the boundary the CI must not cross.
#'     * *clusterRCT*: base two-group args plus `icc` in &lbrack;0, 1) and
#'       `cluster_size` integer >= 1 (DE = 1 + (m-1)*ICC).
#'     * *steppedWedge*: `theta` != 0; `tau2` > 0; `sigma2_ind` > 0; `m` >= 1;
#'       `n_clusters` integer >= 2, a multiple of `clusters_per_step` >= 1.
#'     * *twoOrdinal*: `or` > 0, != 1; `prop_bar` positive vector summing to 1.
#'     * *predictiveModel, binary*: `prev` in (0, 1); `n_parameters` integer
#'       at least  1; `r2_cs` within its feasible maximum; `shrinkage` default 0.9;
#'       `mape` default 0.05; `precision_delta` default 0.05.
#'     * *predictiveModel, rate*: `rate` > 0 per person-year; `timepoint` > 0;
#'       `precision_delta` in (0, 1); optional `n_parameters`/`epv` cross-check.
#'     * *predictiveModel, events*: `n_parameters` >= 1; `epv` >= 1 (classic
#'       10); `event_prevalence` in (0, 1).
#'     * *kappa, estimate*: `pi1`, `pi2` in (0, 1); `kappa` in &lbrack;0, 1); `d` in
#'       (0, 1).
#'     * *kappa, test*: `kappa1` != `kappa2` in (0, 1); same pi's.
#'     * *its*: `effect_sd` > 0; `n_pre`, `n_post` integers >= 3 (>= 8
#'       recommended); `rho` in &lbrack;0, 1). Returns achieved power.
#'   
#'   
#' @return Object of class `sample_size_result` with print, summary, and
#'   plot methods. Default printing shows sample sizes, the plain-text
#'   formula (`formula`), LaTeX source (`formula_latex`), calculation process
#'   (`calculation_steps`, also available as `calculation`), and literature
#'   references (`reference`). New-style objects also carry axis metadata
#'   (`task`, `outcome`, `design_canonical`, `results`, `roles`, `adjustments`).
#'   [summary.sample_size_result()] additionally lists all input parameters
#'   and recorded adjustments.
#'
#' @examples
#' # Antihypertensive RCT: placebo 10 mmHg vs new drug 12 mmHg SBP reduction,
#' # pooled SD 3 mmHg, two-sided alpha 0.05, 80% power
#' calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#'
#' # Generic vs originator antidiabetic, non-inferiority margin 1 point,
#' # one-sided alpha 0.05
#' calculate(
#'   design = "rct", task = "noninferiority", outcome = "mean",
#'   mean1 = 10, mean2 = 9.5, sd = 3, margin = 1
#' )
#'
#' # Bioequivalence of a generic amlodipine: intra-subject CV 25%,
#' # expected GMR 1.0, 80-125% acceptance range (2x2 crossover)
#' calculate("bioequivalence", cv = 0.25)
#'
#' # Colorectal cancer screening kit: expected sensitivity 85%,
#' # CI half-width +/-5%, clinic prevalence 20%
#' calculate("diagAccuracy", "estimate", "proportion",
#'   prob = 0.85, d = 0.05, prevalence = 0.20
#' )
#'
#' # AUC precision for a biomarker validation cohort: AUC 0.80,
#' # CI half-width 0.10, 1:1 case:control, binormal variance
#' calculate("diagAUC", auc = 0.80, d = 0.05, var_method = "binormal")
#' @export
calculate <- function(...) {
  args <- rlang::list2(...)

  # Argument matching is resolved manually with EXACT names: R's partial
  # matching would silently swallow design-specific args like `d`
  # (precision) into the `design` formal -- a latent bug the legacy API
  # also carries (e.g. sample_size_calculator("auc_single", d = 0.05)).
  take_exact <- function(name, default = NULL) {
    val <- args[[name]] # [[ with a character index matches exactly
    if (!is.null(val)) args[[name]] <<- NULL
    if (is.null(val)) default else val
  }

  design <- take_exact("design")
  task <- take_exact("task")
  outcome <- take_exact("outcome")
  alpha <- take_exact("alpha", 0.05)
  power <- take_exact("power", 0.8)
  alternative <- take_exact("alternative")

  # Positional support: leading unnamed one-element character arguments fill
  # design, then task, then outcome (calculate("rct", "test", "mean", ...)).
  nms <- names(args)
  if (is.null(nms)) nms <- rep("", length(args))
  nms[is.na(nms)] <- ""
  unnamed_idx <- which(nms == "" &
    vapply(args, function(x) is.character(x) && length(x) == 1, logical(1)))

  for (slot in c("design", "task", "outcome")) {
    if (!is.null(get(slot))) next
    idx <- unnamed_idx[1]
    if (is.na(idx)) break
    assign(slot, args[[idx]])
    args[[idx]] <- NULL
    nms <- names(args)
    if (is.null(nms)) nms <- rep("", length(args))
    nms[is.na(nms)] <- ""
    unnamed_idx <- which(nms == "" &
      vapply(args, function(x) is.character(x) && length(x) == 1, logical(1)))
  }

  row <- ssr_resolve(design, task, outcome)
  alpha <- validate_alpha(alpha)
  power <- validate_power(power)
  alternative <- validate_alternative(alternative)

  args <- validate_design_args(row$legacy, args)
  # `alternative` is a control argument, not a design argument: it is consumed
  # by the kernels that accept it, so it must not reach validate_design_args().
  args$alternative <- alternative
  calcResult <- dispatch_calculation(row$legacy, args, alpha, power, path = "three-axis")

  res <- as_sample_size_result(row$legacy, row$task, row$outcome, calcResult)
  res$design_canonical <- row$design
  res$replay_args <- args
  res
}
