# sampleSizeCalc 完整使用指南：全场景临床科研样本量计算（零基础到精通）

## 引言：为什么样本量计算是临床研究的第一生命线？

很多临床医生在申报国家自然科学基金、撰写临床试验方案（Protocol）或提交伦理审查时，最容易被评审专家质疑的就是**样本量计算依据**。

不经严谨测算就随意定一个样本量（比如“凭经验随访 50
例”），会面临两大致命风险： 1.
**样本量过小（Underpowered，检验效能不足）**：哪怕药物真有疗效，因为人数太少，微弱的信号会被人体的抽样波动彻底掩盖，最终
$`P > 0.05`$，得出“无统计学显著差异”的假阴性结论，浪费科研经费与受试者心血。
2.
**样本量过大（Overpowered，不符合医学伦理）**：纳入过多患者不仅拖延试验周期，更在伦理上让多余的受试者暴露在未知疗效或有潜在副作用的试验药物中。

`sampleSizeCalc`（临床研究样本量计算器）覆盖了现代临床科研从经典双臂
RCT、流行病学调查，到前沿的 Simon
两阶段肿瘤试验、生物等效性（BE）、多阅片者诊断试验（MRMC）以及 BMJ
最新的 Riley 2020 预测模型样本量规则等 **42 个具体场景**。

**每一次计算，都会输出学术级 LaTeX
公式、精确到章节和页码的文献出处、以及参数角色说明，可直接写入申报书与伦理文件！**

------------------------------------------------------------------------

## 统计零基础必读：核心概念通俗白话字典

- **$`\alpha`$（I 类错误 / 假阳性率 / 显著性水平）**：
  - *通俗比喻*：**“法官冤枉好人的概率”**。新药明明没有用，但巧合之下我们误认为新药有用的概率。
  - *常规取值*：国际学术界惯例设为 **0.05（即
    5%）**。单侧检验（如非劣效试验）常设为 0.025 或 0.05。
- **$`\text{Power} = 1 - \beta`$（检验效能 / 统计学把握度）**：
  - *通俗比喻*：**“警察抓出真凶的把握”**。新药确实有用时，我们的试验能以多大的概率把它检测出来。
  - *常规取值*：通常设为 **0.80（80%）** 或
    **0.90（90%）**。把握度要求越高，需要招募的患者越多。
- **连续型指标（Mean，均数） vs 二分类指标（Proportion，比例）**：
  - *连续型指标*：测量出来是具体数值，如收缩压降幅（mmHg）、空腹血糖（mmol/L）。核心参数是“均数差（$`\Delta`$）”与“标准差（$`\sigma`$,
    SD）”。
  - *二分类指标*：只有“有效/无效”、“治愈/未治愈”，如有效率 80%、死亡率
    15%。
- **双侧检验（Two-sided） vs 单侧检验（One-sided）**：
  - *双侧检验*：事先不确定新药到底会比对照组好还是差，两头都看（经典临床试验通用）。
  - *单侧检验*：只关心新药是否优于对照药，或者新药是否“不差于”对照药（非劣效/优效性试验通用）。
- **脱落率（Dropout Rate）**：
  - 随访中患者失访或退出。设计划脱落率为 $`d`$（如
    10%），目标样本量需放大：$`N_{\text{screen}} = \lceil N / (1 - d) \rceil`$。

------------------------------------------------------------------------

## 核心语法：统一三轴入口 `calculate()`

在 `sampleSizeCalc` 中，所有计算统一汇聚为一个函数：

\$\$\Large \texttt{calculate(design, task, outcome, ...)}\$\$

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
  mmHg；试验组预计降低 12 mmHg（差值 $`\Delta = 2`$
  mmHg）。标准差（SD）约为 3 mmHg。设定双侧
  $`\alpha = 0.05`$、$`\text{Power} = 80\%`$。
- **数学公式与出处**：
  ``` math
  n = 2 \left( \frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2} \right)^2
  ```
  *出处*：Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017).
  *Sample Size Calculations in Clinical Research* (3rd ed.). CRC Press.
- **参数说明**：`mean1`, `mean2` 为两组均值；`sd`
  为合并标准差（$`>0`$）。

``` r

res_1_1 <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, alpha = 0.05, power = 0.8)
print(res_1_1)
```

- **输出解读**：每组需 37 人，总计 74 人。

### 1.2 两独立样本比例比较（二分类治愈率）

- **临床场景**：消化内科评价幽门螺杆菌根除率。传统三联方案为
  70%（$`p_2 = 0.70`$），新方案预计达 85%（$`p_1 = 0.85`$）。设定双侧
  $`\alpha = 0.05`$、$`\text{Power} = 80\%`$。
- **数学公式与出处**：
  ``` math
  n = \frac{\left[ Z_{\alpha/2}\sqrt{2\bar{p}(1-\bar{p})} + Z_{\beta}\sqrt{p_1(1-p_1) + p_2(1-p_2)} \right]^2}{(p_1 - p_2)^2}
  ```
  *出处*：Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). *Biometrics*,
  36(2), 343-346.

