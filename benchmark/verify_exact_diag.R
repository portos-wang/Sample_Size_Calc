# 验证精确二项诊断检验样本量
calc_exact_diag <- function(p0, p1, alpha = 0.05, power = 0.8) {
  for (n in 1:2000) {
    # 找到临界值 r: 使得 P(X >= r | p0) <= alpha
    # 等价于: 使得 P(X <= r-1 | p0) >= 1 - alpha
    # qbinom(1 - alpha, n, p0) 给出的就是满足 P(X <= q) >= 1 - alpha 的最小分位数
    # 所以 r = qbinom(1 - alpha, n, p0) + 1
    # 检查 P(X >= r | p0)
    r_cand <- 0:n
    p_alpha <- pbinom(r_cand - 1, n, p0, lower.tail = FALSE)
    # 取满足 p_alpha <= alpha 的最小 r
    valid_r <- r_cand[p_alpha <= alpha]
    if (length(valid_r) == 0) next
    r <- valid_r[1]
    
    # 在备择假设下的 power
    pwr <- pbinom(r - 1, n, p1, lower.tail = FALSE)
    if (pwr >= power) {
      return(list(n = n, r = r, actual_alpha = p_alpha[r + 1], actual_power = pwr))
    }
  }
}

res <- calc_exact_diag(0.70, 0.85, 0.05, 0.8)
cat("自定义精确二项搜索: n =", res$n, "r =", res$r, "power =", res$actual_power, "\n")
mkmisc_r <- MKmisc::power.diagnostic.test(sens = 0.85, delta = 0.15, sig.level = 0.05, power = 0.8, method = "exact")
cat("MKmisc exact: n =", mkmisc_r$n, "\n")
