# Publish a Data Stream using a Socket

Creates a socket server connection to send stream data.

## Usage

``` r
publish_DSD_via_Socket(dsd, port, blocksize = 1024L, background = TRUE, ...)
```

## Arguments

- dsd:

  A DSD object.

- port:

  port used to serve the DSD.

- blocksize:

  number of data points pushed on the buffer at once.

- background:

  logical; start a background process?

- ...:

  further arguments are passed on to
  [`socketConnection()`](https://rdrr.io/r/base/connections.html).

## Value

a [processx::process](http://processx.r-lib.org/reference/process.md)
object created with
[`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html) which
runs the plumber server in the background. The process can be stopped
with `rp$kill()` or by killing the process using the operating system
with the appropriate PID. `rp$get_result()` can be used to check for
errors in the server process (e.g., when it terminates unexpectedly).

## Details

Creates a server socket with
[`socketConnection()`](https://rdrr.io/r/base/connections.html) and then
uses a
[`stream::write_stream()`](https://rdrr.io/pkg/stream/man/write_stream.html)
to write data to a socket connection. This method does not provide a
header for the data.

## See also

Other Socket:
[`DSD_ReadSocket()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadSocket.md)

Other dsd:
[`DSD_ReadSocket()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadSocket.md),
[`DSD_ReadWebService()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md),
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

  # connect to the port (retry waits for the socket to establish)
  con <- retry(socketConnection(port = port, open = 'r'))
  dsd <- retry(DSD_ReadStream(con, col.names = c("x", "y", "z", ".class")))

  get_points(dsd, n = 10)

  plot(dsd)

  # close connection
  close_stream(dsd)

  # end the DSD process. Note: that closing the connection above
  # may already kill the process.
  rp1$kill()
  rp1
} else {
  message("localhost not available, example skipped.")
}

#> PROCESS 'R', finished.
```
