# Sample Size Calculator for Clinical Research (sampleSizeCalc)

# Validation helpers

validate_alpha <- function(alpha) {
  if (!is.numeric(alpha) || length(alpha) != 1) {
    cli::cli_abort(c(
      "{.arg alpha} must be a single numeric value.",
      "x" = "You provided {.cls {class(alpha)}} of length {length(alpha)}."
    ))
  }
  if (alpha <= 0 || alpha >= 1) {
    cli::cli_abort(c(
      "{.arg alpha} must be between 0 and 1, not {.val {alpha}}.",
      "i" = "Typical values are 0.05 or 0.01."
    ))
  }
  alpha
}

validate_power <- function(power) {
  if (!is.numeric(power) || length(power) != 1) {
    cli::cli_abort(c(
      "{.arg power} must be a single numeric value.",
      "x" = "You provided {.cls {class(power)}} of length {length(power)}."
    ))
  }
  if (power <= 0 || power >= 1) {
    cli::cli_abort(c(
      "{.arg power} must be between 0 and 1, not {.val {power}}.",
      "i" = "Typical values are 0.8, 0.9, or 0.95."
    ))
  }
  power
}

validate_design_args <- function(design, args) {
  required_args <- list(
    twoMeans = c("mean1", "mean2", "sd"),
    twoProportions = c("p1", "p2"),
    pairedMeans = c("meanDiff", "sdDiff"),
    survival = c("hr"),
    nonInferiorityMeans = c("mean1", "mean2", "sd", "margin"),
    superiorityMeans = c("mean1", "mean2", "sd", "margin"),
    equivalenceMeans = c("mean1", "mean2", "sd", "margin"),
    diagnosticAccuracySingle = c("prob", "d"),
    caseControl = c("p0", "OR"),
    superiorityProportions = c("p1", "p2", "margin"),
    diagnosticSuperioritySingle = c("prob", "p0"),
    diagnosticComparisonTwo = c("p1", "p2", "paired"),
    likelihoodRatioTest = c("sens", "spec"),
    auc_single = c("auc", "d"),
    aucSuperiority = c("auc", "auc0"),
    aucComparison = c("auc1", "auc2", "r"),
    equivalenceProportions = c("p1", "p2", "margin")
  )
  
  required <- required_args[[design]]
  if (is.null(required)) return(args)
  
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

# Main calculator

#' Sample size calculator for clinical study designs
#'
#' Computes sample size (or events) for two-group or single-group designs:
#' continuous outcomes, proportions, survival (log-rank), diagnostic accuracy,
#' case-control, AUC comparisons, non-inferiority/superiority/equivalence.
#' Uses parameter validation and unified S3 result objects.
#'
#' @param design Study design type (see list in usage).
#' @param alpha Type I error (default 0.05).
#' @param power Target power (default 0.8).
#' @param ... Design-specific arguments (e.g. mean1, mean2, sd for twoMeans).
#'
#' @return Object of class \code{sample_size_result} with \code{print}, \code{summary}, \code{plot} methods.
#'
#' @importFrom stats power.t.test power.prop.test qnorm
#' @export
#'
#' @examples
#' sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
#' sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)
sample_size_calculator <- function(
    design = c("twoMeans", "twoProportions", "pairedMeans", 
               "survival", "nonInferiorityMeans", "superiorityMeans",
               "equivalenceMeans", "diagnosticAccuracySingle", 
               "caseControl", "superiorityProportions",
               "diagnosticSuperioritySingle", "diagnosticComparisonTwo",
               "likelihoodRatioTest", "auc_single", "aucSuperiority",
               "aucComparison", "equivalenceProportions"),
    alpha = 0.05,
    power = 0.8,
    ...
) {
  design <- rlang::arg_match(design)
  alpha <- validate_alpha(alpha)
  power <- validate_power(power)
  
  args <- list(...)
  args <- validate_design_args(design, args)
  
  calcResult <- switch(design,
    "twoMeans" = {
      result <- power.t.test(
        n = NULL,
        delta = abs(args$mean1 - args$mean2),
        sd = args$sd,
        sig.level = alpha,
        power = power,
        type = "two.sample",
        alternative = "two.sided"
      )
      list(
        design_type = "Two independent samples, mean comparison",
        n_per_group = ceiling(result$n),
        total_n = ceiling(result$n) * 2,
        parameters = list(
          mean1 = args$mean1,
          mean2 = args$mean2,
          sd = args$sd,
          alpha = alpha,
          power = power
        ),
        formula = "n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2",
        formula_latex = "$$n = 2\\left(\\frac{Z_{\\alpha/2} + Z_{\\beta}}{\\delta}\\right)^2 = 2\\left(\\frac{(Z_{\\alpha/2} + Z_{\\beta}) \\cdot \\sigma}{\\mu_1 - \\mu_2}\\right)^2$$",
        reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
      )
    },
    
    "auc_single" = {
      A <- args$auc
      Q1 <- A / (2 - A)
      Q2 <- (2 * A^2) / (1 + A)
      pDis <- if (is.null(args$prevalence)) 1 else args$prevalence
      K <- (1 - pDis) / pDis
      zAlphaHalf <- qnorm(1 - alpha / 2)
      V_factor <- (A*(1-A) + (1/K)*(Q1 - A^2) + (1)*(Q2 - A^2))
      nCases <- (zAlphaHalf / args$d)^2 * V_factor
      nSubjects <- nCases / pDis
      list(
        design_type = "Single-group AUC CI precision",
        target_state_cases_needed = ceiling(nCases),
        total_subjects_to_screen = ceiling(nSubjects),
        parameters = list(
          auc = A,
          precision = args$d,
          prevalence = pDis,
          alpha = alpha
        ),
        formula = "N_cases = (Z_1-a/2 / d)^2 * Var(AUC)",
        formula_latex = "$$n_{cases} = \\left(\\frac{Z_{1-\\alpha/2}}{d}\\right)^2 \\cdot Var(AUC)$$",
        reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204."
      )
    },
    
    "twoProportions" = {
      result <- power.prop.test(
        n = NULL,
        p1 = args$p1,
        p2 = args$p2,
        sig.level = alpha,
        power = power,
        alternative = "two.sided"
      )
      list(
        design_type = "Two independent proportions",
        n_per_group = ceiling(result$n),
        total_n = ceiling(result$n) * 2,
        parameters = list(
          p1 = args$p1,
          p2 = args$p2,
          alpha = alpha,
          power = power
        ),
        formula = "n = (Z_a/2 * sqrt(2*p_bar*(1-p_bar)) + Z_b * sqrt(p1*(1-p1)+p2*(1-p2)))^2 / (p1-p2)^2",
        formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sqrt{2\\bar{p}(1-\\bar{p})} + Z_{\\beta}\\sqrt{p_1(1-p_1) + p_2(1-p_2)}\\right]^2}{(p_1 - p_2)^2}$$",
        reference = "Primary: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). *Statistical methods for rates and proportions* (3rd ed.). Wiley.\n\nSimplified formula: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-486.\n\nAlternative: Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346."
      )
    },
    
    "pairedMeans" = {
      result <- power.t.test(
        n = NULL,
        delta = abs(args$meanDiff),
        sd = args$sdDiff,
        sig.level = alpha,
        power = power,
        type = "paired",
        alternative = "two.sided"
      )
      list(
        design_type = "Paired means",
        pairs_count = ceiling(result$n),
        total_individuals = ceiling(result$n) * 2,
        parameters = list(
          mean_diff = args$meanDiff,
          sd_diff = args$sdDiff,
          alpha = alpha,
          power = power
        ),
        formula = "n = ((Z_a/2 + Z_b) * sd_diff / mean_diff)^2",
        formula_latex = "$$n = \\left(\\frac{(Z_{\\alpha/2} + Z_{\\beta}) \\cdot \\sigma_d}{\\mu_d}\\right)^2$$",
        reference = "Rosner, B. (2015). *Fundamentals of biostatistics* (8th ed.). Cengage Learning."
      )
    },
    
    "survival" = {
      hr <- args$hr
      pE <- if (is.null(args$pE)) 0.5 else args$pE
      zAlpha <- qnorm(1 - alpha / 2)
      zBeta <- qnorm(power)
      totalEventsNeeded <- ((zAlpha + zBeta)^2) / ((pE * (1 - pE)) * (log(hr)^2))
      list(
        design_type = "Survival (log-rank)",
        target_events_needed = ceiling(totalEventsNeeded),
        parameters = list(
          hazard_ratio = hr,
          allocation_ratio = pE,
          alpha = alpha,
          power = power
        ),
        formula = "E = (Z_a/2 + Z_b)^2 / (pE*(1-pE)*log(HR)^2)",
        formula_latex = "$$E = \\frac{(Z_{\\alpha/2} + Z_{\\beta})^2}{p_E(1-p_E)[\\ln(HR)]^2}$$",
        reference = "Primary: Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. Biometrics, 39(2), 499-503.\n\nExtensions:\n- Hsieh, F. Y., & Lavori, P. W. (2000). Sample-size calculations for the Cox proportional hazards regression model with nonbinary covariates. Controlled Clinical Trials, 21(6), 552-560.\n- Rubinstein, L. V., Gail, M. H., & Santner, T. J. (1982). Planning the duration of a comparative clinical trial with loss to follow-up and a period of continued observation. Biometrics, 37(4), 673-682."
      )
    },
    
    "nonInferiorityMeans" = {
      zAlpha <- qnorm(1 - alpha)
      zBeta <- qnorm(power)
      deltaE <- args$mean1 - args$mean2 + args$margin
      if (deltaE <= 0) {
        cli::cli_abort(c(
          "Non-inferiority margin not met.",
          "x" = "mean1 - mean2 + margin = {.val {deltaE}} <= 0",
          "i" = "The effect size must be positive for non-inferiority."
        ))
      }
      nPerGroup <- 2 * (zAlpha + zBeta)^2 * (args$sd^2) / (deltaE^2)
      list(
        design_type = "Non-inferiority (means)",
        n_per_group = ceiling(nPerGroup),
        total_n = ceiling(nPerGroup) * 2,
        parameters = list(
          mean1 = args$mean1,
          mean2 = args$mean2,
          sd = args$sd,
          margin = args$margin,
          alpha = alpha,
          power = power
        ),
        formula = "n = 2*(Z_a+Z_b)^2*sd^2/(mean1-mean2+margin)^2",
        formula_latex = "$$n = 2\\left(\\frac{(Z_{\\alpha} + Z_{\\beta})\\sigma}{\\mu_1 - \\mu_2 + \\Delta}\\right)^2$$",
        reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
      )
    },
    
    "diagnosticAccuracySingle" = {
      p_val <- args[["prob"]]
      d_val <- args[["d"]]
      prev_val <- if (is.null(args[["prevalence"]])) 1 else args[["prevalence"]]
      zAlphaHalf <- qnorm(1 - alpha / 2)
      nTargetCases <- (zAlphaHalf^2 * p_val * (1 - p_val)) / (d_val^2)
      list(
        design_type = "Diagnostic accuracy (single)",
        target_state_cases_needed = ceiling(nTargetCases),
        total_subjects_to_screen = ceiling(nTargetCases / prev_val),
        parameters = list(
          prob = p_val,
          precision = d_val,
          prevalence = prev_val,
          alpha = alpha
        ),
        formula = "N_cases = (Z_1-a/2)^2 * P*(1-P)/d^2",
        formula_latex = "$$n_{{{cases}}} = \\frac{Z_{1-\\alpha/2}^2 \\cdot p(1-p)}{d^2}$$",
        reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\\n\\nReview: Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204."
      )
    },
    
    "diagnosticSuperioritySingle" = {
      p_val <- args[["prob"]]
      p0_val <- args[["p0"]]
      prev_val <- if (is.null(args[["prevalence"]])) 1 else args[["prevalence"]]
      zAlpha <- qnorm(1 - alpha)
      zBeta <- qnorm(power)
      nTargetCases <- ((zAlpha * sqrt(p0_val*(1-p0_val)) + zBeta * sqrt(p_val*(1-p_val))) / (p_val - p0_val))^2
      list(
        design_type = "Diagnostic superiority (single)",
        target_state_cases_needed = ceiling(nTargetCases),
        total_subjects_to_screen = ceiling(nTargetCases / prev_val),
        parameters = list(
          prob = p_val,
          p0 = p0_val,
          prevalence = prev_val,
          alpha = alpha,
          power = power
        ),
        formula = "N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 / (P-P0)^2",
        formula_latex = "$$n = \\frac{\\left[Z_{\\alpha}\\sqrt{p_0(1-p_0)} + Z_{\\beta}\\sqrt{p(1-p)}\\right]^2}{(p - p_0)^2}$$",
        reference = "Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
      )
    },
    
    "diagnosticComparisonTwo" = {
      p1_val <- args[["p1"]]
      p2_val <- args[["p2"]]
      prev_val <- if (is.null(args[["prevalence"]])) 1 else args[["prevalence"]]
      paired_val <- args[["paired"]]
      psi_val <- args[["psi"]]
      
      zAlphaHalf <- qnorm(1 - alpha / 2)
      zBeta <- qnorm(power)
      
      if (paired_val) {
        if (is.null(psi_val)) {
          cli::cli_abort(c(
            "Paired comparison requires {.arg psi} parameter.",
            "i" = "psi represents discordant pair proportion."
          ))
        }
        nTargetCases <- ((zAlphaHalf * psi_val + zBeta * sqrt(psi_val^2 - (p1_val-p2_val)^2/4)) / (p1_val-p2_val))^2
      } else {
        pBar <- (p1_val + p2_val) / 2
        nTargetCases <- ((zAlphaHalf * sqrt(2*pBar*(1-pBar)) + zBeta * sqrt(p1_val*(1-p1_val) + p2_val*(1-p2_val))) / (p1_val-p2_val))^2
      }
      
      list(
        design_type = "Two diagnostic measures",
        target_state_cases_needed = ceiling(nTargetCases),
        total_subjects_to_screen = ceiling(nTargetCases/prev_val * ifelse(paired_val, 1, 2)),
        parameters = list(
          p1 = p1_val,
          p2 = p2_val,
          prevalence = prev_val,
          paired = paired_val,
          psi = psi_val,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n = \\frac{\\left[Z_{\\alpha/2}\\sigma_{paired} + Z_{\\beta}\\sqrt{\\sigma_{paired}^2 - (p_1-p_2)^2/4}\\right]^2}{(p_1-p_2)^2}$$",
        reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\\n\\nReview: Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204."
      )
    },
    
    "likelihoodRatioTest" = {
      precision <- if (is.null(args$precision)) 0.1 else args$precision
      
      zAlphaHalf <- qnorm(1 - alpha / 2)
      pDis <- if (is.null(args$prevalence)) 1 else args$prevalence
      pNon <- 1 - pDis
      
      minCases <- max(
        (zAlphaHalf^2 * args$sens*(1-args$sens))/(precision)^2,
        (zAlphaHalf^2 * args$spec*(1-args$spec))/(precision)^2 * (pDis/pNon)
      )
      
      list(
        design_type = "Likelihood ratio (min sample size)",
        recommended_cases = ceiling(minCases),
        total_subjects_to_screen = ceiling(minCases/pDis),
        parameters = list(
          sensitivity = args$sens,
          specificity = args$spec,
          prevalence = pDis,
          precision = precision,
          alpha = alpha
        ),
        formula_latex = sprintf("$$n_{cases} = \\max\\left\\{\\frac{Z_{1-\\alpha/2}^2 \\cdot Se(1-Se)}{%.2f^2}, \\frac{Z_{1-\\alpha/2}^2 \\cdot Sp(1-Sp)}{%.2f^2} \\cdot \\frac{P}{1-P}\\right\\}$$", precision, precision),
        reference = "Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
      )
    },
    
    "aucSuperiority" = {
      A <- args$auc
      A0 <- args$auc0
      pDis <- if (is.null(args$prevalence)) 1 else args$prevalence
      K <- (1-pDis)/pDis
      Q1 <- A/(2-A)
      Q2 <- (2*A^2)/(1+A)
      Q1_0 <- A0/(2-A0)
      Q2_0 <- (2*A0^2)/(1+A0)
      V_A <- (A*(1-A) + (1/K)*(Q1-A^2) + Q2-A^2)
      V_A0 <- (A0*(1-A0) + (1/K)*(Q1_0-A0^2) + Q2_0-A0^2)
      
      zAlpha <- qnorm(1-alpha)
      zBeta <- qnorm(power)
      nCases <- ((zAlpha*sqrt(V_A0) + zBeta*sqrt(V_A))/(A-A0))^2
      
      list(
        design_type = "AUC superiority (single)",
        target_state_cases_needed = ceiling(nCases),
        total_subjects_to_screen = ceiling(nCases/pDis),
        parameters = list(
          auc = A,
          auc_null = A0,
          prevalence = pDis,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n_{cases} = \\frac{\\left(Z_{\\alpha}\\sqrt{V(AUC_0)} + Z_{\\beta}\\sqrt{V(AUC)}\\right)^2}{(AUC - AUC_0)^2}$$",
        reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.\n\nReview: Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204."
      )
    },
    
    "aucComparison" = {
      A1 <- args$auc1
      A2 <- args$auc2
      r <- args$r
      pDis <- if (is.null(args$prevalence)) 1 else args$prevalence
      K <- (1-pDis)/pDis
      A_avg <- (A1+A2)/2
      Q1_avg <- A_avg/(2-A_avg)
      Q2_avg <- (2*A_avg^2)/(1+A_avg)
      V_A <- (A_avg*(1-A_avg) + (1/K)*(Q1_avg-A_avg^2) + Q2_avg-A_avg^2)
      
      zAlphaHalf <- qnorm(1-alpha/2)
      zBeta <- qnorm(power)
      nCases <- (2*(zAlphaHalf+zBeta)^2 * V_A * (1-r)) / (A1-A2)^2
      
      list(
        design_type = "AUC comparison (two tests)",
        target_state_cases_needed = ceiling(nCases),
        total_subjects_to_screen = ceiling(nCases/pDis),
        parameters = list(
          auc1 = A1,
          auc2 = A2,
          correlation = r,
          prevalence = pDis,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n_{cases} = \\frac{2(Z_{\\alpha/2} + Z_{\\beta})^2 \\cdot V(AUC) \\cdot (1-r)}{(AUC_1 - AUC_2)^2}$$",
        reference = "Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013"
      )
    },
    
    "caseControl" = {
      m <- if (is.null(args$m)) 1 else args$m
      p1 <- (args$OR * args$p0) / (1 - args$p0 + args$OR * args$p0)
      pBar <- (p1 + m * args$p0) / (1+m)
      zAlphaHalf <- qnorm(1-alpha/2)
      zBeta <- qnorm(power)
      nCases <- ((zAlphaHalf*sqrt((1+1/m)*pBar*(1-pBar)) + zBeta*sqrt(p1*(1-p1) + args$p0*(1-args$p0)/m))/(p1-args$p0))^2
      
      list(
        design_type = "Case-control",
        cases_needed = ceiling(nCases),
        controls_needed = ceiling(nCases*m),
        total_subjects = ceiling(nCases)*(1+m),
        parameters = list(
          p0 = args$p0,
          odds_ratio = args$OR,
          matching_ratio = m,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n_{cases} = \\frac{\\left[Z_{\\alpha/2}\\sqrt{(1+1/m)\\bar{p}(1-\\bar{p})} + Z_{\\beta}\\sqrt{p_1(1-p_1) + p_0(1-p_0)/m}\\right]^2}{(p_1-p_0)^2}$$",
        reference = "Primary: Schlesselman, J. J. (1982). Case-control studies: Design, conduct, analysis. Oxford University Press.\n\nIARC Classic: Breslow, N. E., & Day, N. E. (1980). Statistical methods in cancer research: Volume 1 - The analysis of case-control studies. IARC Scientific Publications No. 32.\n\nAlternative: Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168."
      )
    },
    
    "equivalenceMeans" = {
      zAlpha <- qnorm(1-alpha)
      zBetaHalf <- qnorm(1-(1-power)/2)
      diff <- abs(args$mean1 - args$mean2)
      if (args$margin <= diff) {
        cli::cli_abort(c(
          "Equivalence margin must be greater than the mean difference.",
          "x" = "margin ({.val {args$margin}}) <= |mean1 - mean2| ({.val {diff}})",
          "i" = "Increase the margin or adjust the means."
        ))
      }
      nPerGroup <- 2*(zAlpha+zBetaHalf)^2*(args$sd^2) / ((args$margin-diff)^2)
      
      list(
        design_type = "Equivalence (means)",
        n_per_group = ceiling(nPerGroup),
        total_n = ceiling(nPerGroup)*2,
        parameters = list(
          mean1 = args$mean1,
          mean2 = args$mean2,
          sd = args$sd,
          margin = args$margin,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n = 2\\left(\\frac{(Z_{\\alpha} + Z_{\\beta/2})\\sigma}{\\Delta - |\\mu_1 - \\mu_2|}\\right)^2$$",
        reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
      )
    },
    
    "superiorityMeans" = {
      zAlpha <- qnorm(1-alpha)
      zBeta <- qnorm(power)
      deltaE <- args$mean1 - args$mean2 - args$margin
      if (deltaE <= 0) {
        cli::cli_abort(c(
          "Superiority margin not met.",
          "x" = "mean1 - mean2 - margin = {.val {deltaE}} <= 0",
          "i" = "The effect size must be positive for superiority."
        ))
      }
      nPerGroup <- 2*(zAlpha+zBeta)^2*(args$sd^2) / (deltaE^2)
      
      list(
        design_type = "Superiority (means)",
        n_per_group = ceiling(nPerGroup),
        total_n = ceiling(nPerGroup)*2,
        parameters = list(
          mean1 = args$mean1,
          mean2 = args$mean2,
          sd = args$sd,
          margin = args$margin,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n = 2\\left(\\frac{(Z_{\\alpha} + Z_{\\beta})\\sigma}{\\mu_1 - \\mu_2 - \\Delta}\\right)^2$$",
        reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
      )
    },
    
    "equivalenceProportions" = {
      p1 <- args$p1
      p2 <- args$p2
      margin <- args$margin
      zAlpha <- qnorm(1-alpha)
      zBetaHalf <- qnorm(1-(1-power)/2)
      diff <- abs(p1-p2)
      if (margin <= diff) {
        cli::cli_abort(c(
          "Equivalence margin must be greater than the proportion difference.",
          "x" = "margin ({.val {margin}}) <= |p1 - p2| ({.val {diff}})",
          "i" = "Increase the margin or adjust the proportions."
        ))
      }
      nPerGroup <- (zAlpha+zBetaHalf)^2 * (p1*(1-p1)+p2*(1-p2)) / ((margin-diff)^2)
      
      list(
        design_type = "Equivalence (proportions)",
        n_per_group = ceiling(nPerGroup),
        total_n = ceiling(nPerGroup)*2,
        parameters = list(
          p1 = p1,
          p2 = p2,
          margin = margin,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n = \\frac{(Z_{\\alpha} + Z_{\\beta/2})^2[p_1(1-p_1) + p_2(1-p_2)]}{(\\Delta - |p_1-p_2|)^2}$$",
        reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
      )
    },
    
    "superiorityProportions" = {
      p1 <- args$p1
      p2 <- args$p2
      margin <- args$margin
      zAlpha <- qnorm(1-alpha)
      zBeta <- qnorm(power)
      deltaE <- p1-p2-margin
      if (deltaE <= 0) {
        cli::cli_abort(c(
          "Superiority margin not met.",
          "x" = "p1 - p2 - margin = {.val {deltaE}} <= 0",
          "i" = "The effect size must be positive for superiority."
        ))
      }
      nPerGroup <- (zAlpha+zBeta)^2 * (p1*(1-p1)+p2*(1-p2)) / (deltaE^2)
      
      list(
        design_type = "Superiority (proportions)",
        n_per_group = ceiling(nPerGroup),
        total_n = ceiling(nPerGroup)*2,
        parameters = list(
          p1 = p1,
          p2 = p2,
          margin = margin,
          alpha = alpha,
          power = power
        ),
        formula_latex = "$$n = \\frac{(Z_{\\alpha} + Z_{\\beta})^2[p_1(1-p_1) + p_2(1-p_2)]}{(p_1 - p_2 - \\Delta)^2}$$",
        reference = "Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press."
      )
    }
  )
  
  calcResult$design <- design
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

# S3: print

#' @export
print.sample_size_result <- function(x, ...) {
  cli::cli_rule()
  cli::cli_alert_success("Sample Size Calculation Results")
  cli::cli_li("Design type: {.val {x$design_type}}")
  
  if (!is.null(x$n_per_group)) {
    cli::cli_li("Sample size per group: {.val {x$n_per_group}}")
  }
  if (!is.null(x$total_n)) {
    cli::cli_li("Total sample size: {.val {x$total_n}}")
  }
  if (!is.null(x$pairs_count)) {
    cli::cli_li("Pairs needed: {.val {x$pairs_count}}")
  }
  if (!is.null(x$target_events_needed)) {
    cli::cli_li("Target events needed: {.val {x$target_events_needed}}")
  }
  if (!is.null(x$target_state_cases_needed)) {
    cli::cli_li("Target state cases: {.val {x$target_state_cases_needed}}")
  }
  if (!is.null(x$total_subjects_to_screen)) {
    cli::cli_li("Total subjects to screen: {.val {x$total_subjects_to_screen}}")
  }
  if (!is.null(x$cases_needed)) {
    cli::cli_li("Cases needed: {.val {x$cases_needed}}")
    cli::cli_li("Controls needed: {.val {x$controls_needed}}")
  }
  
  cli::cli_rule()
  invisible(x)
}

# S3: summary

#' @export
summary.sample_size_result <- function(object, ...) {
  cli::cli_rule()
  cli::cli_alert_success("Sample Size Calculation Summary")
  cli::cli_rule()
  
  cli::cli_h3("Study Design")
  cli::cli_li("Type: {.val {object$design_type}}")
  
  if (!is.null(object$parameters)) {
    cli::cli_h3("Parameters")
    params <- object$parameters
    for (name in names(params)) {
      cli::cli_li("{.field {name}}: {.val {params[[name]]}}")
    }
  }
  
  cli::cli_h3("Sample Size Results")
  if (!is.null(object$n_per_group)) {
    cli::cli_li("Per group: {.val {object$n_per_group}}")
  }
  if (!is.null(object$total_n)) {
    cli::cli_li("Total: {.val {object$total_n}}")
  }
  if (!is.null(object$pairs_count)) {
    cli::cli_li("Pairs: {.val {object$pairs_count}}")
  }
  if (!is.null(object$target_events_needed)) {
    cli::cli_li("Events needed: {.val {object$target_events_needed}}")
  }
  if (!is.null(object$target_state_cases_needed)) {
    cli::cli_li("Target cases: {.val {object$target_state_cases_needed}}")
  }
  if (!is.null(object$total_subjects_to_screen)) {
    cli::cli_li("Subjects to screen: {.val {object$total_subjects_to_screen}}")
  }
  if (!is.null(object$cases_needed)) {
    cli::cli_li("Cases: {.val {object$cases_needed}}")
    cli::cli_li("Controls: {.val {object$controls_needed}}")
  }
  
  cli::cli_h3("Formula")
  if (!is.null(object$formula_latex)) {
    cat(object$formula_latex, "\n")
  }
  
  cli::cli_h3("Reference")
  if (!is.null(object$reference)) {
    cat(object$reference, "\n")
  }
  
  cli::cli_rule()
  invisible(object)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

# S3: plot

#' Plot sample size calculation result
#'
#' Draw power curve (sample size vs power) or sample size vs effect size ratio.
#' Requires packages \pkg{ggplot2} and \pkg{scales}.
#'
#' @param x Object of class \code{sample_size_result} from \code{\link{sample_size_calculator}}.
#' @param type \code{"power"} for sample size vs power; \code{"sample_size"} for
#'   sample size vs effect size ratio (supported for twoMeans and twoProportions).
#' @param ... Passed to downstream methods (currently unused).
#' @return Invisibly returns \code{x}. A plot is drawn.
#' @export
plot.sample_size_result <- function(x, type = c("power", "sample_size"), ...) {
  type <- rlang::arg_match(type)
  
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg ggplot2} is required for plotting.",
      "i" = "Please install it with {.code install.packages('ggplot2')}"
    ))
  }
  
  if (!requireNamespace("scales", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg scales} is required for plotting.",
      "i" = "Please install it with {.code install.packages('scales')}"
    ))
  }
  
  if (is.null(x$design) || is.null(x$parameters)) {
    cli::cli_abort(c(
      "Cannot plot: missing required fields in result object.",
      "x" = "Expected {.field design} and {.field parameters} to exist."
    ))
  }
  
  if (type == "power") {
    plot_power_curve(x)
  } else {
    plot_sample_size_comparison(x)
  }
}

plot_power_curve <- function(result) {
  params <- result$parameters
  
  if (is.null(params$alpha)) {
    cli::cli_warn("Cannot plot power curve: alpha parameter missing")
    return(invisible(result))
  }
  
  alpha <- params$alpha
  power_range <- seq(0.5, 0.99, by = 0.01)
  
  varying_args <- params
  varying_args$alpha <- NULL
  varying_args$power <- NULL
  
  sample_sizes <- vapply(power_range, function(p) {
    call_args <- c(list(design = result$design, alpha = alpha, power = p), varying_args)
    res <- tryCatch(do.call(sample_size_calculator, call_args), error = function(e) NULL)
    if (is.null(res)) return(NA_real_)
    if (!is.null(res$n_per_group)) return(as.numeric(res$n_per_group))
    if (!is.null(res$pairs_count)) return(as.numeric(res$pairs_count))
    if (!is.null(res$target_events_needed)) return(as.numeric(res$target_events_needed))
    if (!is.null(res$target_state_cases_needed)) return(as.numeric(res$target_state_cases_needed))
    if (!is.null(res$cases_needed)) return(as.numeric(res$cases_needed))
    NA_real_
  }, numeric(1))
  
  df <- data.frame(power = power_range, sample_size = sample_sizes)
  df <- df[!is.na(df$sample_size), , drop = FALSE]
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = power, y = sample_size)) +
    ggplot2::geom_line(color = "#007BC2", linewidth = 1) +
    ggplot2::geom_point(color = "#007BC2", size = 2) +
    ggplot2::labs(
      title = "Sample Size vs Power",
      subtitle = result$design_type %||% result$design,
      x = "Power (1 - beta)",
      y = "Sample Size"
    ) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 10),
      axis.title = ggplot2::element_text(size = 11),
      panel.grid.minor = ggplot2::element_blank()
    )
  
  print(p)
  invisible(result)
}

