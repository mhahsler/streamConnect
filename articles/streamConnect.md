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

    #> PROCESS 'R', running, pid 7996.

Connect a local `DSD` reader and request points from the stream:

``` r

socket_dsd <- DSD_ReadSocket(
  port = port,
  col.names = c("x", "y", ".class")
)

points <- get_points(socket_dsd, n = 10)
head(points)
```

    #>           x          y .class
    #> 1 0.3316778 0.03803245      3
    #> 2 0.1605888 0.91799695      2
    #> 3 0.4606180 0.08785682      3
    #> 4 0.3115893 0.02342845      3
    #> 5 0.3790946 0.03606870      3
    #> 6 0.3056986 0.64449405      1

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
    #>  1 0.922 0.120      3
    #>  2 1.05  0.464      1
    #>  3 0.974 0.408      1
    #>  4 0.890 0.400      1
    #>  5 0.265 0.429      2
    #>  6 0.998 0.496      1
    #>  7 0.970 0.408      1
    #>  8 0.873 0.118      3
    #>  9 0.972 0.100      3
    #> 10 0.201 0.394      2

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
