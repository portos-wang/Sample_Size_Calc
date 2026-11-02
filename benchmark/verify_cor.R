# 核实 Pearson correlation 精度样本量公式
# 来源 1: Machin 2018 第 19 章式 19.5
# CI 半宽 d = w / 2 (absolute precision)
# N = z_{1-a/2}^2 * (1 - r^2)^2 / d^2 + 3
# 若用相对精度 epsilon: d = epsilon * r
# N = z_{1-a/2}^2 * ((1 - r^2) / (r * epsilon))^2 + 3

r <- 0.5; d <- 0.1; alpha <- 0.05
z <- qnorm(1 - alpha/2)
w <- 2 * d

# Machin 19.5 (初值 N_P0)
n_machin_195 <- 4 * z^2 * (1 - r^2)^2 / w^2 + 3
cat("Machin 19.5 (r=0.5, d=0.1, a=0.05):", n_machin_195, "->", ceiling(n_machin_195), "\n")

# Machin 19.6-19.8 (修正版)
N_P0 <- n_machin_195
U <- 0.5 * log((1 + r)/(1 - r)) + z / sqrt(N_P0 - 3)
L <- 0.5 * log((1 + r)/(1 - r)) - z / sqrt(N_P0 - 3)
w0 <- (exp(2*U) - 1)/(exp(2*U) + 1) - (exp(2*L) - 1)/(exp(2*L) + 1)
N_Pfinal <- (N_P0 - 3) * (w0 / w)^2 + 3
cat("Machin 19.6-19.8 修正版:", N_Pfinal, "->", ceiling(N_Pfinal), "\n")

# presize::prec_cor(r=0.5, conf.width=0.2)
p_cor <- presize::prec_cor(r = 0.5, conf.width = 0.2)
cat("presize::prec_cor (CI宽0.2):", p_cor$n, "\n")
