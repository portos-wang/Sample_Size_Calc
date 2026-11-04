# Package index

## Unified Three-Axis API / 统一三轴入口

Primary entry points supporting 39+ study design combinations (design x
task x outcome) and legacy single-keyword compatibility.

- [`calculate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate.md)
  : Unified sample size calculator (three-axis API)
- [`sample_size_calculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md)
  [`sampleSizeCalculator()`](https://rpackages.portos.wang/sample_size_calc/reference/sample_size_calculator.md)
  : Sample size calculator for clinical study designs (legacy API)

## Results Display & Visualisation / 结果输出与绘图

Default print and summary reports include plain-text formulas, LaTeX
source, calculation steps, and references. Plot methods provide visual
diagnostics.

- [`print(`*`<sample_size_result>`*`)`](https://rpackages.portos.wang/sample_size_calc/reference/print.sample_size_result.md)
  : Print method for sample_size_result objects
- [`summary(`*`<sample_size_result>`*`)`](https://rpackages.portos.wang/sample_size_calc/reference/summary.sample_size_result.md)
  : Summary method for sample_size_result objects
- [`plot(`*`<sample_size_result>`*`)`](https://rpackages.portos.wang/sample_size_calc/reference/plot.sample_size_result.md)
  : Plot sample size calculation result
- [`plot_power_curve()`](https://rpackages.portos.wang/sample_size_calc/reference/plot_power_curve.md)
  : Plot power curve
- [`plot_sample_size_comparison()`](https://rpackages.portos.wang/sample_size_calc/reference/plot_sample_size_comparison.md)
  : Plot sample size comparison

## Clinical Trials (RCTs) / 随机对照试验

Calculations for parallel-group randomised controlled trials across
continuous, binary, and time-to-event outcomes, covering superiority,
non-inferiority, and equivalence.

- [`calculate_two_means()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_two_means.md)
  : Two independent means comparison calculation
- [`calculate_two_proportions()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_two_proportions.md)
  : Two independent proportions comparison calculation
- [`calculate_survival()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_survival.md)
  : Survival analysis (log-rank test) calculation
- [`calculate_superiority_means()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_superiority_means.md)
  : Superiority test (means) calculation
- [`calculate_superiority_proportions()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_superiority_proportions.md)
  : Superiority test (proportions) calculation
- [`calculate_non_inferiority_means()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_non_inferiority_means.md)
  : Non-inferiority test (means) calculation
- [`calculate_non_inferiority_proportions()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_non_inferiority_proportions.md)
  : RCT non-inferiority for proportions (fills the legacy margin gap)
- [`calculate_equivalence_means()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_equivalence_means.md)
  : Equivalence test (means) calculation
- [`calculate_equivalence_proportions()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_equivalence_proportions.md)
  : Equivalence test (proportions) calculation

## Paired, Single-Arm & Crossover Designs / 配对、单臂与交叉设计

Within-subject paired comparisons, single-arm trials against historical
benchmarks, Simon two-stage designs, A’Hern single-stage, and 2x2
bioequivalence crossover trials.

- [`calculate_paired_means()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_paired_means.md)
  : Paired means comparison calculation
- [`calculate_paired_proportions()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_paired_proportions.md)
  : Paired binary outcomes (McNemar test sample size)
- [`calculate_single_arm_mean()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_single_arm_mean.md)
  : Single-arm trial: continuous outcome vs a fixed reference value n =
  (Z_a/2 + Z_b)^2 \* sigma^2 / delta^2 (Machin Ch.5, single-sample)
- [`calculate_single_arm_proportion()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_single_arm_proportion.md)
  : Single-arm trial: binary outcome vs a fixed reference proportion
- [`calculate_simon_two_stage()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_simon_two_stage.md)
  : Single-arm phase II: Simon two-stage design (exact search)
- [`calculate_ahern()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_ahern.md)
  : Single-arm phase II: A'Hern single-stage design (exact search)
- [`calculate_crossover_mean()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_crossover_mean.md)
  : 2x2 crossover, continuous outcome (within-subject SD
  parameterization)
- [`calculate_bioequivalence()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_bioequivalence.md)
  : Bioequivalence (2x2 crossover, exact TOST noncentral t, 80-125%)

## Observational & Epidemiological Studies / 观察性流行病学研究

Sample size calculations for prospective cohort studies (cumulative
incidence and person-time rate), unmatched/matched case-control studies,
and cross-sectional prevalence surveys.

- [`calculate_cohort_proportion()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_cohort_proportion.md)
  : Cohort study: exposed vs unexposed cumulative incidence (1:m
  allocation)
- [`calculate_cohort_rate()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_cohort_rate.md)
  : Cohort study: incidence rate comparison (person-time, Poisson)
- [`calculate_case_control()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_case_control.md)
  : Case-control study calculation
- [`calculate_case_control_matched()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_case_control_matched.md)
  : Individually matched (1:1) case-control study
- [`calculate_crosstab_association()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_crosstab_association.md)
  : Cross-sectional study: association between exposure and prevalence

## Single-Sample Precision Estimation / 单组参数置信区间估计

Determination of sample sizes required to estimate a population
proportion (prevalence), continuous mean, or Pearson correlation
coefficient with a target margin of error.

- [`calculate_single_proportion()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_single_proportion.md)
  : Internal calculation: single proportion precision (absolute or
  relative)
- [`calculate_single_mean()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_single_mean.md)
  : Internal calculation: single mean precision
- [`calculate_single_correlation()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_single_correlation.md)
  : Internal calculation: single correlation coefficient precision
  (Fisher z / Machin)

## Diagnostic Accuracy Studies / 诊断试验准确性研究

End-to-end sample size determination for diagnostic accuracy studies:
sensitivity/specificity estimation, single/dual-endpoint hypothesis
testing, paired/unpaired comparisons, ROC-AUC (estimation, testing,
margins), and likelihood ratios.

- [`calculate_diagnostic_accuracy_v2()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_diagnostic_accuracy_v2.md)
  : Upgraded diagnostic accuracy: Zhou Eq 6.1 (CI width + power), Eq 6.2
  (precision), Eq 6.3 (prevalence guarantee) — Zhou 2011 pp.194-196
- [`calculate_diagnostic_superiority_single()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_diagnostic_superiority_single.md)
  : Diagnostic superiority (single test) calculation
- [`calculate_diagnostic_comparison_two()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_diagnostic_comparison_two.md)
  : Diagnostic comparison (two tests) calculation
- [`calculate_diag_compare_margin_prop()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_diag_compare_margin_prop.md)
  : Two-proportion margin designs (non-inferiority / equivalence)
- [`calculate_auc_single_v2()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_auc_single_v2.md)
  : Upgraded AUC estimation: three variance functions, user-set
  case:control ratio R — Zhou 2011 pp.196-199
- [`calculate_auc_superiority()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_auc_superiority.md)
  : AUC superiority test calculation
- [`calculate_auc_comparison()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_auc_comparison.md)
  : AUC comparison (two tests) calculation
- [`calculate_diag_auc_compare_margin()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_diag_auc_compare_margin.md)
  : AUC margin designs (non-inferiority / equivalence of two ROC areas)
- [`calculate_likelihood_ratio_v2()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_likelihood_ratio_v2.md)
  : Likelihood ratio sample size via log(LR) CI (Hajian-Tilaki Eq
  6.10-6.14)
- [`screen_required()`](https://rpackages.portos.wang/sample_size_calc/reference/screen_required.md)
  : Total screening size with probability guarantee (Zhou Eq 6.3)
- [`mrmc_power()`](https://rpackages.portos.wang/sample_size_calc/reference/mrmc_power.md)
  : MRMC study power (Obuchowski-Rockette mixed model, paired-patient
  paired-reader design)

## Complex & Modern Clinical Designs / 复杂与现代临床研究设计

Methodologies for cluster randomised trials (design effect, Machin Eq
12.10 with the Student t correction, optional variable cluster size),
stepped-wedge cluster trials, ordered categorical outcomes, clinical
prediction model sample size, and interrupted time series.

- [`calculate_cluster_mean()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_cluster_mean.md)
  : Cluster RCT wrapping the two-means kernel
- [`calculate_cluster_proportion()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_cluster_proportion.md)
  : Cluster RCT wrapping the two-proportions kernel
- [`cluster_design_from_indiv()`](https://rpackages.portos.wang/sample_size_calc/reference/cluster_design_from_indiv.md)
  : Cluster RCT with Machin Eq 12.10 (DE + Student t correction)
- [`cluster_size_inflation()`](https://rpackages.portos.wang/sample_size_calc/reference/cluster_size_inflation.md)
  : Design effect for a cluster randomised trial (Machin Eq 12.5 / 12.7)
- [`apply_cluster_design()`](https://rpackages.portos.wang/sample_size_calc/reference/apply_cluster_design.md)
  : Apply the cluster design effect to an individually-randomised result
- [`calculate_stepped_wedge()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_stepped_wedge.md)
  : Internal calculation: stepped wedge power (Hussey & Hughes 2007 Eq
  8)
- [`calculate_two_ordinal()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_two_ordinal.md)
  : Two-group comparison of an ordered categorical outcome (Whitehead)
- [`calculate_predictive_riley_binary()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_predictive_riley_binary.md)
  : Internal calculation: prediction model development (Riley 2020 BMJ
  method)
- [`calculate_predictive_timetoevent()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_predictive_timetoevent.md)
  : Internal calculation: prediction model for a time-to-event outcome
  (Riley 2020 criterion T1: person-years for precise cumulative
  incidence) Anchor: lambda=0.1/year, t=10, delta=0.05 -\> T \>= 2366
  person-years.
- [`calculate_predictive_epv()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_predictive_epv.md)
  : Predictive/prognostic model development: events-per-variable rule
- [`calculate_its_level()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_its_level.md)
  : Interrupted time series: level-change power (AR(1)-adjusted,
  experimental)
- [`calculate_kappa()`](https://rpackages.portos.wang/sample_size_calc/reference/calculate_kappa.md)
  : Internal calculation: Cohen's kappa sample size (Cantor 1996)

## Internal Validation & Utilities / 内部校验与辅助工具

Lower-level argument validation, standard normal quantiles, and
assertion utilities.

- [`validate_sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/validate_sample_size_result.md)
  : Validate a sample_size_result object

- [`assert_sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/assert_sample_size_result.md)
  : Assert an object is a valid sample_size_result

- [`validate_design_args()`](https://rpackages.portos.wang/sample_size_calc/reference/validate_design_args.md)
  : Validate design-specific arguments

- [`validate_alpha()`](https://rpackages.portos.wang/sample_size_calc/reference/validate_alpha.md)
  : Validate alpha (type I error) parameter

- [`validate_power()`](https://rpackages.portos.wang/sample_size_calc/reference/validate_power.md)
  : Validate power parameter

- [`validate_alternative()`](https://rpackages.portos.wang/sample_size_calc/reference/validate_alternative.md)
  :

  Validate the `alternative` argument

- [`new_sample_size_result()`](https://rpackages.portos.wang/sample_size_calc/reference/new_sample_size_result.md)
  : Internal constructor for sample_size_result objects
