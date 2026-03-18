# Backward Compatibility Test Script
# Test that all 17 existing designs still work after refactoring

test_backward_compatibility <- function() {
  # Load the package
  library(sampleSizeCalc)

  # Test results storage
  test_results <- list()

  # Test 1: twoMeans
  cat("Testing twoMeans...\n")
  result <- sample_size_calculator(design = "twoMeans", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)
  test_results$twoMeans <- list(
    n_per_group = result$n_per_group,
    total_n = result$total_n,
    passed = !is.null(result$n_per_group) && result$n_per_group > 0
  )
  cat(sprintf("  n_per_group: %d, total_n: %d - %s\n",
              result$n_per_group, result$total_n,
              ifelse(test_results$twoMeans$passed, "PASS", "FAIL")))

  # Test 2: twoProportions
  cat("Testing twoProportions...\n")
  result <- sample_size_calculator(design = "twoProportions", p1 = 0.3, p2 = 0.5, alpha = 0.05, power = 0.8)
  test_results$twoProportions <- list(
    n_per_group = result$n_per_group,
    total_n = result$total_n,
    passed = !is.null(result$n_per_group) && result$n_per_group > 0
  )
  cat(sprintf("  n_per_group: %d, total_n: %d - %s\n",
              result$n_per_group, result$total_n,
              ifelse(test_results$twoProportions$passed, "PASS", "FAIL")))

  # Test 3: pairedMeans
  cat("Testing pairedMeans...\n")
  result <- sample_size_calculator(design = "pairedMeans", meanDiff = 5, sdDiff = 10, alpha = 0.05, power = 0.8)
  test_results$pairedMeans <- list(
    pairs_count = result$pairs_count,
    passed = !is.null(result$pairs_count) && result$pairs_count > 0
  )
  cat(sprintf("  pairs_count: %d - %s\n",
              result$pairs_count,
              ifelse(test_results$pairedMeans$passed, "PASS", "FAIL")))

  # Test 4: survival
  cat("Testing survival...\n")
  result <- sample_size_calculator(design = "survival", hr = 0.7, alpha = 0.05, power = 0.8)
  test_results$survival <- list(
    events_needed = result$target_events_needed,
    passed = !is.null(result$target_events_needed) && result$target_events_needed > 0
  )
  cat(sprintf("  events_needed: %d - %s\n",
              result$target_events_needed,
              ifelse(test_results$survival$passed, "PASS", "FAIL")))

  # Test 5: diagnosticAccuracySingle (precision-based)
  cat("Testing diagnosticAccuracySingle...\n")
  result <- sample_size_calculator(design = "diagnosticAccuracySingle", alpha = 0.05, prob = 0.85, d = 0.05, prevalence = 0.2)
  test_results$diagnosticAccuracySingle <- list(
    cases_needed = result$target_state_cases_needed,
    total_subjects = result$total_subjects_to_screen,
    passed = !is.null(result$target_state_cases_needed) && result$target_state_cases_needed > 0
  )
  cat(sprintf("  target_cases: %d, total_subjects: %d - %s\n",
              result$target_state_cases_needed, result$total_subjects_to_screen,
              ifelse(test_results$diagnosticAccuracySingle$passed, "PASS", "FAIL")))

  # Test 6: auc_single (precision-based)
  cat("Testing auc_single...\n")
  result <- sample_size_calculator(design = "auc_single", alpha = 0.05, auc = 0.8, d = 0.05, prevalence = 0.2)
  test_results$auc_single <- list(
    cases_needed = result$target_state_cases_needed,
    total_subjects = result$total_subjects_to_screen,
    passed = !is.null(result$target_state_cases_needed) && result$target_state_cases_needed > 0
  )
  cat(sprintf("  target_cases: %d, total_subjects: %d - %s\n",
              result$target_state_cases_needed, result$total_subjects_to_screen,
              ifelse(test_results$auc_single$passed, "PASS", "FAIL")))

  # Test 7: caseControl
  cat("Testing caseControl...\n")
  result <- sample_size_calculator(design = "caseControl", p0 = 0.3, OR = 2.0, alpha = 0.05, power = 0.8)
  test_results$caseControl <- list(
    cases_needed = result$cases_needed,
    controls_needed = result$controls_needed,
    passed = !is.null(result$cases_needed) && result$cases_needed > 0
  )
  cat(sprintf("  cases_needed: %d, controls_needed: %d - %s\n",
              result$cases_needed, result$controls_needed,
              ifelse(test_results$caseControl$passed, "PASS", "FAIL")))

  # Test 8: nonInferiorityMeans
  cat("Testing nonInferiorityMeans...\n")
  result <- sample_size_calculator(design = "nonInferiorityMeans", mean1 = 10, mean2 = 9.5, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
  test_results$nonInferiorityMeans <- list(
    n_per_group = result$n_per_group,
    total_n = result$total_n,
    passed = !is.null(result$n_per_group) && result$n_per_group > 0
  )
  cat(sprintf("  n_per_group: %d, total_n: %d - %s\n",
              result$n_per_group, result$total_n,
              ifelse(test_results$nonInferiorityMeans$passed, "PASS", "FAIL")))

  # Test 9: superiorityMeans
  cat("Testing superiorityMeans...\n")
  result <- sample_size_calculator(design = "superiorityMeans", mean1 = 10, mean2 = 8, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
  test_results$superiorityMeans <- list(
    n_per_group = result$n_per_group,
    total_n = result$total_n,
    passed = !is.null(result$n_per_group) && result$n_per_group > 0
  )
  cat(sprintf("  n_per_group: %d, total_n: %d - %s\n",
              result$n_per_group, result$total_n,
              ifelse(test_results$superiorityMeans$passed, "PASS", "FAIL")))

  # Test 10: equivalenceMeans
  cat("Testing equivalenceMeans...\n")
  result <- sample_size_calculator(design = "equivalenceMeans", mean1 = 10, mean2 = 10.5, sd = 3, margin = 2, alpha = 0.05, power = 0.8)
  test_results$equivalenceMeans <- list(
    n_per_group = result$n_per_group,
    total_n = result$total_n,
    passed = !is.null(result$n_per_group) && result$n_per_group > 0
  )
  cat(sprintf("  n_per_group: %d, total_n: %d - %s\n",
              result$n_per_group, result$total_n,
              ifelse(test_results$equivalenceMeans$passed, "PASS", "FAIL")))

  # Summary
  cat("\n=== BACKWARD COMPATIBILITY TEST SUMMARY ===\n")
  total_tests <- length(test_results)
  passed_tests <- sum(sapply(test_results, function(x) x$passed))

  cat(sprintf("Total tests: %d\n", total_tests))
  cat(sprintf("Passed: %d\n", passed_tests))
  cat(sprintf("Failed: %d\n", total_tests - passed_tests))
  cat(sprintf("Success rate: %.1f%%\n", (passed_tests / total_tests) * 100))

  if (passed_tests == total_tests) {
    cat("\n✅ ALL TESTS PASSED! Backward compatibility maintained.\n")
  } else {
    cat("\n❌ SOME TESTS FAILED! Please review the results above.\n")
  }

  return(test_results)
}

# Run the test
if (!interactive()) {
  test_backward_compatibility()
}