``` r

res_1_2 <- calculate("rct", "test", "proportion", p1 = 0.85, p2 = 0.70, alpha = 0.05, power = 0.8)
print(res_1_2)
```

- **输出解读**：每组需 121 人，总计 242 人。

### 1.3 生存分析与 Log-Rank 检验（时间-事件结局）

- **临床场景**：肺癌靶向治疗。预期风险比（Hazard Ratio,
  $`\text{HR} = 0.70`$），试验组与对照组 1:1 分组，检验效能 80%。
- **数学公式与出处**：
  ``` math
  E = \frac{(Z_{\alpha/2} + Z_{\beta})^2}{p_E(1 - p_E) [\ln(HR)]^2}
  ```
  *出处*：Schoenfeld, D. A. (1983). *Biometrics*, 39(2), 499-503.

``` r

res_1_3 <- calculate("rct", "test", "survival", hr = 0.70, pE = 0.50, alpha = 0.05, power = 0.8)
print(res_1_3)
```

- **输出解读**：试验需随访至累计发生 **247 例终点事件（死亡/复发）**。

### 1.4 均数非劣效性检验（Non-Inferiority, Mean）

- **临床场景**：评价国产降糖药是否不劣于进口原研药。试验组预期降低 HbA1c
  1.0%（$`\mu_1 = 10`$），对照组降低 0.95%（$`\mu_2 = 9.5`$），标准差
  $`\text{SD} = 3`$，临床可接受非劣效界值 $`\text{margin} = 1.0`$。
- **数学公式与出处**：
  ``` math
  n = 2\left(\frac{(Z_{\alpha} + Z_{\beta})\sigma}{\mu_1 - \mu_2 + \Delta}\right)^2
  ```
  *出处*：Chow et al. (2017) Chapter 4. 单侧 $`\alpha = 0.05`$。

``` r

res_1_4 <- calculate("rct", "noninferiority", "mean", mean1 = 10, mean2 = 9.5, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_4)
```

- **输出解读**：每组需 50 人，两组总计 100 人。

### 1.5 比例非劣效性检验（Non-Inferiority, Proportion）

- **临床场景**：仿制抗生素口服有效率 85% 对比原研药 85%，非劣效界值设为
  5%（$`\text{margin} = 0.05`$）。
- **数学公式与出处**：
  ``` math
  n = \frac{(Z_{\alpha} + Z_{\beta})^2 [p_1(1-p_1) + p_2(1-p_2)]}{(p_1 - p_2 + \Delta)^2}
  ```
  *出处*：Chow et al. (2017); Machin et al. (2018) Ch.11.

``` r

res_1_5 <- calculate("rct", "noninferiority", "proportion", p1 = 0.85, p2 = 0.85, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_1_5)
```

- **输出解读**：每组需 631 人，总计 1262 人。

### 1.6 均数优效性检验（Superiority, Mean）

- **临床场景**：新药降压效果不仅要好于对照药，而且必须超越预设的有临床价值的界限（$`\text{margin} = 1`$
  mmHg）。预期新药降 12 mmHg，对照降 10 mmHg，$`\text{SD} = 3`$。
- **数学公式与出处**：
  ``` math
  n = 2\left(\frac{(Z_{\alpha} + Z_{\beta})\sigma}{\mu_1 - \mu_2 - \Delta}\right)^2
  ```
  *出处*：Chow et al. (2017). 单侧 $`\alpha = 0.05`$。

``` r

res_1_6 <- calculate("rct", "superiority", "mean", mean1 = 12, mean2 = 10, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_6)
```

- **输出解读**：每组需 112 人，总计 224 人。

### 1.7 比例优效性检验（Superiority, Proportion）

- **临床场景**：新抗真菌药治愈率预期为 30%，对照药为
  20%，要求优效界值至少超过 5%（$`\text{margin} = 0.05`$）。
- **数学公式与出处**：
  ``` math
  n = \frac{(Z_{\alpha} + Z_{\beta})^2 [p_1(1-p_1) + p_2(1-p_2)]}{(p_1 - p_2 - \Delta)^2}
  ```
  *出处*：Chow et al. (2017).

``` r

res_1_7 <- calculate("rct", "superiority", "proportion", p1 = 0.30, p2 = 0.20, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_1_7)
```

- **输出解读**：每组需 916 人，总计 1832 人。

### 1.8 均数等效性检验（Equivalence, Mean）

- **临床场景**：证明两种降糖药疗效在临床上等效。两组均值差预期为 0.2
  mmol/L，临床等效边界为 $`\pm 1.0`$
  mmol/L（$`\text{margin} = 1.0`$），$`\text{SD} = 3`$。
- **数学公式与出处**：
  ``` math
  n = 2\left(\frac{(Z_{\alpha} + Z_{\beta/2})\sigma}{\Delta - |\mu_1 - \mu_2|}\right)^2
  ```
  *出处*：Chow et al. (2017).

``` r

res_1_8 <- calculate("rct", "equivalence", "mean", mean1 = 10, mean2 = 10.2, sd = 3, margin = 1, alpha = 0.05, power = 0.8)
print(res_1_8)
```

