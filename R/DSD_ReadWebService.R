#' A DSD That Reads for a Web Service
#'
#' Reads from a web service that published an operation called
#' `get_points` which takes a parameter `n` and returns `n` data points in CSV or json
#' format.
#' 
#' @family dsd
#' 
#' @param url endpoint URI address in the format `http://host:port/<optional_path>`.
#'
#' @examples
#' # create a background DSD process sending data to port 8001
#' rp1 <- "DSD_Gaussians(k = 3, d = 3)" %>% 
#'    publish_DSD_via_WebService(port = 8001)
#' 
#' ## use json instead of csv
#' # rp1 <- "DSD_Gaussians(k = 3, d = 3)" %>% 
#' #  publish_DSD_via_WebService(port = 8001, serialize = "json")
#' rp1
#'
#' # create a DSD that connects to the web service
#' dsd <- DSD_ReadWebService("http://localhost:8001/")
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
  resp <- httr::RETRY("GET", paste0(x$url, "/get_points?n=", n))
  
  ## complains about missing encoding for json
  suppressMessages(d <- httr::content(resp, as = "text"))
  
  d <- switch(httr::http_type(resp),
    "application/json" = jsonlite::fromJSON(d, 
      simplifyVector = FALSE, 
      simplifyDataFrame = TRUE,
      simplifyMatrix = FALSE),
    "text/csv" = readr::read_csv(d, show_col_types = FALSE)
  )
  
  if (!info)
    d <- remove_info(d)
  d
}
