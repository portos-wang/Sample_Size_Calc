suppressPackageStartupMessages(library(SampleSizeCalc))

run_case <- function(name, code_expr) {
  cat("\n======================================================================\n")
  cat("【场景】", name, "\n")
  cat("【代码】\n", code_expr, "\n")
  cat("【真实运行输出】\n")
  res <- eval(parse(text = code_expr))
  print(res)
  if (!is.null(res$formula)) cat("公式 (ASCII):", res$formula, "\n")
  if (!is.null(res$formula_latex)) cat("公式 (LaTeX):", res$formula_latex, "\n")
  if (!is.null(res$reference)) cat("文献出处:\n", res$reference, "\n")
}

sink("D:/Coding/R_packages/Sample_Size_Calc/benchmark/all_42_outputs.txt")

# 1.1 rct test mean
run_case("1.1 双臂平行RCT - 两独立样本均数检验",
         'calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)')

# 1.2 rct test proportion
run_case("1.2 双臂平行RCT - 两独立样本比例检验",
         'calculate("rct", "test", "proportion", p1 = 0.85, p2 = 0.70, alpha = 0.05, power = 0.8)')

# 1.3 rct test survival
run_case("1.3 双臂平行RCT - 生存分析(Log-rank事件数)",
         'calculate("rct", "test", "survival", hr = 0.70, pE = 0.50, alpha = 0.05, power = 0.8)')

# 1.4 rct noninferiority mean
run_case("1.4 双臂平行RCT - 均数非劣效性检验",
         'calculate("rct", "noninferiority", "mean", mean1 = 10, mean2 = 9.5, sd = 3, margin = 1, alpha = 0.05, power = 0.8)')

# 1.5 rct noninferiority proportion
run_case("1.5 双臂平行RCT - 比例非劣效性检验",
         'calculate("rct", "noninferiority", "proportion", p1 = 0.85, p2 = 0.85, margin = 0.05, alpha = 0.05, power = 0.8)')

# 1.6 rct superiority mean
run_case("1.6 双臂平行RCT - 均数优效性检验",
         'calculate("rct", "superiority", "mean", mean1 = 12, mean2 = 10, sd = 3, margin = 1, alpha = 0.05, power = 0.8)')

# 1.7 rct superiority proportion
run_case("1.7 双臂平行RCT - 比例优效性检验",
         'calculate("rct", "superiority", "proportion", p1 = 0.30, p2 = 0.20, margin = 0.05, alpha = 0.05, power = 0.8)')

# 1.8 rct equivalence mean
run_case("1.8 双臂平行RCT - 均数等效性检验",
         'calculate("rct", "equivalence", "mean", mean1 = 10, mean2 = 10.2, sd = 3, margin = 1, alpha = 0.05, power = 0.8)')

# 1.9 rct equivalence proportion
run_case("1.9 双臂平行RCT - 比例等效性检验",
         'calculate("rct", "equivalence", "proportion", p1 = 0.50, p2 = 0.52, margin = 0.10, alpha = 0.05, power = 0.8)')

# 2.1 paired test mean
run_case("2.1 配对试验 - 配对均数比较",
         'calculate("paired", "test", "mean", meanDiff = 2, sdDiff = 3, alpha = 0.05, power = 0.8)')

# 2.2 paired test proportion
run_case("2.2 配对试验 - 配对比例比较(McNemar/Connor)",
         'calculate("paired", "test", "proportion", p1 = 0.80, p2 = 0.60, psi = 0.25, alpha = 0.05, power = 0.8)')

# 2.3 rctSingleArm test mean
run_case("2.3 单臂试验 - 均数对比已知标准值",
         'calculate("rctSingleArm", "test", "mean", mu0 = 10, mu1 = 12, sigma = 3, alpha = 0.05, power = 0.8)')

# 2.4 rctSingleArm test proportion
run_case("2.4 单臂试验 - 比例对比历史对照率",
         'calculate("rctSingleArm", "test", "proportion", p0 = 0.70, p1 = 0.80, alpha = 0.05, power = 0.8)')

# 2.5 singleArmPhaseII optimal
run_case("2.5 单臂肿瘤II期 - Simon两阶段最优设计(Optimal)",
         'calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "optimal")')

# 2.6 singleArmPhaseII minimax
run_case("2.6 单臂肿瘤II期 - Simon两阶段极小极大设计(Minimax)",
         'calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "minimax")')

# 2.7 ahern
run_case("2.7 单臂肿瘤II期 - A\'Hern单阶段精确二项设计",
         'SampleSizeCalc:::calculate_ahern(p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8)')

# 2.8 crossover test mean
run_case("2.8 交叉设计 - 2x2交叉试验均数比较",
         'calculate("crossover", "test", "mean", delta = 2, sigma_within = 3, alpha = 0.05, power = 0.8)')

