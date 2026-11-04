# Design Matrix

> Complete navigation for the `calculate()` three-axis API: Design × Task × Outcome × Formula × Source.
> Confirmed design decisions: (1) Parallel RCT designs are consolidated under `rct`; (2) Diagnostic family uses explicit canonical names; (3) Single-sample estimation tasks route through `single*`; (4) Legacy keywords are silently backward compatible.

## API Skeleton

```r
calculate(
  design,        # Design axis (see "Design" column below)
  task,          # Task axis: estimate | test | noninferiority | superiority | equivalence
  outcome,       # Outcome axis: mean | proportion | rate | survival | auc | lr | correlation
  ...            # Design-specific arguments + generic parameters (dropout, alternative, var_method, etc.)
)
```

> **Scope of the generic parameters.** Only `alpha`, `power`, `alternative`,
> `var_method`, `ratio` and `dropout` are wired into kernels. `alternative`
> currently reaches `diagAccuracy` + `test` only; `dropout` reaches
> `cohort` + `test` + `proportion` only. Every other row in the table below
> would be silently ignored, so it is not listed.

## Complete Design Matrix Table

| Design | Task | Outcome | Core Formula | Source | Status | Legacy Keyword Equivalent |
|---|---|---|---|---|---|---|
| `rct` | test | mean | n = 2(Zα/2+Zβ)²σ²/δ² | Machin Ch. 5; Chow 2017 | Active | twoMeans |
| `rct` | test | proportion | Fleiss approximation formula | Machin Ch. 3; Fleiss 1980 | Active | twoProportions |
| `rct` | test | survival | E = (Zα/2+Zβ)²/(pE(1−pE)·ln²HR) | Schoenfeld 1983; Machin Ch. 7 | Active | survival |
| `rct` | noninferiority | mean | n = 2(Zα+Zβ)²σ²/(δ+Δ)² | Machin Ch. 11; Chow 2017 | Active | nonInferiorityMeans |
| `rct` | superiority | mean | n = 2(Zα+Zβ)²σ²/(δ−Δ)² | Machin Ch. 11; Chow 2017 | Active | superiorityMeans |
| `rct` | equivalence | mean | n = 2(Zα+Zβ/2)²σ²/(Δ−\|δ\|)² | Machin Ch. 11; Chow 2017 | Active | equivalenceMeans |
| `rct` | superiority | proportion | Superiority proportions formula | Chow 2017 | Active | superiorityProportions |
| `rct` | equivalence | proportion | Equivalence proportions formula | Chow 2017 | Active | equivalenceProportions |
| `paired` | test | mean | n = ((Zα/2+Zβ)σ_d/δ)² | Rosner 2015 | Active | pairedMeans |
| `paired` | test | proportion | Connor ψ formula (McNemar) | Connor 1987; Akoglu Eq 3b | Active | (New) |
| `rctSingleArm` | test | mean | n = (Zα/2+Zβ)²σ²/δ² | Machin Ch. 5 (one-sample) | Active | (New) |
| `rctSingleArm` | test | proportion | [Z√(P0Q0)+Z√(P1Q1)]²/(P1−P0)² | Hajian Eq 6.8 | Active | (New) |
| `singleArmPhaseII` | — | proportion | Simon two-stage / A'Hern | Simon 1989; Machin Ch. 17 | Active | (New) |
| `crossover` | test/equivalence | mean | Paired difference + σ_w=√(2σw²(1−ρ)) | Senn 2002; Julious | Active | (New; BE variant) |
| `cohort` | test | proportion | 1:m two proportions formula (RR) | Bhardwaj p. 2559; Schlesselman | Active | (New) |
| `cohort` | test | rate | Person-time rate ratio events | Machin Ch. 6; Breslow & Day V2 | Active | (New) |
| `caseControl` | test | proportion | Schlesselman group-matched formula | Schlesselman 1982; Dupont 1988 | Active | caseControl |
| `caseControlMatched` | test | proportion | Matched ψ formula | Dupont 1988 | Active | (New) |
| `crosstab` | test | proportion | Cross-sectional association formula | Machin Ch. 3 | Active | (New) |
| `singleProportion` | estimate | proportion | n = Z²p(1−p)/d² | Bhardwaj p. 2558; Lwanga & Lemeshow | Active | (New) |
| `singleMean` | estimate | mean | n = Z²σ²/d² | Machin Ch. 9 | Active | (New) |
| `singleCorrelation` | estimate | correlation | Fisher z transformation formula | Machin Ch. 19 | Active | (New) |
| `clusterRCT` | (inherits core) | (inherits) | DE = 1+(m−1)ICC, then Machin Eq 12.10 (DE × [per-arm term + z²/2]); optional CV(m) via Eq 12.7 | Machin §12.3 Eq 12.4–12.13, pp. 197–200; Donner & Klar | Active | (New) |
| `steppedWedge` | (inherits core) | (inherits) | DE + time correction | Machin Ch. 13; Hussey & Hughes | Active | (New) |
| `kappa` | test | proportion | Cohen kappa sample size | Machin Ch. 20; Cantor 1996 | Active | (New) |
| `predictive` | — | — | EPV≥10 / Riley 2019/2020 | Peduzzi 1996; Riley 2019/2020 BMJ | Active | (New) |
| `its` | test | rate/proportion | Rule-of-thumb + ρ correction | Bernal 2017 | Experimental | (New) |
| `diagAccuracy` | estimate | proportion | n = Z²Se(1−Se)/d² + prevalence conversion | Zhou §6.1.1 Eq 6.2; Hajian §6.1; Akoglu Eq 1/4 | Active | diagnosticAccuracySingle |
| `diagAccuracy` | test | proportion | [Z√(P0Q0)+Z√(P1Q1)]²/(P1−P0)² | Hajian Eq 6.8; Akoglu Eq 2 | Active | diagnosticSuperioritySingle |
| `diagAccuracyCompare` | test | proportion | Unpaired: two-proportions; Paired: Connor | Hajian §6.3; Akoglu Eq 3a/3b; Zhou §6.2.2 | Active | diagnosticComparisonTwo |
| `diagAUC` | estimate | auc | n = Z²V(A)/d² (3 variance functions) | Zhou §6.1.2 Eq 6.4/6.5/6.6 | Active | auc_single |
| `diagAUC` | test | auc | (Z√V(A0)+Z√V(A))²/(A−A0)² | Zhou §6.1.4; Hajian Table 6 | Active | aucSuperiority |
| `diagAUCCompare` | test | auc | 2(Zα/2+Zβ)²V(1−r)/Δ² | Hajian Eq 7.6/7.8; Zhou §6.2.4 | Active | aucComparison |
| `diagAccuracyCompare` | noninferiority/equivalence | proportion/auc | Zhou §6.3 framework | Zhou §6.3 pp. 214-218 | Active | (New) |
| `diagLR` | estimate | lr | Log(LR) CI simultaneous solve | Hajian §6.4 Eq 6.13/6.14 | Active | likelihoodRatioTest |
| `diagMRMC` | — | — | Obuchowski-Rockette | Zhou §6.5 pp. 219-228 | Active | (New) |

