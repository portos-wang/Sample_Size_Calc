# 查看 PowerTOST::power.TOST 源码实现
src <- deparse(PowerTOST::power.TOST)
cat(paste(src[1:80], collapse = "\n"), "\n")
