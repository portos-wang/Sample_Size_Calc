# SampleSizeCalc 包升级计划

**当前版本**: 2.0.0  
**目标版本**: 2.1.0  
**升级日期**: 2026-03-17

---

## 📋 升级概述

基于文献验证报告(literature_verification_report.md)的建议,本次升级主要关注**文献引用的完善**和**文档的改进**。

**主要目标**:
1. ✅ 补充原始文献引用(增加权威性)
2. ✅ 改进引用展示格式(支持多引用)
3. ✅ 更新文档和示例
4. ✅ 提升包的学术严谨性

---

## 🎯 升级任务清单

### 优先级1: 核心文献引用更新

#### 1.1 AUC方法补充原始文献 🔴 HIGH

**当前状态**: 使用Hajian-Tilaki (2014)综述  
**问题**: 综述文章虽好,但原始方法论文更权威  
**改进方案**:

```r
# 当前代码 (行142-165, 385-415, 417-447)
reference = "Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204."

# 改进后 - 添加原始文献
reference = "Primary: Hanley, J. A., & McNeil, B. J. (1982). The meaning and use of the area under a receiver operating characteristic (ROC) curve. Radiology, 143(1), 29-36.

Review: Hajian-Tilaki, K. (2014). Sample size determination in diagnostic test studies of biomedical informatics: Literature review. Journal of Biomedical Informatics, 48, 193-204."
```

**涉及方法**:
- `auc_single` (行142-165)
- `aucSuperiority` (行385-415)
- `aucComparison` (行417-447)

**理由**: Hanley & McNeil (1982)是AUC方法的奠基性论文,被引用数千次,审稿人更认可。

---

#### 1.2 率比较方法补充简化公式文献 🔴 HIGH

**当前状态**: 使用Fleiss et al. (2003)教材  
**问题**: 教材权威,但Casagrande等人的简化公式更实用  
**改进方案**:

```r
# 当前代码 (行168-191)
reference = "Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley."

# 改进后 - 添加简化公式
reference = "Primary: Fleiss, J. L., Levin, B., & Paik, M. C. (2003). Statistical methods for rates and proportions (3rd ed.). Wiley.

Simplified formula: Casagrande, J. T., Pike, M. C., & Smith, P. G. (1978). An improved approximate formula for calculating sample sizes for comparing two binomial distributions. Biometrics, 34(3), 483-486.

Alternative: Fleiss, J. L., Tytun, A., & Ury, H. K. (1980). A simple approximation for calculating sample sizes for comparing independent proportions. Biometrics, 36(2), 343-346."
```

**涉及方法**:
- `twoProportions` (行168-191)

**理由**: 提供更实用的简化公式引用,方便用户快速查阅。

---

#### 1.3 生存分析补充扩展文献 🟡 MEDIUM

**当前状态**: 使用Schoenfeld (1983)  
**问题**: Schoenfeld (1983)是经典,但后续有重要扩展  
**改进方案**:

```r
# 当前代码 (行219-238)
reference = "Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. Biometrics, 39(2), 499-503."

# 改进后 - 添加扩展
reference = "Primary: Schoenfeld, D. A. (1983). Sample-size formula for the proportional-hazards regression model. Biometrics, 39(2), 499-503.

Extensions: 
- Hsieh, F. Y., & Lavori, P. W. (2000). Sample-size calculations for the Cox proportional hazards regression model with nonbinary covariates. Controlled Clinical Trials, 21(6), 552-560.
- Rubinstein, L. V., Gail, M. H., & Santner, T. J. (1982). Planning the duration of a comparative clinical trial with loss to follow-up and a period of continued observation. Biometrics, 37(4), 673-682."
```

**涉及方法**:
- `survival` (行219-238)

**理由**: Hsieh & Lavori扩展到连续协变量,Rubinstein等人讨论试验持续时间。

---

#### 1.4 病例对照补充IARC经典 🟡 MEDIUM

**当前状态**: 使用Schlesselman (1982)  
**问题**: Schlesselman很经典,但Breslow & Day的IARC专著更全面  
**改进方案**:

```r
# 当前代码 (行449-472)
reference = "Schlesselman, J. J. (1982). Case-control studies: Design, conduct, analysis. Oxford University Press."

# 改进后 - 添加IARC经典
reference = "Primary: Schlesselman, J. J. (1982). Case-control studies: Design, conduct, analysis. Oxford University Press.

IARC Classic: Breslow, N. E., & Day, N. E. (1980). Statistical methods in cancer research: Volume 1 - The analysis of case-control studies. IARC Scientific Publications No. 32.

Alternative: Dupont, W. D. (1988). Power calculations for matched case-control studies. Biometrics, 44(4), 1157-1168."
```

**涉及方法**:
- `caseControl` (行449-472)

**理由**: Breslow & Day (1980)是病例对照研究的IARC官方方法学专著。

---

### 优先级2: 连续变量方法补充文献 🟢 LOW