# 2.9 bioequivalence
run_case("2.9 生物等效性(BE) - 2x2交叉精确TOST非中心t检验",
         'calculate("bioequivalence", cv = 0.25, theta0 = 1.0, alpha = 0.05, power = 0.8)')

# 3.1 cohort proportion
run_case("3.1 前瞻性队列研究 - 累积发病率与相对危险度(RR)",
         'calculate("cohort", "test", "proportion", p0 = 0.20, p1 = 0.30, ratio = 1, dropout = 0.10, alpha = 0.05, power = 0.8)')

# 3.2 cohort rate
run_case("3.2 队列研究 - 人时发病率比(IRR)",
         'calculate("cohort", "test", "rate", rate0 = 0.10, rate1 = 0.20, ratio = 1, alpha = 0.05, power = 0.8)')

# 3.3 caseControl
run_case("3.3 病例对照研究 - 频数匹配与优势比(OR)",
         'calculate("caseControl", p0 = 0.30, OR = 2.0, m = 1, alpha = 0.05, power = 0.8)')

# 3.4 caseControlMatched
run_case("3.4 病例对照研究 - 1:1个体配对",
         'calculate("caseControlMatched", p0 = 0.30, OR = 2.0, alpha = 0.05, power = 0.8)')

# 3.5 crosstab
run_case("3.5 现况研究/横断面调查 - 患病率关联性分析",
         'calculate("crosstab", p0 = 0.20, p1 = 0.30, alpha = 0.05, power = 0.8)')

# 4.1 singleProportion
run_case("4.1 总体比例估计 - 患病率抽样调查",
         'calculate("singleProportion", p = 0.10, precision = 0.02, alpha = 0.05)')

# 4.2 singleMean
run_case("4.2 总体均数估计 - 常模均值抽样调查",
         'calculate("singleMean", sigma = 10, precision = 2, alpha = 0.05)')

# 4.3 singleCorrelation
run_case("4.3 相关系数估计 - Pearson相关系数Fisher-z精确置信区间",
         'calculate("singleCorrelation", r = 0.50, precision = 0.10, alpha = 0.05)')

# 5.1 diagAccuracy estimate
run_case("5.1 诊断准确性 - 敏感度/特异度置信区间估计与筛查人数转化",
         'calculate("diagAccuracy", "estimate", "proportion", prob = 0.85, d = 0.05, prevalence = 0.20, alpha = 0.05)')

# 5.2 diagAccuracy test asymptotic
run_case("5.2 诊断准确性 - 单端点优效性检验(渐近正态法)",
         'calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha = 0.05, power = 0.8)')

# 5.3 diagAccuracy test exact
run_case("5.3 诊断准确性 - 单端点优效性检验(A\'Hern精确二项法)",
         'calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, method = "exact", alpha = 0.05, power = 0.8)')

# 5.4 diagAccuracy test dual
run_case("5.4 诊断准确性 - 双端点(敏感度+特异度同时满足80%把握度)协同设计",
         'calculate("diagAccuracy", "test", "proportion", prob = 0.90, p0 = 0.80, prob_spec = 0.85, p0_spec = 0.75, prevalence = 0.40, dual = TRUE)')

# 5.5 diagAccuracyCompare test unpaired
run_case("5.5 诊断方法比较 - 非配对两法敏感度比较",
         'calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = FALSE, alpha = 0.05, power = 0.8)')

# 5.6 diagAccuracyCompare test paired
run_case("5.6 诊断方法比较 - 配对两法敏感度比较(Connor核)",
         'calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = TRUE, psi = 0.10, alpha = 0.05, power = 0.8)')

# 5.7 diagAccuracyCompare noninferiority
run_case("5.7 诊断方法比较 - 诊断准确度非劣效性检验",
         'calculate("diagAccuracyCompare", "noninferiority", "proportion", p1 = 0.90, p2 = 0.88, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)')

# 5.8 diagAccuracyCompare equivalence
run_case("5.8 诊断方法比较 - 诊断准确度等效性检验",
         'calculate("diagAccuracyCompare", "equivalence", "proportion", p1 = 0.90, p2 = 0.89, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)')

# 5.9 diagAUC estimate binormal
run_case("5.9 ROC曲线下面积(AUC) - 置信区间精度估计(双正态模型)",
         'calculate("diagAUC", "estimate", "auc", auc = 0.80, d = 0.10, ratio = 1, var_method = "binormal", alpha = 0.05)')

# 5.10 diagAUC test
run_case("5.10 ROC曲线下面积(AUC) - 单法优效性检验",
         'calculate("diagAUC", "test", "auc", auc = 0.80, auc0 = 0.70, prevalence = 0.30, alpha = 0.05, power = 0.8)')

# 5.11 diagAUCCompare test
run_case("5.11 ROC曲线下面积(AUC) - 两法AUC比较",
         'calculate("diagAUCCompare", "test", "auc", auc1 = 0.80, auc2 = 0.70, r = 0.50, prevalence = 0.30, alpha = 0.05, power = 0.8)')

