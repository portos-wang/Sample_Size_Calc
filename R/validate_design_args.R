# Design argument validation

#' Validate design-specific arguments
#'
#' Checks required, supported, and finite design-specific inputs before
#' dispatch. Arguments not used by the selected calculation path abort.
#'
#' @param design Study design keyword (legacy dispatch name, e.g.
#'   "twoMeans", "cohortProportion", "simonTwoStage")
#' @param args Named list of arguments to validate
#' @return Validated arguments list (invisible)
#' @keywords internal
#' @examples
#' SampleSizeCalc:::validate_design_args(
#'   "twoMeans", list(mean1 = 10, mean2 = 12, sd = 3)
#' )
#' # Error: missing mean2 and sd
#' try(SampleSizeCalc:::validate_design_args("twoMeans", list(mean1 = 10)))
#' @keywords internal
validate_design_args <- function(design, args) {
  required_args <- list(
    # Drug trial designs
    twoMeans = c("mean1", "mean2", "sd"),
    twoProportions = c("p1", "p2"),
    pairedMeans = c("meanDiff", "sdDiff"),
    survival = c("hr"),
    nonInferiorityMeans = c("mean1", "mean2", "sd", "margin"),
    superiorityMeans = c("mean1", "mean2", "sd", "margin"),
    equivalenceMeans = c("mean1", "mean2", "sd", "margin"),
    superiorityProportions = c("p1", "p2", "margin"),
    equivalenceProportions = c("p1", "p2", "margin"),
    # Diagnostic designs
    diagnosticAccuracySingle = c("prob", "d"),
    diagnosticSuperioritySingle = c("prob", "p0"),
    diagnosticComparisonTwo = c("p1", "p2", "paired"),
    likelihoodRatioTest = c("sens", "spec"),
    auc_single = c("auc", "d"),
    aucSuperiority = c("auc", "auc0"),
    aucComparison = c("auc1", "auc2", "r"),
    # Case-control
    caseControl = c("p0", "OR"),
    # Phase 2-3 additions
    singleProportion = c("p", "precision"),
    singleMean = c("sigma", "precision"),
    singleCorrelation = c("r"),
    cohortProportion = c("p0", "p1"),
    cohortRate = c("rate0", "rate1"),
    caseControlMatched = c("p0", "OR"),
    crosstab = c("p0", "p1"),
    pairedProportions = c("p1", "p2", "psi"),
    singleArmMean = c("mu0", "mu1", "sigma"),
    singleArmProportion = c("p0", "p1"),
    diagCompareNI = c("p1", "p2", "margin"),
    diagCompareEquiv = c("p1", "p2", "margin"),
    diagAUCCompareNI = c("auc1", "auc2", "margin"),
    diagAUCCompareEquiv = c("auc1", "auc2", "margin"),
    crossoverMean = c("delta", "sigma_within"),
    bioequivalence = c("cv"),
    clusterMean = c("mean1", "mean2", "sd", "icc", "cluster_size"),
    clusterProportion = c("p1", "p2", "icc", "cluster_size"),
    simonTwoStage = c("p0", "p1"),
    nonInferiorityProportions = c("p1", "p2", "margin"),
    twoOrdinalWhitehead = c("or", "prop_bar"),
    predictiveEPV = c("n_parameters", "event_prevalence"),
    itsLevel = c("effect_sd", "n_pre", "n_post", "rho"),
    kappaEstimate = c("pi1", "pi2", "kappa", "d"),
    kappaTest = c("pi1", "pi2", "kappa1", "kappa2"),
    steppedWedgeMean = c(
      "theta",
      "tau2",
      "sigma2_ind",
      "m",
      "n_clusters",
      "clusters_per_step"
    ),
    steppedWedgeProportion = c(
      "theta",
      "tau2",
      "sigma2_ind",
      "m",
      "n_clusters",
      "clusters_per_step"
    ),
    predictiveRileyBinary = c("prev", "n_parameters", "r2_cs"),
    predictiveRileyTimetoevent = c("rate", "timepoint", "precision_delta")
  )

  optional_args <- list(
    pairedMeans = "pairing",
    survival = "pE",
    diagnosticAccuracySingle = c("prevalence", "ci_method"),
    diagnosticSuperioritySingle = c(
      "prevalence",
      "method",
      "alternative",
      "dual",
      "prob_spec",
      "p0_spec",
      "dual_power"
    ),
    diagnosticComparisonTwo = c("prevalence", "psi"),
    likelihoodRatioTest = c("prevalence", "precision", "lr_type", "target_lr"),
    auc_single = c("prevalence", "ratio", "var_method"),
    aucSuperiority = c("prevalence", "ratio", "var_method"),
    aucComparison = c("prevalence", "ratio", "var_method"),
    caseControl = "m",
    singleProportion = "precision_type",
    singleCorrelation = c("epsilon", "precision"),
    cohortProportion = c("ratio", "dropout"),
    pairedProportions = "pairing",
    cohortRate = "ratio",
    diagCompareNI = "prevalence",
    diagCompareEquiv = "prevalence",
    diagAUCCompareNI = c("r", "var_method"),
    diagAUCCompareEquiv = c("r", "var_method"),
    bioequivalence = c("theta0", "margin_low", "margin_high"),
    simonTwoStage = "optimizer",
    twoOrdinalWhitehead = "allocation",
    predictiveEPV = "epv",
    predictiveRileyBinary = c("shrinkage", "mape", "precision_delta"),
    predictiveRileyTimetoevent = c("n_parameters", "epv")
  )

  arg_names <- names(args)
  if (
    length(args) > 0L &&
      (is.null(arg_names) ||
        anyNA(arg_names) ||
        any(arg_names == "") ||
        anyDuplicated(arg_names))
  ) {
    cli::cli_abort(
      "Design-specific arguments must have unique, non-empty names."
    )
  }

  required <- required_args[[design]]
  if (is.null(required)) {
    return(args)
  }

  # Nullable optional arguments retain their documented defaults.
  supplied <- names(args)[!vapply(args, is.null, logical(1))]
  if (
    design == "singleCorrelation" &&
      (!"r" %in% supplied || !any(c("epsilon", "precision") %in% supplied))
  ) {
    cli::cli_abort(c(
      "{.fn sample_size_calculator} with design {.val {design}} requires missing arguments:",
      "x" = "{.arg r} and either {.arg epsilon} (relative precision) or {.arg precision} (CI half-width).",
      "i" = "See {.fn ?sample_size_calculator} for required arguments."
    ))
  }

  missing <- setdiff(required, supplied)
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "{.fn sample_size_calculator} with design {.val {design}} requires missing arguments:",
      "x" = "{.arg {paste(missing, collapse = ', ')}}",
      "i" = "See {.fn ?sample_size_calculator} for required arguments."
    ))
  }

  optional <- optional_args[[design]]
  if (design == "diagnosticSuperioritySingle") {
    if (isTRUE(args$dual)) {
      optional <- setdiff(optional, c("method", "alternative"))
      missing_dual <- setdiff(c("prob_spec", "p0_spec"), supplied)
      if (length(missing_dual) > 0L) {
        cli::cli_abort("{.arg dual = TRUE} requires {.arg {missing_dual}}.")
      }
    } else {
      optional <- setdiff(optional, c("prob_spec", "p0_spec", "dual_power"))
    }
  }
  if (design == "diagnosticComparisonTwo" && !isTRUE(args$paired)) {
    optional <- setdiff(optional, "psi")
  }
  if (design == "likelihoodRatioTest") {
    if (any(c("lr_type", "target_lr") %in% supplied)) {
      optional <- setdiff(optional, c("precision", "prevalence"))
    }
  }
  if (
    design == "singleCorrelation" &&
      all(c("epsilon", "precision") %in% supplied)
  ) {
    cli::cli_abort("Supply only one of {.arg epsilon} and {.arg precision}.")
  }
  if (
    design == "predictiveRileyTimetoevent" &&
      xor("n_parameters" %in% supplied, "epv" %in% supplied)
  ) {
    cli::cli_abort("Supply {.arg n_parameters} and {.arg epv} together.")
  }
  if (
    design == "predictiveRileyBinary" &&
      "mape" %in% supplied &&
      is.numeric(args$n_parameters) &&
      length(args$n_parameters) == 1L &&
      is.finite(args$n_parameters) &&
      args$n_parameters > 30
  ) {
    cli::cli_abort(
      "{.arg mape} is available only when {.arg n_parameters} is at most 30."
    )
  }

  unused <- setdiff(arg_names, c(required, optional))
  if (length(unused) > 0L) {
    cli::cli_abort(c(
      "Unsupported arguments for design {.val {design}}: {.arg {unused}}.",
      "i" = "These arguments would not be used by this calculation."
    ))
  }

  text_args <- c(
    "ci_method",
    "var_method",
    "precision_type",
    "method",
    "lr_type",
    "optimizer",
    "alternative",
    "pairing"
  )
  flag_args <- c("paired", "dual")
  for (arg in intersect(supplied, flag_args)) {
    value <- args[[arg]]
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      cli::cli_abort("{.arg {arg}} must be a single non-missing logical value.")
    }
  }
  if ("prop_bar" %in% supplied) {
    value <- args$prop_bar
    if (!is.numeric(value) || length(value) < 2L || any(!is.finite(value))) {
      cli::cli_abort(
        "{.arg prop_bar} must contain at least two finite numeric proportions."
      )
    }
  }
  numeric_args <- args[setdiff(supplied, c(text_args, flag_args, "prop_bar"))]
  validate_numeric_args(numeric_args)
  probability_args <- c(
    "p",
    "p0",
    "p1",
    "p2",
    "prob",
    "prob_spec",
    "p0_spec",
    "sens",
    "spec",
    "auc",
    "auc0",
    "auc1",
    "auc2",
    "prev",
    "event_prevalence",
    "pi1",
    "pi2",
    "pE",
    "dual_power"
  )
  for (arg in intersect(supplied, probability_args)) {
    if (args[[arg]] <= 0 || args[[arg]] >= 1) {
      cli::cli_abort("{.arg {arg}} must be a proportion in (0, 1).")
    }
  }
  positive_args <- c(
    "sd",
    "sdDiff",
    "sigma",
    "sigma_within",
    "precision",
    "epsilon",
    "d",
    "margin",
    "ratio",
    "m",
    "cluster_size",
    "cv",
    "OR",
    "or",
    "delta",
    "rate0",
    "rate1",
    "rate",
    "timepoint",
    "epv",
    "effect_sd",
    "margin_low",
    "margin_high"
  )
  for (arg in intersect(supplied, positive_args)) {
    if (args[[arg]] <= 0) cli::cli_abort("{.arg {arg}} must be positive.")
  }
  for (arg in intersect(supplied, c("icc", "rho"))) {
    if (args[[arg]] < 0 || args[[arg]] >= 1) {
      cli::cli_abort("{.arg {arg}} must be in [0, 1).")
    }
  }
  integer_args <- c(
    "cluster_size",
    "n_parameters",
    "n_pre",
    "n_post",
    "n_clusters",
    "clusters_per_step"
  )
  if (design %in% c("steppedWedgeMean", "steppedWedgeProportion")) {
    integer_args <- c(integer_args, "m")
  }
  for (arg in intersect(supplied, integer_args)) {
    if (args[[arg]] < 1 || args[[arg]] != floor(args[[arg]])) {
      cli::cli_abort("{.arg {arg}} must be a positive integer.")
    }
  }
  if (design == "caseControl" && "m" %in% supplied && args$m < 1) {
    cli::cli_abort("{.arg m} (controls per case) must be at least 1.")
  }
  if ("r" %in% supplied && (args$r < 0 || args$r >= 1)) {
    cli::cli_abort("{.arg r} must be in [0, 1).")
  }
  if ("prop_bar" %in% supplied && is.complex(args$prop_bar)) {
    cli::cli_abort("{.arg prop_bar} must contain real-valued proportions.")
  }
  enum_values <- list(
    ci_method = c("precision", "ci_width_power"),
    var_method = c("binormal", "exponential", "conservative"),
    precision_type = c("absolute", "relative"),
    method = c("asymptotic", "exact"),
    lr_type = c("positive", "negative"),
    optimizer = c("optimal", "minimax"),
    alternative = c("one.sided", "two.sided"),
    pairing = c("within_subject", "matched_subjects")
  )
  for (arg in intersect(supplied, names(enum_values))) {
    args[[arg]] <- rlang::arg_match0(
      args[[arg]],
      enum_values[[arg]],
      arg_nm = arg
    )
  }
  if (
    "prevalence" %in% supplied && (args$prevalence <= 0 || args$prevalence > 1)
  ) {
    cli::cli_abort("{.arg prevalence} must be in (0, 1].")
  }
  if ("dropout" %in% supplied && (args$dropout < 0 || args$dropout >= 1)) {
    cli::cli_abort("{.arg dropout} must be in [0, 1).")
  }

  args
}
