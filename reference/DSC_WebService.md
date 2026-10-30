# A DSC Interface for a DSC Running as a Web Service

Provides a DSC front-end for a clusterer running as a web service. The
methods `nclusters()`, `get_center()`, `get_weights()` are supported.
The request is retried with
[`httr::RETRY()`](https://httr.r-lib.org/reference/RETRY.html) if it
fails the first time.

## Usage

``` r
DSC_WebService(url, verbose = FALSE, ...)
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

A [stream::DSC](https://rdrr.io/pkg/stream/man/DSC.html) object.

## See also

Other WebService:
[`DSD_ReadWebService()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md),
[`publish_DSC_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md),
[`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)

Other dsc:
[`publish_DSC_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md)

## Examples

``` r
# tryCatch is used to catch connection errors
tryCatch({
  # find a free port
  port <- httpuv::randomPort()
  port

  # deploy a clustering process listening for data on the port
  rp1 <- publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", port = port)
  rp1

  # get a local DSC interface
  dsc <- DSC_WebService(paste0("http://127.0.0.1", ":", port),
    verbose = TRUE, config = httr::verbose(info = TRUE))
  dsc

  # cluster
  dsd <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)

  update(dsc, dsd, 500)

  get_centers(dsc)
  get_weights(dsc)

  plot(dsc)

  # kill the background clustering process.
  rp1$kill()
  rp1

}, warning = function(w) {
  message("localhost warning: ", w)
}, error = function(e) {
  message("localhost error: ", e)
})
#> Connecting to DSC Web service at http://127.0.0.1:11336
#> Success

#> PROCESS 'R', finished.
```
