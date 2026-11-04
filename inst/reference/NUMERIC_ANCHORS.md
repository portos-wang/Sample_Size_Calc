# Numeric Anchors Reference Manual

> Every implemented formula is bound to at least one published worked example as a benchmark for unit testing.
> Tolerance strategy: literature anchors default to +/-1 subject (due to integer rounding sequence differences); variance/intermediate quantities use 1e-6.
> Each anchor records: primary source citation down to section/page level, tolerance, and resolution decisions when discrepancy arises.

## Verified Anchors (Baseline Phase 0)

| # | Formula / Function | Input Parameters | Expected Output | Source Citation | Tolerance | Status |
|---|---|---|---|---|---|---|
| A0-1 | twoMeans | mean1=10, mean2=12, sd=3, alpha=0.05, 1-beta=0.80 | n=37/group, total 74 | Existing tests (power.t.test exact solution) | 0 | Verified |
| K-1 | z_alpha(0.05, two.sided) | — | 1.959964 | Standard normal quantile | 1e-6 | Verified |
| K-2 | z_power(0.8) | — | 0.8416212 | Standard normal quantile | 1e-6 | Verified |
| K-3 | inflate_n(322.69) | — | 323 | Bhardwaj 2024 p. 2558 (n=322.69 -> 323) | 0 | Verified |
| K-4 | design_effect(20, 0.05) | — | 1.95 | DE = 1 + (m - 1) * ICC; Machin 2018 Ch. 12 | 1e-12 | Verified |

## Implementation Anchors by Phase

### Phase 2 (Estimation Designs)

| # | Formula | Input Parameters | Expected Output | Source Citation | Tolerance |
|---|---|---|---|---|---|
| A1-1 | singleProportion estimate | p=0.30, d=0.05, 95% CI | n=323 | Bhardwaj 2024 p. 2558 | +/-1 |
| A1-2 | dropout=0.10 variant | 323 inflated | 355 (paper addition) or 359 (paper formula) | Bhardwaj 2024 p. 2558 | See "Literature Inconsistencies" below |
| A2-1 | singleMean estimate | sigma=3, d=0.5, 95% CI | 141 (t-iterated) | Machin 2018 Eq 9.18, p. 152 (iterated Student t); z-only would give 139, Bhardwaj prints 138.29 -> 138 | +/-1 |
| A2-2 | singleMean estimate (large N) | sigma=100, d=2 | 9607 (t) vs 9604 (z) | Machin 2018 Eq 9.18 | 0 | Verified |
| A3-1 | diagAccuracy (Zhou 6.2) | Se=0.80, d=0.05, 95% CI | n=246 | Zhou 2011 p. 195 SPECT example | +/-1 |
| A3-2 | diagAccuracy (Zhou 6.1 with power) | Above + 80% power | n=502 | Zhou 2011 p. 195 | +/-1 |
| A4-1 | diagAUC (binormal variance, default) | A=0.80, d=0.10, R=1, 95% CI | n=46 | Zhou 2011 Eq 6.5, p. 198 | +/-1 |
| A4-2 | diagAUC (conservative variance) | Above | n=62 | Zhou 2011 Eq 6.6, p. 198 | +/-1 |
| A4-5 | diagAUC (exponential variance, explicit) | Above | n=38 | Zhou 2011 Eq 6.4, p. 197 | +/-1 |
| A4-6 | diagAUC superiority (CTC anchor) | A0=0.50, A1=0.80, R=1, 95%/80% two-sided | n=13 | Zhou 2011 Eq 6.8, p. 200 (book reports 13) | +/-1 |
| A4-7 | diagAUCCompare independent | A1=0.80, A2=0.70, r=0, binormal | n=212 | Hajian 2014 Eq 7.8, p. 199 (book reports 211) | +/-1 |
| A5-1 | diagLR (log-LR method) | LR-=0.4, Se=0.90, Sp=0.50, 95% CI | 80 per group | Hajian-Tilaki 2014 §6.4 Eq 6.14 | +/-1 |
| A4-3 | diagAUC legacy path (prevalence = 1) | A=0.80, d=0.10, prevalence omitted | 38 cases (R falls back to 1) | Zhou 2011 Eq 6.4; fallback documented | 0 | Verified |
| A4-4 | diagAUC legacy path (prevalence = 0.2) | A=0.80, d=0.05, prevalence=0.2 (R=4) | 120 cases (V=0.07778) | Zhou 2011 Eq 6.4 | 0 | Verified |
| A6-1 | singleCorrelation | r=0.5, eps=0.1 (d=0.05, 95% CI) -> n=867; r=0.5, precision=0.10 (w=0.20) -> n=219 | Machin 2018 Ch. 19 Eqs 19.5-19.8; exact match to presize::prec_cor | 0 | Verified |

