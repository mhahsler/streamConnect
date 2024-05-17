#' Publish a Data Stream Clustering Task via a Web Service
#'
#' Uses the package [plumber] to publish a data stream task as a web service.
#'
#' The function writes a plumber task script file and starts the web server to serve
#' the content of the stream using the endpoints 
#' * GET `/info`
#' * POST `/update` requires the data to be uploaded as a file in csv format (see Examples section).
#' * GET `/get_centers` with parameter `type` (see [get_centers()]).
#' * GET `/get_weights` with parameter `type` (see [get_weights()]).
#' 
#' Supported serializers are `csv` (default), `json`, and `rds`.
#'  
#' APIs generated using plumber can be easily deployed. See: [Hosting](https://www.rplumber.io/articles/hosting.html). By setting a `task_file` and `serve = FALSE` a plumber
#' task script file is generated that can deployment.
#'
#' @family WebService
#' @family dsc
#'
#' @param dsc A character string that creates a DSC.
#' @param port port used to serve the task.
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
#' # Deploy a clustering process listening for data on the port
#' rp1 <- publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", port = port)
#' rp1
#'
#' # look at ? DSC_WebService for a convenient interface. 
#' # Here we we show how to connect to the port and send data manually.
#' library(httr)
#' 
#' # the info verb returns some basic information about the clusterer.
#' resp <- RETRY("GET", paste0("http://localhost:", port, "/info"))
#' d <- content(resp, show_col_types = FALSE)
#' d
#'
#' # create a local data stream and send it to the clusterer using the update verb.
#' dsd <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)
#'
#' tmp <- tempfile()
#' stream::write_stream(dsd, tmp, n = 500, header = TRUE)
#' resp <- POST(paste0("http://localhost:", port, "/update"), 
#'   body = list(upload = upload_file(tmp)))
#' unlink(tmp)
#' resp
#'
#' # retrieve the cluster centers using the get_centers verb
#' resp <- GET(paste0("http://localhost:", port, "/get_centers"))
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
#' if (interactive())
#'   publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", 
#'          port = port, debug = TRUE)
#' @export
publish_DSC_via_WebService <-
  function(dsc,
    port,
    task_file = NULL,
    serializer = "csv",
    serve = TRUE,
    background = TRUE,
    debug = FALSE) {
    ## script requires the following variables: dsc, serializer
    task_file <- complete_plumber_task_file("DSC.plumber",
      task_file,
      dsc = dsc,
      serializer = serializer)
    
    run_plumber_task_file(task_file, port, serve, background, debug)
  }