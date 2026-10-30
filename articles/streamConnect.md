# Getting Started with streamConnect

`streamConnect` connects data stream sources and stream mining
algorithms through sockets or web services. It works with the `DSD`
(data stream) and `DSC` (data stream clustering) interfaces from the
[stream package](https://github.com/mhahsler/stream).

This guide shows two common workflows: reading a stream over a socket
and updating a remote clusterer through a web service. For more control
over the web service endpoints and deployment, see the help pages for
[`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)
and
[`publish_DSC_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md).

## Install and load

Install the released package from CRAN:

``` r

install.packages("streamConnect")
```

Load the package and select an available local port for the examples:

``` r

library(streamConnect)
```

    #> Loading required package: stream

We will use the same free server port throughout this vignette. Some
systems do not allow the use of local ports, then the code in this
vignette will not be executed.

``` r

run_code <- TRUE
tryCatch({
  port <- httpuv::randomPort()

  }, warning = function(w) {
    message("Ports unavailable: ", w)
    run_code <<- FALSE
  }, error = function(e) {
    message("Ports unavailable: ", e)
    run_code <<- FALSE
})
```

## Read a data stream over a socket

Start a background process that publishes a stream. The publisher opens
a socket server and writes data in blocks. Since the socket format does
not include column names, provide them when creating the reader.

``` r

socket_process <- publish_DSD_via_Socket(
  DSD_Gaussians(k = 3, d = 2),
  port = port
)
socket_process
```

    #> PROCESS 'R', running, pid 8026.

Connect a local `DSD` reader and request points from the stream:

``` r

socket_dsd <- DSD_ReadSocket(
  port = port,
  col.names = c("x", "y", ".class")
)

points <- get_points(socket_dsd, n = 10)
head(points)
```

    #>           x            y .class
    #> 1 0.3027910  0.610707372      1
    #> 2 0.2441749  0.960364120      2
    #> 3 0.1751205  0.965338470      2
    #> 4 0.3405278  0.615312227      1
    #> 5 0.1726735  0.954757539      2
    #> 6 0.3939217 -0.004860281      3

Close the reader and stop the publisher when finished:

``` r

close_stream(socket_dsd)
if (socket_process$is_alive()) socket_process$kill()
```

    #> [1] TRUE

## Update a remote clusterer via a web service

Web services also support request and response operations. Start a
clusterer in a background process, then create a local `DSC` interface
for it:

``` r

clusterer_process <- publish_DSC_via_WebService(
  "DSC_DBSTREAM(r = .05)",
  port = port
)

clusterer <- DSC_WebService(paste0("http://127.0.0.1:", port))
clusterer
```

    #> Web Service Data Stream Clusterer: DBSTREAM
    #> Served from: http://127.0.0.1:11336 
    #> Class: DSC_WebService, DSC_R, DSC 
    #> Number of micro-clusters: 0 
    #> Number of macro-clusters: 0

Send a batch of points to the remote clusterer and retrieve its centers
and weights through the local interface:

``` r

stream <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)
update(clusterer, stream, n = 500)

get_centers(clusterer)
```

    #> # A tibble: 24 × 2
    #>       X1       X2
    #>    <dbl>    <dbl>
    #>  1 0.332  0.292  
    #>  2 0.470  0.933  
    #>  3 0.634  0.120  
    #>  4 0.271  0.288  
    #>  5 0.232  0.314  
    #>  6 0.453  0.886  
    #>  7 0.601  0.0798 
    #>  8 0.700 -0.00260
    #>  9 0.644  0.0666 
    #> 10 0.652  0.00159
    #> # ℹ 14 more rows

``` r

get_weights(clusterer)
```

    #>  [1] 50.364869 62.925534 17.643684 94.970135 62.171627 57.319254 13.376050
    #>  [8] 28.404639 60.600800 29.533323 30.663367 48.203102 13.982802  5.231117
    #> [15] 12.220861  8.834957 33.911419 45.884032 35.707734 27.142056  6.202858
    #> [22]  8.310432 30.521944  6.727164

Stop the service process when the work is complete:

``` r

if (clusterer_process$is_alive()) clusterer_process$kill()
```

    #> [1] TRUE

## Publish a stream through a web service

To expose a data source over HTTP, publish a `DSD` and read it with
[`DSD_ReadWebService()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md).
The service returns CSV by default; JSON and RDS serialization are also
available through the `serializer` argument.

``` r

source_process <- publish_DSD_via_WebService(
  "DSD_Gaussians(k = 3, d = 2)",
  port = port
)

remote_stream <- DSD_ReadWebService(paste0("http://127.0.0.1:", port))
get_points(remote_stream, n = 10)
```

    #> # A tibble: 10 × 3
    #>       X1    X2 .class
    #>    <dbl> <dbl>  <dbl>
    #>  1 0.323 0.717      3
    #>  2 0.354 0.691      3
    #>  3 0.606 0.621      2
    #>  4 0.295 0.606      3
    #>  5 0.289 0.700      3
    #>  6 0.377 0.297      1
    #>  7 0.617 0.564      2
    #>  8 0.293 0.712      3
    #>  9 0.368 0.681      3
    #> 10 0.321 0.694      3

``` r

if (source_process$is_alive()) source_process$kill()
```

    #> [1] TRUE

## Next steps

- Use
  [`publish_DSD_via_Socket()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_Socket.md)
  and
  [`DSD_ReadSocket()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadSocket.md)
  for continuous point-to-point stream transfer.
- Use
  [`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)
  and
  [`DSD_ReadWebService()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md)
  to serve stream data over HTTP.
- Use
  [`publish_DSC_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md)
  and
  [`DSC_WebService()`](https://michael.hahsler.net/streamConnect/reference/DSC_WebService.md)
  to update and inspect a remote clusterer.
- Set `serve = FALSE` to write a plumber task file for deployment with a
  hosting environment of your choice.

See the [package
reference](https://michael.hahsler.net/streamConnect/reference/) for the
full function documentation.
