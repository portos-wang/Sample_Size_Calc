# SampleSizeCalc 英文论文初稿说明

本目录是按 **SoftwareX 软件论文**定位撰写的英文初稿 v0.1，可继续改写为 The R Journal 稿件。它包含完整正文、表图和复现代码；作者声明及发表前需要确认的信息用 **TO COMPLETE** 标出。

## 先看哪些文件

- `SampleSizeCalc_SoftwareX_draft.docx`：可编辑的 Word 初稿，建议优先审阅。
- `SampleSizeCalc_SoftwareX_draft.pdf`：PDF 阅读版，用于核对公式、图表和版面。
- `SampleSizeCalc_SoftwareX_draft.md`：展开计算结果后的 Markdown 阅读稿；文献引用标记保留给 Pandoc 处理。
- `paper.Rmd`：正文的主源文件。修改后用 `build.R` 重建，不直接修改生成的 Markdown。
- `references.bib`：11 条参考文献，包括原始方法、书籍和比较软件。
- `replicate.R`：重新计算数值、导出表格并绘图。
- `tables/`、`figures/`：可单独检查和使用的 CSV 表格、PNG 及 PDF 图。
- `evidence/`：冻结源码包、历史检查日志、会话信息与事实核对记录。

论文标题为：

> SampleSizeCalc: Traceable Sample Size Planning for Clinical Research in R

正文按动机、软件设计、三个案例、验证、研究价值及局限性、结论、代码元数据和作者声明组织。主文按导出 Word 文本计数约 2,400 个英文词，摘要约 180 个词，另有元数据、声明和参考文献；具体计数方法及结果见 `evidence/draft-audit.json`。当前版面不是出版社的最终投稿模板。

## 已经落到稿件里的实际结果

| 内容 | 本稿采用的结果及依据 |
|---|---|
| 功能范围 | 从冻结源码的 `ssr_combinations` 读取：46 个合法组合、24 个设计标识。完整清单见 `tables/dispatch-inventory.csv`。 |
| 平行随机试验 | 均值差 2 mmHg、SD 3、双侧 alpha 0.05、power 0.80：37 人/组，74 人总计。显式加上 10% 缺失余量后为 42 人/组。 |
| 诊断敏感度精度 | Se=0.85、95% CI 半宽 0.05：196 个确诊病例；患病率 0.20 时，期望值换算为筛查 980 人，90% 病例数保障对应最小筛查人数为 1,061。 |
| 生物等效性 | CV 0.25、GMR 1.00、界值 0.80–1.25、alpha 0.05、power 0.80：24 人总计、12 人/序列；GMR 改为 0.95 时为 28 人总计。 |
| 数值对照 | 12 个选定比较全部在表内的整数要求上相同，涉及公式核对、文献实例、`presize` 和 `PowerTOST`。正文列出其中 8 项，完整数据见 `tables/validation-full.csv`。 |
| 工程验证 | 2026-11-05 的三份完整 CRAN 风格检查日志均为 0 ERROR、0 WARNING、1 个 `New submission` NOTE；另有 630 项开发断言通过的记录。 |

这里的“46 个组合”是调度入口清单数量，不等于 46 个相互独立的统计方法，也不等于已对每个方法完成全面外部验证。本稿以冻结代码清单和实际调用结果为准。

正文严格区分：

1. 已执行并记录的数值结果和历史软件检查。
2. 为说明流程而设定的教学场景。
3. 尚需作者提供材料的真实研究使用与外部采用情况。

没有将教学案例写成已开展的临床试验，也没有填写未经确认的使用量、研究机构采用情况、用户评价或临床效果。

## 作者需要补充或确认的项目

- 确认署名顺序、姓名写法、单位完整地址、通讯作者、ORCID，以及双方实际 CRediT 贡献。
- 填写真实资助信息和利益冲突声明。目前保留为 TO COMPLETE，未擅自写“无资助”或“无利益冲突”。
- 如已有真实研究方案、分析流程或外部团队使用，提供可核查材料，用于完善 Impact 部分。若暂无，保留对预期用途和证据边界的表述。
- 给最终软件版本创建不可变的发布标识，并确定源码、数值表及复现脚本的长期公开存档地址或 DOI。当前仅提供开发仓库链接和已核验的本地源码快照。
- 确认 CRAN 的正式收录状态，再决定是否加入 CRAN 安装链接。初稿没有宣称包已经通过 CRAN 正式接收。
- 审阅并确认稿件中的期刊必需声明，以及作者对全文、代码、计算和文献的核验与责任说明。
- 最终选定期刊后，使用其当期官方模板整理元数据、参考文献格式与提交附件。

## 已明确写出的适用范围

- `alternative`、`dropout` 等控制参数的适用范围与具体设计有关。
- ITS 入口为实验性简化方案。
- 预测模型入口实现的是选定准则和 EPV 选项，未写成完整实现 Riley 全部准则。
- 选定数值对照的一致性和 CRAN 风格检查，不能替代所有设计的统计性能评价。
- 未声称相对其他工具运行更快、估计更优、减少了实际错误，或已经改善临床研究决策。

## 复现与重建

在本目录启动 R，先安装缺失的工具依赖：

```r
install.packages(c(
  "pkgload", "digest", "jsonlite", "ggplot2", "presize", "PowerTOST",
  "rmarkdown", "knitr"
))
```

数值与图表复现：

```r
source("replicate.R")
```

脚本核对冻结源码包的 SHA-256 后才运行。源码包已放在 `evidence/` 中；即使开发仓库后续更新，本稿数值仍对应这一固定快照。比较软件的具体版本写入 `evidence/verification.json`。

重建 Markdown、Word 和 PDF：

```r
source("build.R")
```

需要 Pandoc 和可用的 LaTeX。当前环境使用 R 4.6.1、Pandoc 3.10.1 和 TeX Live 2026；`build.R` 会识别本机用户目录下的 TinyTeX。已有的 `reference.docx` 用于 Word 样式，无需重新生成；如需改样式，可运行 `python prepare_word_template.py`，该脚本使用 `python-docx`。

`python audit_draft.py` 用于核对导出物中的标题、摘要、图表、验证数据和待补标记，并生成 PDF 版面预览与检查摘要。该步骤另需 `python-docx`、`PyMuPDF` 和 `Pillow`；可用 `python -m pip install -r requirements.txt` 安装本文使用的版本。R 依赖清单另存于 `R-packages.txt`。

本目录位于既有 `.Rbuildignore` 排除的 `plans/` 下。创建初稿无需改动已经完成检查的 R 包源码或源码压缩包。
