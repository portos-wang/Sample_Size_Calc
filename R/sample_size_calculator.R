# Legacy entry point: silently compatible shim over calculate().
# The 17 keywords map to the three-axis API as documented in
# docs/DESIGN_MATRIX.md; dispatch_calculation() shares one code path so
# legacy and new calls produce identical results (golden master tests).

#' Sample size calculator for clinical study designs (legacy API)
#'
#' Computes sample size (or events) for two-group or single-group designs:
#' continuous outcomes, proportions, survival (log-rank), diagnostic accuracy,
#' case-control, AUC comparisons, non-inferiority/superiority/equivalence.
#' Uses parameter validation and unified S3 result objects.
#'
#' `sample_size_calculator()` is the legacy single-keyword API retained for
#' backward compatibility. New code should prefer the three-axis
#' [calculate()] entry point; see docs/DESIGN_MATRIX.md for the keyword
#' mapping. Results are identical between the two entry points.
#'
#' @param design Study design keyword. One of:
#'  
#'   | Keyword | Design | Key parameters |
#'   |---|---|---|
#'   | `twoMeans` | two-arm superiority RCT, continuous | `mean1`, `mean2`, `sd` |
#'   | `twoProportions` | two-arm RCT, binary | `p1`, `p2` |
#'   | `pairedMeans` | pre-post / matched pairs, continuous | `meanDiff`, `sdDiff` |
#'   | `survival` | log-rank events | `hr`, `pE` |
#'   | `nonInferiorityMeans` | NI trial, continuous | `mean1`, `mean2`, `sd`, `margin` |
#'   | `superiorityMeans` | superiority, continuous | `mean1`, `mean2`, `sd`, `margin` |
#'   | `equivalenceMeans` | equivalence, continuous | `mean1`, `mean2`, `sd`, `margin` |
#'   | `diagnosticAccuracySingle` | Se/Sp precision | `prob`, `d`, `prevalence` |
#'   | `caseControl` | unmatched case-control | `p0`, `OR`, `m` |
#'   | `superiorityProportions` | superiority, binary | `p1`, `p2`, `margin` |
#'   | `diagnosticSuperioritySingle` | Se vs null | `prob`, `p0`, `prevalence` |
#'   | `diagnosticComparisonTwo` | two tests | `p1`, `p2`, `prevalence`, `paired`, `psi` |
#'   | `likelihoodRatioTest` | LR precision | `sens`, `spec`, `prevalence`, `precision` |
#'   | `auc_single` | AUC CI precision | `auc`, `d`, `prevalence` |
#'   | `aucSuperiority` | AUC vs null | `auc`, `auc0`, `prevalence` |
#'   | `aucComparison` | two AUCs | `auc1`, `auc2`, `r`, `prevalence` |
#'   | `equivalenceProportions` | equivalence, binary | `p1`, `p2`, `margin` |
#'  
#'   New code should prefer the three-axis [calculate()] API.
#' @param alpha Type I error; scalar in (0, 1). Default 0.05 (two-sided
#'   designs). Non-inferiority designs interpret alpha as one-sided (use 0.025
#'   to spend a full two-sided 0.05).
#' @param power Target power; scalar in (0, 1), typically 0.8 or 0.9. Default 0.8.
#' @param ... Design-specific arguments (see the table in `design` and
#'   `?calculate` for domains; e.g. `mean1`, `mean2`, `sd` for twoMeans).
#'   Parameters outside their validated domain abort with a structured
#'   `cli` error naming the offending argument.
#'
#' @return Object of class `sample_size_result` with print, summary, and
#'   plot methods. Default printing includes the plain-text formula
#'   (`formula`), LaTeX source (`formula_latex`), calculation process
#'   (`calculation_steps`, alias `calculation`), and literature references
#'   (`reference`). These fields can also be extracted directly from the
#'   object. See [print.sample_size_result()] and [summary.sample_size_result()].
#'
#' @importFrom stats power.t.test power.prop.test qnorm
#' @export
#'
#' @examples
#' # Antihypertensive RCT: 10 vs 12 mmHg SBP reduction, SD 3 -> 37 per arm
#' sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
#'
#' # NSCLC immunotherapy trial: HR = 0.70, 1:1 allocation -> 247 events
#' sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
#'
#' # H. pylori eradication: quadruple 85% vs triple 70% -> 121 per arm
#' sample_size_calculator("twoProportions", p1 = 0.85, p2 = 0.70)
sample_size_calculator <- function(
  design = c(
    "twoMeans", "twoProportions", "pairedMeans",
    "survival", "nonInferiorityMeans", "superiorityMeans",
    "equivalenceMeans", "diagnosticAccuracySingle",
    "caseControl", "superiorityProportions",
    "diagnosticSuperioritySingle", "diagnosticComparisonTwo",
    "likelihoodRatioTest", "auc_single", "aucSuperiority",
    "aucComparison", "equivalenceProportions"
  ),
  alpha = 0.05,
  power = 0.8,
  ...
) {
  design <- rlang::arg_match(design)
  alpha <- validate_alpha(alpha)
  power <- validate_power(power)

  args <- validate_design_args(design, list(...))
  calcResult <- dispatch_calculation(design, args, alpha, power, path = "legacy")
  calcResult$replay_args <- args

  calcResult$design <- design
  if (is.null(calcResult$calculation) && is.null(calcResult$calculation_steps)) {
    calcResult$calculation <- generate_calculation_steps(calcResult)
    calcResult$calculation_steps <- calcResult$calculation
  }
  structure(calcResult, class = c("sample_size_result", "list"))
}

# Back-compatibility wrapper

#' @describeIn sample_size_calculator Deprecated alias; use \code{sample_size_calculator}.
#' @export
sampleSizeCalculator <- function(design, alpha = 0.05, power = 0.8, ...) {
  cli::cli_warn(c(
    "{.fn sampleSizeCalculator} is deprecated as of version 2.0.0.",
    "i" = "Please use {.fn sample_size_calculator} instead.",
    ">" = "This function will be removed in a future version."
  ))

  sample_size_calculator(design = design, alpha = alpha, power = power, ...)
}