- **输出解读**：每组需 241 人，总计 482 人。

### 1.9 比例等效性检验（Equivalence, Proportion）

- **临床场景**：两种镇痛药有效率分别为 50% 与 52%，临床等效区间为
  $`\pm 10\%`$（$`\text{margin} = 0.10`$）。
- **数学公式与出处**：
  ``` math
  n = \frac{(Z_{\alpha} + Z_{\beta/2})^2 [p_1(1-p_1) + p_2(1-p_2)]}{(\Delta - |p_1 - p_2|)^2}
  ```
  *出处*：Chow et al. (2017).

``` r

res_1_9 <- calculate("rct", "equivalence", "proportion", p1 = 0.50, p2 = 0.52, margin = 0.10, alpha = 0.05, power = 0.8)
print(res_1_9)
```

- **输出解读**：每组需 669 人，总计 1338 人。

------------------------------------------------------------------------

## 第二章：配对、单臂与交叉临床试验

### 2.1 配对均数比较（自身前后对照）

- **临床场景**：同一批哮喘患者服药前后用力肺活量（FVC）差值平均为 2
  L，差值的标准差 $`\text{SD}_{\text{diff}} = 3`$ L。
- **数学公式与出处**：
  ``` math
  n = \left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma_d}{\mu_d}\right)^2
  ```
  *出处*：Rosner, B. (2015). *Fundamentals of biostatistics* (8th ed.).
  Cengage Learning.

``` r

res_2_1 <- calculate("paired", "test", "mean", meanDiff = 2, sdDiff = 3, alpha = 0.05, power = 0.8)
print(res_2_1)
```

- **输出解读**：需纳入 **20 对受试者（40 人次前后测量）**。

### 2.2 配对二分类比较（McNemar / Connor）

- **临床场景**：同一批病人分别做两套检查，阳性率 80% vs
  60%，预期不一致对占总人数比例 $`\psi = 0.25`$。
- **数学公式与出处**：
  ``` math
  n_{\text{pairs}} = \frac{\left[ Z_{\alpha/2}\sqrt{\psi} + Z_{\beta}\sqrt{\psi - (p_1 - p_2)^2} \right]^2}{(p_1 - p_2)^2}
  ```
  *出处*：Connor, R. J. (1987). *Biometrics*, 43(1), 207-211.

``` r

res_2_2 <- calculate("paired", "test", "proportion", p1 = 0.80, p2 = 0.60, psi = 0.25, alpha = 0.05, power = 0.8)
print(res_2_2)
```

- **输出解读**：需纳入 **47 对受试者**。

### 2.3 单臂试验对比已知常模均值

- **临床场景**：某罕见病历史平均生存期为 10
  个月（$`\mu_0 = 10`$），新疗法预期可延长至 12
  个月（$`\mu_1 = 12`$），$`\text{SD} = 3`$。
- **数学公式与出处**：
  ``` math
  n = \frac{(Z_{\alpha/2} + Z_{\beta})^2 \sigma^2}{(\mu_1 - \mu_0)^2}
  ```
  *出处*：Machin et al. (2018) Chapter 5.

``` r

res_2_3 <- calculate("rctSingleArm", "test", "mean", mu0 = 10, mu1 = 12, sigma = 3, alpha = 0.05, power = 0.8)
print(res_2_3)
```

- **输出解读**：需招募 **18 名单臂患者**。

### 2.4 单臂试验对比历史对照有效率

- **临床场景**：某种复发性肿瘤历史缓解率仅
  70%（$`p_0 = 0.70`$），新药预期提高至 80%（$`p_1 = 0.80`$）。
- **数学公式与出处**：
  ``` math
  n = \frac{\left[ Z_{\alpha/2}\sqrt{p_0(1-p_0)} + Z_{\beta}\sqrt{p_1(1-p_1)} \right]^2}{(p_1 - p_0)^2}
  ```
  *出处*：Hajian-Tilaki, K. (2014). *J Biomed Inform*, 48, 193-204 (Eq
  6.8).

``` r

res_2_4 <- calculate("rctSingleArm", "test", "proportion", p0 = 0.70, p1 = 0.80, alpha = 0.05, power = 0.8)
print(res_2_4)
```

- **输出解读**：需招募 **153 名患者**。

### 2.5 单臂肿瘤 II 期：Simon 两阶段最优设计（Optimal）

- **临床场景**：不可耐受响应率 $`p_0 = 0.10`$，期望目标响应率
  $`p_1 = 0.30`$。采用 Simon Optimal 设计最小化期望样本量。
- **数学公式与出处**：完全精确二项网格穷举搜索，Simon, R. (1989).
  *Controlled Clin Trials*, 10(1), 1-10.

``` r

res_2_5 <- calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "optimal")
print(res_2_5)
```

- **输出解读**：第 1 阶段招 10 人，缓解 $`\le 1`$ 人则因无效停牌；若缓解
  $`>1`$ 人，继续招 19 人至 29 人。两阶段总缓解人数 $`>5`$（即 $`\ge 6`$
  人）宣布有效。期望样本量仅 15.0 人。

