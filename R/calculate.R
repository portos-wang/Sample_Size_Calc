# Unified three-axis entry point: calculate(design, task, outcome, ...)
# Axis decisions documented in docs/DESIGN_MATRIX.md:
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
      "i" = "See {.emph docs/DESIGN_MATRIX.md} for the full combination table."
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
          alpha = alpha, power = power
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
      task = "noninferiority", var_method = args$var_method %||% "exponential"
    ),
    "diagAUCCompareEquiv" = calculate_diag_auc_compare_margin(
      auc1 = args$auc1, auc2 = args$auc2, r = args$r %||% 0.5,
      margin = args$margin, alpha = alpha, power = power,
      task = "equivalence", var_method = args$var_method %||% "exponential"
    ),
    "crossoverMean" = calculate_crossover_mean(
      delta = args$delta, sigma_within = args$sigma_within,
      alpha = alpha, power = power
    ),
    "bioequivalence" = calculate_bioequivalence(
      cv = args$cv, alpha = alpha, power = power
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
      or = args$or, prop_bar = args$prop_bar, alpha = alpha, power = power
    ),
    "predictiveEPV" = calculate_predictive_epv(
      n_parameters = args$n_parameters, epv = args$epv %||% 10,
      event_prevalence = args$event_prevalence
    ),
    "itsLevel" = calculate_its_level(
      effect_sd = args$effect_sd, n_pre = args$n_pre, n_post = args$n_post,
      rho = args$rho, alpha = alpha, power = power
    ),
    cli::cli_abort("No calculation module for legacy keyword {.val {legacy_keyword}}.")
  )
}

#' Unified sample size calculator (three-axis API)
#'
#' Computes sample size (or events/cases) for a study design identified by the
#' triple design / task / outcome. See `docs/DESIGN_MATRIX.md` (source
#' repository) for the complete combination table, formulas, and literature
#' sources.
#'
#' @param ... Control and design arguments, resolved by EXACT name (partial
#'   matching is deliberately avoided so that design-specific arguments such
#'   as `d` cannot be swallowed by the `design` slot). Recognised control
#'   arguments: `design` (e.g. "rct", "caseControl", "diagAccuracy"; may be
#'   the first positional argument), `task` ("estimate", "test",
#'   "noninferiority", "superiority", "equivalence"; optional for
#'   unambiguous designs, may be the second positional argument), `outcome`
#'   ("mean", "proportion", "rate", "survival", "auc", "lr",
#'   "correlation", "ordinal", "events"; optional for unambiguous designs,
#'   may be the third positional argument), `alpha` (type I error, default
#'   0.05), and `power` (target power, default 0.8). All remaining named
#'   arguments are design-specific parameters, identical to the names used
#'   by the legacy [sample_size_calculator()] API.
#' @return Object of class \code{sample_size_result} with print, summary, and
#'   plot methods. New-style objects additionally carry axis metadata
#'   (task, outcome, design_canonical, results, roles, adjustments).
#'
#' @examples
#' calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
#' calculate(
#'   design = "rct", task = "noninferiority", outcome = "mean",
#'   mean1 = 10, mean2 = 9.5, sd = 3, margin = 1
#' )
#' calculate("diagAUC", auc = 0.80, d = 0.05)
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

  args <- validate_design_args(row$legacy, args)
  calcResult <- dispatch_calculation(row$legacy, args, alpha, power, path = "three-axis")

  res <- as_sample_size_result(row$legacy, row$task, row$outcome, calcResult)
  res$design_canonical <- row$design
  res$replay_args <- args
  res
}
