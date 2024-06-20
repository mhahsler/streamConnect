#' A DSC Interface for a DSC Running as a Web Service
#' 
#' Provides a DSC front-end for a clusterer running as a web service. The methods
#' `nclusters()`, `get_center()`, `get_weights()` are supported. The request is
#' retried with [httr::RETRY()] if it fails the first time.
#'
#' @family WebService
#' @family dsc
#'
#' @param url endpoint URI address in the format `http://host:port/<optional_path>`.
#' @param verbose logical; display connection information.
#' @param ... further arguments are passed on to [httr::RETRY()]. Pass 
#'   [httr::verbose()] as parameter `config` to get detailed connection info.
#'
#' @returns A [stream::DSC] object.
#' 
#' @examples
#' # find a free port
#' port <- httpuv::randomPort()
#' port
#' 
#' # deploy a clustering process listening for data on the port
#' rp1 <- publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", port = port)
#' rp1
#'
#' # get a local DSC interface
#' dsc <- DSC_WebService(paste0("http://localhost", ":", port), 
#'   verbose = TRUE, config = httr::verbose(info = TRUE))
#' dsc
#'
#' # cluster
#' dsd <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)
#'
#' update(dsc, dsd, 500)
#'
#' get_centers(dsc)
#' get_weights(dsc)
#'
#' plot(dsc)
#'
#' # kill the background clustering process.
#' rp1$kill()
#' rp1
#'
#' @export
DSC_WebService <- function(url, verbose = FALSE, ...) {
  # trailing / for url
  url <- gsub("/$", "", url)
  
  if (verbose)
    message("Connecting to DSC Web service at ", url)
  
  # we retry to give the server time to spin up
  #resp <- httr::GET(paste0(url, "/info"))
  resp <-
    httr::RETRY("GET", stringr::str_interp("${url}/info"), 
                quiet = !verbose, ...)
  if (httr::http_error(resp))
    d <- "No info"
  else
    d <- decode_response(resp)$description
  
  if (verbose)
    message("Success")
  
  structure(
    list(
      description = stringr::str_interp("Web Service Data Stream Clusterer: ${d}\nServed from: ${url}"),
      url = url,
      quiet = !verbose
    ),
    class = c("DSC_WebService", "DSC_R", "DSC")
  )
}

#' @export
update.DSC_WebService <- function(object, dsd, n = 1L, ...) {
  tmp <- tempfile()
  stream::write_stream(dsd, tmp, n = n, header = TRUE)
  resp <-
    httr::RETRY(
      "POST",
      stringr::str_interp("${object$url}/update"),
      body = list(upload = httr::upload_file(tmp)),
      quiet = object$quiet, ...
    )
  unlink(tmp)
  invisible(resp)
}

.check_error <- function(x)
  ncol(x) == 1 && nrow(x) == 1 && colnames(x)[1] == "error"

#' @export
get_centers.DSC_WebService <-
  function(x, type = c("auto", "micro", "macro"), ...) {
    type <- match.arg(type)
    
    resp <-
      httr::RETRY("GET",
        stringr::str_interp("${x$url}/get_centers?type=${type}"),
        quiet = x$quiet, ...)
    
    centers <- decode_response(resp)
    if (.check_error(centers))
      return(data.frame())
    
    centers
  }

#' @export
get_weights.DSC_WebService <-
  function(x,
    type = c("auto", "micro", "macro"),
    scale = NULL,
    ...) {
    type <- match.arg(type)
    if (!is.null(scale))
      com <-
        stringr::str_interp(
          "${x$url}/get_weights?type=${type}&scale_from=${scale[1]}&scale_to=${scale[2]}"
        )
    else
      com <-
        stringr::str_interp("${x$url}/get_weights?type=${type}")
    
    resp <-
      httr::RETRY("GET", com,  quiet = x$quiet, ...)
    weights <- decode_response(resp)
    
    if (.check_error(weights))
      return(numeric())
    
    weights[["weight"]]
  }