### 2.6 单臂肿瘤 II 期：Simon 两阶段极小极大设计（Minimax）

- **临床场景**：同上条件，但希望在最坏情况下试验最大总人数尽可能少。

``` r

res_2_6 <- calculate("singleArmPhaseII", "test", "proportion", p0 = 0.10, p1 = 0.30, alpha = 0.05, power = 0.8, optimizer = "minimax")
print(res_2_6)
```

- **输出解读**：第 1 阶段招 11 人（缓解 $`\le 0`$ 人停牌），第 2
  阶段总人数达 25 人，最大样本量由 29 人压缩至 25 人。

### 2.7 单臂肿瘤 II 期：A’Hern 单阶段精确二项设计

- **临床场景**：不适宜中途停顿的单阶段探索试验，基于精确二项分布控制错误率。
- **数学公式与出处**：A’Hern, R. P. (2001). *Br J Cancer*, 85(2),
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
#> NULL
#> 
#> $reference
#> [1] "Primary: A'Hern, R. P. (2001). Single stage and double sampling phase II trials. British Journal of Cancer, 85(2), 223-226."
#> 
#> $roles
#> [1] "p0 = unacceptable response rate"                       
#> [2] "p1 = desirable response rate"                          
#> [3] "declare effective if responses > r_total of n_required"
```

- **输出解读**：需入组 **25 名患者**，缓解人数 $`>5`$ 人（$`\ge 6`$
  人）宣布新药有前景。

### 2.8 2x2 交叉试验均数比较

- **临床场景**：健康受试者先后接受两种制剂口服，个体内标准差
  $`\sigma_w = 3`$，预期均值差 $`\Delta = 2`$。
- **数学公式与出处**：$`n = \frac{2(Z_{\alpha/2} + Z_{\beta})^2 \sigma_w^2}{\Delta^2}`$，Senn, S.
  (2002). *Cross-over Trials in Clinical Research*.

``` r

res_2_8 <- calculate("crossover", "test", "mean", delta = 2, sigma_within = 3, alpha = 0.05, power = 0.8)
print(res_2_8)
```

- **输出解读**：每序列需 36 人，总计 72 人。

### 2.9 生物等效性（BE）精确 TOST 非中心 t 检验

- **临床场景**：$`2\times 2`$
  交叉试验评价仿制药与原研药等效，个体内变异系数
  $`CV = 25\%`$，预期几何均数比 $`\theta_0 = 1.0`$，等效限
  $`80\% \sim 125\%`$。
- **数学公式与出处**：
  ``` math
  \text{Power} = F_t(-t_{1-\alpha, \nu}; \nu, \delta_2) - F_t(t_{1-\alpha, \nu}; \nu, \delta_1), \quad \nu = N - 2
  ```
  *出处*：Phillips, K. F. (1990). *J Pharmacokinet Biopharm*, 18(2),
  137-144; Julious (2004) Eq 13.

``` r

res_2_9 <- calculate("bioequivalence", cv = 0.25, theta0 = 1.0, alpha = 0.05, power = 0.8)
print(res_2_9)
```

- **输出解读**：每序列 12 人，总计 **24 名受试者**（与 PowerTOST
  结果完全对齐）。

------------------------------------------------------------------------

## 第三章：观察性与流行病学研究实战

### 3.1 前瞻性队列研究（累积发病率与 RR，含脱落率）

- **临床场景**：吸烟与冠心病发病。非暴露组 5 年发病率 20%，暴露组
  30%，考虑 10% 失访（`dropout = 0.10`）。
- **数学公式与出处**：Bhardwaj et al. (2024). *J Family Med Prim Care*,
  13(7), 2555-2561.

``` r

res_3_1 <- calculate("cohort", "test", "proportion", p0 = 0.20, p1 = 0.30, ratio = 1, dropout = 0.10, alpha = 0.05, power = 0.8)
print(res_3_1)
```

- **输出解读**：每组需 327 人，全队列共需 **654 人**。

### 3.2 队列研究人时发病率比（IRR）比较

- **临床场景**：未暴露人群发病率为 0.10 人年，暴露人群为 0.20 人年，1:1
  随访。
- **数学公式与出处**：
  ``` math
  T_0 = \frac{(Z_{\alpha/2} + Z_{\beta})^2 (\lambda_1/r + \lambda_0)}{(\lambda_1 - \lambda_0)^2}, \quad T_1 = r \cdot T_0
  ```
  *出处*：Machin et al. (2018) Chapter 6.

``` r

res_3_2 <- calculate("cohort", "test", "rate", rate0 = 0.10, rate1 = 0.20, ratio = 1, alpha = 0.05, power = 0.8)
print(res_3_2)
```

- **输出解读**：两组各需随访 **236 人年**，预期观察到 71 例事件。

### 3.3 经典病例对照研究（Case-Control）

- **临床场景**：熬夜与心肌梗死。对照暴露率 30%，预期优势比
  $`\text{OR} = 2.0`$。
- **数学公式与出处**：Schlesselman, J. J. (1982). *Case-Control
  Studies*. Oxford University Press.

``` r

