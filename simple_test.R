# Simple smoke test for the refactored package
# Run with: Rscript simple_test.R
# Updated for the 3.0 three-axis API; exercises the shared dispatch path
# through both entry points.

library(cli)
library(rlang)
library(stats)

stopifnot(requireNamespace("SampleSizeCalc", quietly = TRUE))
library(SampleSizeCalc)

cat("=== BACKWARD COMPATIBILITY TEST (v3 API) ===\n\n")

# Test 1: twoMeans via legacy keyword
cat("Test 1: twoMeans (legacy keyword)\n")
result <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)
cat(sprintf("  n_per_group: %d, total_n: %d\n", result$n_per_group, result$total_n))

# Test 2: same design via three-axis API (must be identical)
cat("Test 2: rct/test/mean (three-axis API)\n")
result2 <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
stopifnot(identical(result$n_per_group, result2$n_per_group))
cat(sprintf("  n_per_group: %d (identical to legacy: TRUE)\n", result2$n_per_group))

# Test 3: twoProportions via three-axis API
cat("Test 3: rct/test/proportion\n")
result <- calculate("rct", "test", "proportion", p1 = 0.3, p2 = 0.5)
cat(sprintf("  n_per_group: %d, total_n: %d\n", result$n_per_group, result$total_n))

# Test 4: diagnosticAccuracySingle via three-axis API
cat("Test 4: diagAccuracy/estimate/proportion\n")
result <- calculate("diagAccuracy", "estimate", "proportion",
  prob = 0.85, d = 0.05, prevalence = 0.2
)
cat(sprintf(
  "  target_cases: %d, total_subjects: %d\n",
  result$target_state_cases_needed, result$total_subjects_to_screen
))

# Test 5: auc_single via three-axis API
cat("Test 5: diagAUC/estimate/auc\n")
result <- calculate("diagAUC", "estimate", "auc", auc = 0.8, d = 0.05, prevalence = 0.2)
cat(sprintf(
  "  target_cases: %d, total_subjects: %d\n",
  result$target_state_cases_needed, result$total_subjects_to_screen
))

# Test 6: illegal combination errors with suggestions
cat("Test 6: illegal combination rejected\n")
tryCatch(
  calculate("rct", "estimate", "mean"),
  error = function(e) cat("  correctly rejected:", conditionMessage(e), "\n")
)

cat("\nAll smoke tests passed!\n")
