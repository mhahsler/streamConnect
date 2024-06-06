#' Retry an Expression that Fails
#'
#' Retries and expression that fails. This is mainly used to retry
#' establishing a connection.
#'
#' @param f expression
#' @param times integer; number of times
#' @param wait  number of seconds to wait in between tries.
#' @param verbose logical; show progress and errors.
#'
#' @return the result of the expression f
#'
#' @examples
#' retry(1)
#' @export
retry <- function(f, times = 5, wait = 1, verbose = FALSE) {
  times <- as.integer(times)
  
  for (i in seq(times)) {
  suppressWarnings(r <- try(f, silent = !verbose))
  if (!inherits(r, "try-error")) 
    return(r)
  
  if (verbose) 
    cat("Try", i, "of", times, "failed.\n")
  
  if (i != times)
    Sys.sleep(wait)
  
  
  }
  stop(substitute(f), " failed after ", times, " ties!")
  
}