res_3_3 <- calculate("caseControl", p0 = 0.30, OR = 2.0, m = 1, alpha = 0.05, power = 0.8)
print(res_3_3)
```

- **输出解读**：需纳入 **141 例病例与 141 例对照**（总计 282 人）。

### 3.4 1:1 个体配对病例对照研究

- **临床场景**：年龄与性别 1:1 严格配对病例对照研究，对照暴露率
  30%，$`\text{OR} = 2.0`$。
- **数学公式与出处**：Dupont, W. D. (1988). *Biometrics*, 44(4),
  1157-1168.

``` r

res_3_4 <- calculate("caseControlMatched", p0 = 0.30, OR = 2.0, alpha = 0.05, power = 0.8)
print(res_3_4)
```

- **输出解读**：需纳入 **144 对（288 人）**。

### 3.5 现况研究 / 横断面调查关联分析

- **临床场景**：某社区横断面调查，非暴露人群与暴露人群高血压患病率分别为
  20% 与 30%。
- **数学公式与出处**：Machin et al. (2018) Chapter 3.

``` r

res_3_5 <- calculate("crosstab", p0 = 0.20, p1 = 0.30, alpha = 0.05, power = 0.8)
print(res_3_5)
```

- **输出解读**：两组各需调查 294 人，总计 588 人。

------------------------------------------------------------------------

## 第四章：单组参数置信区间估计（调查与常模）

### 4.1 总体比例估计（患病率抽样调查）

- **临床场景**：成人糖尿病患病率调查，预期患病率 10%，容许误差半宽
  $`\pm 2\%`$（$`d = 0.02`$）。
- **数学公式与出处**：$`n = \frac{Z_{1-\alpha/2}^2 p(1-p)}{d^2}`$，Lwanga
  & Lemeshow (1991) WHO.

``` r

res_4_1 <- calculate("singleProportion", p = 0.10, precision = 0.02, alpha = 0.05)
print(res_4_1)
```

- **输出解读**：需调查 **865 名居民**。

### 4.2 总体均数估计（常模抽样）

- **临床场景**：测定某地健康儿童血清铁蛋白均值，已知标准差
  $`\text{SD} = 10`$，容许误差 $`\pm 2`$。
- **数学公式与出处**：$`n = \left(\frac{Z_{1-\alpha/2}\sigma}{d}\right)^2`$，Machin
  et al. (2018) Ch.9.

``` r

res_4_2 <- calculate("singleMean", sigma = 10, precision = 2, alpha = 0.05)
print(res_4_2)
```

- **输出解读**：需调查 **97 名儿童**。

### 4.3 Pearson 相关系数估计（Fisher-z 精确法）

- **临床场景**：估计腰围与体脂率的 Pearson 相关系数，预期
  $`r = 0.50`$，希望 95% 置信区间半宽不超过 $`\pm 0.10`$。
- **数学公式与出处**：Machin et al. (2018) Ch.19 Eqs 19.5-19.8
  精修公式，与 `presize::prec_cor` 严格一致。

``` r

res_4_3 <- calculate("singleCorrelation", r = 0.50, precision = 0.10, alpha = 0.05)
print(res_4_3)
```

- **输出解读**：需纳入 **219 名受试者**。

------------------------------------------------------------------------

## 第五章：诊断试验准确性研究全家族

### 5.1 敏感度/特异度估计与全人群筛查规模转化

- **临床场景**：验证结直肠癌早筛试剂盒敏感度，预期 85%，容许半宽
  $`\pm 5\%`$，门诊目标人群患病率 20%。
- **数学公式与出处**：Zhou, Obuchowski, & McClish (2011) §6.1.1.

``` r

res_5_1 <- calculate("diagAccuracy", "estimate", "proportion", prob = 0.85, d = 0.05, prevalence = 0.20, alpha = 0.05)
print(res_5_1)
```

- **输出解读**：敏感度需 196 例确诊真病例；门诊全人群筛查需 **980 人**。

### 5.2 诊断单端点优效性检验（渐近正态法）

- **临床场景**：验证 AI 肺结节诊断系统敏感度是否显著优于行业及格线
  70%（$`p_0 = 0.70`$），预期敏感度 85%。
- **数学公式与出处**：Hajian-Tilaki (2014) Eq 6.8.

``` r

res_5_2 <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, alpha = 0.05, power = 0.8)
print(res_5_2)
```

- **输出解读**：需 50 例病例，筛查 250 人。

### 5.3 诊断单端点优效性检验（A’Hern 精确二项法）

- **临床场景**：小样本或高敏感度时，采用精确二项法消除正态近似误差。

``` r

