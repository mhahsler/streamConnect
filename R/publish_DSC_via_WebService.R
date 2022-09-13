#' Publish a Data Stream Clustering Task via a Web Service
#'
#' Uses the package [plumber] to publish a data stream task as a web service.
#'
#' The function writes a plumber task script file and starts the web server to serve
#' the content of the stream using the endpoints 
#' * TBD
#' 
#' 
#' APIs generated using plumber can be easily deployed. See: [Hosting](https://www.rplumber.io/articles/hosting.html). By setting a `task_file` and `serve = FALSE` a plumber
#' task script file is generated that can deployment.
#'
#' @family dsc
#'
#' @param dsc A character string that creates a DSC.
#' @param port port used to serve the task.
#' @param task_file name of the plumber task script file.
#' @param serializer method used to serialize the data. By default `csv` (comma separated values)
#' is used. Other methods are `json` (see [plumber::serializer_csv]).
#' @param serve if `TRUE`, then a task file is written and a server started, otherwise,
#'   only a plumber task file is written.
#' @param debug if `TRUE`, then the service is started locally and a web client is started to explore the interface.
#'
#' @examples
#' # create a background clustering process sending data to port 8001
#' rp1 <- "DSC_DBSTREAM(r = .05)" %>%  
#'      publish_DSC_via_WebService(port = 8001)
#' rp1
#'
#' # connect to the port and read manually.
#' library(httr)
#' 
#' resp <- RETRY("GET", "http://localhost:8001/info")
#' d <- content(resp, show_col_types = FALSE)
#' d
#'
#' # cluster
#' dsd <- DSD_Gaussians(k = 3, d = 2, noise = 0.05) 
#'
#' tmp <- tempfile()
#' stream::write_stream(dsd, tmp, n = 500, header = TRUE)
#' resp <- POST("http://localhost:8001/update", body = list(upload = upload_file(tmp)))
#' unlink(tmp)
#' resp
#'
#' # retrieve the cluster centers
#' resp <- GET("http://localhost:8001/get_centers")
#' d <- content(resp, show_col_types = FALSE)
#' head(d)
#' 
#' plot(dsd, n = 100)
#' points(d, col = "red", pch = 3, lwd = 3)
#' 
#' # kill the process.
#' rp1$kill()
#' rp1
#' 
#' # Debug the interface (run the service and start a web interface)
#' \dontrun{
#' "DSC_DBSTREAM(r = .05)" %>%
#'          publish_DST_via_WebService(port = 8001, debug = TRUE)
#' }
#' @export
publish_DSC_via_WebService <-
  function(dsc,
    port = 8001,
    task_file = NULL,
    serializer = "csv",
    serve = TRUE,
    debug = FALSE) {
    ## script requires the following variables: dsc, serializer
    task_file <- complete_plumber_task_file("DSC.plumber",
      task_file,
      dsc = dsc,
      serializer = serializer)
    
    run_plumber_task_file(task_file, port, debug, serve)
  }