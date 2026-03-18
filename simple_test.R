# Simple backward compatibility test
# Run with: Rscript simple_test.R

library(cli)
library(rlang)
library(stats)

# Source all required files in order
source("R/utils/validate_parameters.R")
source("R/utils/validate_design_args.R")
source("R/diagnostic/diagnostic_accuracy_single.R")
source("R/diagnostic/diagnostic_existing_designs.R")
source("R/diagnostic/auc_calculations.R")
source("R/drug_trials/basic_designs.R")
source("R/drug_trials/means_hypothesis_tests.R")
source("R/drug_trials/proportions_hypothesis_tests.R")
source("R/drug_trials/case_control.R")
source("R/s3_methods/print_sample_size_result.R")
source("R/s3_methods/summary_sample_size_result.R")
source("R/s3_methods/plot_sample_size_result.R")
source("R/sample_size_calculator.R")

cat("=== BACKWARD COMPATIBILITY TEST ===\n\n")

# Test 1: twoMeans
cat("Test 1: twoMeans\n")
result <- sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)
cat(sprintf("  n_per_group: %d, total_n: %d\n", result$n_per_group, result$total_n))

# Test 2: twoProportions
cat("Test 2: twoProportions\n")
result <- sample_size_calculator("twoProportions", p1 = 0.3, p2 = 0.5, alpha = 0.05, power = 0.8)
cat(sprintf("  n_per_group: %d, total_n: %d\n", result$n_per_group, result$total_n))

# Test 3: diagnosticAccuracySingle
cat("Test 3: diagnosticAccuracySingle\n")
result <- sample_size_calculator("diagnosticAccuracySingle", alpha = 0.05, prob = 0.85, d = 0.05, prevalence = 0.2)
cat(sprintf("  target_cases: %d, total_subjects: %d\n", result$target_state_cases_needed, result$total_subjects_to_screen))

# Test 4: auc_single
cat("Test 4: auc_single\n")
result <- sample_size_calculator("auc_single", alpha = 0.05, auc = 0.8, d = 0.05, prevalence = 0.2)
cat(sprintf("  target_cases: %d, total_subjects: %d\n", result$target_state_cases_needed, result$total_subjects_to_screen))

cat("\n✅ All basic tests passed!\n")
