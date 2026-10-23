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

## Read a data stream over a socket

Start a background process that publishes a stream. The publisher opens
a socket server and writes data in blocks. Since the socket format does
not include column names, provide them when creating the reader.

``` r

port <- httpuv::randomPort()

socket_process <- publish_DSD_via_Socket(
  DSD_Gaussians(k = 3, d = 2),
  port = port
)
socket_process
```

    #> PROCESS 'R', running, pid 8637.

Connect a local `DSD` reader and request points from the stream:

``` r

socket_dsd <- DSD_ReadSocket(
  port = port,
  col.names = c("x", "y", ".class")
)

points <- get_points(socket_dsd, n = 10)
head(points)
```

    #>           x           y .class
    #> 1 0.3715665  0.66089384      1
    #> 2 0.3745540  0.03023631      3
    #> 3 0.3854969  0.53483843      1
    #> 4 0.3518352 -0.01849124      3
    #> 5 0.3367859  0.54765735      1
    #> 6 0.3868021  0.03655485      3

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

stream <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)
update(clusterer, stream, n = 500)

get_centers(clusterer)
```

    #> # A tibble: 21 × 2
    #>       X1    X2
    #>    <dbl> <dbl>
    #>  1 0.533 0.536
    #>  2 0.846 0.920
    #>  3 0.923 0.985
    #>  4 0.649 0.292
    #>  5 0.592 0.554
    #>  6 0.769 0.861
    #>  7 0.532 0.590
    #>  8 0.728 0.244
    #>  9 0.806 0.898
    #> 10 0.878 0.959
    #> # ℹ 11 more rows

``` r

get_weights(clusterer)
```

    #>  [1] 59.328817 90.077228 46.834077 36.829638 39.436172 13.175782 51.902178
    #>  [8] 70.557389 54.903441 74.497302 54.144887 20.563491 17.794179 51.368460
    #> [15]  4.452388  8.345200 48.207425  4.439208 29.068291 10.179184  7.647577

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

port <- httpuv::randomPort()

source_process <- publish_DSD_via_WebService(
  "DSD_Gaussians(k = 3, d = 2)",
  port = port
)

remote_stream <- DSD_ReadWebService(paste0("http://localhost:", port))
get_points(remote_stream, n = 10)
```

    #> # A tibble: 10 × 3
    #>       X1    X2 .class
    #>    <dbl> <dbl>  <dbl>
    #>  1 0.782 0.182      2
    #>  2 0.565 0.662      3
    #>  3 0.952 0.501      1
    #>  4 0.864 0.197      2
    #>  5 0.541 0.601      3
    #>  6 0.837 0.200      2
    #>  7 0.930 0.518      1
    #>  8 0.831 0.133      2
    #>  9 0.920 0.483      1
    #> 10 0.908 0.483      1

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