#### 2.1 twoMeans补充样本量导论

```r
# 当前代码 (行115-140)
reference = "Chow et al. (2017)"

# 改进后
reference = "Primary: Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample size calculations in clinical research (3rd ed.). CRC Press.

Classic: Lachin, J. M. (1981). Introduction to sample size determination and power analysis for clinical trials. Controlled Clinical Trials, 2(2), 93-113."
```

#### 2.2 pairedMeans补充配对设计文献

```r
# 当前代码 (行193-217)
reference = "Rosner (2015)"

# 改进后
reference = "Primary: Rosner, B. (2015). Fundamentals of biostatistics (8th ed.). Cengage Learning.

Paired designs: Guo, Z., et al. (2013). Sample size calculation for repeated measures data. Statistics in Medicine, 32(23), 4041-4054."
```

---

### 优先级3: 代码结构改进 🟢 LOW

#### 3.1 支持多引用字段

**当前结构**: 单个`reference`字符串字段  
**改进方案**: 保持向后兼容,可选添加`references`(复数)字段

```r
# 方案A: 保持单引用字符串(向后兼容)
list(
  # ...
  reference = "Primary: ...\n\nSecondary: ..."
)

# 方案B: 新增可选的references字段
list(
  # ...
  reference = "Hajian-Tilaki (2014)",
  references = list(
    primary = "Hanley & McNeil (1982)",
    review = "Hajian-Tilaki (2014)"
  )
)
```

**推荐**: 方案A,在reference字段中使用段落分隔,保持简单。

---

#### 3.2 更新summary方法展示

**当前**: 直接输出reference字符串  
**改进**: 如果reference包含多个部分,格式化显示

```r
# 在summary.sample_size_result函数中改进
if (!is.null(object$reference)) {
  ref_parts <- strsplit(object$reference, "\\n\\n")[[1]]
  if (length(ref_parts) > 1) {
    cli::cli_h3("References")
    for (i in seq_along(ref_parts)) {
      cat(sprintf("[%s] %s\n\n", names(ref_parts)[i], ref_parts[i]))
    }
  } else {
    cat(object$reference, "\n")
  }
}
```

---

### 优先级4: 文档和元数据更新 🟢 LOW

#### 4.1 更新版本号

```r
# DESCRIPTION文件
Version: 2.1.0  # 从 2.0.0 升级
```

#### 4.2 更新README

在README的"Citation"部分添加完整引用示例:

```markdown
## Citation

If you use this package in your research, please cite:

```bibtex
@software{sampleSizeCalc,
  title = {sampleSizeCalc: Sample Size Calculator for Clinical Research},
  author = {AI Coding Assistant},
  year = {2026},
  version = {2.1.0},
  url = {https://github.com/portos-wang/sampleSizeCalc}
}
```

For specific methods, please cite the original methodology papers listed in the function documentation.
```

#### 4.3 创建CHANGELOG

```markdown
# Changelog

## Version 2.1.0 (2026-03-17)

### Added
- Additional primary literature citations for AUC methods (Hanley & McNeil 1982)
- Supplemental references for survival analysis (Hsieh & Lavori 2000)
- Alternative formula citations for proportion comparisons (Casagrande 1978)
- IARC classic reference for case-control studies (Breslow & Day 1980)

### Improved  
- More comprehensive literature support in method documentation
- Better academic rigor with primary source citations
- Enhanced reference formatting in summary output

### Fixed
- N/A
```

---

## 📊 实施优先级

| 优先级 | 任务 | 预计时间 | 影响 |
|--------|------|---------|------|
| 🔴 HIGH | AUC方法文献更新 | 15分钟 | 提升学术权威性 |
| 🔴 HIGH | 率比较文献更新 | 10分钟 | 提供实用参考 |
| 🟡 MEDIUM | 生存分析文献扩展 | 10分钟 | 增强完整性 |
| 🟡 MEDIUM | 病例对照文献补充 | 10分钟 | 增加经典引用 |
| 🟢 LOW | 连续变量文献补充 | 10分钟 | 锦上添花 |
| 🟢 LOW | 版本号和文档更新 | 10分钟 | 规范化 |
| 🟢 LOW | CHANGELOG创建 | 5分钟 | 版本管理 |

**总计**: 约70分钟

---

## ✅ 验证清单

升级完成后需要验证:

- [ ] 所有17种方法都有至少一个权威引用
- [ ] AUC/ROC方法包含Hanley & McNeil原始文献
- [ ] summary方法正确显示多引用
- [ ] R CMD检查通过
- [ ] 所有测试通过
- [ ] vignette编译正常
- [ ] 版本号更新正确

---

## 📚 参考文档

- `literature_verification_report.md` - 完整文献验证报告
- `formula_reference_guide.md` - 公式参考手册
- `FORMULA_SUMMARY.md` - 速查表

---

**升级负责人**: AI Assistant  
**审核要求**: 在合并前请review所有文献引用的准确性和格式