plot_sample_size_comparison <- function(result) {
  params <- result$parameters
  alpha <- params$alpha
  current_power <- params$power
  
  if (is.null(alpha) || is.null(current_power)) {
    cli::cli_warn("Cannot plot sample size comparison: alpha/power missing")
    return(invisible(result))
  }
  
  effect_sizes <- NULL
  sample_sizes <- NULL
  
  if (!is.null(params$mean1) && !is.null(params$mean2) && !is.null(params$sd)) {
    mean1 <- params$mean1
    mean2 <- params$mean2
    sd <- params$sd
    baseline_diff <- abs(mean1 - mean2)
    
    effect_ratios <- seq(0.5, 2.0, by = 0.1)
    sample_sizes <- vapply(effect_ratios, function(ratio) {
      new_diff <- baseline_diff * ratio
      res <- tryCatch(sample_size_calculator(
        design = "twoMeans",
        mean1 = mean1,
        mean2 = mean1 + new_diff * sign(mean2 - mean1),
        sd = sd,
        alpha = alpha,
        power = current_power
      ), error = function(e) NULL)
      if (is.null(res) || is.null(res$n_per_group)) return(NA_real_)
      as.numeric(res$n_per_group)
    }, numeric(1))
    effect_sizes <- effect_ratios
  } else if (!is.null(params$p1) && !is.null(params$p2)) {
    p1 <- params$p1
    p2 <- params$p2
    baseline_diff <- abs(p1 - p2)
    
    effect_ratios <- seq(0.5, 2.0, by = 0.1)
    sample_sizes <- vapply(effect_ratios, function(ratio) {
      new_diff <- baseline_diff * ratio
      new_p2 <- p1 + new_diff * sign(p2 - p1)
      if (new_p2 <= 0 || new_p2 >= 1) return(NA_real_)
      res <- tryCatch(sample_size_calculator(
        design = "twoProportions",
        p1 = p1,
        p2 = new_p2,
        alpha = alpha,
        power = current_power
      ), error = function(e) NULL)
      if (is.null(res) || is.null(res$n_per_group)) return(NA_real_)
      as.numeric(res$n_per_group)
    }, numeric(1))
    effect_sizes <- effect_ratios
  } else {
    cli::cli_warn("Sample size comparison plot currently supports twoMeans/twoProportions only")
    return(invisible(result))
  }
  
  df <- data.frame(effect_ratio = effect_sizes, sample_size = sample_sizes)
  df <- df[!is.na(df$sample_size), , drop = FALSE]
  
  p <- ggplot2::ggplot(df, ggplot2::aes(x = effect_ratio, y = sample_size)) +
    ggplot2::geom_line(color = "#28A745", linewidth = 1) +
    ggplot2::geom_point(color = "#28A745", size = 2) +
    ggplot2::geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
    ggplot2::labs(
      title = "Sample Size vs Effect Size Ratio",
      subtitle = result$design_type %||% result$design,
      x = "Effect Size Ratio (relative to baseline)",
      y = "Sample Size per Group"
    ) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 10),
      axis.title = ggplot2::element_text(size = 11),
      panel.grid.minor = ggplot2::element_blank()
    )
  
  print(p)
  invisible(result)
}

