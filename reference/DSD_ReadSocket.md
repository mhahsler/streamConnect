# A DSD That Reads from a Server Port

Creates a `DSD_ReadStream` that reads from a port.

## Usage

``` r
DSD_ReadSocket(host = "localhost", port, retry_args = NULL, ...)
```

## Arguments

- host:

  hostname.

- port:

  host port.

- retry_args:

  a list with arguments for
  [`retry()`](https://michael.hahsler.net/streamConnect/reference/retry.md).

- ...:

  further arguments are passed on to
  [`stream::DSD_ReadStream()`](https://rdrr.io/pkg/stream/man/DSD_ReadStream.html).

## Value

A [stream::DSD](https://rdrr.io/pkg/stream/man/DSD.html) object.

## See also

Other Socket:
[`publish_DSD_via_Socket()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_Socket.md)

Other dsd:
[`DSD_ReadWebService()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md),
[`publish_DSD_via_Socket()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_Socket.md),
[`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)

## Examples

``` r
# find a free port
port <- httpuv::randomPort()
port
#> [1] 16725

# create a background DSD process sending data to the port
rp1 <- DSD_Gaussians(k = 3, d = 3) %>% publish_DSD_via_Socket(port = port)
rp1
#> PROCESS 'R', running, pid 7456.

# create a DSD that connects to the socket. Note that we need to 
# specify the column names of the stream
dsd <- DSD_ReadSocket(port = port, col.names = c("x", "y", "z", ".class"))
dsd
#> Data Stream from Connection (d = 3, k = NA) 
#> Class: DSD_ReadStream, DSD_R, DSD 
#> connection: ->localhost:16725 (opened)

get_points(dsd, n = 10)
#>            x         y         z .class
#> 1  0.4658657 0.4604973 0.9296295      3
#> 2  0.7774414 0.7195617 0.9330988      1
#> 3  0.8118455 0.6286028 0.8818273      1
#> 4  0.7942356 0.6071393 0.9607249      1
#> 5  0.8022842 0.6991123 0.9313996      1
#> 6  0.8000235 0.6214970 0.8433864      1
#> 7  0.3637159 0.1501603 0.5301324      2
#> 8  0.4878353 0.4743403 0.9498714      3
#> 9  0.8184675 0.5979035 0.8849015      1
#> 10 0.4307048 0.4037073 0.9727788      3

plot(dsd)


close_stream(dsd)

# end the DSD process. Note: that closing the connection above
# may already kill the process.
if (rp1$is_alive()) rp1$kill()
#> [1] TRUE
rp1
#> PROCESS 'R', finished.
```
