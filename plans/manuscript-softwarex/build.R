# Rebuild the numerical evidence and the Markdown, Word, and PDF drafts.
# Run from this directory: Rscript --vanilla build.R

needed <- c("rmarkdown", "knitr")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Install these packages first: ", paste(missing, collapse = ", "))
}
if (.Platform$OS.type == "windows") {
  latex_dir <- file.path(
    Sys.getenv("LOCALAPPDATA"),
    "TinyTeX",
    "bin",
    "windows"
  )
  if (dir.exists(latex_dir)) {
    Sys.setenv(
      PATH = paste(latex_dir, Sys.getenv("PATH"), sep = .Platform$path.sep)
    )
  }
}
if (!file.exists("reference.docx")) {
  stop("Run python prepare_word_template.py first to create reference.docx.")
}
source("replicate.R", local = TRUE)
render_environment <- new.env(parent = globalenv())
render_environment$paper_data <- paper_data
knitr::knit(
  "paper.Rmd",
  output = "SampleSizeCalc_SoftwareX_draft.md",
  envir = render_environment,
  quiet = TRUE
)
rmarkdown::render(
  "paper.Rmd",
  output_format = "word_document",
  output_file = "SampleSizeCalc_SoftwareX_draft.docx",
  output_options = list(reference_docx = "reference.docx"),
  envir = render_environment,
  quiet = TRUE
)
rmarkdown::render(
  "paper.Rmd",
  output_format = "pdf_document",
  output_file = "SampleSizeCalc_SoftwareX_draft.pdf",
  envir = render_environment,
  quiet = TRUE
)
cat("Built Markdown, Word, and PDF working drafts.\n")
