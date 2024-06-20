#' Publish a Data Stream via a Web Service
#'
#' Uses the package plumber to publish a data stream as a web service.
#'
#' The function writes a plumber task script file and starts the web server to serve
#' the content of the stream using the endpoints 
#' 
#' * `http://localhost:port/get_points?n=100` and
#' * `http://localhost:port/info`.
#'
#' APIs generated using plumber can be easily deployed. See: [Hosting](https://www.rplumber.io/articles/hosting.html). By setting a `task_file` and `serve = FALSE` a plumber
#' task script file is generated that can be deployment.
#'
#' A convenient reader for stream data over web services is available as [DSD_ReadWebService].
#'
#' @family WebService
#' @family dsd
#'
#' @param dsd A character string that creates a DSD.
#' @param port port used to serve the DSD.
#' @param task_file name of the plumber task script file.
#' @param serializer method used to serialize the data. By default `csv` (comma separated values)
#' is used. Other methods are `json` and `rds` (see [plumber::serializer_csv]).
#' @param serve if `TRUE`, then a task file is written and a server started, otherwise,
#'   only a plumber task file is written.
#' @param background logical; start a background process?
#' @param debug if `TRUE`, then the service is started locally and a web client is started to explore the interface.
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
#' rp1 <- publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)", port = port)
#' rp1
#'
#' # connect to the port and read manually. See DSD_ReadWebService for
#' # a more convenient way to connect to the WebService in R.
#' library("httr")
#' 
#' # we use RETRY to give the server time to spin up
#' resp <- RETRY("GET", paste0("http://localhost:", port, "/info"))
#' d <- content(resp, show_col_types = FALSE)
#' d
#'
#' # example: Get 100 points and plot them
#' resp <- GET(paste0("http://localhost:", port, "/get_points?n=100"))
#' d <- content(resp, show_col_types = FALSE)
#' head(d)
#'
#' dsd <- DSD_Memory(d)
#' dsd
#' plot(dsd, n = -1)
#'
#' # end the DSD process. Note: that closing the connection above
#' # may already kill the process.
#' rp1$kill()
#' rp1
#'
#' # Publish using json
#'
#' rp2 <- publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)", 
#'            port = port, serializer = "json")
#' rp2
#'
#' # connect to the port and read
#' # we use RETRY to give the server time to spin up
#' resp <- RETRY("GET", paste0("http://localhost:", port, "/info"))
#' content(resp, as = "text")
#'
#' resp <- GET(paste0("http://localhost:", port, "/get_points?n=5"))
#' content(resp, as = "text")
#'
#' # cleanup
#' rp2$kill()
#' rp2
#'
#' # Debug the interface (run the service and start a web interface)
#' if (interactive())
#'   publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)", port = port, 
#'          debug = TRUE)
#' @export
publish_DSD_via_WebService <-
  function(dsd,
    port,
    task_file = NULL,
    serializer = "csv",
    serve = TRUE,
    background = TRUE,
    debug = FALSE) {
    ## script requires the following variables: dsd, serializer
    task_file <- complete_plumber_task_file("DSD.plumber",
      task_file,
      dsd = dsd,
      serializer = serializer)
    
    run_plumber_task_file(task_file, port, serve, background, debug)
  }