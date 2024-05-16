#' A DSD That Reads for a Web Service
#'
#' Reads from a web service that published an operation called
#' `get_points` which takes a parameter `n` and returns `n` data points in CSV or json
#' format.
#' 
#' @family WebService
#' @family dsd
#' 
#' @param url endpoint URI address in the format `http://host:port/<optional_path>`.
#'
#' @examples
#' # find a free port
#' port <- httpuv::randomPort()
#' port
#' 
#' # create a background DSD process sending data to the port
#' rp1 <- publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)", port = port)
#' 
#' ## use json for the transport layer instead of csv
#' # rp1 <- publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)", 
#' #              port = port, serialize = "json")
#' rp1
#'
#' # create a DSD that connects to the web service
#' dsd <- DSD_ReadWebService(paste0("http://localhost:", port))
#' dsd
#'
#' get_points(dsd, n = 10)
#'
#' plot(dsd)
#'
#' # end the DSD process. Note: that closing the connection above
#' # may already kill the process.
#' rp1$kill()
#' rp1
#' @export
DSD_ReadWebService <- function(url) {
  # trailing / for url
  url <- gsub("/$", "", url)
  
  # we retry to give the server time to spin up
  #resp <- httr::GET(paste0(url, "/info"))
  resp <- httr::RETRY("GET", paste0(url, "/info"), quiet = TRUE)
  if (httr::http_error(resp))
    d <- "No info"
  else
    d <-
    as.data.frame(httr::content(resp, show_col_types = FALSE))$description
  
  structure(list(
    description = paste0('Web Service Data Stream: ', d,
      '\nServed from: ', url),
    url = url
  ),
    class = c("DSD_ReadWebService", "DSD_R", "DSD"))
}

#' @import stream
#' @export
get_points.DSD_ReadWebService <- function(x,
  n = 1L,
  info = TRUE,
  ...) {
  resp <- httr::RETRY("GET", stringr::str_interp("${x$url}/get_points?n=${n}"))
  d <- decode_response(resp)
  
  if (!info)
    d <- remove_info(d)
  d
}