### Phase 3 (Two-Sample / Paired / Observational) — Implemented

| # | Formula | Input Parameters | Expected Output | Source Citation | Tolerance | Status |
|---|---|---|---|---|---|---|
| B3-1 | cohort 1:1 (two proportions) | p1=0.30, p0=0.20, 95%/80% | 293 (rounded z) / **294 (exact z, implemented)** | Bhardwaj 2024 p. 2559 | +/-1 | Verified |
| B3-2 | cohort +10% non-response | 294 inflated | Paper addition 322; formula ceil(294/0.9)=327 | Bhardwaj 2024 p. 2559 (total 644) | See literature notes | Verified |
| B4-1 | rctSingleArm proportion vs P0 | P0=0.70, P1=0.80, 95%/80% (two-sided) | n=153 | Hajian-Tilaki 2014 Eq 6.8 example | +/-1 | Verified |
| B6-1 | cohortRate person-time | lambda0=0.10, lambda1=0.20, r=1 | T=(1.96+0.8416)^2 * 0.3 / 0.01 = 235.5 -> 236/group | Machin Ch. 6 formula derivation | 0 | Verified |
| B8-1 | pairedProportions (Connor/psi) | psi=0.05 (= delta min), delta=0.05, 80% | 154.5 -> 155 (Akoglu Table 6A with Yates is 159) | Akoglu 2022 Table 6A; Connor 1987 | +/-1 | Verified |
| B8-2 | caseControlMatched | p0=0.3, OR=2 -> p1=0.4615, psi=0.4846, delta=0.1615 | 143.2 -> 144 pairs | Dupont 1988 framework | 0 | Verified |

### Phase 3 Anchor Audit Notes

1. **cohort 293 -> 294**: The paper used rounded normal quantiles (1.96 / 0.84) yielding 292.82 -> 293; exact quantiles yield 293.16 -> 294. Our implementation uses exact quantiles and asserts 294, with +/-1 documented.
2. **Hajian-Tilaki LR example (80 per group)**: The negative-LR variance coefficient is Se/(1-Se) + (1-Sp)/Sp = 10 at Se=0.90 and Sp=0.50. With expected LR-=0.20 and upper limit 0.40, the log-CI calculation gives 80 cases and 80 controls. The previous 9-per-group result used the wrong sensitivity probability term and has been corrected.
3. **diagAUC 46 example attribution**: 46 originates from Eq 6.5 binormal variance (V=0.11946), not Eq 6.4 exponential variance (V=0.0978 -> 38). Both are implemented and asserted separately (46=binormal, 38=exponential). **Binormal is the default** for both the legacy path and `var_method`, matching Zhou's own worked examples and Hajian's tables.
4. **screen_required 451 vs 452**: Zhou's normal approximation gives 452; exact binomial search gives 451 (P(X>=350) at N=451 achieves >=0.9). Implemented with exact binomial guarantee.

### Phase 4 (Margins / Diagnostic Comparisons / Bioequivalence)

