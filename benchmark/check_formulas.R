cat("=== TrialSize::TwoSampleMean.Equality 源码 ===\n")
print(TrialSize::TwoSampleMean.Equality)

cat("\n=== MKmisc::power.diagnostic.test 源码(asymptotic 分支) ===\n")
src <- deparse(MKmisc::power.diagnostic.test)
cat(paste(src[1:60], collapse = "\n"), "\n")

cat("\n=== 本包 diagAccuracy/test 复算核验 ===\n")
# prob=0.85, p0=0.70, 单侧 alpha=0.05, power=0.8
za <- qnorm(0.95); zb <- qnorm(0.8)
n <- ((za * sqrt(0.7 * 0.3) + zb * sqrt(0.85 * 0.15)) / 0.15)^2
cat("手工 =", n, "-> ceiling =", ceiling(n), "\n")
