# sampleSizeCalc 3.0 重构与扩展计划

> **目标**：把现有的 17 设计单入口 R 包，升级为覆盖「估计 / 检验 / 边距」×「RCT / 队列 / 病例对照 / 横断面 / 诊断 / 复杂设计」的通用样本量计算包。
> **方法**：Posit agent skills（`.agents/skills/r-package-development`、`r-testthat`、`r-tidyverse-style`、`r-lifecycle`）贯穿全程：每个 Phase 内严格的 文件↔测试镜像、文献算例即测试、air format、NEWS 记录。
> **证据链**：全部新公式锚定 `references/` 五份文献（Zhou 2011 / Machin 2018 / Hajian-Tilaki 2014 / Akoglu 2022 / Bhardwaj 2024）+ 原始论文标注 ◇。

---

## 0. 总原则（来自 skills 的约束）

| 约束 | 执行方式 |
|---|---|
| r-package-development | 每个 R 文件配 `test-{name}.R`；新代码必须有测试；`devtools::document()` 后提交；`NEWS.md` 每个用户可见变化一条 bullet；**错误用 `expect_snapshot(error = TRUE)`** |
| r-testthat | 自足测试；错误/警告一律 snapshot；BDD `describe()` 用于分组规范；数值断言用 `expect_equal`（容差 1e-7） |
| r-tidyverse-style | snake_case；两空格缩进；`\() ...` 单行 lambda；base pipe；内部函数用 `@noRd`；公共 API 全部 roxygen 导出；**每个 Phase 结束跑 `air format .`（未安装则 `styler::style_pkg()`）** |
| r-lifecycle | sampleSizeCalculator 已标 deprecated；本计划新增 deprecate 需走完整三版本周期 |

**本机工具链现状**（已核实）：`devtools` / `usethis` / `air` 未安装；`styler` / `withr` / `roxygen2` / `pkgdown` / `pwr` / `testthat 3` 可用。
→ 用 `Rscript -e "roxygen2::roxygenise()"` 生成文档，`Rscript -e "testthat::test_local('.')"` 跑测试，`R CMD INSTALL` + `Rscript -e "rcmdcheck::rcmdcheck()"`（需确认 rcmdcheck）做检查；格式化用 `styler::style_pkg()` 替代 air。

---

## 1. 架构设计（三层：核心计算层 / 分发层 / 展示层）

### 1.1 目录结构（目标）

```
R/
├── ssr-result.R              # S3 类定义：new/validate/assert/friendly （基础，先于一切）
├── zzz.R                     # 不需要（无注册钩子）
├── utils-z.R                 # z 值、双向反查、边距符号统一（@noRd 内部核）
├── utils-adjust.R            # adjust_inflate（F1/F2 脱落/无应答）、design_effect（E1）——@noRd 或导出（导出：实用工具）
├── math-tolerance.R          # 公共函数的连续性校正选项（B 类共享核）
├── calculate-estimation.R    # A1-A6（估计型核：proportion/mean/sens/AUC/LR/cor）
├── calculate-two-sample.R    # B1/B3/B4/B5/B6（两样本核：mean/prop/rate/order）
├── calculate-paired.R        # B8a/B8b（配对核：连续/二分类 McNemar/Connor）
│
├── calc-crosstab.R           # 横断面（A1+关联、患病率）
├── calc-cohort.R             # 队列（前瞻/回顾：B3-m/B6 人时/失访）
├── calc-case-control.R       # 病例对照（组匹配/配对 Dupont/巢式）
├── calc-trial-mean.R         # RCT 连续（B1/B2/C1-C4）
├── calc-trial-bin.R          # RCT 二分类（B3/B4/C2/C3/C4）
├── calc-trial-surv.R         # 生存（B7 事件数+招募数、单臂生存）
│
├── calc-crossover.R          # 交叉/2×2（σ_w、ρ、BE）
├── calc-single-arm.R         # 单臂二期（Simon 两阶段查表内核）
├── calc-cluster.R            # 整群（DE=1+(m-1)ICC）+ 阶梯楔形
├── calc-kappa.R              # 一致性（Kappa 样本量）
├── calc-predictive.R         # EPV 法 + Riley 2019/2020
│
├── calc-diagnostic.R         # 诊断核（sampling 三模式、式 6.1/6.2/6.3、AUC 三方差函数、Se@FPR、pAUC、LR 重写）
├── calc-diagnostic-compare.R # 诊断比较（非配对/配对 Connor、PPV/NPV、两 AUC、诊断等效 C6）
├── calc-diagnostic-mrmc.R    # MRMC（放最后）
│
├── calculate.R               # ★ 新统一入口 calculate()：三轴分发 + 向后兼容
├── sample_size_calculator.R  # 旧入口 = calculate() 的兼容垫片（含 deprecate 警告）
├── deprecate.R               # sampleSizeCalculator 完整生命周期
├── print_sample_size_result.R  # print/summary/plot 三件套（迁移现有文件并升级）
├── summary_sample_size_result.R
└── plot_sample_size_result.R
```

