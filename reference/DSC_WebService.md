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
[`DSD_ReadWebService()`](http://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md),
[`publish_DSC_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md),
[`publish_DSD_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)

Other dsc:
[`publish_DSC_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md)

## Examples

``` r
# find a free port
port <- httpuv::randomPort()
port
#> [1] 11336

# deploy a clustering process listening for data on the port
rp1 <- publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", port = port)
rp1
#> PROCESS 'R', running, pid 7085.

# get a local DSC interface
dsc <- DSC_WebService(paste0("http://localhost", ":", port), 
  verbose = TRUE, config = httr::verbose(info = TRUE))
#> Connecting to DSC Web service at http://localhost:11336
#> Success
dsc
#> Web Service Data Stream Clusterer: DBSTREAM
#> Served from: http://localhost:11336 
#> Class: DSC_WebService, DSC_R, DSC 
#> Number of micro-clusters: 0 
#> Number of macro-clusters: 0 

# cluster
dsd <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)

update(dsc, dsd, 500)

get_centers(dsc)
#> # A tibble: 21 × 2
#>       X1      X2
#>    <dbl>   <dbl>
#>  1 0.339 -0.0304
#>  2 0.416  0.0231
#>  3 0.176  0.969 
#>  4 0.391  0.0640
#>  5 0.375  0.589 
#>  6 0.367  0.0193
#>  7 0.333  0.607 
#>  8 0.209  0.937 
#>  9 0.311  0.648 
#> 10 0.398  0.544 
#> # ℹ 11 more rows
get_weights(dsc)
#>  [1] 40.258396 45.175064 76.547455 71.563789 62.850884 83.223908 84.640713
#>  [8] 66.549164 43.433155 12.030671  9.596734 48.131107 44.900907 47.570942
#> [15] 38.225420 28.742240 15.678864 23.593335  5.413009  6.732637  3.805923

plot(dsc)


# kill the background clustering process.
rp1$kill()
#> [1] TRUE
rp1
#> PROCESS 'R', finished.
```