# 5.12 diagAUCCompare noninferiority
run_case("5.12 ROC曲线下面积(AUC) - 两法AUC非劣效性检验",
         'calculate("diagAUCCompare", "noninferiority", "auc", auc1 = 0.85, auc2 = 0.82, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)')

# 5.13 diagAUCCompare equivalence
run_case("5.13 ROC曲线下面积(AUC) - 两法AUC等效性检验",
         'calculate("diagAUCCompare", "equivalence", "auc", auc1 = 0.85, auc2 = 0.84, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)')

# 5.14 diagLR estimate
run_case("5.14 似然比(Likelihood Ratio) - 阴性似然比对数置信区间阈值法",
         'calculate("diagLR", "estimate", "lr", sens = 0.90, spec = 0.50, target_lr = 0.40, lr_type = "negative", alpha = 0.05)')

# 5.15 screen_required
cat("\n======================================================================\n")
cat("【场景】 5.15 全人群筛查二项概率安全保障人数(screen_required)\n")
cat("【代码】 screen_required(n = 196, prevalence = 0.20, beta = 0.10)\n【真实运行输出】\n")
s_n <- screen_required(n = 196, prevalence = 0.20, beta = 0.10)
cat("所需总筛查人数 N =", s_n, "(普通除法 196/0.2 = 980，为保证90%概率抓够额外储备:", s_n - 980, "人)\n")

# 5.16 mrmc_power
cat("\n======================================================================\n")
cat("【场景】 5.16 多阅片者多病例(MRMC) - Obuchowski-Rockette混合模型效能分析\n")
cat("【代码】 mrmc_power(n = 50, J = 8, delta = 0.10, sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.00196, rho1 = 0.50, rho2 = 0.30, rho3 = 0.25, rho_b = 0.75)\n【真实运行输出】\n")
m_p <- mrmc_power(n = 50, J = 8, delta = 0.10, sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.00196, rho1 = 0.50, rho2 = 0.30, rho3 = 0.25, rho_b = 0.75)
print(m_p)

# 6.1 clusterRCT mean
run_case("6.1 群随机试验(Cluster RCT) - 连续型结局(均数)",
         'calculate("clusterRCT", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)')

# 6.2 clusterRCT proportion
run_case("6.2 群随机试验(Cluster RCT) - 二分类结局(比例)",
         'calculate("clusterRCT", "test", "proportion", p1 = 0.30, p2 = 0.20, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)')

# 6.3 steppedWedge
run_case("6.3 阶梯楔形整群试验(Stepped-Wedge CRT) - Hussey-Hughes式8",
         'calculate("steppedWedge", "test", "mean", theta = -0.016, tau2 = 2.25e-4, sigma2_ind = 0.0475, m = 100, n_clusters = 24, clusters_per_step = 6, alpha = 0.05)')

# 6.4 twoOrdinal
run_case("6.4 有序多分类结局 - Whitehead比例优势比模型",
         'calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.5, 0.3), alpha = 0.05, power = 0.8)')

# 6.5 predictiveModel binary
run_case("6.5 临床预测模型开发 - Riley 2020 BMJ最新准则(二分类结局)",
         'calculate("predictiveModel", "plan", "binary", prev = 0.30, n_parameters = 10, r2_cs = 0.10, shrinkage = 0.90, precision_delta = 0.05, alpha = 0.05)')

# 6.6 predictiveModel rate
run_case("6.6 临床预测模型开发 - Riley 2020 时间-事件结局人年估算",
         'calculate("predictiveModel", "plan", "rate", rate = 0.10, timepoint = 10, precision_delta = 0.05, alpha = 0.05)')

# 6.7 predictiveModel events (EPV)
run_case("6.7 临床预测模型开发 - 经典每变量事件数(EPV)经验法则",
         'calculate("predictiveModel", "plan", "events", n_parameters = 10, epv = 10, event_prevalence = 0.30)')

# 6.8 kappa estimate
run_case("6.8 评分者一致性 - Cohen\'s Kappa置信区间精度估计(Cantor 1996)",
         'calculate("kappa", "estimate", "proportion", pi1 = 0.30, pi2 = 0.30, kappa = 0.70, d = 0.10, alpha = 0.05)')

# 6.9 kappa test
run_case("6.9 评分者一致性 - 两独立Kappa系数差异检验(Cantor 1996)",
         'calculate("kappa", "test", "proportion", pi1 = 0.50, pi2 = 0.50, kappa1 = 0.70, kappa2 = 0.50, alpha = 0.05, power = 0.8)')

# 6.10 its rate
run_case("6.10 中断时间序列(ITS) - AR(1)自相关调整水平变化(实验性)",
         'calculate("its", "test", "rate", effect_sd = 2, n_pre = 12, n_post = 12, rho = 0.3, alpha = 0.05, power = 0.8)')

sink()
cat("全部 42 组场景运行完毕，保存在 all_42_outputs.txt 中！\n")
