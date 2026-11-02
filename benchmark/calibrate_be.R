# 校准1: 精确 TOST power 的一维积分形式 vs PowerTOST::power.TOST
# Power = E_u[ Phi((thetaU - delta)/sd_delta - t1*sqrt(u)) - Phi((thetaL - delta)/sd_delta + t1*sqrt(u)) ]
# 其中 u ~ chi2_nu/nu, sd_delta = sqrt(k * sigma2_w), k 待校准 (2/N 或 4/N 等)

power_tost_int <- function(N, cv, theta0 = 1, alpha = 0.05,
                           mlo = 0.8, mhi = 1.25, k) {
  s2w <- log(1 + cv^2)
  nu  <- N - 2
  sd_d <- sqrt(k * s2w)
  d  <- log(theta0)
  thL <- log(mlo); thU <- log(mhi)
  t1 <- qt(1 - alpha, nu)
  f <- function(u) {
    s <- sqrt(u) # u ~ chi2_nu/nu, s = sd(se)/sd_delta
    pnorm((thU - d)/sd_d - t1 * s) - pnorm((thL - d)/sd_d + t1 * s)
  }
  integrate(f, 0, Inf)$value
}

cat("=== 校准 se 定义: 对照 power.TOST(CV=0.25, n=24, theta0=1) ===\n")
ref <- PowerTOST::power.TOST(CV = 0.25, n = 24, theta0 = 1, alpha = 0.05)
cat("PowerTOST exact =", ref, "\n")
for (k in c(2/24, 4/24, 1/12, 2/12)) {
  cat(sprintf("k = 1/%.0f (se^2=k*s2w): power_int = %.6f\n", 1/k,
              power_tost_int(24, 0.25, 1, 0.05, 0.8, 1.25, k)))
}