| # | Formula | Input Parameters | Expected Output | Source Citation | Tolerance |
|---|---|---|---|---|---|
| C5-1 | Bioequivalence 2x2 | CV=25%, 80-125%, alpha=5%, 80% power, theta0=1.0: n=12/seq (N=24); theta0=0.95: n=14/seq (N=28) | Phillips 1990; Julious 2004 §6.3 Eq 6.8; exact match to PowerTOST::sampleN.TOST | 0 | Verified |
| C5-2 | 2x2 crossover, continuous | delta=2, sigma_w=3, 95%/80% | 18 per sequence, 36 total (Julious Eq 6.6 gives n_total=35.3) | Julious 2004 §6.3 Eq 6.6 (n is the TOTAL sample size) | 0 | Verified |
| C6-1 | Diagnostic equivalence | Zhou §6.3 example table | pp. 214-218 | Zhou 2011 §6.3 | Pending |
| D5-1 | Two AUC comparison (independent) | A1=0.80, A2=0.70, r=0, 95%/80% | V_H0=0.13480 (intermediate) | Hajian-Tilaki 2014 §7.6 | 1e-5 |
| D3-1 | diagAccuracyCompare paired | Connor psi formula, Akoglu Table 6B combination | Cross-table check | Akoglu 2022 | +/-1 |

### Advanced Designs & v3.1 Updates

| # | Method | Anchor Benchmark | Status |
|---|---|---|---|
| E9-MRMC | mrmc_power(): Obuchowski-Rockette mixed model, Eq 6.32 + Table 6.4 parameterization, non-central F | Zhou p. 221-225 mammography example: n=50, J=8, delta=0.10, sigma_c2=0.00196, rho1=0.5, rho2=0.3, rho3=0.25, rho_b=0.75 -> power = 0.893 (book reports 89%) | Implemented |
| E8-kappa | Cantor 1996 / Fleiss-Cohen-Everitt formulation | Cantor 1996 exact worked example | Implemented |
| E2-steppedWedge | Hussey & Hughes 2007 Eq 8 | H&H EPT example: I=24, T=5, m=100, p=0.05, CV=0.3 -> power = 0.774 at RR=0.64 (paper: ~80% at a 36% reduction) | Implemented |
| Prediction Models | Riley 2019/2020 (BMJ 364:l951, BMJ 2020;368:m441) | Box 1 criteria B1-B3 & T1 examples | Implemented |

#### Riley 2020 (Prediction Models) — Implemented (BMJ 2020;368:m441)

1. **Primary Source**: BMJ 2020;368:m441, Box 1 four criteria + Figures 1-5 formulas extracted and validated.
2. **Implemented Criteria** (binary outcome):
   - **B1** (Outcome proportion precision): `n = (z / delta)^2 * phi * (1 - phi)`; anchors phi=0.5, delta=0.05 -> 385; phi=0.2 -> 246; phi=0.1 -> 139 (all exact).
   - **B3** (Shrinkage target S): `n = P / ((S - 1) * ln(1 - R2cs / S))`; anchors:
     **P=30, R2cs=0.05, S=0.9 -> 5249 (exact agreement with pmsampsize package example, 263 events, EPP=8.75)**; Figure 3 example P=20, R2cs=0.1 -> 1698.04 (book rounds to 1698, +/-1 documented).
     The paper's Example 1 (preeclampsia, prev=0.05, P=30, R2cs=0.05) reports 5249 women / 263 events; the package reproduces both, and with P=20 the paper's 3500 women / 175 events are reproduced exactly.
   - **B2** (MAPE, van Smeden formula, P <= 30):
     `n = exp((-0.508 + 0.259*ln(phi) + 0.504*ln(P) - ln(MAPE)) / 0.544)`; anchor MAPE=0.05, phi=0.3, P=10 -> **460.9 -> 461** (exact match to Figure 2); at prev=0.05, P=30 -> 543.4 -> 544, matching the paper's own Example 1 value.
     **Scope note (verified)**: Box 1 states "The software calculates the sample size needed to meet all the criteria listed in box 1 (except B2, which is available at https://mvansmeden.shinyapps.io/BeyondEPV/)". B2 is therefore reported as informational only and the returned n is `max(B1, B3)`, exactly as pmsampsize behaves.
   - Max(R2cs) entropy helper: `1 - exp(-2 * H(phi))`; anchor phi=0.05 -> 0.3277 ~ 0.33.
