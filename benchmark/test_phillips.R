# 测试 Phillips 1990 非中心 t 分布在 2x2 crossover 的 power 与样本量
phillips_tost_power <- function(N, cv, theta0 = 1, theta1 = 0.8, theta2 = 1.25, alpha = 0.05) {
  df <- N - 2
  s2w <- log(1 + cv^2)
  sem <- sqrt(s2w * 2 / N)
  diffm <- log(theta0)
  lth1 <- log(theta1)
  lth2 <- log(theta2)
  tval <- qt(1 - alpha, df)
  delta1 <- (diffm - lth1) / sem
  delta2 <- (diffm - lth2) / sem
  pow <- pt(-tval, df, ncp = delta2) - pt(tval, df, ncp = delta1)
  max(0, pow)
}

# 比较 Phillips 1990 vs PowerTOST exact
for (n in c(18, 20, 22, 24, 26, 28)) {
  p_phil <- phillips_tost_power(n, 0.25, 1)
  p_pt   <- PowerTOST::power.TOST(CV=0.25, n=n, theta0=1, method="exact")
  cat(sprintf("N = %2d: Phillips = %.5f, PowerTOST exact = %.5f, diff = %.6f\n",
              n, p_phil, p_pt, abs(p_phil - p_pt)))
}

# 找 80% power 样本量
n_exact <- 4
while(phillips_tost_power(n_exact, 0.25, 1) < 0.8) {
  n_exact <- n_exact + 2
}
cat("Phillips 1990 求得 80% power 样本量 N =", n_exact, "每序列 =", n_exact/2, "\n")
pt_n <- PowerTOST::sampleN.TOST(CV=0.25, theta0=1, targetpower=0.8, print=FALSE)
cat("PowerTOST sampleN.TOST 求得 N =", pt_n[1, "Sample size"], "\n")
