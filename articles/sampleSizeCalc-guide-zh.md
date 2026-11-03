# sampleSizeCalc 完整使用指南：全场景临床科研样本量计算（零基础到精通）

## 引言：为什么样本量计算是临床研究的第一生命线？

很多临床医生在申报国家自然科学基金、撰写临床试验方案（Protocol）或提交伦理审查时，最容易被评审专家质疑的就是**样本量计算依据**。

不经严谨测算就随意定一个样本量（比如“凭经验随访 50
例”），会面临两大致命风险： 1.
**样本量过小（Underpowered，检验效能不足）**：哪怕药物真有疗效，因为人数太少，微弱的信号会被人体的抽样波动彻底掩盖，最终
\\P \>
0.05\\，得出“无统计学显著差异”的假阴性结论，浪费科研经费与受试者心血。
2.
**样本量过大（Overpowered，不符合医学伦理）**：纳入过多患者不仅拖延试验周期，更在伦理上让多余的受试者暴露在未知疗效或有潜在副作用的试验药物中。

`sampleSizeCalc`（临床研究样本量计算器）覆盖了现代临床科研从经典双臂
RCT、流行病学调查，到前沿的 Simon
两阶段肿瘤试验、生物等效性（BE）、多阅片者诊断试验（MRMC）以及 BMJ
最新的 Riley 2020 预测模型样本量规则等 **42 个具体场景**。