3. **T1** (Time-to-event): Exponential model F(t) = 1 - exp(-lambda * t), exact search for bilateral margin <= delta; anchor lambda=0.1/year, t=10 years, delta=0.05 -> **2366 person-years** (exact match to Figure 1).
4. **Scope boundary**: B4 (Nagelkerke R2 optimism <= 0.05) independent formula relies on Riley Part II (Stat Med 2019;38:1276-96) supplementary material; B3 shrinkage target conceptually covers overfitting control (matching pmsampsize output structure).
5. **API Invocation**: `calculate("predictiveModel", "plan", "binary" | "rate", ...)`, coexisting with legacy EPV mode (`outcome="events"`).

#### steppedWedge: Implemented (Hussey & Hughes 2007)

1. **Source**: Contemporary Clinical Trials 28(2):182-191.
2. **Eq 8 Formulation (p. 187, verbatim)**: `Var(theta_hat) = I * sigma^2 * (sigma^2 + T * tau^2) / [(I * U - W) * sigma^2 + (U^2 + I * T * U - T * W - I * V) * tau^2]`, where U/W/V are quadratic forms of design matrix X; `power = Phi(|theta| / SE - z_{1-alpha/2})` (Eq 7). `sigma^2` is the cluster-mean variance (`= sigma^2_ind / m`); `tau^2` is the between-cluster variance.
3. **EPT Example Validation** (I=24, T=5, 6 clusters per step, m=100, p=0.05, CV=0.3):
   U=60, W=1080, V=180 -> Var=4.405e-5, SE=0.006637;
   - RR=0.60 -> power = **0.854**
   - RR=0.64 -> power = **0.774**
   - RR=0.70 -> power = **0.618**
   - RR=0.75 -> power = **0.469**
   The paper states "about 80% power to detect a decrease in prevalence of roughly 36% (from 0.05 to 0.032)", i.e. RR ~ 0.64 at ~80%; Eq 8 gives 0.774 there, which is consistent.
4. **Correction record**: an earlier implementation swapped `sigma^2` and `tau^2` in Eq 8, returning Var=2.36e-5 / SE=0.00486 and power=0.959 at RR=0.64. That inflated power by ~0.19 and produced a spurious "80% crossing at RR=0.73" claim. The current code is a verbatim transcription of the printed equation and matches an independent hand evaluation across the whole RR range.
5. **API Invocation**: `calculate("steppedWedge", "test", "mean" | "proportion", theta=, tau2=, sigma2_ind=, m=, n_clusters=, clusters_per_step=)`.

#### kappa: Cantor 1996 Formulation

1. Cantor's Q is the **Eq 3** expression (p. 151), not the simpler Fleiss-Cohen-Everitt ratio:
   `Q = (1-pi_e)^(-4) * { sum_i pi_ii[(1-pi_e) - (pi_i. + pi_.i)(1-pi_o)]^2 + (1-pi_o)^2 * sum_{i!=j} pi_ij(pi_.i + pi_j.)^2 - (pi_o pi_e - 2pi_e + pi_o)^2 }`
   with the Eq 4 identities `pi_2. = 1 - pi_1.`, `pi_.2 = 1 - pi_.1`, `pi_e = pi_1. pi_.1 + pi_2. pi_.2`, `pi_o = kappa(1-pi_e) + pi_e`, `pi_22 = (pi_o - pi_1. + pi_.2)/2`, `pi_11 = pi_o - pi_22`, `pi_12 = pi_1. - pi_11`, `pi_21 = pi_.1 - pi_11`.
   It reduces to `pi_o(1-pi_o)/(1-pi_e)^2` only when `pi_1. = pi_.1 = 0.5`.
