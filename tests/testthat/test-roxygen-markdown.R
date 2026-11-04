# Guard against a markdown-link bug in the roxygen documentation.
#
# DESCRIPTION sets `Roxygen: list(markdown = TRUE)`, so an unescaped `[` in a
# `#'` line starts a link and the parser scans forward for a closing `]`. When
# the interval `[0, 1)` is written literally, the nearest `]` can be dozens of
# lines away, and everything in between is swallowed into a reference-style
# link. R CMD check does not flag this (the Rd file stays syntactically valid),
# but the rendered help page loses whole parameter blocks.
#
# Two things are checked here:
#   1. no roxygen line may open a bracket that is not closed on the same line
#      (unless it is inside a `code span`, an already-escaped &lbrack;, or a
#      genuine link like [calculate()]);
#   2. every &lbrack; escape must sit in a `#'` doc line, never in a runtime
#      cli message, otherwise users would see the entity literally.

# Strip the parts of a roxygen line where a bare `[` is legitimate:
#   - backtick code spans  `...`
#   - already-escaped entities &lbrack; / &rbrack;
#   - complete markdown links [text] or [text](target)
strip_legal_brackets <- function(line) {
  # remove backtick spans
  line <- gsub("`[^`]*`", "", line)
  # remove escaped entities
  line <- gsub("&lbrack;", "", line, fixed = TRUE)
  line <- gsub("&rbrack;", "", line, fixed = TRUE)
  # remove complete links: [text](target) first, then bare [text]
  line <- gsub("\\[[^][]*\\]\\([^()]*\\)", "", line)
  line <- gsub("\\[[^][]*\\]", "", line)
  line
}

# Collect the roxygen documentation lines of every R source file.
#
# Returns NULL when the R sources are not available, which is the case once
# the package is installed: R CMD check runs the tests against the built and
# installed tree, where only the compiled namespace exists. The guards below
# are therefore development-time checks and skip in that situation.
roxygen_lines <- function() {
  src <- file.path(testthat::test_path("..", ".."), "R")
  if (!dir.exists(src)) {
    return(NULL)
  }
  files <- list.files(src, pattern = "[.]R$", full.names = TRUE)
  out <- list()
  for (f in files) {
    lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
    idx <- which(grepl("^\\s*#'", lines))
    if (length(idx) == 0) next
    out[[basename(f)]] <- data.frame(
      file = basename(f),
      line = idx,
      text = lines[idx],
      stringsAsFactors = FALSE
    )
  }
  if (length(out) == 0) NULL else out
}

test_that("no roxygen line leaves a bracket unclosed (markdown link hazard)", {
  docs <- roxygen_lines()
  skip_if(is.null(docs), "R sources not available (installed package)")

  offenders <- character()
  for (df in docs) {
    for (i in seq_len(nrow(df))) {
      stripped <- strip_legal_brackets(df$text[i])
      opens <- lengths(regmatches(stripped, gregexpr("[[]", stripped)))
      closes <- lengths(regmatches(stripped, gregexpr("[]]", stripped)))
      if (opens != closes) {
        offenders <- c(
          offenders,
          sprintf(
            "%s:%d  [ = %d, ] = %d  %s",
            df$file[i], df$line[i], opens, closes,
            trimws(sub("^\\s*#'", "", df$text[i]))
          )
        )
      }
    }
  }

  expect_equal(
    offenders, character(0),
    info = paste(
      "Unbalanced brackets in roxygen docs. Write intervals as",
      "&lbrack;0, 1) instead of [0, 1), or Roxygen's markdown parser will",
      "treat the text up to the next ']' as a link target and the help page",
      "will render a percent-encoded fragment.\n",
      paste(offenders, collapse = "\n")
    )
  )
})

test_that("&lbrack; is used only in roxygen docs, never in runtime strings", {
  src <- file.path(testthat::test_path("..", ".."), "R")
  skip_if_not(dir.exists(src), "R sources not available (installed package)")
  files <- list.files(src, pattern = "[.]R$", full.names = TRUE)
  offenders <- character()
  for (f in files) {
    lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
    hit <- which(grepl("&lbrack;", lines, fixed = TRUE))
    for (i in hit) {
      if (!grepl("^\\s*#'", lines[i])) {
        offenders <- c(
          offenders,
          sprintf("%s:%d  %s", basename(f), i, trimws(lines[i]))
        )
      }
    }
  }
  expect_equal(
    offenders, character(0),
    info = paste(
      "&lbrack; is a markdown escape and must appear only in '#' doc lines.",
      "In a cli::cli_abort() message it reaches the user verbatim, so write a",
      "plain '[' there instead.\n",
      paste(offenders, collapse = "\n")
    )
  )
})

test_that("the bracket scanner detects the bug it is meant to catch", {
  # Self-test: a deliberately broken line must be reported. This keeps the
  # helper honest if the regexes are ever simplified.
  bad <- "#'     * `dropout`: anticipated dropout rate in [0, 1),"
  stripped <- strip_legal_brackets(bad)
  opens <- lengths(regmatches(stripped, gregexpr("[[]", stripped)))
  closes <- lengths(regmatches(stripped, gregexpr("[]]", stripped)))
  expect_false(opens == closes)

  good <- "#'     * `dropout`: anticipated dropout rate in &lbrack;0, 1),"
  stripped_good <- strip_legal_brackets(good)
  opens_good <- lengths(regmatches(stripped_good, gregexpr("[[]", stripped_good)))
  closes_good <- lengths(regmatches(stripped_good, gregexpr("[]]", stripped_good)))
  expect_equal(opens_good, closes_good)
})