res_5_3 <- calculate("diagAccuracy", "test", "proportion", prob = 0.85, p0 = 0.70, prevalence = 0.20, method = "exact", alpha = 0.05, power = 0.8)
print(res_5_3)
```

- **输出解读**：精确法需 **49 例确诊病例**，临界正确数 $`r = 40`$
  例（正确判断 $`\ge 40`$ 例宣布优效）。

### 5.4 双端点诊断试验设计（敏感度+特异度协同达标）

- **临床场景**：要求敏感度（80%升至90%）与特异度（75%升至85%）**同时**满足
  $`\ge 80\%`$ 联合检验效能。
- **数学公式与出处**：Akoglu, H. (2022). *Turk J Emerg Med*, 22(4),
  177-185 (各端点置于 90% 效能取最大值).

``` r

res_5_4 <- calculate("diagAccuracy", "test", "proportion", prob = 0.90, p0 = 0.80, prob_spec = 0.85, p0_spec = 0.75, prevalence = 0.40, dual = TRUE)
print(res_5_4)
```

- **输出解读**：需 123 例病例，全人群需筛查 308 人。

### 5.5 非配对两诊断方法敏感度比较

- **临床场景**：两组独立受试者分别接受方法 1 与方法 2，敏感度分别为 85%
  与 75%。

``` r

res_5_5 <- calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = FALSE, alpha = 0.05, power = 0.8)
print(res_5_5)
```

- **输出解读**：每组需 250 例病例，两组筛查需 2500 人。

### 5.6 配对两诊断方法敏感度比较（Connor 核）

- **临床场景**：同一批患者同时接受两套检查，敏感度 85% vs
  75%，不一致对比例 $`\psi = 0.10`$。

``` r

res_5_6 <- calculate("diagAccuracyCompare", "test", "proportion", p1 = 0.85, p2 = 0.75, prevalence = 0.20, paired = TRUE, psi = 0.10, alpha = 0.05, power = 0.8)
print(res_5_6)
```

- **输出解读**：仅需 **77 对病例**，筛查 385 人。

### 5.7 诊断准确度非劣效性检验

- **临床场景**：新简便试剂盒敏感度 90% 对比金标准 88%，非劣效界值
  5%（$`\text{margin} = 0.05`$）。

``` r

res_5_7 <- calculate("diagAccuracyCompare", "noninferiority", "proportion", p1 = 0.90, p2 = 0.88, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_7)
```

- **输出解读**：需 247 例病例，筛查 824 人。

### 5.8 诊断准确度等效性检验

- **临床场景**：两款仪器敏感度分别为 90% 与 89%，临床等效界值
  $`\pm 5\%`$。

``` r

res_5_8 <- calculate("diagAccuracyCompare", "equivalence", "proportion", p1 = 0.90, p2 = 0.89, margin = 0.05, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_8)
```

- **输出解读**：需 1006 例病例，筛查 3354 人。

### 5.9 ROC 曲线下面积（AUC）精度估计（双正态模型）

- **临床场景**：预期 $`\text{AUC} = 0.80`$，容许置信区间半宽
  $`\pm 0.10`$，病例对照比 1:1。
- **数学公式与出处**：Obuchowski, N. A. (1994); Zhou et al. (2011) Eq
  6.5.

``` r

res_5_9 <- calculate("diagAUC", "estimate", "auc", auc = 0.80, d = 0.10, ratio = 1, var_method = "binormal", alpha = 0.05)
print(res_5_9)
```

- **输出解读**：需 **46 例病例与 46 例对照**（总计 92 人）。

### 5.10 ROC 曲线下面积（AUC）单法优效检验

- **临床场景**：检验新标志物 $`\text{AUC} = 0.80`$
  是否显著高于临床及格线 $`\text{AUC}_0 = 0.70`$。

``` r

res_5_10 <- calculate("diagAUC", "test", "auc", auc = 0.80, auc0 = 0.70, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_10)
```

- **输出解读**：需 180 例病例，筛查 600 人。

### 5.11 两诊断方法 ROC-AUC 比较

- **临床场景**：两法 $`\text{AUC}_1 = 0.80`$ vs
  $`\text{AUC}_2 = 0.70`$，两法相关系数 $`r = 0.50`$。
- **数学公式与出处**：Hajian-Tilaki (2014) Eq 7.6/7.8.

``` r

res_5_11 <- calculate("diagAUCCompare", "test", "auc", auc1 = 0.80, auc2 = 0.70, r = 0.50, prevalence = 0.30, alpha = 0.05, power = 0.8)
print(res_5_11)
```

- **输出解读**：需 223 例病例，筛查 744 人。

### 5.12 两法 ROC-AUC 非劣效性检验

- **临床场景**：新简易设备 $`\text{AUC}_1 = 0.85`$ 对比金标准
  $`\text{AUC}_2 = 0.82`$，非劣效限 $`\text{margin} = 0.05`$。

``` r

res_5_12 <- calculate("diagAUCCompare", "noninferiority", "auc", auc1 = 0.85, auc2 = 0.82, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_5_12)
```

- **输出解读**：需 80 例病例，筛查 160 人。

### 5.13 两法 ROC-AUC 等效性检验

- **临床场景**：两法 $`\text{AUC}_1 = 0.85`$ vs
  $`\text{AUC}_2 = 0.84`$，等效界值 $`\text{margin} = 0.05`$。

``` r