### 1.2 统一入口 API（三轴设计）

> **✅ 已确认决策（2024，operator）**：
> ① RCT 族坍缩为单一 `rct` design（task × outcome 正交组合）；
> ② 诊断族用显式全名：`diagAccuracy` / `diagAccuracyCompare` / `diagAUC` / `diagAUCCompare` / `diagLR`；
> ③ 估计型统一走 `singleProportion` / `singleMean` / `singleCorrelation`（`crosstab` 只做横断面关联检验）；
> ④ 17 个旧关键字静默兼容（无警告，文档标注 legacy）。

```r
calculate(
  design,                      # 设计轴：crosstab | cohort | caseControl | caseControlMatched
                               #          | rctMean | rctBin | rctSurv | crossover | singleArmPhaseII
                               #          | clusterRCT | steppedWedge | kappa | predictive
                               #          | diagAccuracy | diagAUC | diagCompareSe | diagCompareAUC | ...
  task,                        # 任务轴：estimate | test | noninferiority | superiority | equivalence
  outcome,                     # 结局轴：mean | proportion | rate | survival | auc | ordinal
  sampling = c("clinical", "caseControl"),   # 诊断专用：连续入组 vs 病例对照富集
  ...
)
```

- **design 是主键，task/outcome 是校验维度**：`design` 与 `(task, outcome)` 组合校验合法性（合法性表写死在 `R/calculate.R` 内的 tibble/列表常量），非法组合给出「最接近的合法设计建议」。
- **向后兼容（已确认：静默）**：现有 17 个 `design` 关键字全部映射到新 API；`sample_size_calculator()` 保留为兼容垫片，映射表：
  - `twoMeans` → `calculate(design="rct", task="test", outcome="mean", ...)`
  - `twoProportions` → `rct + test + proportion`
  - `pairedMeans` → `paired + test + mean`
  - `survival` → `rct + test + survival`
  - `nonInferiorityMeans` → `rct + noninferiority + mean`
  - `superiorityMeans` → `rct + superiority + mean`
  - `equivalenceMeans` → `rct + equivalence + mean`
  - `superiorityProportions` → `rct + superiority + proportion`
  - `equivalenceProportions` → `rct + equivalence + proportion`
  - `diagnosticAccuracySingle` → `diagAccuracy + estimate + proportion`
  - `diagnosticSuperioritySingle` → `diagAccuracy + test + proportion`
  - `diagnosticComparisonTwo` → `diagAccuracyCompare + test + proportion`
  - `likelihoodRatioTest` → `diagLR + estimate + lr`
  - `auc_single` → `diagAUC + estimate + auc`
  - `aucSuperiority` → `diagAUC + test + auc`
  - `aucComparison` → `diagAUCCompare + test + auc`
  - `caseControl` → `caseControl + test + proportion`
- **参数角色自动化**（用户上轮需求）：每种 design 打印参数角色说明，如 `caseControl: p0 = 对照组暴露率（不是发病率！）`，写入 result 对象 `roles` 字段，`print()` 输出。

### 1.3 统一返回对象 `sample_size_result`（扩展现有 S3）

```
sample_size_result:
  class: sample_size_result
  fields:
    design / task / outcome / sampling    # 轴信息
    n_1 / n_2 / total_n / events / pairs  # 统一字段名（旧 n_per_group 等保留为别名）
    parameters / formula / formula_latex / reference
    roles          # 参数角色说明（character vector）
    adjustments    # dropout / nonresponse / inflate factor 审计信息
    power_curve    # optional: 计算过程数据（供 plot）
```

