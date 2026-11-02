# Shared test helpers (sourced before all tests, safe under shuffled runs)

# cli sends informational output through message conditions in
# non-interactive sessions, so capture both streams.
capture_cli <- function(expr) {
  msgs <- character()
  out <- withCallingHandlers(
    capture.output(print(expr)),
    message = function(m) {
      msgs <<- c(msgs, m$message)
      invokeRestart("muffleMessage")
    }
  )
  paste(c(out, msgs), collapse = "\n")
}

capture_cli_summary <- function(expr) {
  msgs <- character()
  out <- withCallingHandlers(
    capture.output(summary(expr)),
    message = function(m) {
      msgs <<- c(msgs, m$message)
      invokeRestart("muffleMessage")
    }
  )
  paste(c(out, msgs), collapse = "\n")
}
