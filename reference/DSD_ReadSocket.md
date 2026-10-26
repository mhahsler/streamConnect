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
if (has_localhost_server(port = 8000)) {
  # find a free port
  port <- httpuv::randomPort()
  port

  # create a background DSD process sending data to the port
  rp1 <- DSD_Gaussians(k = 3, d = 3) %>% publish_DSD_via_Socket(port = port)
  rp1

  # create a DSD that connects to the socket. Note that we need to
  # specify the column names of the stream
  dsd <- DSD_ReadSocket(port = port, col.names = c("x", "y", "z", ".class"))
  dsd

  get_points(dsd, n = 10)

  plot(dsd)

  close_stream(dsd)

  # end the DSD process. Note: that closing the connection above
  # may already kill the process.
  if (rp1$is_alive()) rp1$kill()
  rp1
} else {
  message("localhost not available, example skipped.")
}

#> PROCESS 'R', finished.
```