- `new_sample_size_result()` 构造器 + `validate_sample_size_result()` 校验器（r-package-development 规范：构造/校验/断言三件套，参考 vctrs/recipes 风格）。
- 兼容：保留旧字段名（`n_per_group`、`target_events_needed` 等作为动态别名或直接保留），确保**现有 24 个测试和 vignettes 全部继续通过**——这是每个 Phase 的 CI 红线。

### 1.4 数值锚点（每个公式必须至少 1 个文献算例）

| 公式 | 锚点数值 | 来源 |
|---|---|---|
| twoMeans | n=37/组（δ=2, sd=3, 80%power） | 现有测试已覆盖 |
| prevalence (A1) | p=0.30, d=0.05 → 323（+10%脱落=355） | [Bhardwaj] p.2558 |
| 单比例 vs P0 (B4) | 0.70 vs 0.80 → n=153 | [Hajian] 式 6.8 算例 |
| diagAccuracySingle | SPECT 算例：Se=0.80, d=0.05, 95%CI → 246（式 6.2） | [Zhou] p.195（246~714 区间） |
| LR 估计（重写后） | LR−=0.4, Se=0.9, Sp=0.5 → 每组 80 | [Hajian] §6.4 算例 |
| AUC 单试验 | A=0.80, d=0.10, R=1 → 46（指数）/ 62（保守） | [Zhou] p.198 |
| AUC 比较 | V_H0=0.13480, Δ=0.10, r=0（独立） | [Hajian] §7.6 算例 |
| 生存 | E=25 (HR=0.7, 1:1) | Schoenfeld |
| Simon 两阶段 | p0=0.2, p1=0.4, α=0.05, β=0.1 → r1/n1/r/n=(2/17, 7/25) 最优 | Simon 1989 Table 1 |
| 整群 DE | m=20, ICC=0.05 → DE=1.95 | 公式自明 |
| Kappa | κ₀=0.2→κ₁=0.4, p̄=0.5, ... | Cantor 1996 算例需查原文页码 |
| 配对病例对照 | Dupont 1988 算例（需查原文） | Dupont 1988 |
| 配对诊断（Connor） | ψ=0.12, Δ=0.05, 80% → 22.5→23 | [Akoglu] Table 6A |
| BE 交叉 | CV=25%, μT−μR=0 → n≈12-13/序列 | Schuirmann/常规 |

---

## 2. 分 Phase 实施计划（每个 Phase = 一次可交付、可测试、可回滚的增量）

### Phase 0：基础设施与地基（0.5 天）
**产出**：可复现的构建环境 + S3 类地基 + 内部核工具

- [ ] 0.1 安装缺失工具链：`install.packages(c("devtools", "usethis", "rcmdcheck"))`（保留 styler 兜底）
- [ ] 0.2 用 usethis 激活规范基础设施：`use_testthat(3)`（已有，验证 edition=3）、`use_package()` 声明依赖、`use_mit_license()`（已有）、`use_news_md()`（新建 NEWS.md）
- [ ] **0.3 新建 `R/ssr-result.R`**：`new_sample_size_result()` / `validate_sample_size_result()` / `assert_sample_size_result()`
  - 测试：`tests/testthat/test-ssr-result.R`（构造/校验/断言 + 快照错误）
- [ ] **0.4 新建 `R/utils-z.R`**：`z_alternative()`、`z_power()`、`inflate_n()`、`design_effect()`（内部核，@noRd）
  - 测试：`test-utils-z.R`（z_0.975=1.959964, z_power=0.8416212）
- [ ] 0.5 冻结现状：跑全量 `testthat::test_local()` 确认 24 pass 作为基线
- [ ] 0.6 新建 `docs/DESIGN_MATRIX.md`（前两轮清单的落地文档，作为「设计-任务-公式-来源」导航）
- [ ] 0.7 新建 `docs/NUMERIC_ANCHORS.md`（所有锚点数值 + 页码 + 推导）

### Phase 0 验收：`testthat::test_local()` ≥ 24 pass，无 warning；S3 类测试通过

### Phase 1：统一入口 + 向后兼容（1 天）
**产出**：`calculate()` 三轴入口，旧 API 全兼容

- [ ] 1.1 新建 `R/calculate.R`：三轴参数化 + 合法性表 + 路由 + 建议（如 `rctMean` 拼错建议 `rctMean`/`rctBin`）
- [ ] 1.2 `R/sample_size_calculator.R` 映射表：17 个旧关键字 → 新 API（保持零警告转换）
  - **测试：对 17 个旧设计逐一做「旧调用 = 新调用」等价断言**（golden master 测试，锁定行为）
