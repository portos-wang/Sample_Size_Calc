# Formulas, calculation steps, and references / 公式、计算过程与参考文献

## Default output / 默认输出

[`calculate()`](https://portos-wang.github.io/Sample_Size_Calc/reference/calculate.md)
and
[`sample_size_calculator()`](https://portos-wang.github.io/Sample_Size_Calc/reference/sample_size_calculator.md)
return a `sample_size_result` object. Printing it displays the study
design, required sample size, and four report components. Assigning the
result to a variable stores it; `print(res)` or entering `res` in the R
console displays the report.

[`calculate()`](https://portos-wang.github.io/Sample_Size_Calc/reference/calculate.md)
和
[`sample_size_calculator()`](https://portos-wang.github.io/Sample_Size_Calc/reference/sample_size_calculator.md)
返回 `sample_size_result` 对象。
默认打印会显示研究设计、所需样本量，以及以下四项内容。赋值仅保存结果；
输入对象名称或调用 `print(res)` 即可查看完整输出。

| Content / 内容 | Console label / 控制台标签 | Field / 对象字段 |
|----|----|----|
| Plain-text formula / 纯文本公式 | `Formula (plain text)` | `formula` |
| LaTeX source / LaTeX 公式源码 | `Formula (LaTeX)` | `formula_latex` |
| Calculation process / 计算过程 | `Calculation process` | `calculation_steps` |
| Literature sources / 参考文献 | `Reference` | `reference` |

The following example runs when this page is built. Its calculation
process shows the normal approximation of about 35.32 per arm, followed
by the noncentral t power calculation and rounding to 37 per arm (74
total). Intermediate calculations and rounding depend on the chosen
method.

以下示例在构建页面时实际运行。计算过程先列出每组约 35.32 人的正态近似，
再说明非中心 t 分布效能求解和取整，最终为每组 37 人、合计 74 人。
不同设计采用的中间计算与取整规则有所不同。

``` r

res <- calculate("rct", "test", "mean", mean1 = 10, mean2 = 12, sd = 3)
print(res)
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
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 3 (Comparing Means), Section 3.2.1 two-sample parallel design, Eq 3.11 (p. 48; the Student t refinement is Table 3.2, p. 49).
#> 
#>  Also: Machin et al. (2018) Eq 5.4, p. 69 (same formula with the Student t correction term).
#> ────────────────────────────────────────────────────────────────────────────────
#> 
```

## Extract the four components / 提取四项内容

The report fields are available without parsing console output.
`calculation` and `calculation_steps` contain the same character vector.
[`cat()`](https://rdrr.io/r/base/cat.html) prints character values
without R’s quotes and vector indices.

可以直接从对象提取报告内容。`calculation` 与 `calculation_steps`
保存相同的 步骤文本向量；用 [`cat()`](https://rdrr.io/r/base/cat.html)
可避免 R 的引号和向量下标，便于复制到方案或论文。

``` r

cat(res$formula, "\n")
#> n = 2 * ((Z_alpha/2 + Z_beta) * sd / (mean1 - mean2))^2
```

``` r

cat(res$formula_latex, "\n")
#> $$n = 2\left(\frac{Z_{\alpha/2} + Z_{\beta}}{\delta}\right)^2 = 2\left(\frac{(Z_{\alpha/2} + Z_{\beta}) \cdot \sigma}{\mu_1 - \mu_2}\right)^2$$
```

``` r

cat(res$calculation_steps, sep = "\n")
#> Step 1: State hypotheses: H0: mu1 = mu2 vs H1: mu1 != mu2 (two-sided alpha = 0.05, power = 0.80).
#> Step 2: Calculate mean difference delta = |mu1 - mu2| = |10 - 12| = 2; common SD sigma = 3.
#> Step 3: Determine critical values: Z_(alpha/2) = 1.96 (for two-sided alpha = 0.05), Z_beta = 0.8416 (for power = 0.80).
#> Step 4: Compute initial sample size via normal approximation: n0 = 2 * ((Z_(alpha/2) + Z_beta) * sigma / delta)^2 = 2 * ((1.96 + 0.8416) * 3 / 2)^2 = 35.32.
#> Step 5: Refine via exact two-sample Student's t-test power iteration (accounting for degrees of freedom df = 2n - 2).
#> Step 6: Round up to integer: n = 37 per group, total sample size N = 74.
```

``` r

cat(res$reference, "\n")
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 3 (Comparing Means), Section 3.2.1 two-sample parallel design, Eq 3.11 (p. 48; the Student t refinement is Table 3.2, p. 49).
#> 
#>  Also: Machin et al. (2018) Eq 5.4, p. 69 (same formula with the Student t correction term).
```

## Typeset the LaTeX formula / 排版 LaTeX 公式

The R console displays LaTeX as copyable source. For an HTML or PDF
report in R Markdown, set the chunk option `results = "asis"` and use
`cat(res$formula_latex, "\n\n")`. This page uses that approach below;
the formula comes directly from the result object.

R 控制台显示可复制的 LaTeX 源码。在 R Markdown 的 HTML 或 PDF 文档中，
可在 `results = "asis"` 代码块中使用 `cat(res$formula_latex, "\n\n")`
来排版公式。下方公式直接来自计算结果对象。

``` r

cat(res$formula_latex, "\n\n")
```

\\n = 2\left(\frac{Z\_{\alpha/2} + Z\_{\beta}}{\delta}\right)^2 =
2\left(\frac{(Z\_{\alpha/2} + Z\_{\beta}) \cdot \sigma}{\mu_1 -
\mu_2}\right)^2\\

## Additional parameters and adjustments / 参数与调整明细

[`summary()`](https://rdrr.io/r/base/summary.html) includes the four
report components and additionally lists all input parameters,
classification axes, and recorded adjustments.

[`summary()`](https://rdrr.io/r/base/summary.html)
同样包含四项报告内容，并进一步列出全部输入参数、设计分类轴和
已记录的调整。

``` r

summary(res)
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
#> Chow, S. C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size Calculations in Clinical Research (3rd ed.). CRC Press. Chapter 3 (Comparing Means), Section 3.2.1 two-sample parallel design, Eq 3.11 (p. 48; the Student t refinement is Table 3.2, p. 49).
#> 
#>  Also: Machin et al. (2018) Eq 5.4, p. 69 (same formula with the Student t correction term).
#> ────────────────────────────────────────────────────────────────────────────────
```

The legacy entry point provides the same four report components:

旧入口也包含相同的四项报告内容：

``` r

legacy_res <- sample_size_calculator(
  "twoProportions", p1 = 0.85, p2 = 0.70
)
print(legacy_res)
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

## Save a text report / 保存文本报告

This example writes the stored report components to a UTF-8 text file in
your R working directory. It is shown without execution so building the
website does not create a report file.

以下代码会将对象中的报告内容保存为 R 工作目录下的 UTF-8 文本文件。
网页展示代码供使用者运行，构建网站时不会创建该文件。

``` r

report <- c(
  res$design_type,
  paste("Sample size per group:", res$n_per_group),
  paste("Total sample size:", res$total_n),
  "", "Formula (plain text)", res$formula,
  "", "Formula (LaTeX)", res$formula_latex,
  "", "Calculation process", res$calculation_steps,
  "", "Reference", res$reference
)
writeLines(enc2utf8(report), "sample-size-report.txt", useBytes = TRUE)
```

See the [English
guide](https://portos-wang.github.io/Sample_Size_Calc/articles/sampleSizeCalc-guide-en.md)
or
[中文完整指南](https://portos-wang.github.io/Sample_Size_Calc/articles/sampleSizeCalc-guide-zh.md)
for examples across study designs.
