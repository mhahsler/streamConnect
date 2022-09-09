#' Publish a Data Stream via a Web Service
#'
#' Uses the package [plumber] to publish a data stream as a web service.
#'
#' The function writes a plumber task script file and starts the web server to serve
#' the content of the stream using the endpoints `http://localhost:port/get_points?n=100`) and
#' `http://localhost:port/info`.
#'
#' APIs generated using plumber can be easily deployed. See: [Hosting](https://www.rplumber.io/articles/hosting.html). By setting a `task_file` and `serve = FALSE` a plumber
#' task script file is generated that can be deployment.
#'
#' @param dsd A character string that creates a DSD.
#' @param port port used to serve the DSD.
#' @param task_file name of the plumber task script file.
#' @param serializer method used to serialize the data. By default `csv` (comma separated values)
#' is used. Other methods are `json` (see [plumber::serializer_csv]).
#' @param serve if `TRUE`, then a task file is written and a server started, otherwise,
#'   only a plumber task file is written.
#'
#' @examples
#' # create a background DSD process sending data to port 8001
#' rp1 <- "DSD_Gaussians(k = 3, d = 3)" %>%
#'          publish_DSD_via_WebService(port = 8001)
#' rp1
#'
#' #' Sys.sleep(1) # wait for the socket to become available
#'
#' # connect to the port and read
#' resp <- httr::GET("localhost:8001/info")
#' d <- httr::content(resp, show_col_types = FALSE)
#' d
#'
#' # example: Get 100 points and plot them
#' resp <- httr::GET("http://localhost:8001/get_points?n=100")
#' d <- httr::content(resp, show_col_types = FALSE)
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
#' rp2 <- "DSD_Gaussians(k = 3, d = 3)" %>%
#'          publish_DSD_via_WebService(port = 8001, serializer = "json")
#' rp2
#'
#' #' Sys.sleep(1) # wait for the socket to become available
#'
#' # connect to the port and read
#' resp <- httr::GET("localhost:8001/info")
#' httr::content(resp, as = "text")
#'
#' resp <- httr::GET("http://localhost:8001/get_points?n=5")
#' httr::content(resp, as = "text")
#'
#' # cleanup
#' rp2$kill()
#' rp2
#'
#' @export
publish_DSD_via_WebService <-
  function(dsd,
    port = 8001,
    task_file = NULL,
    serializer = "csv",
    serve = TRUE) {
    if (is.null(task_file))
      task_file <- tempfile(pattern = "plumber_", fileext = ".R")
    
    script = '# Plumber task file created by package streamConnect (no not edit!)
#
# Run with:
# library("plumber")
# pr("${task_file}") %>% pr_run(port = 8002)

library("stream")
dsd <- ${dsd}

#* @apiTitle DSD

#* Get Data Points from the Stream
#* @serializer ${serializer}
#* @param n number of points
#* @get /get_points
function(n = 1, info = TRUE) {
  get_points(dsd, n)
}

#* Data Stream Info
#* @serializer ${serializer}
#* @get /info
function() {
  data.frame(description = dsd$description, d = dsd$d, k = dsd$k)
}
'
cat(stringr::str_interp(script), file = task_file)

if (serve)
  callr::r_bg(function(task_file, port)
  {
    plumber::pr_run(plumber::pr(task_file), port = port, docs = FALSE)
  },
    args = list(task_file = task_file, port = port))
else
  cat("plumber script written to", task_file, "\n")
  }