res_5_13 <- calculate("diagAUCCompare", "equivalence", "auc", auc1 = 0.85, auc2 = 0.84, r = 0.50, margin = 0.05, alpha = 0.05, power = 0.8)
print(res_5_13)
```

- **输出解读**：需 317 例病例，筛查 634 人。

### 5.14 似然比（Likelihood Ratio）对数置信区间阈值法

- **临床场景**：排除试验要求阴性似然比（$`\text{LR}^-`$）置信区间上限不能超过
  0.40（$`\text{target\_lr} = 0.40`$）。预期敏感度 90%，特异度 50%。
- **数学公式与出处**：Hajian-Tilaki (2014) Eq 6.14; Simel et al. (1991).

``` r

res_5_14 <- calculate("diagLR", "estimate", "lr", sens = 0.90, spec = 0.50, target_lr = 0.40, lr_type = "negative", alpha = 0.05)
print(res_5_14)
```

- **输出解读**：病例与对照各需 9 例，总计 18 人。

### 5.15 临床真实筛查总人数的“二项安全保障”（`screen_required`）

- **临床场景**：理论筛查 980 人只有 50% 把握抓够 196 例病例。要求以 90%
  概率安全保障抓满 196 例。
- **数学公式与出处**：$`P(\text{Binomial}(N, \text{prev}) \ge n) \ge 1 - \beta`$，Zhou
  et al. (2011) Eq 6.3.

``` r

safe_n <- screen_required(n = 196, prevalence = 0.20, beta = 0.10)
cat("理论平均筛查数：980 人；90% 概率安全保障筛查数：", safe_n, "人\n")
#> 理论平均筛查数：980 人；90% 概率安全保障筛查数： 1061 人
```

- **输出解读**：实际筛查名单需扩大至 **1058 人**（多储备 78 人备荒）。

### 5.16 多阅片者多病例（MRMC）研究效能分析

- **临床场景**：8 名放射科医生独立阅读 50
  例乳腺钼靶片，检测两种成像技术的 AUC 差异（$`\Delta = 0.10`$）。
- **数学公式与出处**：Obuchowski-Rockette 混合效应模型非中心 $`F`$
  检验，Zhou et al. (2011) Eq 6.32, p.225.

``` r

res_5_16 <- mrmc_power(n = 50, J = 8, delta = 0.10, sigma_b2 = 0.00123, sigma_w2 = 0.00087, sigma_c2 = 0.05, rho1 = 0.25, rho2 = 0.20, rho3 = 0.10)
print(res_5_16)
```

- **输出解读**：在 50 例病例、8 名阅片者下，该试验达到 **88.8%
  的统计学效能**（与教材报道的 89% 一致）。

------------------------------------------------------------------------

## 第六章：复杂与现代前沿临床研究设计

### 6.1 群随机试验（Cluster RCT：连续型结局）

- **临床场景**：以病区为单位随机（每病区 20 张床位，组内相关系数
  $`\text{ICC} = 0.05`$）。干预使并发症均分由 10 降至
  12，$`\text{SD} = 3`$。
- **数学公式与出处**：$`DE = 1 + (m - 1)ICC = 1.95`$，Donner & Klar
  (2000).

``` r

res_6_1 <- calculate("clusterRCT", "test", "mean", mean1 = 10, mean2 = 12, sd = 3, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)
print(res_6_1)
```

- **输出解读**：每个干预臂需 4 个病区（80 人），两臂共计 **8 个病区（160
  人）**。

### 6.2 群随机试验（Cluster RCT：二分类结局）

- **临床场景**：以社区为单位随机干预，有效率由 20% 提高至 30%，每社区 20
  人，$`\text{ICC} = 0.05`$。

``` r

res_6_2 <- calculate("clusterRCT", "test", "proportion", p1 = 0.30, p2 = 0.20, icc = 0.05, cluster_size = 20, alpha = 0.05, power = 0.8)
print(res_6_2)
```

- **输出解读**：每臂需 29 个社区（580 人），共计 **58 个社区（1160
  人）**。

### 6.3 阶梯楔形整群试验（Stepped-Wedge CRT）

- **临床场景**：24 个县分 4 批阶梯交叉推行某干预措施（每步 6 群，共 5
  个时间节点，每群每期 100 人）。疗效差异 $`\theta = -0.016`$。
- **数学公式与出处**：Hussey, M. A., & Hughes, J. P. (2007). *Contemp
  Clin Trials*, 28(2), 182-191 (Eq 8).

``` r

res_6_3 <- calculate("steppedWedge", "test", "mean", theta = -0.016, tau2 = 2.25e-4, sigma2_ind = 0.0475, m = 100, n_clusters = 24, clusters_per_step = 6, alpha = 0.05)
print(res_6_3)
```

- **输出解读**：该阶梯楔形方案实现 **90.8% 的检验效能**。

### 6.4 有序多分类结局（Whitehead 比例优势比模型）

- **临床场景**：评价骨关节炎缓解程度（轻度 20%、中度 50%、重度
  30%），预期优势比 $`\text{OR} = 1.5`$。
- **数学公式与出处**：Whitehead, J. (1993). *Stat Med*, 12(24),
  2257-2271.

``` r

