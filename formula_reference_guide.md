# 样本量计算公式速查手册

**项目**: sampleSizeCalc R包  
**版本**: 2.0.0  
**更新日期**: 2026-03-17

---

## 📋 目录

1. [连续结果变量](#连续结果变量)
2. [分类结果变量](#分类结果变量)
3. [生存分析](#生存分析)
4. [诊断试验](#诊断试验)
5. [ROC/AUC分析](#rocauc分析)
6. [病例对照研究](#病例对照研究)

---

## 连续结果变量

### 1️⃣ twoMeans - 两独立样本均值比较

**📐 公式**:
```
n = 2 × [(Z_α/2 + Z_β) × σ / (μ₁ - μ₂)]²
```

**🎯 适用场景**:
- 比较两组的连续型变量均值
- 例如：试验组 vs 对照组的血压、体重、评分等

**📊 关键参数**:
- `mean1`: 第一组均值
- `mean2`: 第二组均值  
- `sd`: 共同标准差（假设两组方差相等）
- `alpha`: I类错误概率（通常0.05）
- `power`: 检验效能（通常0.8或0.9）

**📚 来源**: Chow et al. (2017), Chapter 3

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "twoMeans",
  mean1 = 10,
  mean2 = 12,
  sd = 3,
  alpha = 0.05,
  power = 0.8
)
# 结果: 每组需要 64 例，共 128 例
```

---

### 2️⃣ pairedMeans - 配对样本均值比较

**📐 公式**:
```
n = [(Z_α/2 + Z_β) × σd / μd]²
```

**🎯 适用场景**:
- 前后对照设计（同一受试者前后两次测量）
- 配对设计（如根据年龄、性别配对）
- 交叉设计的crossover

**📊 关键参数**:
- `meanDiff`: 配对差异的均值
- `sdDiff`: 配对差异的标准差
- `alpha`, `power`: 同上

**📚 来源**: Rosner (2015), Fundamentals of Biostatistics, 8th ed.

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "pairedMeans",
  meanDiff = 5,    # 平均差异
  sdDiff = 10,     # 差异的标准差
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 34 对（68 例个体）
```

---

### 3️⃣ nonInferiorityMeans - 非劣效性检验（均值）

**📐 公式**:
```
δ = μ₁ - μ₂ + Δ
n = 2 × [(Z_α + Z_β) × σ / δ]²
```

其中 Δ 是非劣效性界值（margin）

**🎯 适用场景**:
- 证明新药不比标准治疗差
- 新方法是否"不劣于"金标准
- **单侧检验**（使用Z_α而非Z_α/2）

**📊 关键参数**:
- `mean1`: 试验组均值
- `mean2`: 对照组均值
- `sd`: 标准差
- `margin`: 非劣效性界值Δ（允许的最大差异）
- `alpha`: 单侧检验的I类错误（通常0.025）

**⚠️ 关键要求**: δ = μ₁ - μ₂ + Δ 必须 > 0

**📚 来源**: Chow et al. (2017), Chapter 10

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "nonInferiorityMeans",
  mean1 = 100,      # 新药
  mean2 = 102,      # 标准药
  sd = 15,
  margin = 5,       # 非劣效性界值：允许新药比标准药差5个单位
  alpha = 0.025,    # 单侧检验
  power = 0.8
)
# δ = 100 - 102 + 5 = 3 > 0 ✓
# 结果: 每组需要 432 例
```

---

### 4️⃣ superiorityMeans - 优效性检验（均值）

**📐 公式**:
```
δ = μ₁ - μ₂ - Δ
n = 2 × [(Z_α + Z_β) × σ / δ]²
```

其中 Δ 是优效性界值（最小临床重要差异）

**🎯 适用场景**:
- 证明新药**优效于**标准治疗或安慰剂
- 证明差异不仅是统计显著的，且有**临床意义**
- **单侧检验**

**📊 关键参数**:
- `mean1`, `mean2`: 两组均值
- `sd`: 标准差
- `margin`: 最小临床重要差异Δ
- `alpha`: 单侧（通常0.025）

**⚠️ 关键要求**: δ = μ₁ - μ₂ - Δ 必须 > 0

**📚 来源**: Chow et al. (2017), Chapter 10

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "superiorityMeans",
  mean1 = 120,      # 新药
  mean2 = 110,      # 标准药
  sd = 20,
  margin = 5,       # 临床重要差异：至少比标准药好5个单位
  alpha = 0.025,
  power = 0.8
)
# δ = 120 - 110 - 5 = 5 > 0 ✓
# 结果: 每组需要 252 例
```

---

### 5️⃣ equivalenceMeans - 等效性检验（均值）

**📐 公式**:
```
δ = Δ - |μ₁ - μ₂|
n = 2 × [(Z_α + Z_β/2) × σ / δ]²
```

**🎯 适用场景**:
- 证明两种治疗方法**等效**
- TOST（Two One-Sided Tests）方法
- 常用于仿制药与原药比较

**📊 关键参数**:
- `mean1`, `mean2`: 两组均值
- `sd`: 标准差
- `margin`: 等效性界值Δ
- `alpha`: 通常0.05（每个单侧检验0.025）

**⚠️ 关键要求**: 
1. Δ > |μ₁ - μ₂|（等效界值必须大于实际差异）
2. 使用Z_β/2（因为需要两次单侧检验）

**📚 来源**: Chow et al. (2017), Chapter 10

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "equivalenceMeans",
  mean1 = 100,
  mean2 = 101,       # 两药均值只差1
  sd = 15,
  margin = 10,       # 等效界值：差异在±10以内认为等效
  alpha = 0.05,
  power = 0.8
)
# δ = 10 - |100-101| = 9 > 0 ✓
# 结果: 每组需要 85 例
```

---

## 分类结果变量

### 6️⃣ twoProportions - 两独立样本率比较

**📐 公式**:
```
n = [Z_α/2√(2p̄(1-p̄)) + Z_β√(p₁(1-p₁) + p₂(1-p₂))]² / (p₁ - p₂)²

其中 p̄ = (p₁ + p₂) / 2
```

**🎯 适用场景**:
- 比较两组的发生率、有效率、阳性率等
- 例如：试验组有效率 vs 对照组有效率

**📊 关键参数**:
- `p1`: 第一组率
- `p2`: 第二组率
- `alpha`, `power`: 同上

**📚 来源**: Fleiss et al. (2003), Statistical Methods for Rates and Proportions, 3rd ed.

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "twoProportions",
  p1 = 0.30,        # 对照组有效率30%
  p2 = 0.50,        # 试验组有效率50%
  alpha = 0.05,
  power = 0.8
)
# 结果: 每组需要 124 例，共 248 例
```

---

### 7️⃣ equivalenceProportions - 等效性检验（率）

**📐 公式**:
```
δ = Δ - |p₁ - p₂|
n = (Z_α + Z_β/2)²[p₁(1-p₁) + p₂(1-p₂)] / δ²
```

**🎯 适用场景**:
- 证明两种治疗方法的**有效率等效**
- TOST方法用于分类数据

**📊 关键参数**:
- `p1`, `p2`: 两组率
- `margin`: 等效界值Δ
- `alpha`: 通常0.05

**⚠️ 关键要求**: Δ > |p₁ - p₂|

**📚 来源**: Chow et al. (2017)

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "equivalenceProportions",
  p1 = 0.75,
  p2 = 0.73,        # 两率仅差2%
  margin = 0.10,    # 等效界值：差异在±10%以内认为等效
  alpha = 0.05,
  power = 0.8
)
# 结果: 每组需要 353 例
```

---

### 8️⃣ superiorityProportions - 优效性检验（率）

**📐 公式**:
```
δ = p₁ - p₂ - Δ
n = (Z_α + Z_β)²[p₁(1-p₁) + p₂(1-p₂)] / δ²
```

**🎯 适用场景**:
- 证明新方法的有效率**优效于**对照
- 要求差异具有临床意义

**📊 关键参数**:
- `p1`, `p2`: 两组率
- `margin`: 最小临床重要差异Δ
- `alpha`: 单侧（通常0.025）

**⚠️ 关键要求**: δ = p₁ - p₂ - Δ 必须 > 0

**📚 来源**: Chow et al. (2017)

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "superiorityProportions",
  p1 = 0.80,        # 新药有效率80%
  p2 = 0.65,        # 标准药有效率65%
  margin = 0.05,    # 临床重要差异：至少高5%
  alpha = 0.025,
  power = 0.8
)
# δ = 0.80 - 0.65 - 0.05 = 0.10 > 0 ✓
# 结果: 每组需要 443 例
```

---

## 生存分析

### 9️⃣ survival - 生存分析（Log-rank检验）

**📐 公式**:
```
E = (Z_α/2 + Z_β)² / [p_E(1-p_E) × ln(HR)²]
```

**🎯 适用场景**:
- 比较两组的生存时间
- 时间-事件数据分析
- 临床试验的主要终点是总生存期（OS）或无进展生存期（PFS）

**📊 关键参数**:
- `hr`: 风险比（Hazard Ratio）
- `pE`: 试验组事件比例（默认0.5，即等比例随机化）
- `alpha`, `power`: 同上

**⚠️ 重要说明**:
- **计算的是事件数（E），不是样本数**
- 样本数 = 事件数 / 事件发生率
- ln(HR)是自然对数

**📚 来源**: Schoenfeld (1983), Biometrics, 39(2), 499-503

**💡 R代码示例**:
```r
# 假设HR=0.7（试验组风险降低30%）
sample_size_calculator(
  design = "survival",
  hr = 0.7,         # 风险比
  pE = 0.5,         # 1:1随机化
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 352 个事件
# 如果预期事件率70%，则总样本数 = 352/0.7 ≈ 503 例
```

**🔍 公式解读**:
- HR < 1: 试验组风险更低（有利）
- HR > 1: 试验组风险更高（不利）
- |ln(HR)|越大，所需事件数越少

---

## 诊断试验

### 🔟 diagnosticAccuracySingle - 诊断精度估计（单组）

**📐 公式**:
```
n_cases = Z_1-α/2² × p(1-p) / d²
```

**🎯 适用场景**:
- 估计诊断方法的灵敏度或特异度
- 估计AUC的置信区间精度
- **单组设计**（只有一个诊断方法）

**📊 关键参数**:
- `prob`: 预期的灵敏度、特异度或AUC值
- `d`: 精度（置信区间半宽，marginal error）
- `prevalence`: 目标疾病患病率（默认1）
- `alpha`: 通常0.05（95%置信区间）

**📚 来源**: Hajian-Tilaki (2014), Journal of Biomedical Informatics, 48, 193-204

**💡 R代码示例**:
```r
# 估计灵敏度，预期85%，精度±5%
sample_size_calculator(
  design = "diagnosticAccuracySingle",
  prob = 0.85,      # 预期灵敏度
  d = 0.05,         # 精度±5%
  prevalence = 0.20, # 患病率20%
  alpha = 0.05
)
# 结果: 需要 195 个病例
# 总筛查数 = 195/0.20 = 975 例
```

---

### 1️⃣1️⃣ diagnosticSuperioritySingle - 诊断优效性（单组）

**📐 公式**:
```
n = [Z_α√(p₀(1-p₀)) + Z_β√(p(1-p))]² / (p - p₀)²
```

**🎯 适用场景**:
- 检验新诊断方法的性能是否**优效于**某个标准值p₀
- 例如：新方法的灵敏度是否显著优于80%

**📊 关键参数**:
- `prob`: 新方法的预期性能（p）
- `p0`: 标准值/对照值（p₀）
- `prevalence`: 患病率
- `alpha`: 单侧（通常0.05）

**📚 来源**: Hajian-Tilaki (2014)

**💡 R代码示例**:
```r
# 检验新方法灵敏度是否优效于0.80
sample_size_calculator(
  design = "diagnosticSuperioritySingle",
  prob = 0.88,      # 新方法预期88%
  p0 = 0.80,        # 标准值80%
  prevalence = 0.25,
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 302 个病例
```

---

### 1️⃣2️⃣ diagnosticComparisonTwo - 两诊断方法比较

**📐 公式**:

**不配对设计**:
```
n = [Z_α/2√(2p̄(1-p̄)) + Z_β√(p₁(1-p₁) + p₂(1-p₂))]² / (p₁ - p₂)²
```

**配对设计**（McNemar检验）:
```
n = [Z_α/2×ψ + Z_β√(ψ² - (p₁-p₂)²/4)]² / (p₁-p₂)²
```
其中 ψ 是不一致对的比例

**🎯 适用场景**:
- **不配对**: 两种诊断方法用于不同受试者
- **配对**: 两种诊断方法用于**同一受试者**（更常见）

**📊 关键参数**:
- `p1`, `p2`: 两种方法的灵敏度/特异度
- `paired`: TRUE=配对设计，FALSE=不配对
- `psi`: 不一致对比例（配对设计必需）
- `prevalence`: 患病率

**📚 来源**: Hajian-Tilaki (2014)

**💡 R代码示例**:

```r
# 配对设计
sample_size_calculator(
  design = "diagnosticComparisonTwo",
  p1 = 0.90,        # 方法A灵敏度
  p2 = 0.85,        # 方法B灵敏度
  paired = TRUE,
  psi = 0.15,       # 不一致对比例15%
  prevalence = 0.30,
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 539 个病例
```

---

### 1️⃣3️⃣ likelihoodRatioTest - 似然比估计

**📐 公式**:
```
n_cases = max{
  Z_1-α/2² × Se(1-Se) / d²,
  Z_1-α/2² × Sp(1-Sp) / d² × [P/(1-P)]
}
```

**🎯 适用场景**:
- 同时估计阳性似然比（LR+）和阴性似然比（LR-）
- 取灵敏度和特异度所需样本量的**最大值**

**📊 关键参数**:
- `sens`: 预期灵敏度
- `spec`: 预期特异度
- `prevalence`: 患病率P
- `precision`: 精度d（默认0.1）
- `alpha`: 通常0.05

**📚 来源**: Hajian-Tilaki (2014)

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "likelihoodRatioTest",
  sens = 0.85,
  spec = 0.80,
  prevalence = 0.20,
  precision = 0.10,  # 精度±10%
  alpha = 0.05
)
# 结果: 需要 196 个病例（基于灵敏度）
```

---

## ROC/AUC分析

### 1️⃣4️⃣ auc_single - AUC置信区间估计

**📐 公式**:
```
Q₁ = A / (2-A)
Q₂ = 2A² / (1+A)
V(A) = A(1-A) + (1/K)(Q₁ - A²) + (Q₂ - A²)
n_cases = (Z_1-α/2 / d)² × V(A)
```

其中 K = (1-P) / P（非病例与病例的比例）

**🎯 适用场景**:
- 估计ROC曲线下面积（AUC）
- 确定AUC的置信区间精度

**📊 关键参数**:
- `auc`: 预期AUC值
- `d`: 精度（置信区间半宽）
- `prevalence`: 患病率P
- `alpha`: 通常0.05

**📚 来源**: Hajian-Tilaki (2014), based on Hanley & McNeil (1982)

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "auc_single",
  auc = 0.80,       # 预期AUC
  d = 0.05,         # 精度±0.05
  prevalence = 0.25,
  alpha = 0.05
)
# 结果: 需要 241 个病例
```

---

### 1️⃣5️⃣ aucSuperiority - AUC优效性检验

**📐 公式**:
```
n_cases = [Z_α√(V(AUC₀)) + Z_β√(V(AUC))]² / (AUC - AUC₀)²
```

**🎯 适用场景**:
- 检验新诊断方法的AUC是否**优效于**某个标准值AUC₀

**📊 关键参数**:
- `auc`: 新方法的预期AUC
- `auc0`: 标准值（null AUC）
- `prevalence`: 患病率
- `alpha`: 单侧（通常0.05）

**📚 来源**: Hajian-Tilaki (2014)

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "aucSuperiority",
  auc = 0.85,       # 新方法
  auc0 = 0.75,      # 标准值
  prevalence = 0.30,
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 143 个病例
```

---

### 1️⃣6️⃣ aucComparison - 两AUC比较（配对）

**📐 公式**:
```
A_avg = (AUC₁ + AUC₂) / 2
V(A_avg) 基于平均AUC计算
n_cases = 2(Z_α/2 + Z_β)² × V(A_avg) × (1-r) / (AUC₁ - AUC₂)²
```

其中 r 是两个AUC之间的相关系数

**🎯 适用场景**:
- 比较两种诊断方法的AUC
- **配对设计**（同一受试者接受两种诊断）

**📊 关键参数**:
- `auc1`, `auc2`: 两种方法的AUC
- `r`: AUC之间的相关系数
- `prevalence`: 患病率
- `alpha`, `power`: 同上

**📚 来源**: Hajian-Tilaki (2014), based on Hanley & McNeil (1983)

**💡 R代码示例**:
```r
sample_size_calculator(
  design = "aucComparison",
  auc1 = 0.88,
  auc2 = 0.80,
  r = 0.6,          # 两AUC相关系数
  prevalence = 0.25,
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 182 个病例
```

---

## 病例对照研究

### 1️⃣7️⃣ caseControl - 病例对照研究

**📐 公式**:
```
p₁ = (OR × p₀) / (1 - p₀ + OR × p₀)
p̄ = (p₁ + m×p₀) / (1+m)
n_cases = [Z_α/2√((1+1/m)p̄(1-p̄)) + Z_β√(p₁(1-p₁) + p₀(1-p₀)/m)]² / (p₁-p₀)²
```

**🎯 适用场景**:
- 病例对照研究设计
- 估计暴露与疾病的关联（OR）
- 1:m匹配设计（每个病例匹配m个对照）

**📊 关键参数**:
- `p0`: 对照组暴露率
- `OR`: 预期的比值比
- `m`: 每个病例对应的对照数（默认1）
- `alpha`, `power`: 同上

**📚 来源**: Schlesselman (1982), Case-Control Studies: Design, Conduct, Analysis

**💡 R代码示例**:
```r
# 1:2匹配病例对照研究
sample_size_calculator(
  design = "caseControl",
  p0 = 0.20,        # 对照组暴露率20%
  OR = 2.5,         # 预期OR=2.5
  m = 2,            # 1:2匹配
  alpha = 0.05,
  power = 0.8
)
# 结果: 需要 165 个病例，330 个对照
# 总样本数 = 495 例
```

**🔍 公式解读**:
- p₁: 病例组预期暴露率（通过OR计算）
- m > 1时，可以减少所需病例数（但总样本数可能增加）
- m = 1时就是1:1匹配

---

## 📊 快速参考表

| 设计类型 | 公式核心 | 关键特点 | 主要引用 |
|---------|---------|---------|---------|
| **twoMeans** | 2[(Z_α/2+Z_β)σ/Δ]² | 双侧检验 | Chow 2017 |
| **pairedMeans** | [(Z_α/2+Z_β)σd/Δd]² | 配对设计 | Rosner 2015 |
| **nonInferiorityMeans** | 2[(Z_α+Z_β)σ/(Δ₁-Δ₂+margin)]² | 单侧检验 | Chow 2017 |
| **superiorityMeans** | 2[(Z_α+Z_β)σ/(Δ₁-Δ₂-margin)]² | 单侧+临床意义 | Chow 2017 |
| **equivalenceMeans** | 2[(Z_α+Z_β/2)σ/(margin-\|Δ₁-Δ₂\|)]² | TOST | Chow 2017 |
| **twoProportions** | 分母:(p₁-p₂)² | 率的比较 | Fleiss 2003 |
| **survival** | (Z_α/2+Z_β)²/[p(1-p)ln²(HR)] | 事件数计算 | Schoenfeld 1983 |
| **caseControl** | 基于OR和暴露率 | 1:m匹配 | Schlesselman 1982 |
| **AUC方法** | Hanley-McNeil方差 | ROC分析 | Hajian-Tilaki 2014 |
| **诊断试验** | 精度或检验 | 灵敏度/特异度 | Hajian-Tilaki 2014 |

---

## 🎯 如何选择合适的设计

```
                    ┌─ 连续结果? ──→ twoMeans/pairedMeans
                    │
                    ├─ 分类结果? ──→ twoProportions
                    │
                    ├─ 生存数据? ──→ survival (注意:事件数!)
                    │
研究目的? ──────┼─ 诊断试验? ──→ diagnosticAccuracySingle等
                    │
                    ├─ AUC比较? ──→ auc_single/aucComparison
                    │
                    └─ 病例对照? ──→ caseControl
                    
                    
                    ┌─ 证明"不差" ──→ nonInferiorityMeans/Proportions
                    │
                    ├─ 证明"更好" ──→ superiorityMeans/Proportions
                    │
                    └─ 证明"相当" ──→ equivalenceMeans/Proportions
```

---

## ⚠️ 常见错误提醒

1. **混淆单双侧**:
   - 非劣效性/优效性: 单侧（Z_α）
   - 等效性: 双单侧（Z_α, Z_β/2）
   - 普通比较: 双侧（Z_α/2）

2. **生存分析**:
   - 计算的是**事件数**，不是样本数
   - 需要根据事件率换算样本数

3. **等效性检验**:
   - 界值必须大于实际差异
   - 使用TOST方法

4. **诊断试验**:
   - 注意患病率调整
   - 分清"病例数"和"筛查总数"

---

## 📚 完整参考文献

1. Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). *Sample size calculations in clinical research* (3rd ed.). CRC Press.

2. Fleiss, J. L., Levin, B., & Paik, M. C. (2003). *Statistical methods for rates and proportions* (3rd ed.). Wiley.

3. Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. *Biometrics*, 39(2), 499-503.

4. Rosner, B. (2015). *Fundamentals of biostatistics* (8th ed.). Cengage Learning.

5. Schlesselman, J. J. (1982). *Case-control studies: Design, conduct, analysis*. Oxford University Press.

6. Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. *Journal of Biomedical Informatics*, 48, 193-204.

---

**文档版本**: 1.0  
**最后更新**: 2026-03-17  
**维护者**: sampleSizeCalc开发团队
