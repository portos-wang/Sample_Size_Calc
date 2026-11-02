library(pdftools)
pdf <- "D:/Coding/R_packages/Sample_Size_Calc/references/Sample Sizes for Clinical, Laboratory and Epidemiology Studies.pdf"
txt <- pdf_text(pdf)
for (pg in c(317, 318, 320, 321)) {
  cat("\n\n################ PDF page", pg, "################\n")
  cat(txt[pg])
}
