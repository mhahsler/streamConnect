# Getting Started with streamConnect

`streamConnect` connects data stream sources and stream mining
algorithms through sockets or web services. It works with the `DSD`
(data stream) and `DSC` (data stream clustering) interfaces from the
[stream package](https://github.com/mhahsler/stream).

This guide shows two common workflows: reading a stream over a socket
and updating a remote clusterer through a web service. For more control
over the web service endpoints and deployment, see the help pages for
[`publish_DSD_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)
and
[`publish_DSC_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md).

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

``` r

port <- httpuv::randomPort()
port
```

    #> [1] 11336

## Read a data stream over a socket

Start a background process that publishes a stream. The publisher opens
a socket server and writes data in blocks. Since the socket format does
not include column names, provide them when creating the reader.

``` r

socket_process <- publish_DSD_via_Socket(
  stream::DSD_Gaussians(k = 3, d = 2),
  port = port
)
socket_process
```

    #> PROCESS 'R', running, pid 8476.

Connect a local `DSD` reader and request points from the stream:

``` r

socket_dsd <- DSD_ReadSocket(
  port = port,
  col.names = c("x", "y", ".class")
)

points <- stream::get_points(socket_dsd, n = 10)
head(points)
```

    #>           x           y .class
    #> 1 0.3943938 0.017548812      3
    #> 2 0.3626888 0.027016006      3
    #> 3 0.3962445 0.044915080      3
    #> 4 0.4387063 0.021204061      3
    #> 5 0.3844297 0.005798028      3
    #> 6 0.1883367 0.935410989      2

Close the reader and stop the publisher when finished:

``` r

stream::close_stream(socket_dsd)
if (socket_process$is_alive()) socket_process$kill()
```

    #> [1] TRUE

## Update a remote clusterer over a web service

Web services also support request and response operations. Start a
clusterer in a background process, then create a local `DSC` interface
for it:

``` r

web_port <- httpuv::randomPort()
clusterer_process <- publish_DSC_via_WebService(
  "DSC_DBSTREAM(r = .05)",
  port = web_port
)

clusterer <- DSC_WebService(paste0("http://localhost:", web_port))
clusterer
```

    #> Web Service Data Stream Clusterer: DBSTREAM
    #> Served from: http://localhost:26595 
    #> Class: DSC_WebService, DSC_R, DSC 
    #> Number of micro-clusters: 0 
    #> Number of macro-clusters: 0

Send a batch of points to the remote clusterer and retrieve its centers
and weights through the local interface:

``` r

stream <- stream::DSD_Gaussians(k = 3, d = 2, noise = 0.05)
stats::update(clusterer, stream, n = 500)

stream::get_centers(clusterer)
```

    #> # A tibble: 18 × 2
    #>       X1       X2
    #>    <dbl>    <dbl>
    #>  1 0.912  0.504  
    #>  2 0.554  0.665  
    #>  3 0.242  0.0686 
    #>  4 0.948  0.595  
    #>  5 0.581  0.714  
    #>  6 0.911  0.550  
    #>  7 0.247  0.0153 
    #>  8 0.298 -0.00909
    #>  9 0.850  0.499  
    #> 10 0.196  0.0709 
    #> 11 0.283  0.0488 
    #> 12 0.985  0.624  
    #> 13 0.630  0.715  
    #> 14 0.514  0.641  
    #> 15 0.204  0.130  
    #> 16 0.602  0.662  
    #> 17 0.956  0.537  
    #> 18 0.284 -0.0584

``` r

stream::get_weights(clusterer)
```

    #>  [1] 58.365646 71.920920 74.630887 60.992149 74.360894 89.673484 54.582404
    #>  [8] 29.568905 13.720000 43.746145 54.109393 17.041666 38.361624 24.469960
    #> [15] 22.513467 37.922865 39.908855  5.657336

Stop the service process when the work is complete:

``` r

if (clusterer_process$is_alive()) clusterer_process$kill()
```

    #> [1] TRUE

## Publish a stream through a web service

To expose a data source over HTTP, publish a `DSD` and read it with
[`DSD_ReadWebService()`](http://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md).
The service returns CSV by default; JSON and RDS serialization are also
available through the `serializer` argument.

``` r

port <- httpuv::randomPort()
source_process <- publish_DSD_via_WebService(
  "DSD_Gaussians(k = 3, d = 2)",
  port = port
)

remote_stream <- DSD_ReadWebService(paste0("http://localhost:", port))
stream::get_points(remote_stream, n = 10)

source_process$kill()
```

## Next steps

- Use
  [`publish_DSD_via_Socket()`](http://michael.hahsler.net/streamConnect/reference/publish_DSD_via_Socket.md)
  and
  [`DSD_ReadSocket()`](http://michael.hahsler.net/streamConnect/reference/DSD_ReadSocket.md)
  for continuous point-to-point stream transfer.
- Use
  [`publish_DSD_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)
  and
  [`DSD_ReadWebService()`](http://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md)
  to serve stream data over HTTP.
- Use
  [`publish_DSC_via_WebService()`](http://michael.hahsler.net/streamConnect/reference/publish_DSC_via_WebService.md)
  and
  [`DSC_WebService()`](http://michael.hahsler.net/streamConnect/reference/DSC_WebService.md)
  to update and inspect a remote clusterer.
- Set `serve = FALSE` to write a plumber task file for deployment with a
  hosting environment of your choice.

See the [package
reference](https://mhahsler.r-universe.dev/streamConnect) for the full
function documentation.