## Generic Parameters (Available Across Study Designs)

| Parameter | Meaning | Default | Source |
|---|---|---|---|
| `alpha` | Type I error rate | 0.05 | — |
| `power` | Statistical power (1 - beta) | 0.8 | — |
| `alternative` | Two-sided (`Z_{α/2}`) or one-sided (`Z_α`) test convention. `NULL` (default) keeps each kernel's documented convention; currently consumed by `diagAccuracy` + `test` only (default `"one.sided"`). | `NULL` (design-dependent) | Akoglu 2022 Table 2 Eq 2 (one-sided, default); Hajian 2014 p. 197 (two-sided) |
| `dropout` | Anticipated dropout rate: n / (1 - d). **Currently implemented for `cohort` + `test` + `proportion` only.** | 0 | Bhardwaj p. 2557 |
| `ratio` / `k` / `m` | Unequal allocation ratio (semantics depends on design) | 1 | Machin chapters |
| `var_method` | exponential / binormal / conservative (AUC variance) | exponential | Zhou §6.1.2 |

## Parameter Roles Quick Reference (`p0` semantics varies by design)

| Design | `p0` Meaning | `p1` Meaning | Effect Metric | Role of `prevalence` |
|---|---|---|---|---|
| `cohort` | Incidence in unexposed group | Incidence in exposed group | RR | Excluded from sample size formula |
| `caseControl` | **Exposure rate in control group** | Exposure rate in case group | OR | Excluded from sample size formula |
| `crosstab` | Prevalence in unexposed group | Prevalence in exposed group | PR / OR | Excluded from sample size formula |
| `rct` (proportion) | Response rate in control group | Response rate in experimental group | RD | Excluded from sample size formula |
| `diagAccuracy` | None (expected Se/Sp) | — | Se / Sp | Determines screening population |
| `diagAccuracy` (test) | Null hypothesis accuracy P0 | Alternative accuracy P1 | Se − P0 | Determines screening population |

## Legacy to New Mapping (17 Keyword Equivalents, Silently Compatible)

| Legacy Keyword | New Invocation | Behavior Contract |
|---|---|---|
| twoMeans | rct + test + mean | Golden master identical |
| twoProportions | rct + test + proportion | Golden master identical |
| pairedMeans | paired + test + mean | Golden master identical |
| survival | rct + test + survival | Golden master identical |
| nonInferiorityMeans | rct + noninferiority + mean | Golden master identical (one-sided alpha) |
| superiorityMeans | rct + superiority + mean | Golden master identical |
| equivalenceMeans | rct + equivalence + mean | Golden master identical |
| superiorityProportions | rct + superiority + proportion | Golden master identical |
| equivalenceProportions | rct + equivalence + proportion | Golden master identical |
| diagnosticAccuracySingle | diagAccuracy + estimate + proportion | Golden master identical |
| diagnosticSuperioritySingle | diagAccuracy + test + proportion | Golden master identical |
| diagnosticComparisonTwo | diagAccuracyCompare + test + proportion | Golden master identical |
| likelihoodRatioTest | diagLR + estimate + lr | Golden master identical |
| auc_single | diagAUC + estimate + auc | Golden master identical |
| aucSuperiority | diagAUC + test + auc | Golden master identical |
| aucComparison | diagAUCCompare + test + auc | Golden master identical |
| caseControl | caseControl + test + proportion | Golden master identical |