res_6_4 <- calculate("twoOrdinal", "test", "ordinal", or = 1.5, prop_bar = c(0.2, 0.5, 0.3), alpha = 0.05, power = 0.8)
print(res_6_4)
```

- **输出解读**：每组需 86 人，总计 **171 人**。

### 6.5 临床预测模型开发：Riley 2020 BMJ 准则（二分类结局）

- **临床场景**：开发 ICU 死亡预测模型，10 个候选预测变量，结局发生率
  30%，预期 $`R^2_{CS} = 0.10`$，目标收缩因子 $`S = 0.90`$。
- **数学公式与出处**：Riley et al. (2020). *BMJ*, 368, m441 (Box 1 准则
  B1 与 B3).

``` r

res_6_5 <- calculate("predictiveModel", "plan", "binary", prev = 0.30, n_parameters = 10, r2_cs = 0.10, shrinkage = 0.90, precision_delta = 0.05, alpha = 0.05)
print(res_6_5)
```

- **输出解读**：需纳入 **850 名患者，其中包含 255
  例事件**（有效事件参数比 EPP=25.5，与 `pmsampsize` 结果完全一致）。

### 6.6 临床预测模型开发：Riley 2020 时间-事件结局（人年估算）

- **临床场景**：生存模型预测 10 年心血管死亡，年发病率
  0.10/年，容许累计发病率误差 $`\pm 5\%`$。

``` r

res_6_6 <- calculate("predictiveModel", "plan", "rate", rate = 0.10, timepoint = 10, precision_delta = 0.05, alpha = 0.05)
print(res_6_6)
```

- **输出解读**：需随访累计 **2366 人年**。

### 6.7 临床预测模型开发：经典每变量事件数（EPV）规则

- **临床场景**：经典每变量 10 个事件粗算（Peduzzi et al., 1996）。

``` r

res_6_7 <- calculate("predictiveModel", "plan", "events", n_parameters = 10, epv = 10, event_prevalence = 0.30)
print(res_6_7)
```

- **输出解读**：需 100 例事件，总共需调查 334 人。

### 6.8 评分者一致性：Cohen’s Kappa 置信区间精度估计

- **临床场景**：两位专家阅片一致性估计，预期 $`\kappa = 0.70`$，希望 95%
  置信区间半宽不超过 $`\pm 0.10`$。
- **数学公式与出处**：Cantor, A. B. (1996). *Psychol Methods*, 1(2),
  150-153.

``` r

res_6_8 <- calculate("kappa", "estimate", "proportion", pi1 = 0.30, pi2 = 0.30, kappa = 0.70, d = 0.10, alpha = 0.05)
print(res_6_8)
```

- **输出解读**：需调查 **165 名受试者**。

### 6.9 评分者一致性：两独立 Kappa 系数差异检验

- **临床场景**：比较新量表（$`\kappa_1 = 0.70`$）与旧量表（$`\kappa_2 = 0.50`$）的一致性是否有显著提升。

``` r

res_6_9 <- calculate("kappa", "test", "proportion", pi1 = 0.50, pi2 = 0.50, kappa1 = 0.70, kappa2 = 0.50, alpha = 0.05, power = 0.8)
print(res_6_9)
```

- **输出解读**：两组各需评估 **214 例标本**。

### 6.10 中断时间序列研究（Interrupted Time Series, ITS）

- **临床场景**：政策干预前后各监测 12 个月度时点，预期干预产生 2
  个标准差的水平跃升（$`\delta = 2`$），时间序列自相关系数
  $`\rho = 0.30`$。
- **数学公式与出处**：Bernal et al. (2017). *Int J Epidemiol*, 46(1),
  348-355（AR(1) 有效样本量校正近似）。

``` r

res_6_10 <- calculate("its", "test", "rate", effect_sd = 2, n_pre = 12, n_post = 12, rho = 0.3, alpha = 0.05, power = 0.8)
print(res_6_10)
```

- **输出解读**：在该序列配置下，可实现 **94.9% 的检验效能**。

------------------------------------------------------------------------

## 第七章：结果解读、标书撰写模板与实战图表展示

### 论文与标书方法学撰写填空模板

调用 [`summary()`](https://rdrr.io/r/base/summary.html) 可直接生成包含
LaTeX 公式与标准参考文献的完整报告：

``` r

summary(res_1_1)
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.
```

#### 标准填空模板

> **【RCT 方案填空示例】**
> 本研究为两臂平行、双盲、随机对照优效性试验。根据既往预试验（Author et
> al., Year），对照组主要终点均值预计为 10 mmHg，试验组预计为 12
> mmHg，两组联合标准差为 3 mmHg。设定双侧检验水准
> $`\alpha = 0.05`$，检验效能 $`1 - \beta = 80\%`$。采用两独立样本 $`t`$
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
