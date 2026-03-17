pkgname <- "sampleSizeCalc"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
library('sampleSizeCalc')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("sample_size_calculator")
### * sample_size_calculator

flush(stderr()); flush(stdout())

### Name: sample_size_calculator
### Title: Sample size calculator for clinical study designs
### Aliases: sample_size_calculator sampleSizeCalculator

### ** Examples

sample_size_calculator("twoMeans", mean1 = 10, mean2 = 12, sd = 3)
sample_size_calculator("survival", hr = 0.7, alpha = 0.05, power = 0.8)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
