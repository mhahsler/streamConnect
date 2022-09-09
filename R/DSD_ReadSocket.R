#' A DSD That Reads from a Server Port
#'
#' Creates a `DSD_ReadStream` that reads from a port.
#'
#' @param host hostname.
#' @param port host port.
#' @param ... further arguments are passed on to [DSD_ReadStream()].
#'
#' @examples
#' # create a background DSD process sending data to port 8001
#' rp1 <- DSD_Gaussians(k = 3, d = 3) %>% publish_DSD_via_Socket(port = 6011)
#' rp1
#'
#' Sys.sleep(1)  # wait for the socket to become available
#'
#' # create a DSD that connects to the web service
#' dsd <- DSD_ReadSocket(port = 6011, col.names = c("x", "y", "z", ".class"))
#' dsd
#'
#' get_points(dsd, n = 10)
#' 
#' plot(dsd)
#'
#' close_stream(dsd)
#'
#' # end the DSD process. Note: that closing the connection above
#' # may already kill the process.
#' rp1$kill()
#' rp1
#' @export
DSD_ReadSocket <- function(host = "localhost", port, ...) {
  con <- socketConnection(host, port, open = 'r')
  Sys.sleep(1)
  DSD_ReadStream(con, ...)
}