- [ ] 1.3 `R/deprecate.R`：`sampleSizeCalculator()` 生命周期延续（已是 deprecated，维持警告文本不变——快照锁定）
- [ ] 1.4 `R/utils-adjust.R`：`adjust_inflate()`（dropout/nonresponse 放大）作为导出工具函数 + 测试（0.30/d=0.05→323, +10%→355.3→356 但 355 完美匹配无膨胀 → **实现细节：膨胀用 ceiling(n/(1-d))**
  - 注：Bhardwaj 算例 322.69→323→+10%→355.3→356（ceiling 后 356≠355），文档如实记录差异原因（四舍五入 vs ceiling 顺序），锚点容差 ±1
- 1.5 更新 `DESCRIPTION`：Version → 3.0.0（主版本：API 变更），Collate 顺序更新（roxygen `@include` 链）
- [ ] 1.6 NEWS.md：API 变更记录
- [ ] 1.7 格式化 + 全量测试 + `R CMD check`

### Phase 1 验收：17 个旧设计等价测试全过（行为锁定）；新 calculate() 单元测试通过；R CMD check 无 ERROR/WARNING

### Phase 2：估计型全家桶（维度 A，1 天）
**产出**：A1 患病率、A2 均值、A6 相关、A3/A4/A5 升级

- [ ] 2.1 `R/calc-crosstab.R`：`calculate(design="crosstab", task="estimate", outcome="proportion")`（A1 精确度法）
  - 锚点：p=0.30, d=0.05, 95% → 323（[Bhardwaj]）
  - 相对精确度变体、连续均值变体（A2）
  - 患病率 <10%/ >90% 时 d 惯例警告（Bhardwaj p.2558）
  - 测试：`test-calc-crosstab.R`
- [ ] 2.2 **A3 升级**（`calc-diagnostic.R`）：diagnosticAccuracySingle 加 `ci_method`（"exact"/"normal"）与 Zhou 式 6.1（带 power 的 CI 宽度法）
  - 锚点：SPECT Se=0.80, d=0.05, 95%CI → 246；带 power 版 → 502
  - 式 6.3 患病率概率保证换算（`prevalence_rule = "guarantee"`）
  - 测试：锚点断言 + snapshot 警告
- [ ] 2.3 **A4 升级**：auc_single 加 `var_method = c("exponential", "binormal", "conservative")` 三方差函数
  - 锚点：A=0.80, d=0.10, R=1 → 指数 46 / 保守 62（[Zhou] p.198）
- [ ] 2.4 **A5 重写**：likelihoodRatioTest → 基于 log(LR) CI 联立求解（[Hajian] 式 6.13/6.14，锚点每组 80）
  - 旧简化式保留为 `legacy = TRUE` 选项并文档标注差异
- [ ] 2.5 **A6 相关**：correlation estimate（Fisher z 变换，[Machin] Ch.19）
- [ ] 2.6 F5 患病率概率保证换算 → 导出为 `screen_required()` 独立工具函数

### Phase 2 验收：A 维度 6 个设计全部有文献锚点测试；旧 24+新测试全绿

### Phase 3：两样本/配对核 + 观察性设计（维度 B，2 天）
**产出**：观察性三设计 + 配对二分类 + 率结局

- [ ] 3.1 `R/calc-crosstab.R` 补：横断面关联分析（两比例 PR/OR）
- [ ] **3.2 `R/calc-cohort.R`：队列研究**
  - B3-m 版（1:m 不等分）：p̄ 加权式 + 失访校正（F1）
  - B6 人时率比：事件数 D = (Z₁₋α/2+Z₁₋β)²(r+1)²/((r−1)²)，λ 换算人数
  - 锚点：[Bhardwaj] p.2559（293→322→644 算例）；人时公式需补锚点（Machin Ch.6 查页）
  - 参数角色表（p0=非暴露发病率）
- [ ] **3.3 `R/calc-case-control.R`：病例对照**
  - 现有 Schlesselman 组匹配式迁移 + `k`（对照:病例比）参数化
  - **新增配对版**（Dupont 1988）：`n_对 = [Z√ψ + Z√(ψ−Δ²)]²/Δ²` 或 Dupont 修正
  - 巢式病例对照（组匹配 + 效率因子说明）
  - 参数角色表（p0=对照组暴露率！）
