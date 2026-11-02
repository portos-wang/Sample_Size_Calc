# 仲裁: H&H Eq8 (无时间效应) vs 含时间固定效应的 GLS 方差
I <- 24; T <- 5; m <- 100
tau2 <- 2.25e-4; sigma2_ind <- 0.0475
theta <- 0.015

# cluster-period 层面数据
rows <- list(); k <- 1
Xi <- matrix(0, I, T)
idx <- 1
for (t in 2:T) { Xi[idx:(idx+5), t:T] <- 1; idx <- idx + 6 }

# V: 组内复合对称 (对角 tau2+sigma2/m, 组间 tau2)
n_cp <- I * T
V <- matrix(0, n_cp, n_cp)
for (i in 1:I) {
  for (t in 1:T) {
    for (t2 in 1:T) {
      r1 <- (i-1)*T + t; r2 <- (i-1)*T + t2
      V[r1, r2] <- if (t == t2) tau2 + sigma2_ind/m else tau2
    }
  }
}
Vi <- solve(V)

# 模型1: 仅截距+处理 (H&H Eq8 结构)
M1 <- cbind(1, as.vector(t(Xi)))
# 模型2: 加时间固定效应
TD <- matrix(0, n_cp, T-1)
for (i in 1:I) for (t in 2:T) TD[(i-1)*T + t, t-1] <- 1
M2 <- cbind(1, as.vector(t(Xi)), TD)

var1 <- solve(t(M1) %*% Vi %*% M1)[2, 2]
var2 <- solve(t(M2) %*% Vi %*% M2)[2, 2]

se1 <- sqrt(var1); se2 <- sqrt(var2)
pow1 <- pnorm(theta/se1 - qnorm(0.975))
pow2 <- pnorm(theta/se2 - qnorm(0.975))
cat(sprintf("GLS 无时间效应: SE=%.5f power=%.3f (对照 H&H Eq8 闭式 0.870)\n", se1, pow1))
cat(sprintf("GLS 含时间固定效应: SE=%.5f power=%.3f (对照 swPwr 0.618)\n", se2, pow2))
