# Design argument validation

#' Validate design-specific arguments
#'
#' Checks that every required argument for the chosen design keyword is
#' present and aborts with a structured error naming the missing parameters
#' (e.g. twoMeans requires mean1, mean2, sd).
#'
#' @param design Study design keyword (legacy dispatch name, e.g.
#'   "twoMeans", "cohortProportion", "simonTwoStage")
#' @param args Named list of arguments to validate
#' @return Validated arguments list (invisible)
#' @keywords internal
#' @examples
#' sampleSizeCalc:::validate_design_args(
#'   "twoMeans", list(mean1 = 10, mean2 = 12, sd = 3)
#' )
#' # Error: missing mean2 and sd
#' try(sampleSizeCalc:::validate_design_args("twoMeans", list(mean1 = 10)))
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
    singleCorrelation = c("r", "epsilon"),
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
    steppedWedgeMean = c("theta", "tau2", "sigma2_ind", "m", "n_clusters", "clusters_per_step"),
    steppedWedgeProportion = c("theta", "tau2", "sigma2_ind", "m", "n_clusters", "clusters_per_step"),
    predictiveRileyBinary = c("prev", "n_parameters", "r2_cs"),
    predictiveRileyTimetoevent = c("rate", "timepoint", "precision_delta")
  )

  required <- required_args[[design]]
  if (is.null(required)) {
    return(args)
  }

  # Special case: singleCorrelation accepts either epsilon or precision
  if (design == "singleCorrelation") {
    if (!"r" %in% names(args) || (!"epsilon" %in% names(args) && !"precision" %in% names(args))) {
      cli::cli_abort(c(
        "{.fn sample_size_calculator} with design {.val {design}} requires missing arguments:",
        "x" = "{.arg r} and either {.arg epsilon} (relative precision) or {.arg precision} (CI half-width).",
        "i" = "See {.fn ?sample_size_calculator} for required arguments."
      ))
    }
    return(args)
  }

  missing <- setdiff(required, names(args))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "{.fn sample_size_calculator} with design {.val {design}} requires missing arguments:",
      "x" = "{.arg {paste(missing, collapse = ', ')}}",
      "i" = "See {.fn ?sample_size_calculator} for required arguments."
    ))
  }

  args
}
