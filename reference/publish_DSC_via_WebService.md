# Publish a Data Stream Clustering Task via a Web Service

Uses the package plumber to publish a data stream task as a web service.

## Usage

``` r
publish_DSC_via_WebService(
  dsc,
  port,
  task_file = NULL,
  serializer = "csv",
  serve = TRUE,
  background = TRUE,
  debug = FALSE
)
```

## Arguments

- dsc:

  A character string that creates a DSC.

- port:

  port used to serve the task.

- task_file:

  name of the plumber task script file.

- serializer:

  method used to serialize the data. By default, `csv` (comma-separated
  values) is used. Other methods are `json` and `rds` (see
  [plumber::serializer_csv](https://www.rplumber.io/reference/serializers.html)).

- serve:

  if `TRUE`, then a task file is written and a server started,
  otherwise, only a plumber task file is written.

- background:

  logical; start a background process?

- debug:

  if `TRUE`, then the service is started locally and a web client is
  started to explore the interface.

## Value

a [processx::process](http://processx.r-lib.org/reference/process.md)
object created with
[`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html) which
runs the plumber server in the background. The process can be stopped
with `rp$kill()` or by killing the process using the operating system
with the appropriate PID. `rp$get_result()` can be used to check for
errors in the server process (e.g., when it terminates unexpectedly).

## Details

The function writes a plumber task script file and starts the web server
to serve the content of the stream using the endpoints

- GET `/info`

- POST `/update` requires the data to be uploaded as a file in csv
  format (see Examples section).

- GET `/get_centers` with parameter `type` (see
  [`stream::get_centers()`](https://rdrr.io/pkg/stream/man/DSC.html)).

- GET `/get_weights` with parameter `type` (see
  [`stream::get_weights()`](https://rdrr.io/pkg/stream/man/DSC.html)).

Supported serializers are `csv` (default), `json`, and `rds`.

APIs generated using plumber can be easily deployed. See:
[Hosting](https://www.rplumber.io/articles/hosting.html). By setting a
`task_file` and `serve = FALSE` a plumber task script file is generated
for deployment.

## See also

Other WebService:
[`DSC_WebService()`](https://michael.hahsler.net/streamConnect/reference/DSC_WebService.md),
[`DSD_ReadWebService()`](https://michael.hahsler.net/streamConnect/reference/DSD_ReadWebService.md),
[`publish_DSD_via_WebService()`](https://michael.hahsler.net/streamConnect/reference/publish_DSD_via_WebService.md)

Other dsc:
[`DSC_WebService()`](https://michael.hahsler.net/streamConnect/reference/DSC_WebService.md)

## Examples

``` r
if (has_localhost_server(port = 8000)) {
  # find a free port
  port <- httpuv::randomPort()
  port

  # Deploy a clustering process listening for data on the port
  rp1 <- publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", port = port)
  rp1

  # look at ? DSC_WebService for a convenient interface.
  # Here we we show how to connect to the port and send data manually.
  library(httr)

  # the info verb returns some basic information about the clusterer.
  resp <- RETRY("GET", paste0("http://localhost:", port, "/info"))
  d <- content(resp, show_col_types = FALSE)
  d

  # create a local data stream and send it to the clusterer using the update verb.
  dsd <- DSD_Gaussians(k = 3, d = 2, noise = 0.05)

  tmp <- tempfile()
  stream::write_stream(dsd, tmp, n = 500, header = TRUE)
  resp <- POST(paste0("http://localhost:", port, "/update"),
    body = list(upload = upload_file(tmp)))
  unlink(tmp)
  resp

  # retrieve the cluster centers using the get_centers verb
  resp <- GET(paste0("http://localhost:", port, "/get_centers"))
  d <- content(resp, show_col_types = FALSE)
  head(d)

  plot(dsd, n = 100)
  points(d, col = "red", pch = 3, lwd = 3)

  # kill the process.
  rp1$kill()
  rp1

  # Debug the interface (run the service and start a web interface)
  if (interactive())
    publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)",
           port = port, debug = TRUE)
} else {
  message("localhost not available, example skipped.")
}
#> 
#> Attaching package: ‘httr’
#> The following object is masked from ‘package:stream’:
#> 
#>     write_stream
```
