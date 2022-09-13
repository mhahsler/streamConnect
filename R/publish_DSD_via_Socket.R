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
#' 
#' @examples
#' # create a background DSD process sending data to port 6011
#' rp1 <- DSD_Gaussians(k = 3, d = 3) %>% publish_DSD_via_Socket(port = 6011)
#' rp1
#'
#' Sys.sleep(3) # wait for the socket to become available
#' 
#' # connect to the port and read
#' con <- socketConnection(port = 6011, open = 'r') 
#' Sys.sleep(2) # wait for the connection to establish
#' dsd <- DSD_ReadStream(con, col.names = c("x", "y", "z", ".class"))
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
publish_DSD_via_Socket <- function(dsd, port = 6011, blocksize = 1024L) {
  callr::r_bg(function(dsd, port, blocksize) {

    con <- socketConnection(port = port, server = TRUE)
    while (TRUE) {
      stream::write_stream(dsd, con, n = blocksize, close = FALSE, header = FALSE, info = TRUE)
    }
    
    close(con)
  },
    list(dsd = dsd, port = port, blocksize = blocksize)
  )
}
