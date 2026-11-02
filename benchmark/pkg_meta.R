pkgs <- c("pwr", "presize", "samplesize", "TrialSize", "PASSED", "powerSurvEpi",
          "epiR", "clinfun", "PowerTOST", "pROC", "kappaSize", "CRTSize",
          "pmsampsize", "swCRTdesign", "MKmisc", "gsDesign")
for (p in pkgs) {
  d <- packageDescription(p)
  pub <- if (is.null(d$`Date/Publication`)) "-" else substr(d$`Date/Publication`, 1, 10)
  mnt <- if (is.null(d$Maintainer)) "-" else strsplit(d$Maintainer, "<")[[1]][1]
  cat(sprintf("%-14s | v%-8s | %s | %s\n", p, d$Version, pub, trimws(mnt)))
}
