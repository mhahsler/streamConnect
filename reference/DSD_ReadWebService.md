# A DSD That Reads from a Web Service

Reads from a web service that publishes an operation called `get_points`
which takes a parameter `n` and returns `n` data points in CSV or json
format. The request is retried with
[`httr::RETRY()`](https://httr.r-lib.org/reference/RETRY.html) if it
fails the first time.

## Usage

``` r
DSD_ReadWebService(url, verbose = FALSE, ...)
```

## Arguments

- url:

  endpoint URI address in the format `http://host:port/<optional_path>`.
  For localhost, use `127.0.0.1`, the default IPv4 loopback address.

- verbose:

  logical; display connection information.

- ...:

  further arguments are passed on to
  [`httr::RETRY()`](https://httr.r-lib.org/reference/RETRY.html). Pass
  [`httr::verbose()`](https://httr.r-lib.org/reference/verbose.html) as
  parameter `config` to get detailed connection info.

## Value

A [stream::DSD](https://rdrr.io/pkg/stream/man/DSD.html) object.

## See also

Other WebService:
[`DSC_WebService()`](https://michael.hahsler.net/streamConnect/reference/DSC_WebService.md),
[`publish_DSC_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md),
[`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)

Other dsd:
[`DSD_ReadSocket()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadSocket.md),
[`publish_DSD_via_Socket()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_Socket.md),
[`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)

## Examples

``` r
# tryCatch is used to catch connection errors
tryCatch({
  # find a free port
  port <- httpuv::randomPort()
  port

  # create a background DSD process sending data to the port
  rp1 <- publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)", port = port)

  ## use json for the transport layer instead of csv
  # rp1 <- publish_DSD_via_WebService("DSD_Gaussians(k = 3, d = 3)",
  #              port = port, serialize = "json")
  rp1

  # create a DSD that connects to the web service
  dsd <- DSD_ReadWebService(paste0("http://127.0.0.1", ":", port))
  dsd

  get_points(dsd, n = 10)

  plot(dsd)

  # end the DSD process. Note: that closing the connection above
  # may already kill the process.
  rp1$kill()
  rp1
}, warning = function(w) {
  message("localhost warning: ", w)
}, error = function(e) {
  message("localhost error: ", e)
})

#> PROCESS 'R', finished.
```
