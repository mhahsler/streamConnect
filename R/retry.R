#' Retry an Expression that Fails
#'
#' Retries an expression that fails. This is mainly used when
#' establishing a connection.
#'
#' @param f expression
#' @param times integer; number of times
#' @param wait  number of seconds to wait in between tries.
#' @param verbose logical; show progress and errors.
#' @param operation name of the operation used in the error message.
#'
#' @return the result of the expression f
#'
#' @examples
#' retry(1)
#' @export
retry <- function(f, times = 5, wait = 1, verbose = FALSE, operation = NULL) {
  times <- as.integer(times)
  last_error <- NULL
  
  for (i in seq(times)) {
  suppressWarnings(r <- try(f, silent = !verbose))
  if (!inherits(r, "try-error")) { 
    if (verbose) 
      cat("Try", i, "of", times, "success.\n")
    return(r)
  }
  last_error <- attr(r, "condition")
  
  if (verbose) 
    cat("Try", i, "of", times, "failed.\n")
  
  if (i != times)
    Sys.sleep(wait)
  
  }
  
  if (is.null(operation))
    operation <- as.character(quote(f))
  
  error_message <- if (is.null(last_error))
    ""
  else
    paste0(". Last error: ", conditionMessage(last_error))

  stop(operation, " failed after ", times, " tries", error_message, ".")
  
}
