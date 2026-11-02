
# Golden master data (shared by test-calculate.R); defined in a helper file so
# shuffled test runs always have it available.
golden_cases <- list(
  list(
    old = "twoMeans", new = c("rct", "test", "mean"),
    args = list(mean1 = 10, mean2 = 12, sd = 3)
  ),
  list(
    old = "twoProportions", new = c("rct", "test", "proportion"),
    args = list(p1 = 0.3, p2 = 0.5)
  ),
  list(
    old = "pairedMeans", new = c("paired", "test", "mean"),
    args = list(meanDiff = 5, sdDiff = 10)
  ),
  list(
    old = "survival", new = c("rct", "test", "survival"),
    args = list(hr = 0.7)
  ),
  list(
    old = "nonInferiorityMeans", new = c("rct", "noninferiority", "mean"),
    args = list(mean1 = 10, mean2 = 9.5, sd = 3, margin = 1)
  ),
  list(
    old = "superiorityMeans", new = c("rct", "superiority", "mean"),
    args = list(mean1 = 10, mean2 = 8, sd = 3, margin = 1)
  ),
  list(
    old = "equivalenceMeans", new = c("rct", "equivalence", "mean"),
    args = list(mean1 = 10, mean2 = 10.5, sd = 3, margin = 2)
  ),
  list(
    old = "superiorityProportions", new = c("rct", "superiority", "proportion"),
    args = list(p1 = 0.7, p2 = 0.5, margin = 0.1)
  ),
  list(
    old = "equivalenceProportions", new = c("rct", "equivalence", "proportion"),
    args = list(p1 = 0.5, p2 = 0.52, margin = 0.1)
  ),
  list(
    old = "caseControl", new = c("caseControl", "test", "proportion"),
    args = list(p0 = 0.3, OR = 2.0)
  ),
  list(
    old = "diagnosticAccuracySingle",
    new = c("diagAccuracy", "estimate", "proportion"),
    args = list(prob = 0.85, d = 0.05, prevalence = 0.2)
  ),
  list(
    old = "diagnosticSuperioritySingle",
    new = c("diagAccuracy", "test", "proportion"),
    args = list(prob = 0.9, p0 = 0.8, prevalence = 0.4)
  ),
  list(
    old = "diagnosticComparisonTwo",
    new = c("diagAccuracyCompare", "test", "proportion"),
    args = list(p1 = 0.85, p2 = 0.75, prevalence = 0.3, paired = FALSE)
  ),
  list(
    old = "likelihoodRatioTest",
    new = c("diagLR", "estimate", "lr"),
    args = list(sens = 0.9, spec = 0.8, prevalence = 0.3)
  ),
  list(
    old = "auc_single", new = c("diagAUC", "estimate", "auc"),
    args = list(auc = 0.8, d = 0.05, prevalence = 0.2)
  ),
  list(
    old = "aucSuperiority", new = c("diagAUC", "test", "auc"),
    args = list(auc = 0.85, auc0 = 0.7, prevalence = 0.3)
  ),
  list(
    old = "aucComparison", new = c("diagAUCCompare", "test", "auc"),
    args = list(auc1 = 0.85, auc2 = 0.75, r = 0.5, prevalence = 0.3)
  )
)

# Fields compared between old and new results (axis metadata intentionally
# differs; calculation fields must be identical).
golden_fields <- c(
  "design_type", "n_per_group", "total_n", "pairs_count",
  "total_individuals", "target_events_needed", "target_state_cases_needed",
  "total_subjects_to_screen", "cases_needed", "controls_needed",
  "formula", "formula_latex", "reference"
)