- [ ] 3.4 `R/calc-paired.R`：配对二分类 McNemar/Connor 核（D3 与 3.3 配对版共用）
  - 锚点：[Akoglu] Table 6A（ψ=0.12, Δ=0.05 → 23）
- [ ] 3.5 B4 单比例 vs 固定值 → 导出（[Hajian] 锚点 153）
- [ ] 3.6 B5 等级/有序结局（Whitehead，[Machin] Ch.4）——锚点待查
- [ ] 3.7 B6 率结局（[Machin] Ch.6）——与 3.2 共用
- [ ] 3.8 F4 双终点同时达标（Akoglu p.184：各自 90% power 取大者）→ `multi_endpoint=TRUE` 选项

### Phase 3 验收：观察性三设计（crosstab/cohort/caseControl）全链路（计算+角色表+测试）；B 维度补全约 6 个新设计

### Phase 4：边距设计 + 诊断比较升级（维度 C/D，1.5 天）
**产出**：诊断模块对齐 Zhou/Akoglu；BE；诊断等效

- [ ] 4.1 **诊断比较升级**（`R/calc-diagnostic-compare.R`）：
  - D2 非配对（现有式，锚点 [Hajian] §6.3）
  - **D3 配对重写**：Connor ψ 式（[Akoglu] Eq 3b + Table 6 锚点）
  - **D4 PPV/NPV 比较**（[Zhou] §6.2.3）
  - **D5 两 AUC 比较**（var_method 三函数 + r 参数（默认 0.5 依据 [Hajian] §11 Rockette））
  - **D6 sensitivity@FPR**（[Zhou] §6.1.5/6.2.6，binormal 模型）
  - **D7 partial AUC**（[Zhou] §6.1.6/6.2.7，McClish 1989）
- [ ] 4.2 **C6 诊断非劣效/等效**（[Zhou] §6.3，pp.214-218）
- [ ] 4.3 **C5 生物等效性**（2×2 交叉 TOST，log 尺度 80-125%）
  - 锚点：CV=25% → n≈12/序列（常规教科书值，需精确锚点：Julious 或 Chow & Liu 表）
  - `calc-crossover.R`：交叉试验通用（σ_w、ρ 参数化，◇◇◇Senn 2002 框架）
- [ ] 4.4 诊断三阶段 sampling 参数：`sampling = "clinical"/"caseControl"` 切换患病率换算行为（[Zhou] §3.3）
  - Phase I（caseControl）：prevalence 不参与，n_case/n_control 独立
  - Phase III（clinical）：式 6.3 概率保证换算
  - 测试：两种 sampling 模式的行为差异 snapshot
- 4.5 snapshot 锁定诊断类全部错误信息
- [ ] 4.6 vignette：诊断模块完全重写（三阶段设计讲解 + sampling 参数）

### Phase 4 验收：诊断模块 12+ 设计，每个都有 Zhou/Akoglu/Hajian 锚点；crossover/BE 通过锚点

### Phase 5：复杂设计（维度 E，2 天）
**产出**：整群、楔形、Simon、Kappa、预测模型、ITS

- [ ] 5.1 **E1 整群 RCT**（`calc-cluster.R`）：DE = 1+(m−1)ICC × 任意核心设计包装
  - 锚点：m=20, ICC=0.05 → DE=1.95；包装 twoMeans 后数值 = 37×1.95/20 → 群数
  - 参数角色：ICC 来源警告（文献或预试）
- [ ] 5.2 **E2 阶梯楔形**（含时间效应校正因子）
- [ ] 5.3 **E5 Simon 两阶段**（`calc-single-arm.R`）：
  - 内部实现最优/最小最大设计查表内核（ Simon 1989 Table 1 离散搜索法）
  - 锚点：p0=0.2, p1=0.4, α=0.05, β=0.1 → 最优 (r1,n1,r,n)=(2/17, 7/25)
  - A'Hern 单阶段选项
- [ ] 5.4 **E8 Kappa 一致性**（`R/calc-kappa.R`，[Machin] Ch.20 / Cantor 1996 式）
  - 锚点：Cantor 算例（需查原文确认）