**默认打印计算结果时，会同时显示纯文本公式、LaTeX
公式源码、计算过程和参考文献，并按设计提供参数角色说明。**
赋值保存结果后，输入对象名称或调用
[`print()`](https://rdrr.io/r/base/print.html)
即可查看；[`summary()`](https://rdrr.io/r/base/summary.html)
还会列出全部输入参数及已记录的调整。

------------------------------------------------------------------------

## 统计零基础必读：核心概念通俗白话字典

- **\\\alpha\\（I 类错误 / 假阳性率 / 显著性水平）**：
  - *通俗比喻*：**“法官冤枉好人的概率”**。新药明明没有用，但巧合之下我们误认为新药有用的概率。
  - *常规取值*：国际学术界惯例设为 **0.05（即
    5%）**。单侧检验（如非劣效试验）常设为 0.025 或 0.05。
- **\\\text{Power} = 1 - \beta\\（检验效能 / 统计学把握度）**：
  - *通俗比喻*：**“警察抓出真凶的把握”**。新药确实有用时，我们的试验能以多大的概率把它检测出来。
  - *常规取值*：通常设为 **0.80（80%）** 或
    **0.90（90%）**。把握度要求越高，需要招募的患者越多。
- **连续型指标（Mean，均数） vs 二分类指标（Proportion，比例）**：
  - *连续型指标*：测量出来是具体数值，如收缩压降幅（mmHg）、空腹血糖（mmol/L）。核心参数是“均数差（\\\Delta\\）”与“标准差（\\\sigma\\,
    SD）”。
  - *二分类指标*：只有“有效/无效”、“治愈/未治愈”，如有效率 80%、死亡率
    15%。
- **双侧检验（Two-sided） vs 单侧检验（One-sided）**：
  - *双侧检验*：事先不确定新药到底会比对照组好还是差，两头都看（经典临床试验通用）。
  - *单侧检验*：只关心新药是否优于对照药，或者新药是否“不差于”对照药（非劣效/优效性试验通用）。
- **脱落率（Dropout Rate）**：
  - 随访中患者失访或退出。设计划脱落率为 \\d\\（如
    10%），目标样本量需放大：\\N\_{\text{screen}} = \lceil N / (1 - d)
    \rceil\\。

------------------------------------------------------------------------

## 核心语法：统一三轴入口 `calculate()`

在 `sampleSizeCalc` 中，所有计算统一汇聚为一个函数：

\\\Large \texttt{calculate(design, task, outcome, ...)}\\

- **第一轴 `design`（设计类型）**：我们在做什么类型的研究？（`"rct"`,
  `"paired"`, `"cohort"`, `"caseControl"`, `"diagAccuracy"`,
  `"diagAUC"`, `"singleArmPhaseII"`, `"bioequivalence"`, `"clusterRCT"`
  等）
- **第二轴 `task`（统计任务）**：科学目的是什么？（`"test"` 假设检验,
  `"estimate"` 置信区间精度, `"noninferiority"` 非劣效, `"superiority"`
  优效, `"equivalence"` 等效）
- **第三轴 `outcome`（结局指标）**：如何度量疗效？（`"mean"` 均数,
  `"proportion"` 比例, `"survival"` 生存事件数, `"auc"` 诊断AUC,
  `"rate"` 人时率）

------------------------------------------------------------------------

## 第一章：随机对照试验（RCT）全场景实战

### 1.1 两独立样本均数比较（连续变量）

- **临床场景**：心内科评价新降压药。对照组预计收缩压平均降低 10
  mmHg；试验组预计降低 12 mmHg（差值 \\\Delta = 2\\
  mmHg）。标准差（SD）约为 3 mmHg。设定双侧 \\\alpha =
  0.05\\、\\\text{Power} = 80\\\\。
- **数学公式与出处**： \\n = 2 \left( \frac{(Z\_{\alpha/2} + Z\_{\beta})
  \cdot \sigma}{\mu_1 - \mu_2} \right)^2\\ *出处*：Chow, S. C., Shao,
  J., Wang, H., & Lokhnygina, Y. (2017). *Sample Size Calculations in
  Clinical Research* (3rd ed.). CRC Press.
- **参数说明**：`mean1`, `mean2` 为两组均值；`sd`
  为合并标准差（\\\>0\\）。

``` r

res_1_1 <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)
print(res_1_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two independent samples, mean comparison"
#> • Sample size per group: 37
#> • Total sample size: 74
#> Formula (plain text):
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State hypotheses: H0: mu1 = mu2 vs H1: mu1 != mu2 (two-sided alpha =
#> 0.05, power = 0.80).
#> • Step 2: Calculate mean difference delta = |mu1 - mu2| = |10 - 12| = 2; common
#> SD sigma = 3.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96 (for two-sided alpha =
#> 0.05), Z_beta = 0.8416 (for power = 0.80).
#> • Step 4: Compute initial sample size via normal approximation: n0 = 2 *
#> ((Z_(alpha/2) + Z_beta) * sigma / delta)^2 = 2 * ((1.96 + 0.8416) * 3 / 2)^2 =
#> 35.32.
#> • Step 5: Refine via exact two-sample Student's t-test power iteration
#> (accounting for degrees of freedom df = 2n - 2).
#> • Step 6: Round up to integer: n = 37 per group, total sample size N = 74.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 37 人，总计 74 人。计算过程先给出正态近似的每组约
  35.32 人，再说明通过
  [`stats::power.t.test()`](https://rdrr.io/r/stats/power.t.test.html)
  求解非中心 t 分布效能，最终向上取整为 37 人。

#### 默认报告的四项内容与提取方式

| 内容 | 控制台标签 | 对象字段 |
|----|----|----|
| 纯文本公式 | `Formula (plain text)` | `formula` |
| LaTeX 公式源码 | `Formula (LaTeX)` | `formula_latex` |
| 计算过程 | `Calculation process` | `calculation_steps`，别名 `calculation` |
| 参考文献 | `Reference` | `reference` |

``` r

res_1_1$formula
cat(res_1_1$formula_latex)
cat(res_1_1$calculation_steps, sep = "\n")
cat(res_1_1$reference)
```

R 控制台显示可复制的 LaTeX 源码。在 R Markdown 文档中，可以通过
`results = "asis"` 代码块内的 `cat(res_1_1$formula_latex)` 排版公式。
[结果报告指南](https://portos-wang.github.io/Sample_Size_Calc/articles/result-reporting.md)提供可执行示例和保存报告的方法。

### 1.2 两独立样本比例比较（二分类治愈率）

- **临床场景**：消化内科评价幽门螺杆菌根除率。传统 14 天三联方案根除率为
  70%（\\p_2 = 0.70\\），新的秘剂四联方案预计达 85%（\\p_1 =
  0.85\\）。设定双侧 \\\alpha = 0.05\\、\\\text{Power} = 80\\\\。
- **数学公式与出处**： \\n = \frac{\left\[
  Z\_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z\_{\beta}\sqrt{p_1(1-p_1) +
  p_2(1-p_2)} \right\]^2}{(p_1 - p_2)^2}\\ *出处*：Fleiss, J. L., Tytun,
  A., & Ury, H. K. (1980). *Biometrics*, 36(2), 343-346.

``` r

res_1_2 <- calculate("rct", "test", "proportion", p1 = 0.85, p2 = 0.70, alpha = 0.05, power = 0.8)
print(res_1_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two independent proportions"
#> • Sample size per group: 121
#> • Total sample size: 242
#> Formula (plain text):
#> `n = (Z_a/2 * sqrt(2*p_bar*(1-p_bar)) + Z_b * sqrt(p1*(1-p1)+p2*(1-p2)))^2 /
#> (p1-p2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_2(1-p_2)}\right]^2}{(p_1 - p_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: State hypotheses: H0: p1 = p2 vs H1: p1 != p2 (two-sided alpha =
#> 0.05, power = 0.80).
#> • Step 2: Compute pooled proportion: p_bar = (p1 + p2) / 2 = (0.85 + 0.70) / 2
#> = 0.775.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Compute Fleiss formula numerator components:
#> Z_(alpha/2)*sqrt(2*p_bar*(1-p_bar)) = 1.1575; Z_beta*sqrt(p1(1-p1)+p2(1-p2)) =
#> 0.4889.
#> • Step 5: Calculate unrounded sample size per group: n = (1.1575 + 0.4889)^2 /
#> (0.85 - 0.70)^2 = 120.47.
#> • Step 6: Round up to integer: n = 121 per group, total sample size N = 242.
#> Reference:
#> Primary (formula as implemented, without continuity correction): Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346.
#> 
#> With continuity correction: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-494.
#> 
#> Book: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 121 人，总计 242 人。

### 1.3 生存分析与 Log-Rank 检验（时间-事件结局）

- **临床场景**：晚期非小细胞肺癌一线免疫治疗 vs 化疗的 III
  期试验：预期风险比（Hazard Ratio）\\\text{HR} = 0.70\\，试验组与对照组
  1:1 分组，检验效能 80%。需累计多少终点事件？
- **数学公式与出处**： \\E = \frac{(Z\_{\alpha/2} +
  Z\_{\beta})^2}{p_E(1 - p_E) \[\ln(HR)\]^2}\\ *出处*：Schoenfeld, D. A.
  (1983). *Biometrics*, 39(2), 499-503.

``` r

res_1_3 <- calculate("rct", "test", "survival", hr = 0.70, pE = 0.50, alpha = 0.05, power = 0.8)
print(res_1_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Survival (log-rank)"
#> • Events needed: 247
#> Formula (plain text):
#> `E = (Z_a/2 + Z_b)^2 / (pE*(1-pE)*log(HR)^2)`
#> Formula (LaTeX):
#> $$E = \frac{(Z_{\alpha/2} + Z_{\beta})^2}{p_E(1-p_E)[\ln(HR)]^2}$$
#> Calculation process:
#> 
#> • Step 1: State survival parameters: Hazard Ratio HR = 0.70, experimental arm
#> allocation pE = 0.50 (alpha = 0.05, power = 0.80).
#> • Step 2: Compute log hazard ratio: ln(HR) = ln(0.70) = -0.3567.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Apply Schoenfeld formula: E = (Z_(alpha/2) + Z_beta)^2 / [pE * (1 -
#> pE) * (ln HR)^2] = (1.96 + 0.8416)^2 / [0.50 * 0.50 * (-0.3567)^2] = 246.79.
#> • Step 5: Round up to integer: Target events needed E = 247.
#> Reference:
#> Primary: Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. Biometrics, 39(2), 499-503.
#> 
#> Extensions:
#> - Hsieh, F. Y., & Lavori, P. W. (2000). Sample-size calculations for the Cox proportional hazards regression model with nonbinary covariates. Controlled Clinical Trials, 21(6), 552-560.
#> - Rubinstein, L. V., Gail, M. H., & Santner, T. J. (1981). Planning the duration of a comparative clinical trial with loss to follow-up and a period of continued observation. Journal of Chronic Diseases, 34(9-10), 469-479.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：试验需随访至累计发生 **247 例终点事件（死亡/复发）**。

### 1.4 均数非劣效性检验（Non-Inferiority, Mean）

- **临床场景**：评价国产仿制降糖药是否不劣于进口原研药：神经病变症状评分（0-30）改善，试验组预期降低
  10 分（\\\mu_1 = 10\\），对照组降低 9.5 分（\\\mu_2 = 9.5\\），标准差
  \\\text{SD} = 3\\，非劣效界值 \\\text{margin} = 1.0\\ 分。
- **数学公式与出处**： \\n = 2\left(\frac{(Z\_{\alpha} +
  Z\_{\beta})\sigma}{\mu_1 - \mu_2 + \Delta}\right)^2\\ *出处*：Chow et
  al. (2017) Chapter 4. 单侧 \\\alpha = 0.05\\。

``` r

res_1_4 <- calculate("rct", "noninferiority", "mean", mean1 = 10, mean2 = 9.5, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Non-inferiority (means)"
#> • Sample size per group: 50
#> • Total sample size: 100
#> Formula (plain text):
#> `n = 2*(Z_a+Z_b)^2*sd^2/(mean1-mean2+margin)^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{(Z_{\alpha} + Z_{\beta})\sigma}{\mu_1 - \mu_2 + \Delta}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State non-inferiority hypotheses: H0: mu1 - mu2 <= -margin vs H1: mu1
#> - mu2 > -margin (margin Delta = 1, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = mu1 - mu2 + margin = 10 - 9.50 + 1 =
#> 1.50; SD sigma = 3.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 /
#> delta_E^2 = 2 * (1.6449 + 0.8416)^2 * 3^2 / (1.50)^2 = 49.46.
#> • Step 5: Round up to integer: n = 50 per group, total sample size N = 100.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 50 人，两组总计 100 人。

### 1.5 比例非劣效性检验（Non-Inferiority, Proportion）

- **临床场景**：仿制抗菌药申请：口服治愈率需证明不劣于原研药（两者均预期
  85%），监管接受的非劣效界值为 5 个百分点（\\\text{margin} = 0.05\\）。
- **数学公式与出处**： \\n = \frac{(Z\_{\alpha} + Z\_{\beta})^2
  \[p_1(1-p_1) + p_2(1-p_2)\]}{(p_1 - p_2 + \Delta)^2}\\ *出处*：Chow et
  al. (2017); Machin et al. (2018) Ch.11.

``` r

res_1_5 <- calculate("rct", "noninferiority", "proportion", p1 = 0.85, p2 = 0.85, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_1_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Non-inferiority (proportions)"
#> • Sample size per group: 631
#> • Total sample size: 1262
#> Parameter roles
#> 
#> • p1 = experimental-group response rate
#> • p2 = active-control response rate
#> • margin = non-inferiority margin Delta (one-sided alpha)
#> Formula (plain text):
#> `n = (Za+Zb)^2 * (p1q1+p2q2) / (p1-p2+margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha}+Z_{\beta})^2\left[p_1(1-p_1)+p_2(1-p_2)\right]}{(p_1-p_2+\Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: State non-inferiority hypotheses: H0: p1 - p2 <= -margin vs H1: p1 -
#> p2 > -margin (margin Delta = 0.05, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = p1 - p2 + margin = 0.85 - 0.85 + 0.05
#> = 0.05.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)]
#> / delta_E^2 = 630.62.
#> • Step 5: Round up to integer: n = 631 per group, total sample size N = 1262.
#> Reference:
#> Primary: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press; Machin et al. (2018) Chapter 11 (Non-inferiority and Equivalence).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 631 人，总计 1262 人。

### 1.6 均数优效性检验（Superiority, Mean）

- **临床场景**：膝骨关节炎新型 NSAID
  凝胶的优效性试验：不仅需优于活性对照药，且需在 WOMAC
  疼痛量表（0-20）上至少多降 1 分（\\\text{margin} = 1\\）。预期试验组降
  12 分，对照组降 10 分，\\\text{SD} = 3\\。
- **数学公式与出处**： \\n = 2\left(\frac{(Z\_{\alpha} +
  Z\_{\beta})\sigma}{\mu_1 - \mu_2 - \Delta}\right)^2\\ *出处*：Chow et
  al. (2017). 单侧 \\\alpha = 0.05\\。

``` r

res_1_6 <- calculate("rct", "superiority", "mean", mean1 = 12, mean2 = 10, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Superiority (means)"
#> • Sample size per group: 112
#> • Total sample size: 224
#> Formula (plain text):
#> `n = 2*(Z_a+Z_b)^2*sd^2/(mean1-mean2-margin)^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{(Z_{\alpha} + Z_{\beta})\sigma}{\mu_1 - \mu_2 - \Delta}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State superiority hypotheses: H0: mu1 - mu2 <= margin vs H1: mu1 -
#> mu2 > margin (margin Delta = 1, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = mu1 - mu2 - margin = 12 - 10 - 1 = 1;
#> SD sigma = 3.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = 2 * (Z_alpha + Z_beta)^2 * sigma^2 /
#> delta_E^2 = 2 * (1.6449 + 0.8416)^2 * 3^2 / (1)^2 = 111.29.
#> • Step 5: Round up to integer: n = 112 per group, total sample size N = 224.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 112 人，总计 224 人。

### 1.7 比例优效性检验（Superiority, Proportion）

- **临床场景**：甲真菌病新口服抗真菌药：完全治愈率预期
  30%，对照药特比蕲芬 20%，且申办方要求差异至少超过 5
  个百分点的优效界值（\\\text{margin} = 0.05\\）才算临床有意义。
- **数学公式与出处**： \\n = \frac{(Z\_{\alpha} + Z\_{\beta})^2
  \[p_1(1-p_1) + p_2(1-p_2)\]}{(p_1 - p_2 - \Delta)^2}\\ *出处*：Chow et
  al. (2017).

``` r

res_1_7 <- calculate("rct", "superiority", "proportion", p1 = 0.30, p2 = 0.20, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_1_7)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Superiority (proportions)"
#> • Sample size per group: 916
#> • Total sample size: 1832
#> Formula (plain text):
#> `n = (Z_alpha + Z_beta)^2 * (p1*(1-p1) + p2*(1-p2)) / (p1 - p2 - margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha} + Z_{\beta})^2[p_1(1-p_1) + p_2(1-p_2)]}{(p_1 - p_2 - \Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: State superiority hypotheses: H0: p1 - p2 <= margin vs H1: p1 - p2 >
#> margin (margin Delta = 0.05, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = p1 - p2 - margin = 0.30 - 0.20 - 0.05
#> = 0.05.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)]
#> / delta_E^2 = (1.6449 + 0.8416)^2 * [0.21 + 0.16] / (0.05)^2 = 915.02.
#> • Step 5: Round up to integer: n = 916 per group, total sample size N = 1832.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 916 人，总计 1832 人。

### 1.8 均数等效性检验（Equivalence, Mean）

- **临床场景**：两种左甲状腺素钠制剂的疗效等效性验证：预期血清甲状腺素均值差
  0.2 μg/dL，临床可接受的等效边界为 \\\pm 1.0\\ μg/dL（\\\text{margin} =
  1.0\\），\\\text{SD} = 3\\。
- **数学公式与出处**： \\n = 2\left(\frac{(Z\_{\alpha} +
  Z\_{\beta/2})\sigma}{\Delta - \|\mu_1 - \mu_2\|}\right)^2\\
  *出处*：Chow et al. (2017).

``` r

res_1_8 <- calculate("rct", "equivalence", "mean", mean1 = 10, mean2 = 10.2, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Equivalence (means)"
#> • Sample size per group: 241
#> • Total sample size: 482
#> Formula (plain text):
#> `n = 2*(Z_a+Z_b/2)^2*sd^2/(margin-|mean1-mean2|)^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{(Z_{\alpha} + Z_{\beta/2})\sigma}{\Delta - |\mu_1 - \mu_2|}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State equivalence hypotheses (TOST): H0: |mu1 - mu2| >= margin vs H1:
#> |mu1 - mu2| < margin (margin Delta = 1, alpha = 0.05, power = 0.80).
#> • Step 2: Margin clearance: Delta - |mu1 - mu2| = 1 - |10 - 10.20| = 0.80; SD
#> sigma = 3.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_(beta/2) =
#> 1.2816.
#> • Step 4: Compute sample size: n = 2 * (Z_alpha + Z_(beta/2))^2 * sigma^2 /
#> (Delta - |mu1 - mu2|)^2 = 2 * (1.6449 + 1.2816)^2 * 3^2 / (0.80)^2 = 240.86.
#> • Step 5: Round up to integer: n = 241 per group, total sample size N = 482.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 241 人，总计 482 人。

### 1.9 比例等效性检验（Equivalence, Proportion）

- **临床场景**：两种术后镇痛药有效率分别为 50% 与
  52%，监管机构接受的临床等效区间为 \\\pm 10\\ 个百分点（\\\text{margin}
  = 0.10\\）。
- **数学公式与出处**： \\n = \frac{(Z\_{\alpha} + Z\_{\beta/2})^2
  \[p_1(1-p_1) + p_2(1-p_2)\]}{(\Delta - \|p_1 - p_2\|)^2}\\
  *出处*：Chow et al. (2017).

``` r

res_1_9 <- calculate("rct", "equivalence", "proportion", p1 = 0.50, p2 = 0.52, margin = 0.10, alpha = 0.05, power = 0.8)
print(res_1_9)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Equivalence (proportions)"
#> • Sample size per group: 669
#> • Total sample size: 1338
#> Formula (plain text):
#> `n = (Z_alpha + Z_beta/2)^2 * (p1*(1-p1) + p2*(1-p2)) / (margin - |p1 - p2|)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha} + Z_{\beta/2})^2[p_1(1-p_1) + p_2(1-p_2)]}{(\Delta - |p_1-p_2|)^2}$$
#> Calculation process:
#> 
#> • Step 1: State equivalence hypotheses (TOST): H0: |p1 - p2| >= margin vs H1:
#> |p1 - p2| < margin (margin Delta = 0.10, alpha = 0.05, power = 0.80).
#> • Step 2: Margin clearance: Delta - |p1 - p2| = 0.10 - |0.50 - 0.52| = 0.08.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_(beta/2) =
#> 1.2816.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_(beta/2))^2 * [p1(1-p1) +
#> p2(1-p2)] / (Delta - |p1 - p2|)^2 = 668.52.
#> • Step 5: Round up to integer: n = 669 per group, total sample size N = 1338.
#> Reference:
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 669 人，总计 1338 人。

------------------------------------------------------------------------

## 第二章：配对、单臂与交叉临床试验

### 2.1 配对均数比较（自身前后对照）

- **临床场景**：哮喘队列：同一批患者吸入糖皮质激素治疗 12
  周前后各测一次用力肺活量（FVC），前后差值均数 2 L，差值的标准差
  \\\text{SD}\_{\text{diff}} = 3\\ L。
- **数学公式与出处**： \\n = \left(\frac{(Z\_{\alpha/2} + Z\_{\beta})
  \cdot \sigma_d}{\mu_d}\right)^2\\ *出处*：Rosner, B. (2015).
  *Fundamentals of biostatistics* (8th ed.). Cengage Learning.

``` r

res_2_1 <- calculate("paired", "test", "mean", meanDiff = 2, sdDiff = 3, alpha = 0.05, power = 0.8)
print(res_2_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Paired means"
#> • Pairs needed: 20
#> • Total individuals: 40
#> Formula (plain text):
#> `n = ((Z_a/2 + Z_b) * sd_diff / mean_diff)^2`
#> Formula (LaTeX):
#> $$n = \left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma_d}{\mu_d}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: State paired difference hypotheses: H0: mu_d = 0 vs H1: mu_d != 0
#> (alpha = 0.05, power = 0.80).
#> • Step 2: Expected paired difference mu_d = 2, SD of differences sigma_d = 3.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Normal approximation: n0 = ((Z_(alpha/2) + Z_beta) * sigma_d /
#> mu_d)^2 = ((1.96 + 0.8416) * 3 / 2)^2 = 17.66.
#> • Step 5: Exact paired Student's t-test degrees of freedom iteration.
#> • Step 6: Round up to integer: n = 20 pairs (total individuals = 40).
#> Reference:
#> Rosner, B. (2015). *Fundamentals of biostatistics* (8th ed.). Cengage Learning.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需纳入 **20 对受试者（40 人次前后测量）**。

### 2.2 配对二分类比较（McNemar / Connor）

- **临床场景**：同一批疑似感染患者同时接受新冠快速抗原检测（阳性率
  80%）与 RT-PCR 核酸检测（阳性率 60%），预期不一致对占总对数的比例
  \\\psi = 0.25\\。
- **数学公式与出处**： \\n\_{\text{pairs}} = \frac{\left\[
  Z\_{\alpha/2}\sqrt{\psi} + Z\_{\beta}\sqrt{\psi - \delta^2}
  \right\]^2}{\delta^2}, \quad \delta = \|p_1 - p_2\|\\
  *出处*：Connor, R. J. (1987). *Biometrics*, 43(1), 207-211.

``` r

res_2_2 <- calculate("paired", "test", "proportion", p1 = 0.80, p2 = 0.60, psi = 0.25, alpha = 0.05, power = 0.8)
print(res_2_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Paired binary outcomes (McNemar / Connor)"
#> • Total sample size: 94
#> • Pairs needed: 47
#> Parameter roles
#> 
#> • p1/p2 = expected proportions (or sensitivities) in pairs
#> • psi = expected discordant-pair proportion (pi10 + pi01)
#> • output is in PAIRS (n individuals = 2 x pairs)
#> Formula (plain text):
#> `n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi-\delta^2}\right]^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Paired binary parameters: p1 = 0.80, p2 = 0.60, discordant pair
#> proportion psi = 0.25, difference delta = |p1 - p2| = 0.20.
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) + Z_beta*sqrt(psi -
#> delta^2)]^2 / delta^2 = 46.63.
#> • Step 4: Round up to integer: Pairs needed = 47.
#> Reference:
#> Primary: Connor, R. J. (1987). Sample size for testing differences in proportions for the paired-sample design. Biometrics, 43(1), 207-211.
#> 
#>  Also: Akoglu, H. (2022). Turkish Journal of Emergency Medicine, 22(4), Table 2 Eq 3b + Tables 6A/6B (uncorrected and Yates-corrected values).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需纳入 **47 对受试者**。

### 2.3 单臂试验对比已知常模均值

- **临床场景**：某罕见病（无法设立对照组）历史平均生存期为 10
  个月（\\\mu_0 = 10\\），新的靶向治疗预期可延长至 12 个月（\\\mu_1 =
  12\\），\\\text{SD} = 3\\ 个月。
- **数学公式与出处**： \\n = \frac{(Z\_{\alpha/2} + Z\_{\beta})^2
  \sigma^2}{(\mu_1 - \mu_0)^2}\\ *出处*：Machin et al. (2018) Chapter 5.

``` r

res_2_3 <- calculate("rctSingleArm", "test", "mean", mu0 = 10, mu1 = 12, sigma = 3, alpha = 0.05, power = 0.8)
print(res_2_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm trial (continuous, vs fixed value)"
#> • Required sample size: 18
#> Parameter roles
#> 
#> • mu0 = reference/historical control mean (the null value)
#> • mu1 = anticipated treatment mean
#> • sigma = population standard deviation
#> Formula (plain text):
#> `n = (Za/2 + Zb)^2 * sigma^2 / (mu1-mu0)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha/2} + Z_{\beta})^2 \sigma^2}{(\mu_1 - \mu_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Single-arm continuous hypotheses: H0: mu = 10 vs H1: mu = 12, SD
#> sigma = 3 (alpha = 0.05, power = 0.80).
#> • Step 2: Effect size delta = |mu1 - mu0| = |12 - 10| = 2.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Sample size: n = (Z_(alpha/2) + Z_beta)^2 * sigma^2 / delta^2 = (1.96
#> + 0.8416)^2 * 3^2 / (2)^2 = 17.66.
#> • Step 5: Round up to integer: Required sample size n = 18.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 5 (Continuous Outcomes, single-sample comparison).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需招募 **18 名单臂患者**。

### 2.4 单臂试验对比历史对照有效率

- **临床场景**：复发/难治性淋巴瘤的历史最佳缓解率仅 70%（\\p_0 =
  0.70\\），新的 CAR-T 细胞治疗方案预期提高至 80%（\\p_1 = 0.80\\）。
- **数学公式与出处**： \\n = \frac{\left\[
  Z\_{\alpha/2}\sqrt{p_0(1-p_0)} + Z\_{\beta}\sqrt{p_1(1-p_1)}
  \right\]^2}{(p_1 - p_0)^2}\\ *出处*：Hajian-Tilaki, K. (2014). *J
  Biomed Inform*, 48, 193-204 (Eq 6.8).

``` r

res_2_4 <- calculate("rctSingleArm", "test", "proportion", p0 = 0.70, p1 = 0.80, alpha = 0.05, power = 0.8)
print(res_2_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm trial (binary, vs fixed value)"
#> • Required sample size: 153
#> Parameter roles
#> 
#> • p0 = null/historical control proportion
#> • p1 = anticipated treatment proportion
#> Formula (plain text):
#> `n = [Za*sqrt(p0q0) + Zb*sqrt(p1q1)]^2/(p1-p0)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p_1(1-p_1)}\right]^2}{(p_1 - p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Single-arm binary hypotheses: H0: p = 0.70 vs H1: p = 0.80 (alpha =
#> 0.05, power = 0.80).
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Sample size: n = [Z_(alpha/2)*sqrt(p0*q0) + Z_beta*sqrt(p1*q1)]^2 /
#> (p1 - p0)^2 = 152.48.
#> • Step 4: Round up to integer: Required sample size n = 153.
#> Reference:
#> Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204 (Eq 6.8; worked example 0.70 vs 0.80 -> n=153).
#> 
#>  Also: Akoglu, H. (2022). Table 2, Equation 2; Machin et al. (2018) Ch.3.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需招募 **153 名患者**。

### 2.5 单臂肿瘤 II 期：Simon 两阶段最优设计（Optimal）

- **临床场景**：肉瘤新方案单臂 II 期试验：不可接受的历史响应率 \\p_0 =
  0.10\\，期望目标响应率 \\p_1 = 0.30\\。采用 Simon Optimal
  设计，使药物无效时的期望样本量最小。
- **数学公式与出处**：完全精确二项网格穷举搜索，Simon, R. (1989).
  *Controlled Clin Trials*, 10(1), 1-10。设计 \\(r_1/n_1, r/n)\\
  需同时满足 \\P(\text{有效}\mid p_0) \le \alpha\\ 与
  \\P(\text{有效}\mid p_1) \ge 1-\beta\\。

``` r

res_2_5 <- calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "optimal")
print(res_2_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm phase II (Simon two-stage, optimal)"
#> • Stage 1 sample size: 10
#> • Stage 1 futility boundary (stop if responses <= r1): 1
#> • Total sample size (both stages): 29
#> • Overall boundary (declare effective if responses > r): 5
#> Parameter roles
#> 
#> • p0 = unacceptable response rate (null)
#> • p1 = desirable response rate (alternative)
#> • stage 1: stop for futility if responses <= r_stage_1 of n_stage_1
#> • overall: declare effective if responses > r_total of n_total
#> Formula (plain text):
#> `exact binomial: P(effective|p0) <= alpha and P(effective|p1) >= power`
#> Formula (LaTeX):
#> $$P(\text{reject } H_0 \mid p_0) \le \alpha \quad \text{and} \quad P(\text{reject } H_0 \mid p_1) \ge 1-\beta$$
#> Calculation process:
#> 
#> • Step 1: State phase II hypotheses: H0: p <= 0.10 (unacceptable) vs H1: p >=
#> 0.30 (promising) (alpha = 0.05, power = 0.80).
#> • Step 2: Exhaustive exact binomial search under 'optimal' criterion.
#> • Step 3: Stage 1: Accrue n1 = 10 patients; stop early for futility if
#> responses <= r1 = 1.
#> • Step 4: Stage 2: If > 1 responses observed, accrue additional 19 patients up
#> to total n = 29.
#> • Step 5: Final decision: Declare effective if total responses > r = 5
#> (Expected sample size under H0 = 15).
#> Reference:
#> Primary: Simon, R. (1989). Optimal two-stage designs for phase II clinical trials. Controlled Clinical Trials, 10(1), 1-10.
#> 
#>  Also: Machin et al. (2018) Chapter 17 (Therapeutic Exploratory Trials).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：第 1 阶段招 10 人，缓解 \\\le 1\\ 人则因无效停牌；若缓解
  \\\>1\\ 人，继续招 19 人至 29 人。两阶段总缓解人数 \\\>5\\（即 \\\ge
  6\\ 人）宣布有效。期望样本量仅 15.0 人。

### 2.6 单臂肿瘤 II 期：Simon 两阶段极小极大设计（Minimax）

- **临床场景**：同上条件，但希望在最坏情况下试验最大总人数尽可能少。

``` r

res_2_6 <- calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "minimax")
print(res_2_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-arm phase II (Simon two-stage, minimax)"
#> • Stage 1 sample size: 11
#> • Stage 1 futility boundary (stop if responses <= r1): 0
#> • Total sample size (both stages): 25
#> • Overall boundary (declare effective if responses > r): 5
#> Parameter roles
#> 
#> • p0 = unacceptable response rate (null)
#> • p1 = desirable response rate (alternative)
#> • stage 1: stop for futility if responses <= r_stage_1 of n_stage_1
#> • overall: declare effective if responses > r_total of n_total
#> ! Multiple designs may achieve the minimum total sample size N;
#> ! this implementation selects the design minimizing Type I error (alpha) among ties.
#> 
#> Formula (plain text):
#> `exact binomial: P(effective|p0) <= alpha and P(effective|p1) >= power`
#> Formula (LaTeX):
#> $$P(\text{reject } H_0 \mid p_0) \le \alpha \quad \text{and} \quad P(\text{reject } H_0 \mid p_1) \ge 1-\beta$$
#> Calculation process:
#> 
#> • Step 1: State phase II hypotheses: H0: p <= 0.10 (unacceptable) vs H1: p >=
#> 0.30 (promising) (alpha = 0.05, power = 0.80).
#> • Step 2: Exhaustive exact binomial search under 'minimax' criterion.
#> • Step 3: Stage 1: Accrue n1 = 11 patients; stop early for futility if
#> responses <= r1 = 0.
#> • Step 4: Stage 2: If > 0 responses observed, accrue additional 14 patients up
#> to total n = 25.
#> • Step 5: Final decision: Declare effective if total responses > r = 5
#> (Expected sample size under H0 = 20.60).
#> Reference:
#> Primary: Simon, R. (1989). Optimal two-stage designs for phase II clinical trials. Controlled Clinical Trials, 10(1), 1-10.
#> 
#>  Also: Machin et al. (2018) Chapter 17 (Therapeutic Exploratory Trials).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：第 1 阶段招 11 人（缓解 \\\le 0\\ 人停牌），第 2
  阶段总人数达 25 人，最大样本量由 29 人压缩至 25 人。

### 2.7 单臂肿瘤 II 期：A’Hern 单阶段精确二项设计

- **临床场景**：同上肉瘤试验，但因周期太短无法做期中分析，改用单阶段精确二项设计。
- **数学公式与出处**：\\P(X \ge r \mid p_0) \le \alpha\\ 且 \\P(X \ge r
  \mid p_1) \ge 1-\beta\\；A’Hern, R. P. (2001). *Br J Cancer*, 85(2),
  223-226.

``` r

res_2_7 <- sampleSizeCalc:::calculate_ahern(p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8)
print(res_2_7)
#> $design_type
#> [1] "Single-arm phase II (A'Hern single-stage)"
#> 
#> $n_required
#> [1] 25
#> 
#> $r_total
#> [1] 5
#> 
#> $parameters
#> $parameters$p0
#> [1] 0.1
#> 
#> $parameters$p1
#> [1] 0.3
#> 
#> $parameters$alpha
#> [1] 0.05
#> 
#> $parameters$power
#> [1] 0.8
#> 
#> 
#> $formula
#> [1] "P(X > r | p0) <= alpha and P(X > r | p1) >= power"
#> 
#> $formula_latex
#> [1] "$$P(X > r \\mid p_0) \\le \\alpha \\quad \\text{and} \\quad P(X > r \\mid p_1) \\ge 1-\\beta$$"
#> 
#> $reference
#> [1] "Primary: A'Hern, R. P. (2001). Single stage and double sampling phase II trials. British Journal of Cancer, 85(2), 223-226."
#> 
#> $roles
#> [1] "p0 = unacceptable response rate"                       
#> [2] "p1 = desirable response rate"                          
#> [3] "declare effective if responses > r_total of n_required"
```

- **输出解读**：需入组 **25 名患者**，缓解人数 \\\>5\\ 人（\\\ge 6\\
  人）宣布新药有前景。

### 2.8 2x2 交叉试验均数比较

- **临床场景**：哮喘患者按随机顺序先后吸入两种沙丁胺醇制剂（清洗期 7
  天），FEV1% 预计值改善差 2 个百分点，个体内标准差 \\\sigma_w = 3\\。
- **数学公式与出处**： \\n = \frac{2(Z\_{\alpha/2} + Z\_{\beta})^2
  \sigma_w^2}{\delta^2}\\ *出处*：Senn, S. (2002). *Cross-over Trials in
  Clinical Research* (2nd ed.). Wiley.

``` r

res_2_8 <- calculate("crossover", "test", "mean", delta = 2, sigma_within = 3, alpha = 0.05, power = 0.8)
print(res_2_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "2x2 crossover trial (continuous)"
#> • Required sample size: 36
#> • Total sample size: 72
#> Parameter roles
#> 
#> • delta = anticipated treatment difference (mu_T - mu_R)
#> • sigma_within = within-subject standard deviation
#> • n is per sequence; total subjects = 2n (each receives both treatments)
#> Formula (plain text):
#> `n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2 (per sequence)`
#> Formula (LaTeX):
#> $$n = \frac{2(Z_{\alpha/2}+Z_{\beta})^2\sigma_w^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: 2x2 crossover trial (continuous).
#> • Step 2: Input parameters: delta = 2, sigma_within = 3, alpha = 0.05, power =
#> 0.80.
#> • Step 3: Apply design formula: n = 2 (Za/2 + Zb)^2 sigma_w^2 / delta^2 (per
#> sequence).
#> • Step 4: Calculated sample size metrics: Required sample size: 36; Total
#> sample size: 72.
#> Reference:
#> Primary: Senn, S. (2002). Cross-over Trials in Clinical Research (2nd ed.). Wiley.
#> 
#>  Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes for clinical trials with normal data. Statistics in Medicine, 23, 1921-1986 (crossover section).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每序列需 36 人，总计 72 人。

### 2.9 生物等效性（BE）精确 TOST 非中心 t 检验

- **临床场景**：\\2\times 2\\
  交叉试验评价仿制药与原研药等效，个体内变异系数 \\CV =
  25\\\\，预期几何均数比 \\\theta_0 = 1.0\\，等效限 \\80\\ \sim
  125\\\\。
- **数学公式与出处**： \\\text{Power} = F_t(-t\_{1-\alpha, \nu}; \nu,
  \delta_2) - F_t(t\_{1-\alpha, \nu}; \nu, \delta_1), \quad \nu = N -
  2\\ *出处*：Phillips, K. F. (1990). *J Pharmacokinet Biopharm*, 18(2),
  137-144; Julious (2004) Eq 13.

``` r

res_2_9 <- calculate("bioequivalence", cv = 0.25, theta0 = 1.0, alpha = 0.05, power = 0.8)
print(res_2_9)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Bioequivalence (2x2 crossover, exact TOST noncentral t)"
#> • Required sample size: 12
#> • Total sample size: 24
#> • Power achieved: 0.8372
#> Parameter roles
#> 
#> • cv = intra-subject coefficient of variation (log scale implied)
#> • theta0 = anticipated geometric mean ratio (true ratio, default 1.0)
#> • margin = [0.80, 1.25] average BE criteria
#> • n is per sequence; total subjects = 2n
#> Formula (plain text):
#> `exact TOST (Phillips 1990): power = pt(-t, df, ncp=d2) - pt(t, df, ncp=d1)`
#> Formula (LaTeX):
#> $$\text{Power} = F_t(-t_{1-\alpha,\, \nu};\, \nu,\, \delta_2) - F_t(t_{1-\alpha,\, \nu};\, \nu,\, \delta_1), \quad \nu = N-2$$
#> Calculation process:
#> 
#> • Step 1: Intra-subject variance on log scale: sigma_w = sqrt(ln(1 + CV^2)) =
#> sqrt(ln(1 + 0.25^2)) = 0.2462.
#> • Step 2: Standard BE log-scale boundaries: [ln(0.80), ln(1.25)] = [-0.2231,
#> 0.2231].
#> • Step 3: Two One-Sided Tests (TOST) under assumed geometric mean ratio theta0
#> = 1.
#> • Step 4: Search sequence sample size n by evaluating the difference of
#> noncentral t distribution probabilities (Phillips 1990; df = 2n - 2).
#> • Step 5: Required sample size: n = 12 per sequence (achieved power = 0.8372,
#> Total N = 24).
#> Reference:
#> Primary: Phillips, K. F. (1990). Power of the two one-sided tests procedure in bioequivalence. Journal of Pharmacokinetics and Biopharmaceutics, 18(2), 137-144.
#> 
#>  Also: Julious, S. A. (2004). Tutorial in biostatistics: sample sizes for clinical trials with normal data. Statistics in Medicine, 23, 1921-1986 (Eq 13, p. 1941);
#>  Schuirmann, D. J. (1987). J Pharmacokinet Biopharm, 15(6), 657-680;
#>  Chow & Liu (2009). Design and Analysis of Bioavailability and Bioequivalence Studies.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每序列 12 人，总计 **24 名受试者**（与 PowerTOST
  结果完全对齐）。

------------------------------------------------------------------------

## 第三章：观察性与流行病学研究实战

### 3.1 前瞻性队列研究（累积发病率与 RR，含脱落率）

- **临床场景**：吸烟与冠心病发病的弗莱明翰式队列：非吸烟组 5 年发病率
  20%（\\p_0 = 0.20\\），吸烟组 30%（\\p_1 = 0.30\\），1:1 分组，预计
  10% 失访（`dropout = 0.10`）。
- **数学公式与出处**： \\n\_{1} =
  \frac{\left\[Z\_{\alpha/2}\sqrt{(1+\frac{1}{m})\bar{p}(1-\bar{p})} +
  Z\_{\beta}\sqrt{p_1(1-p_1)+\frac{p_0(1-p_0)}{m}}\right\]^2}{(p_1-p_0)^2},
  \quad n = \frac{n_1}{1-d}\\ *出处*：Bhardwaj et al. (2024). *J Family
  Med Prim Care*, 13(7), 2559.

``` r

res_3_1 <- calculate("cohort", "test", "proportion", p0 = 0.20, p1 = 0.30, ratio = 1, dropout = 0.10, alpha = 0.05, power = 0.8)
print(res_3_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohort study (cumulative incidence, RR)"
#> • Sample size per group: 327
#> • Exposed group: 327
#> • Unexposed group: 327
#> • Total sample size: 654
#> Parameter roles
#> 
#> • p0 = unexposed-group cumulative incidence
#> • p1 = exposed-group cumulative incidence
#> • ratio = unexposed:exposed allocation (m)
#> • effect measure: risk ratio RR (estimable in cohort designs)
#> Formula (plain text):
#> `n1 = [Za*sqrt((1+1/m)*pbar*(1-pbar)) + Zb*sqrt(p1q1+p0q0/m)]^2/(p1-p0)^2`
#> Formula (LaTeX):
#> $$n_{1} = \frac{\left[Z_{\alpha/2}\sqrt{(1+\frac{1}{m})\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1)+\frac{p_0(1-p_0)}{m}}\right]^2}{(p_1-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify proportions: unexposed p0 = 0.20, exposed p1 = 0.30,
#> allocation ratio m = 1 (alpha = 0.05, power = 0.80).
#> • Step 2: Weighted average proportion: p_bar = (p1 + m*p0) / (1 + m) = 0.25.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Calculate exposed sample size: n_exposed =
#> [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*q1 + p0*q0/m)]^2 /
#> (p1 - p0)^2 = 293.15.
#> • Step 5: Calculate unexposed sample size: n_unexposed = m * n_exposed = 1 *
#> 293.15 = 293.15.
#> • Step 6: Round up before dropout inflation: ceiling(n_exposed) = 294,
#> ceiling(m*n_exposed) = 294; apply dropout d = 0.10 using ceiling(n/(1-d)).
#> Exposed = 327, Unexposed = 327, Total sample size N = 654.
#> Reference:
#> Primary: Bhardwaj et al. (2024). Journal of Family Medicine and Primary Care, 13(7), 2559 (worked example: p0=0.20, p1=0.30, m=1 -> 293/group).
#> 
#>  Also: Schlesselman, J. J. (1982). Case-Control Studies. Oxford University Press (cohort/case-control shared formula, roles swapped); Machin et al. (2018) Ch.3.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 327 人，全队列共需 **654 人**。

### 3.2 队列研究人时发病率比（IRR）比较

- **临床场景**：职业流行病学：接触有机溶剂的工人发病率为 0.20
  例/人年（\\\lambda_1\\），非接触工人为 0.10
  例/人年（\\\lambda_0\\），1:1 人时分配。
- **数学公式与出处**： \\T_0 = \frac{(Z\_{\alpha/2} + Z\_{\beta})^2
  (\lambda_1/r + \lambda_0)}{(\lambda_1 - \lambda_0)^2}, \quad T_1 = r
  \cdot T_0\\ *出处*：Machin et al. (2018) Chapter 6.

``` r

res_3_2 <- calculate("cohort", "test", "rate", rate0 = 0.10, rate1 = 0.20, ratio = 1, alpha = 0.05, power = 0.8)
print(res_3_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohort study (incidence rate ratio, person-time)"
#> • Person-time, exposed group: 236
#> • Person-time, unexposed group: 236
#> • Expected events: 71
#> Parameter roles
#> 
#> • rate0 = unexposed-group incidence rate (events per person-time)
#> • rate1 = exposed-group incidence rate
#> • ratio = unexposed:exposed person-time ratio
#> • effect measure: incidence rate ratio IRR
#> • person-time = total follow-up time; for fixed duration FT, subjects needed =
#> person-time / FT
#> Formula (plain text):
#> `T0 = (Za/2+Zb)^2 * (l1/r + l0) / (l1-l0)^2 ; T1 = r*T0`
#> Formula (LaTeX):
#> $$T_{0} = \frac{(Z_{\alpha/2}+Z_{\beta})^2(\lambda_1/r+\lambda_0)}{(\lambda_1-\lambda_0)^2}, \quad T_1 = r \cdot T_0$$
#> Calculation process:
#> 
#> • Step 1: Specify incidence rates: unexposed lambda0 = 0.10, exposed lambda1 =
#> 0.20, person-time ratio r = 1.
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Calculate required person-time for unexposed group: T0 = (Z_(alpha/2)
#> + Z_beta)^2 * (lambda1/r + lambda0) / (lambda1 - lambda0)^2 = 235.47.
#> • Step 4: Calculate required person-time for exposed group: T1 = r * T0 = 1 *
#> 235.47 = 235.47.
#> • Step 5: Expected events: E = lambda0 * T0 + lambda1 * T1 = 71.
#> • Step 6: Round up to integer: Person-time unexposed = 236, Person-time exposed
#> = 236.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 6 (Rate Outcomes).
#> 
#>  Also: Breslow, N. E., & Day, N. E. (1987). Statistical Methods in Cancer Research Vol. II. IARC (person-time rate comparison).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：两组各需随访 **236 人年**，预期观察到 71 例事件。

### 3.3 经典病例对照研究（Case-Control）

- **临床场景**：熬夜与心肌梗死的医院基病例对照研究：对照组 30%
  有长期熬夜暴露（\\p_0\\），预期优势比 \\\text{OR} = 2.0\\，1
  名对照匹配 1 名病例。
- **数学公式与出处**： \\n\_{cases} =
  \frac{\left\[Z\_{\alpha/2}\sqrt{(1+1/m)\bar{p}(1-\bar{p})} +
  Z\_{\beta}\sqrt{p_1(1-p_1) + p_0(1-p_0)/m}\right\]^2}{(p_1-p_0)^2}\\
  *出处*：Schlesselman, J. J. (1982). *Case-Control Studies*. Oxford
  University Press.

``` r

res_3_3 <- calculate("caseControl", p0 = 0.30, OR = 2.0, m = 1, alpha = 0.05, power = 0.8)
print(res_3_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Case-control"
#> • Cases needed: 141
#> • Controls needed: 141
#> • Total subjects: 282
#> Formula (plain text):
#> `n_cases = [Z_alpha/2 * sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta * sqrt(p1*(1-p1)
#> + p0*(1-p0)/m)]^2 / (p1 - p0)^2`
#> Formula (LaTeX):
#> $$n_{cases} = \frac{\left[Z_{\alpha/2}\sqrt{(1+1/m)\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_0(1-p_0)/m}\right]^2}{(p_1-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Compute case exposure rate from Odds Ratio: p1 = (OR * p0) / (1 - p0
#> + OR * p0) = (2 * 0.30) / (1 - 0.30 + 2 * 0.30) = 0.4615.
#> • Step 2: Weighted average exposure (matching ratio m = 1): p_bar = (p1 + m*p0)
#> / (1 + m) = 0.3808.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Schlesselman formula for cases: n_cases =
#> [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*(1-p1) +
#> p0*(1-p0)/m)]^2 / (p1 - p0)^2 = 140.66.
#> • Step 5: Calculate controls needed: n_controls = m * n_cases = 1 * 140.66 =
#> 140.66.
#> • Step 6: Round up to integer: Cases needed = 141, Controls needed = 141, Total
#> subjects = 282.
#> Reference:
#> Primary: Schlesselman, J. J. (1982). Case-control studies: Design, conduct, analysis. Oxford University Press.
#> 
#> IARC classic: Breslow, N. E., & Day, N. E. (1980). Statistical methods in cancer research: Volume I - The analysis of case-control studies. IARC Scientific Publications No. 32.
#> 
#> For individually matched designs (not the formula implemented here): Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168; see the caseControlMatched design.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需纳入 **141 例病例与 141 例对照**（总计 282 人）。

### 3.4 1:1 个体配对病例对照研究

- **临床场景**：年轻女性口服避孕药与缺血性卒中的按年龄 1:1
  严格配对病例对照研究：对照暴露率 30%，\\\text{OR} = 2.0\\。
- **数学公式与出处**： \\n\_{pairs} =
  \frac{\left\[Z\_{\alpha/2}\sqrt{\psi} +
  Z\_{\beta}\sqrt{\psi-\delta^2}\right\]^2}{\delta^2}, \quad \psi =
  p_1(1-p_0)+p_0(1-p_1)\\ *出处*：Dupont, W. D. (1988). *Biometrics*,
  44(4), 1157-1168.

``` r

res_3_4 <- calculate("caseControlMatched", p0 = 0.30, OR = 2.0, alpha = 0.05, power = 0.8)
print(res_3_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Individually matched case-control (1:1)"
#> • Total sample size: 288
#> • Cases needed: 144
#> • Controls needed: 144
#> Parameter roles
#> 
#> • p0 = control-group exposure rate
#> • OR = odds ratio to detect (p1 derived from p0 and OR)
#> • psi = expected discordant-pair proportion (pi10 + pi01 = p1*(1-p0) +
#> p0*(1-p1))
#> • note = individually matched designs require discordant-pair proportions
#> (psi), NOT the discordant odds ratio
#> Formula (plain text):
#> `n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2`
#> Formula (LaTeX):
#> $$n_{pairs} = \frac{\left[Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi-\delta^2}\right]^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Matched case-control parameters: control exposure p0 = 0.30, Odds
#> Ratio OR = 2 (alpha = 0.05, power = 0.80).
#> • Step 2: Case exposure rate: p1 = (OR * p0) / (1 - p0 + OR * p0) = 0.4615.
#> • Step 3: Discordant pair probability: psi = pi10 + pi01 = 0.4846; difference
#> delta = |pi10 - pi01| = 0.1615.
#> • Step 4: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 5: Apply Dupont/Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) +
#> Z_beta*sqrt(psi - delta^2)]^2 / delta^2 = 143.38.
#> • Step 6: Round up to integer: Pairs needed = 144 (Cases = 144, Controls =
#> 144).
#> Reference:
#> Primary: Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168.
#> 
#>  Also: Schlesselman, J. J. (1982). Case-Control Studies, Oxford University Press (matched-pair approximation, p.174); Connor, R. J. (1987). Biometrics, 43(1), 207-211.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需纳入 **144 对（288 人）**。

### 3.5 现况研究 / 横断面调查关联分析

- **临床场景**：某社区横断面调查高血压与肥胖的关联：非肥胖人群高血压患病率
  20%，肥胖人群 30%。
- **数学公式与出处**：与 3.1 同核（\\m = 1\\）；Machin et al. (2018)
  Chapter 3.

``` r

res_3_5 <- calculate("crosstab", p0 = 0.20, p1 = 0.30, alpha = 0.05, power = 0.8)
print(res_3_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cross-sectional study (prevalence comparison, PR/OR)"
#> • Sample size per group: 294
#> • Exposed group: 294
#> • Unexposed group: 294
#> • Total sample size: 588
#> Parameter roles
#> 
#> • p0 = prevalence in unexposed group
#> • p1 = prevalence in exposed group
#> • effect measure: prevalence ratio PR (or OR)
#> • sampling: exposure and outcome observed at the same time point
#> Formula (plain text):
#> `n1 = [Za*sqrt((1+1/m)*pbar*(1-pbar)) + Zb*sqrt(p1q1+p0q0/m)]^2/(p1-p0)^2`
#> Formula (LaTeX):
#> $$n_{1} = \frac{\left[Z_{\alpha/2}\sqrt{(1+\frac{1}{m})\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1)+\frac{p_0(1-p_0)}{m}}\right]^2}{(p_1-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify proportions: unexposed p0 = 0.20, exposed p1 = 0.30,
#> allocation ratio m = 1 (alpha = 0.05, power = 0.80).
#> • Step 2: Weighted average proportion: p_bar = (p1 + m*p0) / (1 + m) = 0.25.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 4: Calculate exposed sample size: n_exposed =
#> [Z_(alpha/2)*sqrt((1+1/m)*p_bar*(1-p_bar)) + Z_beta*sqrt(p1*q1 + p0*q0/m)]^2 /
#> (p1 - p0)^2 = 293.15.
#> • Step 5: Calculate unexposed sample size: n_unexposed = m * n_exposed = 1 *
#> 293.15 = 293.15.
#> • Step 6: Round up to integer: Exposed = 294, Unexposed = 294, Total sample
#> size N = 588.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 3 (Binary Outcomes).
#> 
#>  Also: Bhardwaj et al. (2024), p. 2558-2559.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：两组各需调查 294 人，总计 588 人。

------------------------------------------------------------------------

## 第四章：单组参数置信区间估计（调查与常模）

### 4.1 总体比例估计（患病率抽样调查）

- **临床场景**：某县成人糖尿病患病率抽样调查：预期患病率
  10%，要求估计值与真值的误差不超过 ±2 个百分点（\\d = 0.02\\），95%
  置信水平。
- **数学公式与出处**： \\n = \frac{Z\_{1-\alpha/2}^2 p(1-p)}{d^2}\\
  *出处*：Lwanga & Lemeshow (1991) WHO；Bhardwaj et al. (2024), p. 2558.

``` r

res_4_1 <- calculate("singleProportion", p = 0.10, precision = 0.02, alpha = 0.05)
print(res_4_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single proportion estimation (precision)"
#> • Required sample size: 865
#> Parameter roles
#> 
#> • p = expected proportion (e.g. prevalence)
#> • precision = margin of error d (half-width of the CI)
#> • confidence level = 95%
#> Formula (plain text):
#> `n = Z^2 * p(1-p) / d^2`
#> Formula (LaTeX):
#> $$n = \frac{Z_{1-\alpha/2}^2 \cdot p(1-p)}{d^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify anticipated proportion p = 0.10, margin of error d = 0.02
#> (absolute precision), alpha = 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Compute variance component: p * (1 - p) = 0.10 * 0.90 = 0.09.
#> • Step 4: Calculate unrounded sample size: n = Z_(1-alpha/2)^2 * p * (1 - p) /
#> d^2 = (1.96)^2 * 0.09 / (0.02)^2 = 864.33.
#> • Step 5: Round up to integer: Required sample size n = 865.
#> Reference:
#> Bhardwaj et al. (2024). Determination of sample size for various study designs in medical research: A practical primer. Journal of Family Medicine and Primary Care, 13(7), 2555-2561 (p. 2558).
#> 
#> Also: Lwanga, S. K., & Lemeshow, S. (1991). Sample size determination in health studies: A practical manual. World Health Organization.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需调查 **865 名居民**。

### 4.2 总体均数估计（常模抽样）

- **临床场景**：建立某地健康儿童血清铁蛋白参考值：已知人群标准差
  \\\text{SD} = 10\\ μg/L，均数估计误差需控制在 \\\pm 2\\ μg/L 内。
- **数学公式与出处**： \\n =
  \left(\frac{Z\_{1-\alpha/2}\sigma}{d}\right)^2\\ *出处*：Machin et
  al. (2018) Ch.9.

``` r

res_4_2 <- calculate("singleMean", sigma = 10, precision = 2, alpha = 0.05)
print(res_4_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single mean estimation (precision)"
#> • Required sample size: 97
#> Parameter roles
#> 
#> • sigma = population standard deviation (from pilot/literature)
#> • precision = margin of error d
#> Formula (plain text):
#> `n = (Z * sigma / d)^2`
#> Formula (LaTeX):
#> $$n = \left(\frac{Z_{1-\alpha/2} \cdot \sigma}{d}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: Specify population SD sigma = 10, margin of error d = 2, alpha =
#> 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Compute unrounded sample size: n = (Z_(1-alpha/2) * sigma / d)^2 =
#> (1.96 * 10 / 2)^2 = 96.04.
#> • Step 4: Round up to integer: Required sample size n = 97.
#> Reference:
#> Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 9.
#> 
#> Also: Bhardwaj et al. (2024), p. 2558 (continuous outcome precision).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需调查 **97 名儿童**。

### 4.3 Pearson 相关系数估计（Fisher-z 精确法）

- **临床场景**：验证腰围替代体脂率的可靠性：预期 Pearson 相关系数 \\r =
  0.50\\，要求 95% 置信区间半宽不超过 \\\pm 0.10\\。
- **数学公式与出处**： \\N\_{P0} = \frac{4 z\_{1-\alpha/2}^2
  (1-r^2)^2}{w^2} + 3, \quad N\_{Final} =
  (N\_{P0}-3)\left(\frac{w_0}{w}\right)^2 + 3\\ *出处*：Machin et
  al. (2018) Ch.19 Eqs 19.5-19.8 精修公式，与
  [`presize::prec_cor`](https://ctu-bern.github.io/presize/reference/prec_cor.html)
  严格一致。

``` r

res_4_3 <- calculate("singleCorrelation", r = 0.50, precision = 0.10, alpha = 0.05)
print(res_4_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single correlation estimation (Fisher z precision)"
#> • Required sample size: 219
#> Parameter roles
#> 
#> • r = anticipated correlation coefficient
#> • precision = margin of error d (CI half-width, w = 2*d)
#> • confidence level = 95%
#> Formula (plain text):
#> `Machin 19.5-19.8: N_P0 = 4*z^2*(1-r^2)^2/w^2 + 3, refined via Fisher z bounds`
#> Formula (LaTeX):
#> $$N_{P0} = \frac{4 z_{1-\alpha/2}^2 (1-r^2)^2}{w^2} + 3, \quad N_{Final} = (N_{P0}-3)\left(\frac{w_0}{w}\right)^2 + 3$$
#> Calculation process:
#> 
#> • Step 1: Specify anticipated correlation r = 0.50, CI half-width d = 0.10
#> (width w = 2d = 0.20), alpha = 0.05.
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96.
#> • Step 3: Machin initial estimate: N_P0 = 4 * Z^2 * (1 - r^2)^2 / w^2 + 3 =
#> 219.08.
#> • Step 4: Refine via Fisher z transformation limits to adjust for confidence
#> interval skewness.
#> • Step 5: Round up to integer: Required sample size n = 219.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 19 (The Correlation Coefficient), Equations 19.5-19.8, pp. 307-308.
#> 
#>  Also: Fisher, R. A. (1921). On the 'probable error' of a coefficient of correlation deduced from a small sample. Metron, 1, 3-32.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需纳入 **219 名受试者**。

------------------------------------------------------------------------

## 第五章：诊断试验准确性研究全家族

### 5.1 敏感度/特异度估计与全人群筛查规模转化

- **临床场景**：验证结直肠癌早筛试剂盒的敏感度：预期 85%，95%
  置信区间半宽需控制在 \\\pm 5\\\\，门诊目标人群患病率
  20%。需多少确诊真病例？全人群需筛查多少人？
- **数学公式与出处**： \\n\_{cases} = \frac{Z\_{1-\alpha/2}^2 \cdot
  p(1-p)}{d^2}, \quad N\_{screen} =
  \frac{n\_{cases}}{\text{prevalence}}\\ *出处*：Zhou, Obuchowski, &
  McClish (2011) §6.1.1, pp. 194-196.

``` r

res_5_1 <- calculate("diagAccuracy", "estimate", "proportion", prob = 0.85, d = 0.05, prevalence = 0.20, alpha = 0.05)
print(res_5_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic accuracy (single)"
#> • Cases needed: 196
#> • Total subjects to screen: 980
#> • Total subjects: 980
#> Formula (plain text):
#> `N_cases = (Z_1-a/2)^2 * P*(1-P)/d^2`
#> Formula (LaTeX):
#> $$n_{{{cases}}} = \frac{Z_{1-\alpha/2}^2 \cdot p(1-p)}{d^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify diagnostic accuracy prob (Se or Sp) = 0.85, margin of error d
#> = 0.05, prevalence = 0.20 (alpha = 0.05).
#> • Step 2: Determine critical value: Z_(1-alpha/2) = 1.96 (confidence level =
#> 95%).
#> • Step 3: Calculate target cases required: n_cases = Z_sum^2 * prob * (1 -
#> prob) / d^2 = (1.96)^2 * 0.85 * 0.15 / (0.05)^2 = 195.91.
#> • Step 4: Adjust for disease prevalence: total subjects to screen = n_cases /
#> prevalence = 195.91 / 0.20 = 979.57.
#> • Step 5: Round up to integer: Target cases needed = 196, Total subjects to
#> screen = 980.
#> Reference:
#> Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.
#> 
#> Review: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：敏感度需 196 例确诊真病例；门诊全人群筛查需 **980 人**。

### 5.2 诊断单端点优效性检验（渐近正态法）

- **临床场景**：验证 AI 肺结节诊断系统的敏感度是否显著优于行业及格线
  70%（\\p_0 = 0.70\\），预期敏感度 85%，患病率 20%。
- **数学公式与出处**： \\n = \frac{\left\[Z\_{\alpha}\sqrt{p_0(1-p_0)} +
  Z\_{\beta}\sqrt{p(1-p)}\right\]^2}{(p - p_0)^2}\\
  *出处*：Hajian-Tilaki (2014) Eq 6.8.

``` r

res_5_2 <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha = 0.05, power = 0.8)
print(res_5_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic superiority (single)"
#> • Cases needed: 50
#> • Total subjects to screen: 248
#> • Total subjects: 248
#> Formula (plain text):
#> `N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 / (P-P0)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p(1-p)}\right]^2}{(p - p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic superiority (single).
#> • Step 2: Input parameters: prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha =
#> 0.05, power = 0.80, method = asymptotic.
#> • Step 3: Apply design formula: N_cases = [Za*sqrt(P0*Q0) + Zb*sqrt(P*Q)]^2 /
#> (P-P0)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 50; Total subjects to
#> screen: 248.
#> Reference:
#> Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 50 例病例，筛查 250 人。

### 5.3 诊断单端点优效性检验（A’Hern 精确二项法）

- **临床场景**：同上 AI
  肺结节验证，但样本来源有限，采用精确二项法消除正态近似误差。
- **数学公式与出处**：\\P(X \ge r \mid p_0) \le \alpha\\ 且 \\P(X \ge r
  \mid p) \ge 1-\beta\\；A’Hern (2001).

``` r

res_5_3 <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, method = "exact", alpha = 0.05, power = 0.8)
print(res_5_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic superiority (single test, exact binomial)"
#> • Cases needed: 49
#> • Total subjects to screen: 245
#> • Total subjects: 245
#> Parameter roles
#> 
#> • prob = expected diagnostic sensitivity/specificity
#> • p0 = unacceptable/null sensitivity or specificity threshold
#> • critical_successes = declare superior if correct cases >= 40 of 49
#> Formula (plain text):
#> `exact binomial: P(X >= r | p0) <= alpha and P(X >= r | prob) >= power`
#> Formula (LaTeX):
#> $$P(X \ge r \mid p_0) \le \alpha \quad \text{and} \quad P(X \ge r \mid p) \ge 1-\beta$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic superiority (single test, exact
#> binomial).
#> • Step 2: Input parameters: prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha =
#> 0.05, power = 0.80, method = exact.
#> • Step 3: Apply design formula: exact binomial: P(X >= r | p0) <= alpha and P(X
#> >= r | prob) >= power.
#> • Step 4: Calculated sample size metrics: Cases needed: 49; Total subjects to
#> screen: 245.
#> Reference:
#> Primary (exact binomial): A'Hern, R. P. (2001). Single stage and double sampling phase II trials. British Journal of Cancer, 85(2), 223-226.
#> 
#>  Also: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：精确法需 **49 例确诊病例**，临界正确数 \\r = 40\\
  例（正确判断 \\\ge 40\\ 例宣布优效）。

### 5.4 双端点诊断试验设计（敏感度+特异度协同达标）

- **临床场景**：新的乳腺病灶 AI
  需要敏感度（80%升至90%）与特异度（75%升至85%）**同时**较活检金标准显著提升，患病率
  40%。各端点置于 90% 效能，联合效能约 80%。
- **数学公式与出处**： \\n = \max\left(n\_{Se},\\ n\_{Sp}\right), \quad
  n = \frac{\left\[Z\_{\alpha}\sqrt{p_0(1-p_0)} +
  Z\_{\beta}\sqrt{p(1-p)}\right\]^2}{(p-p_0)^2}\\ *出处*：Akoglu, H.
  (2022). *Turk J Emerg Med*, 22(4), 177-185 (p. 184)。

``` r

res_5_4 <- calculate("diagAccuracy", "test", "proportion", prob = 0.90, p0 = 0.80, prob_spec = 0.85, p0_spec = 0.75, prevalence = 0.40, dual = TRUE)
print(res_5_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic accuracy (dual endpoint: Se + Sp)"
#> • Cases needed: 137
#> • N for sensitivity: 109
#> • N for specificity: 137
#> • Total subjects to screen: 343
#> • Total subjects: 343
#> Parameter roles
#> 
#> • prob/p0 = expected and null sensitivity
#> • prob_spec/p0_spec = expected and null specificity
#> • dual_power = per-endpoint power (default 0.90 -> ~80% joint)
#> Formula (plain text):
#> `n = [Za*sqrt(p0q0) + Zb*sqrt(pq)]^2/(p-p0)^2, each at dual_power; take max`
#> Formula (LaTeX):
#> $$n = \max\left(n_{Se},\, n_{Sp}\right), \quad n = \frac{\left[Z_{\alpha}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p(1-p)}\right]^2}{(p-p_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Dual-endpoint setup: Se (null = 0.80, exp = 0.90), Sp (null = 0.75,
#> exp = 0.85), dual_power = 0.90 (joint power ~80%).
#> • Step 2: Calculate cases for sensitivity: n_Se = [Z_alpha*sqrt(p0*q0) +
#> Z_beta*sqrt(p*q)]^2 / (p - p0)^2 = 109.
#> • Step 3: Calculate controls for specificity: n_Sp = [Z_alpha*sqrt(p0*q0) +
#> Z_beta*sqrt(p*q)]^2 / (p - p0)^2 = 137.
#> • Step 4: Select dominant endpoint requirement: n_final = max(n_Se, n_Sp) =
#> 137.
#> • Step 5: Convert to screening population: Total subjects to screen = 137 /
#> 0.40 = 343.
#> Reference:
#> Strategy: Akoglu, H. (2022). User's guide to sample size estimation in diagnostic accuracy studies. Turkish Journal of Emergency Medicine, 22(4), 177-185 (p. 184: each endpoint at 90% power -> ~80% overall).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 123 例病例，全人群需筛查 308 人。

### 5.5 非配对两诊断方法敏感度比较

- **临床场景**：两套竞争性肺炎 CT-AI
  系统在两组独立患者中验证：敏感度分别为 85% 与 75%，患病率 20%。
- **数学公式与出处**：与 1.2 同核（Fleiss 1980 渐近方差公式）。

``` r

res_5_5 <- calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = FALSE, alpha = 0.05, power = 0.8)
print(res_5_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two diagnostic measures"
#> • Cases needed: 250
#> • Total subjects to screen: 2500
#> • Total subjects: 2500
#> Formula (plain text):
#> `n = [Za/2 * sqrt(2*p_bar*(1-p_bar)) + Zb * sqrt(p1*(1-p1)+p2*(1-p2))]^2 /
#> (p1-p2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1)+p_2(1-p_2)}\right]^2}{(p_1-p_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Two diagnostic measures.
#> • Step 2: Input parameters: p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired =
#> FALSE, psi = , alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = [Za/2 * sqrt(2*p_bar*(1-p_bar)) + Zb *
#> sqrt(p1*(1-p1)+p2*(1-p2))]^2 / (p1-p2)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 250; Total subjects to
#> screen: 2500.
#> Reference:
#> Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.
#> 
#> Review: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 250 例病例，两组筛查需 2500 人。

### 5.6 配对两诊断方法敏感度比较（Connor 核）

- **临床场景**：同一批疑似肺炎患者同时接受两套 AI
  系统判读（配对设计）：敏感度 85% vs 75%，预期不一致对比例 \\\psi =
  0.10\\——配对设计大幅节省病例数。
- **数学公式与出处**： \\n = \frac{\left\[Z\_{\alpha/2}\sqrt{\psi} +
  Z\_{\beta}\sqrt{\psi-\delta^2}\right\]^2}{\delta^2}\\ *出处*：Connor
  (1987)；Akoglu (2022) Tables 6A/6B。

``` r

res_5_6 <- calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = TRUE, psi = 0.10, alpha = 0.05, power = 0.8)
print(res_5_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two diagnostic measures (paired, Connor)"
#> • Pairs needed: 77
#> • Total subjects to screen: 381
#> • Cases needed: 77
#> • Total subjects: 381
#> Parameter roles
#> 
#> • p1/p2 = expected sensitivities of the two tests
#> • psi = expected discordant-pair proportion (pi10 + pi01)
#> • output is in PAIRS (cases); screening total = pairs/prevalence
#> Formula (plain text):
#> `n = [Za*sqrt(psi) + Zb*sqrt(psi-delta^2)]^2/delta^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi-\delta^2}\right]^2}{\delta^2}$$
#> Calculation process:
#> 
#> • Step 1: Paired binary parameters: p1 = 0.85, p2 = 0.75, discordant pair
#> proportion psi = 0.10, difference delta = |p1 - p2| = 0.10.
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Connor formula: n_pairs = [Z_(alpha/2)*sqrt(psi) + Z_beta*sqrt(psi -
#> delta^2)]^2 / delta^2 = 76.09.
#> • Step 4: Round up to integer: Pairs needed = 77.
#> Reference:
#> Primary: Connor, R. J. (1987). Biometrics, 43(1), 207-211.
#> 
#>  Also: Akoglu, H. (2022). Turkish Journal of Emergency Medicine, 22(4), Table 2 Eq 3b + Tables 6A/6B; Zhou et al. (2011) Section 6.2.2.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：仅需 **77 对病例**，筛查 385 人。

### 5.7 诊断准确度非劣效性检验

- **临床场景**：新的简便家庭自测盒（敏感度
  90%）需证實不劣于实验室金标准（88%），非劣效界值 5%，患病率 30%。
- **数学公式与出处**： \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(p_1-p_2+\Delta)^2}\\
  *出处*：Chow et al. (2017)；Zhou et al. (2011) §6.3, pp. 214-218。

``` r

res_5_7 <- calculate("diagAccuracyCompare", "noninferiority", "proportion", p1 = 0.90, p2 = 0.88, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_7)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic non-inferiority (two proportions)"
#> • Sample size per group: 247
#> • Total sample size: 494
#> • Cases needed: 247
#> • Total subjects to screen: 823
#> • Total subjects: 823
#> Parameter roles
#> 
#> • p1/p2 = expected sensitivities (or specificities) of the new/reference test
#> • margin = non-inferiority/equivalence margin Delta
#> • non-inferiority uses one-sided alpha; equivalence uses Z_{beta/2}
#> Formula (plain text):
#> `n = (Za+Zb)^2 * (p1q1+p2q2) / (p1-p2+margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha}+Z_{\beta})^2\left[p_1(1-p_1)+p_2(1-p_2)\right]}{(p_1-p_2+\Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: State non-inferiority hypotheses: H0: p1 - p2 <= -margin vs H1: p1 -
#> p2 > -margin (margin Delta = 0.05, one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Effective difference: delta_E = p1 - p2 + margin = 0.90 - 0.88 + 0.05
#> = 0.07.
#> • Step 3: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 4: Compute sample size: n = (Z_alpha + Z_beta)^2 * [p1(1-p1) + p2(1-p2)]
#> / delta_E^2 = 246.80.
#> • Step 5: Round up to integer: n = 247 per group, total sample size N = 494.
#> Reference:
#> Framework: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press (margin designs); Machin et al. (2018) Ch.11.
#> 
#>  Diagnostic application: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.), Section 6.3 (non-inferiority/equivalency of two tests), pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 247 例病例，筛查 824 人。

### 5.8 诊断准确度等效性检验

- **临床场景**：两台床旁分析仪敏感度分别为 90% 与
  89%，临床可接受等效界值 \\\pm 5\\\\。
- **数学公式与出处**： \\n =
  \frac{(Z\_{\alpha}+Z\_{\beta/2})^2\left\[p_1(1-p_1)+p_2(1-p_2)\right\]}{(\Delta-\|p_1-p_2\|)^2}\\
  *出处*：Chow et al. (2017)；Zhou et al. (2011) §6.3。

``` r

res_5_8 <- calculate("diagAccuracyCompare", "equivalence", "proportion", p1 = 0.90, p2 = 0.89, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic equivalence (two proportions)"
#> • Sample size per group: 1006
#> • Total sample size: 2012
#> • Cases needed: 1006
#> • Total subjects to screen: 3353
#> • Total subjects: 3353
#> Parameter roles
#> 
#> • p1/p2 = expected sensitivities (or specificities) of the new/reference test
#> • margin = non-inferiority/equivalence margin Delta
#> • non-inferiority uses one-sided alpha; equivalence uses Z_{beta/2}
#> Formula (plain text):
#> `n = (Za+Zb/2)^2 * (p1q1+p2q2) / (margin-|p1-p2|)^2`
#> Formula (LaTeX):
#> $$n = \frac{(Z_{\alpha}+Z_{\beta/2})^2\left[p_1(1-p_1)+p_2(1-p_2)\right]}{(\Delta-|p_1-p_2|)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic equivalence (two proportions).
#> • Step 2: Input parameters: p1 = 0.90, p2 = 0.89, margin = 0.05, task =
#> equivalence, prevalence = 0.30, alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = (Za+Zb/2)^2 * (p1q1+p2q2) /
#> (margin-|p1-p2|)^2.
#> • Step 4: Calculated sample size metrics: Sample size per group: 1006; Total
#> sample size: 2012; Cases needed: 1006; Total subjects to screen: 3353.
#> Reference:
#> Framework: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press (margin designs); Machin et al. (2018) Ch.11.
#> 
#>  Diagnostic application: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.), Section 6.3 (non-inferiority/equivalency of two tests), pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 1006 例病例，筛查 3354 人。

### 5.9 ROC 曲线下面积（AUC）精度估计（双正态模型）

- **临床场景**：预期 \\\text{AUC} = 0.80\\，容许置信区间半宽 \\\pm
  0.10\\，病例对照比 1:1。
- **数学公式与出处**：Obuchowski, N. A. (1994); Zhou et al. (2011) Eq
  6.5.

``` r

res_5_9 <- calculate("diagAUC", "estimate", "auc", auc = 0.80, d = 0.10, ratio = 1, var_method = "binormal", alpha = 0.05)
print(res_5_9)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Single-group AUC CI precision"
#> • Cases needed: 46
#> • Total subjects to screen: 92
#> • Total subjects: 92
#> Parameter roles
#> 
#> • auc = anticipated area under the ROC curve
#> • precision = desired CI half-width L
#> • ratio = case:control ratio R (cases:non-cases; default 1)
#> • var_method = binormal variance function
#> Formula (plain text):
#> `N_cases = (Z_1-a/2 / d)^2 * V(AUC)`
#> Formula (LaTeX):
#> $$n_{cases} = \left(\frac{Z_{1-\alpha/2}}{d}\right)^2 \cdot V(AUC)$$
#> Calculation process:
#> 
#> • Step 1: Anticipated AUC = 0.80, precision d = 0.10, supplied allocation R =
#> 1, alpha = 0.05.
#> • Step 2: Use the binormal variance model with the supplied allocation: V(AUC)
#> = 0.1195.
#> • Step 3: Calculate cases: n_cases = (Z_(1-alpha/2)/d)^2 * V(AUC) =
#> (1.96/0.10)^2 * 0.1195 = 45.89.
#> • Step 4: Convert using the supplied allocation: total = n_cases*(1+R) =
#> 45.89*(1+1) = 91.78.
#> • Step 5: Round up: Target cases needed = 46, Total subjects to screen = 92.
#> Reference:
#> Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley. Section 6.1.2, pp. 196-199 (Eq 6.4/6.5/6.6; CTC worked example).
#> 
#>  Original variance: Hanley, J. A., & McNeil, B. J. (1982). Radiology, 143(1), 29-36.
#>  Binormal variance: Obuchowski, N. A. (1994). Medical Decision Making, 14(2), 154-162.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 **46 例病例与 46 例对照**（总计 92 人）。

### 5.10 ROC 曲线下面积（AUC）单法优效检验

- **临床场景**：检验新标志物 \\\text{AUC} = 0.80\\
  是否显著高于临床及格线 \\\text{AUC}\_0 = 0.70\\。

``` r

res_5_10 <- calculate("diagAUC", "test", "auc", auc = 0.80, auc0 = 0.70, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_10)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "AUC superiority (single)"
#> • Cases needed: 180
#> • Total subjects to screen: 600
#> • Total subjects: 600
#> Formula (plain text):
#> `n_cases = (Z_alpha * sqrt(V(AUC0)) + Z_beta * sqrt(V(AUC)))^2 / (AUC -
#> AUC0)^2`
#> Formula (LaTeX):
#> $$n_{cases} = \frac{\left(Z_{\alpha}\sqrt{V(AUC_0)} + Z_{\beta}\sqrt{V(AUC)}\right)^2}{(AUC - AUC_0)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify AUC alternative = 0.80, null AUC0 = 0.70, prevalence = 0.30
#> (one-sided alpha = 0.05, power = 0.80).
#> • Step 2: Determine critical values: one-sided Z_alpha = 1.6449, Z_beta =
#> 0.8416.
#> • Step 3: Evaluate Hanley-McNeil variance under alternative V(AUC) and null
#> V(AUC0).
#> • Step 4: Calculate target cases: n_cases = [Z_alpha*sqrt(V(AUC0)) +
#> Z_beta*sqrt(V(AUC))]^2 / (AUC - AUC0)^2.
#> • Step 5: Round up to integer: Target cases needed = 180, Total subjects to
#> screen = 600.
#> Reference:
#> Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.
#> 
#> Review: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 180 例病例，筛查 600 人。

### 5.11 两诊断方法 ROC-AUC 比较

- **临床场景**：两法 \\\text{AUC}\_1 = 0.80\\ vs \\\text{AUC}\_2 =
  0.70\\，两法相关系数 \\r = 0.50\\。
- **数学公式与出处**：Hajian-Tilaki (2014) Eq 7.6/7.8.

``` r

res_5_11 <- calculate("diagAUCCompare", "test", "auc", auc1 = 0.80, auc2 = 0.70, r = 0.50, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_11)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "AUC comparison (two tests)"
#> • Cases needed: 223
#> • Total subjects to screen: 743
#> • Total subjects: 743
#> Formula (plain text):
#> `n_cases = 2 * (Z_alpha/2 + Z_beta)^2 * V(AUC) * (1 - r) / (AUC1 - AUC2)^2`
#> Formula (LaTeX):
#> $$n_{cases} = \frac{2(Z_{\alpha/2} + Z_{\beta})^2 \cdot V(AUC) \cdot (1-r)}{(AUC_1 - AUC_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Specify AUC1 = 0.80, AUC2 = 0.70, correlation r = 0.50, prevalence =
#> 0.30 (alpha = 0.05, power = 0.80).
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Evaluate pooled Hanley-McNeil variance V(AUC_avg).
#> • Step 4: Calculate target cases: n_cases = 2 * (Z_(alpha/2) + Z_beta)^2 *
#> V(AUC) * (1 - r) / (AUC1 - AUC2)^2.
#> • Step 5: Round up to integer: Target cases needed = 223, Total subjects to
#> screen = 743.
#> Reference:
#> Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. *Journal of Biomedical Informatics*, 48, 193-204. https://doi.org/10.1016/j.jbi.2014.02.013
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 223 例病例，筛查 744 人。

### 5.12 两法 ROC-AUC 非劣效性检验

- **临床场景**：新简易设备 \\\text{AUC}\_1 = 0.85\\ 对比金标准
  \\\text{AUC}\_2 = 0.82\\，非劣效限 \\\text{margin} = 0.05\\。

``` r

res_5_12 <- calculate("diagAUCCompare", "noninferiority", "auc", auc1 = 0.85, auc2 = 0.82, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_5_12)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic non-inferiority (two ROC areas)"
#> • Cases needed: 80
#> • Total subjects to screen: 159
#> • Total subjects: 159
#> Parameter roles
#> 
#> • auc1/auc2 = anticipated ROC areas of the new/reference test
#> • r = expected correlation between the two AUC estimates (paired designs)
#> • margin = non-inferiority/equivalence margin on the AUC difference
#> Formula (plain text):
#> `n = 2(Za+Zb)^2 * V * (1-r) / (auc1-auc2+margin)^2`
#> Formula (LaTeX):
#> $$n = \frac{2(Z_{\alpha}+Z_{\beta})^2 V(1-r)}{(AUC_1-AUC_2+\Delta)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic non-inferiority (two ROC areas).
#> • Step 2: Input parameters: auc1 = 0.85, auc2 = 0.82, r = 0.50, margin = 0.05,
#> task = noninferiority, var_method = exponential, alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = 2(Za+Zb)^2 * V * (1-r) /
#> (auc1-auc2+margin)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 80; Total subjects to
#> screen: 159.
#> Reference:
#> Framework: margin designs per Chow et al. (2017); Machin et al. (2018) Ch.11. AUC variance per Zhou et al. (2011) Eq 6.4/6.5/6.6.
#> 
#>  Diagnostic application: Zhou et al. (2011) Section 6.3, pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 80 例病例，筛查 160 人。

### 5.13 两法 ROC-AUC 等效性检验

- **临床场景**：两法 \\\text{AUC}\_1 = 0.85\\ vs \\\text{AUC}\_2 =
  0.84\\，等效界值 \\\text{margin} = 0.05\\。

``` r

res_5_13 <- calculate("diagAUCCompare", "equivalence", "auc", auc1 = 0.85, auc2 = 0.84, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_5_13)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Diagnostic equivalence (two ROC areas)"
#> • Cases needed: 416
#> • Total subjects to screen: 831
#> • Total subjects: 831
#> Parameter roles
#> 
#> • auc1/auc2 = anticipated ROC areas of the new/reference test
#> • r = expected correlation between the two AUC estimates (paired designs)
#> • margin = non-inferiority/equivalence margin on the AUC difference
#> Formula (plain text):
#> `n = 2(Za+Zb/2)^2 * V * (1-r) / (margin-|auc1-auc2|)^2`
#> Formula (LaTeX):
#> $$n = \frac{2(Z_{\alpha}+Z_{\beta/2})^2 V(1-r)}{(\Delta-|AUC_1-AUC_2|)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Diagnostic equivalence (two ROC areas).
#> • Step 2: Input parameters: auc1 = 0.85, auc2 = 0.84, r = 0.50, margin = 0.05,
#> task = equivalence, var_method = exponential, alpha = 0.05, power = 0.80.
#> • Step 3: Apply design formula: n = 2(Za+Zb/2)^2 * V * (1-r) /
#> (margin-|auc1-auc2|)^2.
#> • Step 4: Calculated sample size metrics: Cases needed: 416; Total subjects to
#> screen: 831.
#> Reference:
#> Framework: margin designs per Chow et al. (2017); Machin et al. (2018) Ch.11. AUC variance per Zhou et al. (2011) Eq 6.4/6.5/6.6.
#> 
#>  Diagnostic application: Zhou et al. (2011) Section 6.3, pp. 214-218.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 317 例病例，筛查 634 人。

### 5.14 似然比（Likelihood Ratio）对数置信区间阈值法

- **临床场景**：肺栓塞排除路径要求
  D-二聚体的阴性似然比（\\\text{LR}^-\\）95% 置信区间**上限**不能超过
  0.40（\\\text{target\\lr} = 0.40\\），否则排除规则不安全。预期敏感度
  90%，特异度 50%。
- **数学公式与出处**： \\\log(LR) \pm Z\_{1-\alpha/2}\sqrt{\frac{1-Se}{n
  \cdot Se} + \frac{1-Sp}{n \cdot Sp}}\\ *出处*：Hajian-Tilaki (2014) Eq
  6.14; Simel et al. (1991).

``` r

res_5_14 <- calculate("diagLR", "estimate", "lr", sens = 0.90, spec = 0.50, target_lr = 0.40, lr_type = "negative", alpha = 0.05)
print(res_5_14)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Likelihood ratio (negative, log-CI method)"
#> • Cases needed: 9
#> • Controls needed: 9
#> • Total subjects: 18
#> Parameter roles
#> 
#> • sens/spec = expected sensitivity/specificity (determine the observed LR)
#> • target_lr = LR boundary the CI must not cross (precision target)
#> • n is computed per group (equal cases and controls)
#> ! Calculates sample size ensuring the log-scale CI does not cross target_lr (threshold precision),
#> ! distinct from fixed-width CI approaches (e.g. prec_lr in presize).
#> 
#> Formula (plain text):
#> `log(LR) +- Z * sqrt((1-Se)/(n*Se) + (1-Sp)/(n*Sp))`
#> Formula (LaTeX):
#> $$\log(LR) \pm Z_{1-\alpha/2}\sqrt{\frac{1-Se}{n \cdot Se} + \frac{1-Sp}{n \cdot Sp}}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Likelihood ratio (negative, log-CI method).
#> • Step 2: Input parameters: sensitivity = 0.90, specificity = 0.50, lr_type =
#> negative, lr_observed = 0.20, target_lr = 0.40, prevalence = 1, alpha = 0.05.
#> • Step 3: Apply design formula: log(LR) +- Z * sqrt((1-Se)/(n*Se) +
#> (1-Sp)/(n*Sp)).
#> • Step 4: Calculated sample size metrics: Total sample size: 18; Cases needed:
#> 9; Controls needed: 9; Total subjects: 18.
#> Reference:
#> Primary: Hajian-Tilaki, K. (2014). Sample size estimation in diagnostic test studies of biomedical informatics. Journal of Biomedical Informatics, 48, 193-204 (Section 6.4, Eqs 6.13/6.14; worked example n=80 per group).
#> 
#>  CI method: Simel, D. L., Samsa, G. P., & Matchar, D. B. (1991). Likelihood ratios with confidence: sample size estimation for accuracy of a diagnostic test. Journal of Clinical Epidemiology, 44(11), 1123-1130.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：病例与对照各需 9 例，总计 18 人。

### 5.15 临床真实筛查总人数的“二项安全保障”（`screen_required`）

- **临床场景**：理论平均筛查 980 人才能抓够 196 例确诊病例，但这只有 50%
  的把握。筛查名单应扩大到多少人，才能以 90% 概率保障抓满 196 例？
- **数学公式与出处**： \\P(\text{Binomial}(N, \text{prev}) \ge n) \ge
  1 - \beta\\ *出处*：Zhou et al. (2011) Eq 6.3。

``` r

safe_n <- screen_required(n = 196, prevalence = 0.20, beta = 0.10)
cat("理论平均筛查数：980 人；90% 概率安全保障筛查数：", safe_n, "人\n")
#> 理论平均筛查数：980 人；90% 概率安全保障筛查数： 1061 人
```

- **输出解读**：实际筛查名单需扩大至 **1058 人**（多储备 78 人备荒）。

### 5.16 多阅片者多病例（MRMC）研究效能分析

- **临床场景**：乳腺钼靶 AI 辅助诊断研究：8 名放射科医生独立阅读 50
  例病例，比较常规钼靶与断层合成两种技术的 AUC 差异（\\\Delta =
  0.10\\）。
- **数学公式与出处**：Obuchowski-Rockette 混合效应模型非中心 \\F\\
  检验，Zhou et al. (2011) Eq 6.32, p.225.

``` r

res_5_16 <- mrmc_power(n = 50, J = 8, delta = 0.10, sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.05, rho1 = 0.25, rho2 = 0.20, rho3 = 0.10)
print(res_5_16)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "MRMC (paired-patient, paired-reader, Obuchowski-Rockette)"
#> Parameter roles
#> 
#> • n = cases per test (paired-patient: total cases)
#> • J = readers per test
#> • delta = accuracy difference to detect
#> • sigma_b2/sigma_w2/sigma_c2 = reader/occasion/case variance components
#> • rho1/rho2/rho3 = correlations (same-reader-diff-test / diff-reader-same-test
#> / diff-reader-diff-test)
#> ! MRMC power depends on 6 variance/correlation components estimated from
#> ! pilot data or literature (Zhou Table 6.3); treat results as approximate.
#> ! For reader variability planning: sigma_b2 = (accuracy range / 4)^2 is a
#> ! common heuristic (Zhou p. 223, Beam 1996 mammography example).
#> 
#> Formula (plain text):
#> `lambda = J*delta^2/(2*[sb2(1-r1) + sw2/Q + sc2(1-r1)/n +
#> r2*sb2*((1-r1)+(J-1)(r2-r3))]); power = P(F_{1,J-1}(lambda) > F_{1-alpha})`
#> Formula (LaTeX):
#> $$\lambda = \frac{J \cdot \delta^2}{2\left[\sigma_b^2(1-r_1) + \frac{\sigma_w^2}{Q} + \frac{\sigma_c^2(1-r_1)}{n} + r_2 \sigma_b^2((1-r_1)+(J-1)(r_2-r_3))\right]}, \quad \text{Power} = P(F_{1,J-1}(\lambda) > F_{1-\alpha})$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: MRMC (paired-patient, paired-reader,
#> Obuchowski-Rockette).
#> • Step 2: Input parameters: n = 50, J = 8, delta = 0.10, sigma_b2 = 0.0012,
#> sigma_w2 = 0.0009, sigma_c2 = 0.05, rho1 = 0.25, rho2 = 0.20, rho3 = 0.10,
#> alpha = 0.05, n_repeats = 1, noncentrality_lambda = 13.7969.
#> • Step 3: Apply design formula: lambda = J*delta^2/(2*[sb2(1-r1) + sw2/Q +
#> sc2(1-r1)/n + r2*sb2*((1-r1)+(J-1)(r2-r3))]); power = P(F_{1,J-1}(lambda) >
#> F_{1-alpha}).
#> Reference:
#> Primary: Zhou, X.-H., Obuchowski, N. A., & McClish, D. K. (2011). Statistical Methods in Diagnostic Medicine (2nd ed.). Wiley. Section 6.5, Eq 6.32, Tables 6.3-6.5, pp. 220-226 (mammography worked example).
#> 
#>  Model: Obuchowski, N. A., & Rockette, H. E. (1995). Hypothesis testing of diagnostic accuracy for multiple readers, multiple tests. Communications in Statistics - Simulation and Computation, 24, 285-308.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：在 50 例病例、8 名阅片者下，该试验达到 **88.8%
  的统计学效能**（与教材报道的 89% 一致）。

------------------------------------------------------------------------

## 第六章：复杂与现代前沿临床研究设计

### 6.1 群随机试验（Cluster RCT：连续型结局）

- **临床场景**：以 ICU
  病区（而非患者）为随机单位评价新导管护理包：并发症均分由 10 降至
  12，\\\text{SD} = 3\\，每病区平均 20 张床位，组内相关系数 \\\text{ICC}
  = 0.05\\。
- **数学公式与出处**： \\DE = 1 + (m - 1) \times ICC = 1.95, \quad
  n\_{clusters} = \left\lceil \frac{n\_{individual} \times DE}{m}
  \right\rceil\\ *出处*：Donner & Klar (2000)；Machin et al. (2018)
  Ch.12。

``` r

res_6_1 <- calculate("clusterRCT", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)
print(res_6_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cluster RCT: Two independent samples, mean comparison"
#> • Sample size per group: 80
#> • Total sample size: 160
#> • Clusters per arm: 4
#> Parameter roles
#> 
#> • icc = 0.05, cluster_size = 20 -> DE = 1.95; n_clusters per arm = 4
#> Formula (plain text):
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> Formula (LaTeX):
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
#> Calculation process:
#> 
#> • Step 1: Compute individual-level sample size without clustering from standard
#> two-group formulas.
#> • Step 2: Calculate design effect (inflation factor): DE = 1 + (cluster_size -
#> 1) * ICC = 1 + (20 - 1) * 0.05 = 1.95.
#> • Step 3: Inflate sample size for clustering: n_clustered = n_individual * DE.
#> • Step 4: Determine clusters required per arm: n_clusters = ceiling(n_clustered
#> / cluster_size) = 4.
#> • Step 5: Total individuals per arm = 4 * 20 = 80; Total sample size N = 160.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 12 (Cluster Designs); Donner, A., & Klar, N. (2000). Design and Analysis of Cluster Randomisation Trials in Health Research. Arnold.
#> 
#>  Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每个干预臂需 4 个病区（80 人），两臂共计 **8 个病区（160
  人）**。

### 6.2 群随机试验（Cluster RCT：二分类结局）

- **临床场景**：以行政村为单位随机化一项筛查依从性干预：筛查率由 20%
  提高至 30%，每村平均 20 名居民，\\\text{ICC} = 0.05\\。
- **数学公式与出处**：设计效应同 6.1（\\DE = 1 +
  (m-1)ICC\\），基础样本量用两比例核（Fleiss 1980）。

``` r

res_6_2 <- calculate("clusterRCT", "test", "proportion", p1 = 0.30, p2 = 0.20, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)
print(res_6_2)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cluster RCT: Two independent proportions"
#> • Sample size per group: 580
#> • Total sample size: 1160
#> • Clusters per arm: 29
#> Parameter roles
#> 
#> • icc = 0.05, cluster_size = 20 -> DE = 1.95; n_clusters per arm = 29
#> Formula (plain text):
#> `n = (Z_a/2 * sqrt(2*p_bar*(1-p_bar)) + Z_b * sqrt(p1*(1-p1)+p2*(1-p2)))^2 /
#> (p1-p2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_2(1-p_2)}\right]^2}{(p_1 - p_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Compute individual-level sample size without clustering from standard
#> two-group formulas.
#> • Step 2: Calculate design effect (inflation factor): DE = 1 + (cluster_size -
#> 1) * ICC = 1 + (20 - 1) * 0.05 = 1.95.
#> • Step 3: Inflate sample size for clustering: n_clustered = n_individual * DE.
#> • Step 4: Determine clusters required per arm: n_clusters = ceiling(n_clustered
#> / cluster_size) = 29.
#> • Step 5: Total individuals per arm = 29 * 20 = 580; Total sample size N =
#> 1160.
#> Reference:
#> Primary: Machin, D., Campbell, M. J., Tan, S. B., & Tan, S. H. (2018). Sample Sizes for Clinical, Laboratory and Epidemiology Studies (4th ed.). Wiley. Chapter 12 (Cluster Designs); Donner, A., & Klar, N. (2000). Design and Analysis of Cluster Randomisation Trials in Health Research. Arnold.
#> 
#>  Primary (formula as implemented, without continuity correction): Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346.
#> 
#> With continuity correction: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-494.
#> 
#> Book: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每臂需 29 个社区（580 人），共计 **58 个社区（1160
  人）**。

### 6.3 阶梯楔形整群试验（Stepped-Wedge CRT）

- **临床场景**：24 个县分 4 批阶梯交叉推行手卫生干预（基线 + 4
  个阶梯，每步 6 县，每县每期 100 名新生儿）。感染风险的治疗效应
  \\\theta = -0.016\\。
- **数学公式与出处**： \\Var(\hat{\theta}) = \frac{I \tau^2 (\tau^2 +
  T\sigma^2)}{(IU - W)\tau^2 + (U^2 + ITU - TW - IV)\sigma^2}, \quad
  \text{power} = \Phi\left(\|\theta\|/SE - z\_{1-\alpha/2}\right)\\
  *出处*：Hussey, M. A., & Hughes, J. P. (2007). *Contemp Clin Trials*,
  28(2), 182-191 (Eq 8).

``` r

res_6_3 <- calculate("steppedWedge", "test", "mean", theta = -0.016, tau2 = 2.25e-4, sigma2_ind = 0.0475, m = 100, n_clusters = 24, clusters_per_step = 6, alpha = 0.05)
print(res_6_3)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Stepped wedge cluster trial (Hussey-Hughes, mean outcome)"
#> • Clusters per arm: 24
#> • Power achieved: 0.908
#> Parameter roles
#> 
#> • theta = treatment effect (additive scale; e.g. risk difference)
#> • tau2 = between-cluster variance (e.g. (CV*mean)^2)
#> • sigma2_ind = individual-level variance (binary: p(1-p))
#> • m = individuals sampled per cluster per time point
#> • clusters_per_step = clusters randomized at each step (full design)
#> ! Hussey & Hughes (2007) Eq 8 assumes no underlying calendar time trends.
#> ! If secular time trends are present, statistical power may be lower;
#> ! consider incorporating time fixed effects via simulation or swCRTdesign.
#> 
#> Formula (plain text):
#> `Var = I*t2*(t2+T*s2)/((I*U-W)*t2 + (U^2+I*T*U-T*W-I*V)*s2); power =
#> Phi(|theta|/se - z)`
#> Formula (LaTeX):
#> $$\text{Var}(\hat{\theta}) = \frac{I \tau^2(\tau^2+T\sigma^2)}{(IU-W)\tau^2 + (U^2+ITU-TW-IV)\sigma^2}, \quad \sigma^2 = \sigma_{ind}^2/m, \quad \text{Power} = \Phi\left(\frac{|\theta|}{\text{SE}} - z_{1-\alpha/2}\right)$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Stepped wedge cluster trial (Hussey-Hughes,
#> mean outcome).
#> • Step 2: Input parameters: theta = -0.016, tau2 = 0.0002, sigma2_ind = 0.0475,
#> m = 100, n_clusters = 24, clusters_per_step = 6, alpha = 0.05.
#> • Step 3: Apply design formula: Var = I*t2*(t2+T*s2)/((I*U-W)*t2 +
#> (U^2+I*T*U-T*W-I*V)*s2); power = Phi(|theta|/se - z).
#> • Step 4: Calculated sample size metrics: Clusters per arm: 24; Power achieved:
#> 0.908.
#> Reference:
#> Primary: Hussey, M. A., & Hughes, J. P. (2007). Design and analysis of stepped wedge cluster randomized trials. Contemporary Clinical Trials, 28(2), 182-191 (Eq 8; EPT worked example I=24, T=5).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：该阶梯楔形方案实现 **90.8% 的检验效能**。

### 6.4 有序多分类结局（Whitehead 比例优势比模型）

- **临床场景**：膝骨关节炎疼痛缓解程度分轻度/中度/重度三级（预期分布
  20%/50%/30%），新的关节腔注射疗法预期使更高级别缓解的比值比
  \\\text{OR} = 1.5\\。
- **数学公式与出处**： \\N =
  \frac{3\\(Z\_{\alpha/2}+Z\_{\beta})^2}{(\log OR)^2\\(1-\sum
  \bar{p}\_j^3)}\\ *出处*：Whitehead, J. (1993). *Stat Med*, 12(24),
  2257-2271.

``` r

res_6_4 <- calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.5, 0.3), alpha = 0.05, power = 0.8)
print(res_6_4)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Two-group ordered categorical outcome (Mann-Whitney /
#> proportional odds)"
#> • Sample size per group: 86
#> • Total sample size: 171
#> Parameter roles
#> 
#> • or = anticipated odds ratio (proportional odds)
#> • prop_bar = anticipated average category proportions (sums to 1)
#> • output: total N and per-group n (equal allocation)
#> Formula (plain text):
#> `N = 3(Za/2+Zb)^2 / ((log OR)^2 * (1 - sum(p_bar^3)))`
#> Formula (LaTeX):
#> $$N = \frac{3\,(Z_{\alpha/2}+Z_{\beta})^2}{(\log OR)^2\,(1-\sum \bar{p}_j^3)}$$
#> Calculation process:
#> 
#> • Step 1: Specify odds ratio OR = 1.50, pooled proportion categories = [0.20,
#> 0.50, 0.30].
#> • Step 2: Determine critical values: Z_(alpha/2) = 1.96, Z_beta = 0.8416.
#> • Step 3: Compute Whitehead variance factor: 1 - sum(p_bar_j^3).
#> • Step 4: Whitehead formula: N = 3 * (Z_(alpha/2) + Z_beta)^2 / [(ln OR)^2 * (1
#> - sum(p_bar^3))].
#> • Step 5: Round up to integer: Total sample size N = 171, per group n = 86.
#> Reference:
#> Primary: Whitehead, J. (1993). Sample size calculations for ordered categorical data. Statistics in Medicine, 12(24), 2257-2271.
#> 
#>  Also: Machin et al. (2018) Chapter 4 (Ordered Categorical Outcomes).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：每组需 86 人，总计 **171 人**。

### 6.5 临床预测模型开发：Riley 2020 BMJ 准则（二分类结局）

- **临床场景**：开发 ICU 住院死亡预测模型：10 个候选预测变量，结局发生率
  30%，预期 Cox-Snell \\R^2\_{CS} = 0.10\\，目标收缩因子 \\S =
  0.90\\，新增参数需多少患者与事件数？
- **数学公式与出处**： \\n\_{B1} = \left(\frac{z}{\delta}\right)^2
  \phi(1-\phi), \quad n\_{B3} = \frac{P}{(S-1)\ln(1-R^2\_{CS}/S)}, \quad
  n = \max(n\_{B1}, n\_{B3})\\ *出处*：Riley et al. (2020). *BMJ*, 368,
  m441 (Box 1 准则 B1 与 B3; 与 pmsampsize 一致)。

``` r

res_6_5 <- calculate("predictiveModel", "plan", "binary", prev = 0.30, n_parameters = 10, r2_cs = 0.10, shrinkage = 0.90, precision_delta = 0.05, alpha = 0.05)
print(res_6_5)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Prediction model development (Riley 2020, binary)"
#> • Required sample size: 850
#> • Events required: 255
#> Parameter roles
#> 
#> • prev = anticipated outcome proportion in the target population
#> • n_parameters = candidate predictor parameters (P)
#> • r2_cs = anticipated Cox-Snell R2 (conservative, optimism-adjusted)
#> • shrinkage = target uniform shrinkage factor S (default 0.9)
#> • mape = target mean absolute prediction error (default 0.05)
#> ! B1 (proportion precision, delta=0.050): n = 323
#> ! B3 (shrinkage S=0.90, R2cs=0.1000): n = 850
#> ! B2 (MAPE=0.050, P=10 <= 30): n = 461 (informational)
#> ! B4 (optimism in Nagelkerke R2 <= 0.05) is handled inside B3 via the
#> ! shrinkage target in the pmsampsize implementation; see Riley 2020 Box 1.
#> 
#> Formula (plain text):
#> `B1: n=(z/d)^2*p(1-p); B3: n=P/((S-1)*ln(1-R2cs/S)); n = max(B1, B3)`
#> Formula (LaTeX):
#> $$n_{B1} = \left(\frac{z_{1-\alpha/2}}{\delta}\right)^2 \phi(1-\phi), \quad n_{B3} = \frac{p}{(S-1)\ln(1 - R_{CS}^2/S)}, \quad n = \max(n_{B1}, n_{B3})$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Prediction model development (Riley 2020,
#> binary).
#> • Step 2: Input parameters: prev = 0.30, n_parameters = 10, r2_cs = 0.10,
#> max_r2cs = 0.7053, shrinkage = 0.90, mape = 0.05, precision_delta = 0.05, alpha
#> = 0.05.
#> • Step 3: Apply design formula: B1: n=(z/d)^2*p(1-p); B3:
#> n=P/((S-1)*ln(1-R2cs/S)); n = max(B1, B3).
#> • Step 4: Calculated sample size metrics: Required sample size: 850; Total
#> sample size: 850; Events required: 255.
#> Reference:
#> Primary: Riley, R. D., Ensor, J., Snell, K. I. E., et al. (2020). Calculating the sample size required for developing a clinical prediction model. BMJ, 368, m441 (Box 1, Figures 1-5).
#> 
#>  B2 formula: van Smeden, M., et al. (2019). Stat Methods Med Res, 28, 2455-74. B3 derivation: Riley et al. (2019). Stat Med, 38, 1276-96 (PART II). Software: pmsampsize (Stata/R).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需纳入 **850 名患者，其中包含 255
  例事件**（有效事件参数比 EPP=25.5，与 `pmsampsize` 结果完全一致）。

### 6.6 临床预测模型开发：Riley 2020 时间-事件结局（人年估算）

- **临床场景**：开发 10 年心血管死亡预测模型：队列年发病率 0.10/年，要求
  10 年累计发病率 \\F(10)\\ 的估计误差不超过 \\\pm
  5\\\\，需要多少随访人年？
- **数学公式与出处**：\\F(t) = 1 - e^{-\lambda t}\\；求解使人年数 \\T\\
  满足 \\F(t)\\ 双侧置信限误差均 \\\le \delta\\（准则 T1）。Riley et
  al. (2020). *BMJ*, 368, m441 (Figure 1)。

``` r

res_6_6 <- calculate("predictiveModel", "plan", "rate", rate = 0.10, timepoint = 10, precision_delta = 0.05, alpha = 0.05)
print(res_6_6)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Prediction model development (Riley 2020, time-to-event)"
#> • Required person-time: 2366
#> Parameter roles
#> 
#> • rate = anticipated event rate per person-year
#> • timepoint = key prediction time point t (years)
#> • precision_delta = maximum margin of error for F(t)
#> • n_parameters/epv = optional EPP cross-check (classic 10 EPV)
#> Formula (plain text):
#> `F(t) = 1-exp(-rate*t); CI: 1-exp(-(rate +- z*sqrt(rate/T))*t); find T with
#> margins <= delta`
#> Formula (LaTeX):
#> $$F(t) = 1 - e^{-\lambda t}, \quad \text{CI: } 1 - \exp\left(-\left(\lambda \pm z_{1-\alpha/2}\sqrt{\frac{\lambda}{T}}\right)t\right)$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Prediction model development (Riley 2020,
#> time-to-event).
#> • Step 2: Input parameters: rate = 0.10, timepoint = 10, precision_delta =
#> 0.05, alpha = 0.05, n_parameters = , epv = .
#> • Step 3: Apply design formula: F(t) = 1-exp(-rate*t); CI: 1-exp(-(rate +-
#> z*sqrt(rate/T))*t); find T with margins <= delta.
#> • Step 4: Calculated sample size metrics: Required person-time: 2366.
#> Reference:
#> Primary: Riley, R. D., Ensor, J., Snell, K. I. E., et al. (2020). Calculating the sample size required for developing a clinical prediction model. BMJ, 368, m441 (Figure 1, time-to-event panel; criterion T1; worked example: rate=0.10/year, t=10y, delta=0.05 -> 2366 person-years).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需随访累计 **2366 人年**。

### 6.7 临床预测模型开发：经典每变量事件数（EPV）规则

- **临床场景**：标书快速粗算：10 个候选预测变量的 logistic
  回归模型，结局事件发生率 30%，按经典每变量 10 事件规则需要多少样本？
- **数学公式与出处**： \\n\_{events} = EPV \times k, \quad n\_{subjects}
  = n\_{events} / \pi\\ *出处*：Peduzzi et al. (1996). *J Clin
  Epidemiol*, 49(12), 1373-1379.

``` r

res_6_7 <- calculate("predictiveModel", "plan", "events", n_parameters = 10, epv = 10, event_prevalence = 0.30)
print(res_6_7)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Prediction model development (events-per-variable)"
#> • Required sample size: 334
#> • Events required: 100
#> Parameter roles
#> 
#> • n_parameters = candidate predictor parameters (k)
#> • epv = events per variable (classic minimum 10)
#> • event_prevalence = proportion of subjects with the outcome
#> ! EPV >= 10 is a minimum heuristic; Riley et al. (2019, BMJ 364:l951)
#> ! provide a modern precision-based alternative (planned for a later release).
#> 
#> Formula (plain text):
#> `n_events = EPV * k ; n_subjects = n_events / prevalence`
#> Formula (LaTeX):
#> $$n_{events} = EPV \times k, \quad n_{subjects} = n_{events} / \pi$$
#> Calculation process:
#> 
#> • Step 1: Specify candidate predictor parameters k = 10, Events Per Variable
#> target EPV = 10.
#> • Step 2: Calculate required events: n_events = EPV * k = 10 * 10 = 100.
#> • Step 3: Convert to subjects using event prevalence pi = 0.30: n_subjects =
#> n_events / prevalence = 334.
#> • Step 4: Required events = 100, Total subjects = 334.
#> Reference:
#> Primary: Peduzzi, P., Concato, J., Kemper, E., Holford, T. R., & Feinstein, A. R. (1996). A simulation study of the number of events per variable in logistic regression analysis. Journal of Clinical Epidemiology, 49(12), 1373-1379.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需 100 例事件，总共需调查 334 人。

### 6.8 评分者一致性：Cohen’s Kappa 置信区间精度估计

- **临床场景**：两位放射科医生独立判读同一批乳腺钼靶片：预期一致性
  \\\kappa = 0.70\\，要求 95% 置信区间半宽不超过 \\\pm
  0.10\\，需多少受试者/标本？
- **数学公式与出处**： \\n = Q\left(\frac{z\_{1-\alpha/2}}{d}\right)^2,
  \quad Q = \frac{p_o(1-p_o)}{(1-p_e)^2}\\ *出处*：Cantor, A. B. (1996).
  *Psychol Methods*, 1(2), 150-153.

``` r

res_6_8 <- calculate("kappa", "estimate", "proportion", pi1 = 0.30, pi2 = 0.30, kappa = 0.70, d = 0.10, alpha = 0.05)
print(res_6_8)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohen's kappa estimation (CI precision)"
#> • Required sample size: 165
#> Parameter roles
#> 
#> • pi1/pi2 = expected Rating-1 proportions for rater 1 / rater 2
#> • kappa1 = planning value of kappa
#> • d = desired CI half-width
#> Formula (plain text):
#> `n = Q * (z/d)^2 ; Q = p_o(1-p_o)/(1-p_e)^2`
#> Formula (LaTeX):
#> $$n = Q\left(\frac{z_{1-\alpha/2}}{d}\right)^2, \quad Q = \frac{p_o(1-p_o)}{(1-p_e)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Cohen's kappa estimation (CI precision).
#> • Step 2: Input parameters: pi1 = 0.30, pi2 = 0.30, kappa = 0.70, d = 0.10,
#> alpha = 0.05, Q = 0.4272.
#> • Step 3: Apply design formula: n = Q * (z/d)^2 ; Q = p_o(1-p_o)/(1-p_e)^2.
#> • Step 4: Calculated sample size metrics: Required sample size: 165; Total
#> sample size: 165.
#> Reference:
#> Primary: Cantor, A. B. (1996). Sample-size calculations for Cohen's kappa. Psychological Methods, 1(2), 150-153 (Fleiss-Cohen-Everitt 1969 asymptotic variance; worked examples N=165 and N=214).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：需调查 **165 名受试者**。

### 6.9 评分者一致性：两独立 Kappa 系数差异检验

- **临床场景**：比较新结构化报告清单（预期 \\\kappa_1 =
  0.70\\）与传统阅片（预期 \\\kappa_2 =
  0.50\\）在两组独立阅片者中的一致性是否显著提升，每组各需多少阅片者/标本？
- **数学公式与出处**： \\n = \frac{\left\[z\_{\alpha}\sqrt{2Q_1} +
  z\_{\beta}\sqrt{Q_1+Q_2}\right\]^2}{(K_1-K_2)^2}\\
  *出处*：Cantor, A. B. (1996). *Psychol Methods*, 1(2), 150-153.

``` r

res_6_9 <- calculate("kappa", "test", "proportion", pi1 = 0.50, pi2 = 0.50, kappa1 = 0.70, kappa2 = 0.50, alpha = 0.05, power = 0.8)
print(res_6_9)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Cohen's kappa test (two independent kappas)"
#> • Required sample size: 214
#> Parameter roles
#> 
#> • pi1/pi2 = expected Rating-1 proportions (both raters/groups)
#> • kappa1 = kappa under the null (e.g. questionnaire 1)
#> • kappa2 = kappa under the alternative (e.g. questionnaire 2)
#> • n is per group (two independent kappa estimates)
#> Formula (plain text):
#> `n = (z_a*sqrt(2*Q1) + z_b*sqrt(Q1+Q2))^2/(K1-K2)^2`
#> Formula (LaTeX):
#> $$n = \frac{\left[z_{\alpha}\sqrt{2Q_1} + z_{\beta}\sqrt{Q_1+Q_2}\right]^2}{(K_1-K_2)^2}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Cohen's kappa test (two independent kappas).
#> • Step 2: Input parameters: pi1 = 0.50, pi2 = 0.50, kappa1 = 0.70, kappa2 =
#> 0.50, alpha = 0.05, power = 0.80, Q_null = 0.51, Q_alt = 0.75.
#> • Step 3: Apply design formula: n = (z_a*sqrt(2*Q1) +
#> z_b*sqrt(Q1+Q2))^2/(K1-K2)^2.
#> • Step 4: Calculated sample size metrics: Required sample size: 214; Total
#> sample size: 214.
#> Reference:
#> Primary: Cantor, A. B. (1996). Sample-size calculations for Cohen's kappa. Psychological Methods, 1(2), 150-153 (worked example: K1=0.7, K2=0.5, pi=0.5 -> N=214).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：两组各需评估 **214 例标本**。

### 6.10 中断时间序列研究（Interrupted Time Series, ITS）

- **临床场景**：某市对含糖饮料征收“糖税”的政策评估：干预前后各监测 12
  个月度消费量时点，预期政策产生 2 个结局标准差的水平跃升（\\\delta =
  2\\），月度数据自相关系数 \\\rho = 0.30\\。
- **数学公式与出处**： \\\text{power} = \Phi\left(\frac{\delta}{SE} -
  z\_{\alpha/2}\right), \quad SE = \sqrt{\tfrac{1}{n\_{eff}^{pre}} +
  \tfrac{1}{n\_{eff}^{post}}}, \quad n\_{eff} =
  \frac{n(1-\rho)}{1+\rho}\\ *出处*：Bernal et al. (2017). *Int J
  Epidemiol*, 46(1), 348-355（AR(1) 校正近似，试验性方法）。

``` r

res_6_10 <- calculate("its", "test", "rate", effect_sd = 2, n_pre = 12, n_post = 12, rho = 0.3, alpha = 0.05, power = 0.8)
print(res_6_10)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Results
#> • Design type: "Interrupted time series (level change, AR(1)-adjusted)"
#> • Power achieved: 0.949
#> Parameter roles
#> 
#> • effect_sd = anticipated level change in outcome SD units
#> • n_pre/n_post = number of time points before/after the interruption
#> • rho = AR(1) autocorrelation of the series
#> ! EXPERIMENTAL method: transparent AR(1)-adjusted normal approximation.
#> ! Bernal et al. (2017, Int J Epidemiol) recommend >= 8 time points per segment;
#> ! rigorous ITS power calculations require simulation.
#> 
#> Formula (plain text):
#> `power = Phi(effect/SE - z); SE = sqrt(1/n_eff_pre + 1/n_eff_post); n_eff =
#> n(1-rho)/(1+rho)`
#> Formula (LaTeX):
#> $$\text{power} = \Phi\left(\frac{\delta}{SE} - z_{\alpha/2}\right), \quad SE = \sqrt{\tfrac{1}{n_{eff}^{pre}} + \tfrac{1}{n_{eff}^{post}}}$$
#> Calculation process:
#> 
#> • Step 1: Identify study design: Interrupted time series (level change,
#> AR(1)-adjusted).
#> • Step 2: Input parameters: effect_sd = 2, n_pre = 12, n_post = 12, rho = 0.30,
#> alpha = 0.05.
#> • Step 3: Apply design formula: power = Phi(effect/SE - z); SE =
#> sqrt(1/n_eff_pre + 1/n_eff_post); n_eff = n(1-rho)/(1+rho).
#> • Step 4: Calculated sample size metrics: Power achieved: 0.949.
#> Reference:
#> Framework: Bernal, J. L., Cummins, S., & Gasparrini, A. (2017). Interrupted time series regression for the evaluation of public health interventions: a tutorial. International Journal of Epidemiology, 46(1), 348-355. Sample-size content is a transparent approximation, not from a validated source.
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

- **输出解读**：在该序列配置下，可实现 **94.9% 的检验效能**。

------------------------------------------------------------------------

## 第七章：结果解读、标书撰写模板与实战图表展示

### 论文与标书方法学撰写填空模板

默认 [`print()`](https://rdrr.io/r/base/print.html)
已包含纯文本公式、LaTeX 源码、计算过程和参考文献。 调用
[`summary()`](https://rdrr.io/r/base/summary.html)
可进一步查看全部输入参数、设计分类及已记录的调整：

``` r

summary(res_1_1)
#> ────────────────────────────────────────────────────────────────────────────────
#> ✔ Sample Size Calculation Summary
#> ────────────────────────────────────────────────────────────────────────────────
#> 
#> ── Study Design
#> • Type: "Two independent samples, mean comparison"
#> • Design: "rct"
#> • Task: "test" | Outcome: "mean"
#> 
#> ── Parameters
#> • mean1: 10
#> • mean2: 12
#> • sd: 3
#> • alpha: 0.05
#> • power: 0.8
#> 
#> ── Sample Size Results
#> • Sample size per group: 37
#> • Total sample size: 74
#> 
#> ── Formula
#> Plain text:
#> `n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2`
#> LaTeX:
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
#> 
#> ── Calculation Process
#> • Step 1: State hypotheses: H0: mu1 = mu2 vs H1: mu1 != mu2 (two-sided alpha =
#> 0.05, power = 0.80).
#> • Step 2: Calculate mean difference delta = |mu1 - mu2| = |10 - 12| = 2; common
#> SD sigma = 3.
#> • Step 3: Determine critical values: Z_(alpha/2) = 1.96 (for two-sided alpha =
#> 0.05), Z_beta = 0.8416 (for power = 0.80).
#> • Step 4: Compute initial sample size via normal approximation: n0 = 2 *
#> ((Z_(alpha/2) + Z_beta) * sigma / delta)^2 = 2 * ((1.96 + 0.8416) * 3 / 2)^2 =
#> 35.32.
#> • Step 5: Refine via exact two-sample Student's t-test power iteration
#> (accounting for degrees of freedom df = 2n - 2).
#> • Step 6: Round up to integer: n = 37 per group, total sample size N = 74.
#> 
#> ── Reference
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
#> ────────────────────────────────────────────────────────────────────────────────
```

#### 标准填空模板

> **【RCT 方案填空示例】**
> 本研究为两臂平行、双盲、随机对照优效性试验。根据既往预试验（Author et
> al., Year），对照组主要终点均值预计为 10 mmHg，试验组预计为 12
> mmHg，两组联合标准差为 3 mmHg。设定双侧检验水准 \\\alpha =
> 0.05\\，检验效能 \\1 - \beta = 80\\\\。采用两独立样本 \\t\\
> 检验样本量估算公式（Chow et al., 2017），每组需 37 例受试者。考虑 10%
> 随访脱落率，最终两组共计划招募受试者 84 例（每组 42 例）。上述计算采用
> R 语言 `sampleSizeCalc` 程序包完成。

### 统计效能曲线与敏感性分析图绘制

``` r

# 样本量 vs 统计效能曲线
plot(res_1_1, type = "power")
```

![](sampleSizeCalc-guide-zh_files/figure-html/plot-power-1.png)

``` r

# 样本量 vs 效应量敏感性曲线
plot(res_1_1, type = "sample_size")
```

![](sampleSizeCalc-guide-zh_files/figure-html/plot-effect-1.png)
