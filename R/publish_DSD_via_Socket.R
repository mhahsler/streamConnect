#' Write a Stream to a Socket
#'
#' Use a `write_stream()` to write data to a socket connection.
#'
#' Provide access to a data stream using a local port.
#'
#' Blocking: The DSD will be blocked once the
#' buffer is full and resume producing data when it gets unblocked.
#'
#' This method does not provide a header.
#'
#' @family Socket
#' @family dsd
#'
#' @param dsd A DSD object.
#' @param port port used to serve the DSD.
#' @param blocksize number of data points pushed on the buffer at once.
#' @param background logical; start a background process?
#' @param ... further arguments are passed on to [socketConnection()].
#'
#' @returns a [processx::process] object created with [callr::r_bg()] which runs the plumber server
#'  in the background. The process can be stopped with `rp$kill()` or by killing the process
#'  using the operating system with the appropriate PID. `rp$get_result()` can
#'  be used to check for errors in the server process (e.g., when it terminates
#'  unexpectedly).
#'
#' @examples
#' # find a free port
#' port <- httpuv::randomPort()
#' port
#'
#' # create a background DSD process sending data to the port
#' rp1 <- DSD_Gaussians(k = 3, d = 3) %>% publish_DSD_via_Socket(port = port)
#' rp1
#'
#' # connect to the port (retry waits for the socket to establish)
#' con <- retry(socketConnection(port = port, open = 'r'))
#' dsd <- retry(DSD_ReadStream(con, col.names = c("x", "y", "z", ".class")))
#'
#' get_points(dsd, n = 10)
#'
#' plot(dsd)
#'
#' # close connection
#' close_stream(dsd)
#'
#' # end the DSD process. Note: that closing the connection above
#' # may already kill the process.
#' rp1$kill()
#' rp1
#' @export
publish_DSD_via_Socket <- function(dsd,
                                   port,
                                   blocksize = 1024L,
                                   background = TRUE,
                                   ...) {
  if (background) {
    pr <- callr::r_bg(function(dsd, port, blocksize, ...) {
      con <- socketConnection(port = port, server = TRUE, ...)
      on.exit(close(con))
      
      while (TRUE) {
        stream::write_stream(
          dsd,
          con,
          n = blocksize,
          close = FALSE,
          header = FALSE,
          info = TRUE
        )
      }
    },
    list(
      dsd = dsd,
      port = port,
      blocksize = blocksize
    ))
    
    return(pr)
  }
  
  ### run directly
  con <- socketConnection(port = port, server = TRUE, ...)
  on.exit(close(con))
  
  while (TRUE) {
    stream::write_stream(
      dsd,
      con,
      n = blocksize,
      close = FALSE,
      header = FALSE,
      info = TRUE
    )
  }
}