- [ ] 5.5 **E7 预测模型**（`calc-predictive.R`）：EPV≥10 法（Peduzzi 1996）+ Riley 2019 开发 / Riley 2020 验证法
  - Riley 法公式较复杂（4 项精确度目标联立），先实现 EPV 简化版 + Riley 完整版后置
- [ ] 5.6 **E10 ITS**（`calc-its.R`）：经验法则版（前后各 ≥8 时点；ρ 校正 power 公式）+ 提示模拟法
  - 锚点：经验法则断言（时点数检查）
- [ ] 5.7 生存招募人数换算（B7 从事件数到招募数的招募期/随访期/失访换算）→ `calc-trial-surv.R` 完整版

### Phase 5 验收：复杂设计 6 个新模块，每个有独立测试文件；整群包装任意核心设计的通用性测试

### Phase 6：展示层升级 + 文档工程（1 天）
**产出**：print/summary/plot 现代化 + pkgdown 站点

- [ ] 6.1 `R/s3-methods/` 迁移三文件并升级：
  - print：紧凑输出（含角色说明、调整审计）
  - summary：完整报告（公式+引用+锚点对照）——**文献引用字段按设计×来源精确到小节页码**
  - plot：power 曲线支持新 API（design/task/outcome 重放调用）
  - **测试**：snapshot print/summary 输出（17 旧 + 全部新设计）
  - **测试**：plot 递归调用兼容新 API（ggplot2 缺失时跳过）
- [ ] 6.2 全包 `styler::style_pkg()`（air 未安装）；roxygenise；`devtools::check()`（或 R CMD check）
- [ ] 6.3 **引用修复**（上轮发现的问题全部落地）：
  - Rubinstein → 1981 J Chronic Dis 34(9-10):469-479
  - diagnosticAccuracySingle → Zhou §6.1.1 + Hajian §6.1
  - diagnosticComparisonTwo 修 `\\n` bug + Connor 1987
  - twoProportions 归属 Fleiss 1980 + Casagrande 页码补全 483-494
  - caseControl 的 Breslow & Day 副标题补全 + Dupont 改标注
  - Hajian-Tilaki 标题 determination→estimation
- [ ] 6.4 `_pkgdown.yml`：按设计族分组的 reference 索引
- [ ] 6.5 vignettes 重写：Getting started（三轴 API 教程）+ 设计选择指南（Hajian §11 六条指南）+ 观察性设计专文 + 诊断三阶段专文
- [ ] 6.6 README 重写：新 API + 设计矩阵速查表 + 引用示例

### Phase 6 验收：R CMD check 全绿；pkgdown::check_pkgdown() 无缺页；所有 snapshot 通过

### Phase 7：质量关卡（0.5 天）
**产出**：发布级质量

- [ ] 7.1 全量 `R CMD check --as-cran`（--no-vignettes 可先跳过 vignette 重建）
- [ ] 7.2 testthat **并行 + shuffle** 测试（确保测试独立）：`testthat::test_local(shuffle=TRUE)`
- [ ] 7.3 性能：plot power 曲线 40 点 = 40 次重算（现实现），对 17 旧设计计时基准（<5s 全部完成）
- [ ] 7.4 `critical-code-reviewer` 技能跑一轮全代码审查（.agents/skills/critical-code-reviewer）
- [ ] 7.5 `review-testing` 技能评估测试覆盖缺口
- [ ] 7.6 引用核验脚本固化：项目根 `scripts/verify_references.R`（Crossref 核验，可重复执行）
- [ ] 7.7 VERSION 终检：DESCRIPTION 3.0.0、NEWS.md 完整、DESCRIPTION Collate 顺序正确
- [ ] 7.8 最终交付物盘点（对照 §1.1 目录结构核对文件清单）
- [ ] 7.9 后续工作占位（→ 3.1 版本）：MRMC（[Zhou] §6.5）、Simon 优化两阶段变体、CRM（◇◇◇O'Quigley 1990）、Riley 2020 验证法完整版

---

## 3. 每个新设计的「实施卡」模板（Phase 3-5 每个设计一张卡）