2. **Exact Benchmark Matches**:
   - Cantor **Table 1** (p. 152) reproduced at all 18 spot-checked cells (e.g. `Q(0.3,0.3,0.5) = 0.893`, `Q(0.5,0.5,0.7) = 0.510`, `Q(0.9,0.5,0) = 0.360`).
   - Cantor **Table 2** (p. 153) maxima reproduced exactly: `(0.3,0.3) 1.07003 at kappa=0.187`, `(0.4,0.4) 1.00558 at 0.067`, `(0.5,0.5) 1.00000 at 0.000`, `(0.7,0.3) 0.52438 at 0.000`, `(0.9,0.1) 0.04819 at 0.000`.
   - Precision example (p. 151): `Q=1.0, d=0.1, 80% CI -> n = 165` (exact).
   - Two-questionnaire test (p. 153): `Q01 = Q02 = 0.510`, `QA1 = 0.510`, `QA2 = 0.750`, 95%/80% -> `N = 214` (exact).
3. **Correction record**: an earlier implementation used `Q = p_o(1-p_o)/(1-p_e)^2` labelled "Fleiss-Cohen-Everitt", which coincides with Cantor's Q only at equal marginals of 0.5. At `pi = 0.3` it returned Q = 0.724 whereas Cantor's Table 2 maximum is 1.07003, and the "Q = 1.0 at pi = 0.3" anchor was arithmetically impossible.
4. **API Invocation**: `calculate("kappa", "estimate" | "test", "proportion", pi1=, pi2=, ...)`.

#### MRMC Implementation Notes

- **Scope**: Implements statistical power computation for paired-patient, paired-reader designs under the Obuchowski-Rockette mixed model (Eq 6.32 + Table 6.4 non-central F distribution), given n, J, and 6 variance/covariance components. Sample size inverse-solving is left to wrapper iteration.
- **Formula**: `lambda = J*delta^2 / (2*[sigma_b2*(1-rho_b) + sigma_w2/Q + sigma_c2*((1-rho1) + (J-1)*(rho2-rho3))])` — verbatim Eq 6.32 (Zhou p. 221). Two features matter: the between-reader term is weighted by `rho_b` (Table 6.3 `p_b`, the same-reader/different-test correlation), and `sigma_c2` is **not** divided by n (it is already `V(A)/n`; see Zhou p. 221).
- **Benchmark**: Zhou mammography example (n=50, J=8, delta=0.10, sigma_b2=0.00123, sigma_w2=0.00087, sigma_c2=0.00196, rho1=0.5, rho2=0.3, rho3=0.25, rho_b=0.75) -> lambda=14.0672, power=**0.893**, reproducing the book's "89% power".
- **Correction record**: an earlier implementation used `(1-rho1)` instead of `(1-rho_b)`, divided `sigma_c2` by `n`, and added a spurious `rho2*sigma_b2*(...)` term. It reported 0.979 for the book's own parameters; the old 0.888 anchor came from a different parameter set (sigma_c2=0.05, rho1=0.25) and did not reproduce the book.
- **Parameter Check**: rho1 > rho2 > rho3 is checked and warns if violated; `rho_b` is validated in [0, 1) and defaults to `rho1` when omitted (backward-compatible path).

### Phase 5 (Complex Designs) — Implemented