```
### 设计名: cohort（队列研究, 1:m 不等分, 二分类结局）
- 任务/结局/时间方向: test / proportion / 前瞻或回顾（参数角色不同）
- 公式: n₁ = [Z₁₋α/2·√((1+1/m)p̄q̄) + Z₁₋β·√(p₁q₁+p₀q₀/m)]² / (p₁−p₀)²
- 来源: Bhardwaj p.2559（队列表格）；Schlesselman 1982；Machin Ch.3
- 锚点: 暴露组 p1=0.30, 非暴露 p0=0.20, m=1, 95%/80% → n=293；+10% 无应答 → 322/组 → 644
- 参数角色: p0 = 非暴露组发病率；m = 非暴露:暴露比；效应指标 RR
- 错误条件: p1==p0 → error；m<1 或非整数 → error
- S3 输出: n_1/n_2/total_n/roles/formula_latex/reference
- 测试: 锚点 expect_equal ±1（文献四舍五入顺序）；错误路径 snapshot；参数角色字符串断言
```

---

## 4. 测试策略（r-testthat 技能全面落地）

1. **镜像组织**：每个 `R/{name}.R` ↔ `tests/testthat/test-{name}.R`（现有 test-sample-size-calculator.R 保留并扩展）
2. **三层验证**（每个公式）：
   - **锚点层**：文献算例 `expect_equal(n, 323)`（容差按来源定 ±0.5 或 ±1）
   - **结构层**：S3 字段完备性（new/validate 断言）
   - **条件层**：边界（δ=0、margin≤0、ICC∈[0,1]）→ `expect_snapshot(error=TRUE)`
3. **行为锁定**（golden master）：17 个旧设计的「旧调用 vs 新调用」等价断言；print/summary 快照
4. **独立性**：Phase 7 shuffle 测试；无跨测试状态
5. **快照管理**：新增/修改输出时 `snapshot_review()` → 人工确认 → `snapshot_accept()`

---

## 5. 风险与对策

| 风险 | 对策 |
|---|---|
| 锚点数值与实现差 ±1（文献四舍五入顺序差异） | 容差策略文档化（NUMERIC_ANCHORS.md 记录每个锚点的容差及原因）；不硬凑数值 |
| Zhou §6.3/§6.5 公式需要细读推导 | 每张实施卡先做「纸面推导确认」再写代码（卡上增加"推导确认"字段） |
| Cantor/Dupont/Simon 锚点需要下载原文 | 优先用 references/ 已有文献的算例锚点；原文算例待补（锚点待定项单独标记） |
| 17 个旧设计在重构中行为漂移 | Phase 1 的 golden master 等价测试为最高优先级红线 |
| devtools 缺失导致流程不畅 | roxygen2 + rcmdcheck 直跑（本机可用）；devtools 仅是便利层 |
| vignette 重建耗时长 | check 时 --no-vignettes 先跑代码检查，发布前再全量 |
| styler 与 air 格式不一致 | 选定 styler（tidyverse 规则），CI 里固定 `styler::style_pkg()` |
| ITS/Riley 公式不成熟 | 标记 experimental（r-lifecycle）标注 + 文档注明方法学限制 |

---

## 6. 交付时间线（总计 ~8.5 个工作日）

| Phase | 内容 | 工时 |
|---|---|---|
| 0 | 地基（S3 类 + 内部核 + 文档） | 0.5 天 |
| 1 | 统一入口 + 向后兼容（golden master） | 1 天 |
| 2 | 估计型 A1-A6 | 1 天 |
| 3 | 两样本/配对核 + 观察性设计 | 2 天 |
| 4 | 边距设计 + 诊断升级 + BE | 1.5 天 |
| 5 | 复杂设计（整群/楔形/Simon/Kappa/预测/ITS） | 2 天 |
| 6 | 展示层 + 文档工程 + 引用修复 | 1 天 |
| 7 | 质量关卡（并行/shuffle/reviewer/引用核验） | 0.5 天 |
| **合计** | | **~8.5 天** |

---

## 7. 每日工作循环（对每个 Phase 内的任务）

1. `use_r()`/`use_test()` 创建配对文件（或手动创建 R/x.R + tests/testthat/test-x.R）
2. 写公式实现 + 参数角色表 + reference 字段（精确到小节/页码）
3. 写测试：锚点 + 结构 + 条件（snapshot）
4. `testthat::test_local(filter="^calc-cohort")` 快速反馈
5. `styler::style_pkg()`（或 air format）+ `roxygen2::roxygenise()`
6. Phase 边界：全量 test_local + R CMD check + NEWS.md 更新 + git commit
7. 引用新文献时跑 `scripts/verify_references.R`（Crossref 核验脚本固化）
```