| # | Formula | Input Parameters | Expected Output | Source Citation | Tolerance | Status |
|---|---|---|---|---|---|---|
| E1-1 | clusterRCT wrapping twoMeans | Machin Ex 12.1: delta=3.5, sigma=6.94, m=2, ICC=0.025, 2-sided a=0.05, power=0.90 | **N=172, K=86, 43 per arm** (Eq 12.10 raw N=171.35) | **Machin 2018 Eq 12.10, p. 199; Example 12.1, p. 206** | 0 | Verified |
| E1-1b | clusterRCT ICC sensitivity | same, ICC=0.1 / 0.2 | **184 / 204** | Machin 2018 p. 206 ("would increase N to 184 and 204") | 0 | Verified |
| E1-2 | clusterRCT wrapping twoMeans (small) | m=20, ICC=0.05, 10 vs 12, sd=3 | DE=1.95; K=4 per arm; 80/arm, 160 total | Algebraic derivation; Machin Eq 12.5 + 12.10 | 0 | Verified |
| E1-3 | clusterRCT wrapping twoProportions | m=10, ICC=0.01, 0.3 vs 0.5 | DE=1.09; K=11 per arm; 110/arm, 220 total | Machin Eq 12.5/12.10/12.12 | 0 | Verified |
| E1-4 | cluster_size_inflation (Eq 12.7) | m=20, ICC=0.05, CV(m)=0.35 | DE=2.0725 (vs 1.95 constant) | Machin 2018 Eq 12.7, p. 197 | 0 | Verified |
| E5-1 | Simon two-stage (optimal) | p0=0.1, p1=0.3, alpha=0.05, power=0.80 | (r1/n1, r/n) = (1/10, 5/29); EN(p0)=15.0 | **Machin 2018 Example 17.2 exact match**; clinfun::ph2simon exact match; Simon 1989 | 0 | Verified |
| E5-1b | Simon two-stage (minimax) | p0=0.1, p1=0.3, alpha=0.05, power=0.80 | (r1/n1, r/n) = (1/15, 5/25) | **Machin 2018 Example 17.2 exact match**; clinfun::ph2simon exact match (minimise N, tie-break by EN(p0)) | 0 | Verified |
| E5-2 | A'Hern single-stage | p0=0.1, p1=0.3, alpha=0.05, power=0.80 | C/N = 6/25 (r=5, n=25) | **Machin Table 17.1 exact match**; A'Hern 2001 | 0 | Verified |
| E5-3 | A'Hern single-stage | p0=0.2, p1=0.4, alpha=0.05, power=0.80 | C/N = 12/35 (r=11, n=35) | Machin Table 17.1 | 0 | Verified |
| E5-4 | Simon optimal | p0=0.2, p1=0.4, alpha=0.05, power=0.90 | (4/19, 15/54), EN(p0)=23.8 | Exact search & constraint verification | 0 | Verified |
| E9-1 | predictive EPV | k=10, EPV=10, prev=0.2 | events=100, subjects=500 | Peduzzi 1996 | 0 | Verified |
| E10-1 | ITS (experimental) | effect=1, n=12/12, rho=0.3 | power = Phi(1/SE - 1.96), SE=sqrt(2 / 6.4615) | Bernal 2017 approximation | 0 | Verified |

## Literature Inconsistencies & Resolution Records

### 1. Bhardwaj 2024 Dropout Rate Formula vs Arithmetic
- **Stated Formula** (p. 2557): `n* = n / (1 - d)`
- **Worked Example** (p. 2558): `323 + 32 = 355` (additive addition, i.e., `n * (1 + d)`)
- Both examples in the paper (355 and 644 = 322 * 2) used the additive rule, contradicting the stated mathematical definition.
- **Resolution**: Implementation strictly adheres to the canonical definition `ceil(n / (1 - d))`, with the test asserting 359; the paper's additive value (355) is recorded for reference.

### 2. Hajian-Tilaki 2014 Eq 6.8 One-sided vs Two-sided Convention
- The paper explicitly notes two-sided tests (Z_alpha/2 = 1.96). Historical legacy implementations used one-sided Z_alpha.
- **Resolution**: New three-axis API exposes `alternative` (defaulting to `"two.sided"`), while legacy keyword functions maintain one-sided behavior for backward compatibility.

## Anchor Verification Workflow

When adding a new numeric anchor:
1. Locate the worked example in the primary literature under `references/` (page number, parameters, and results).
2. Manually compute the algebraic derivation on paper to verify steps.
3. Construct the unit test adhering to documented tolerances.
4. If an implementation discrepancy arises, investigate the underlying cause (rounding sequence, formula variants, or typographical errata) and record the resolution in this document.
