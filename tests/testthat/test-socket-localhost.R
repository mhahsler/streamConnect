# Tests default and explicit hosts, connection failure messages, and real
# socket streaming with process cleanup. These tests are skipped on CRAN.

test_that("socket readers respect the default and explicit hosts", {
  skip_on_cran()
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  connected_host <- NULL
  local_mocked_bindings(
    socketConnection = function(host, port, server, open, ...) {
      connected_host <<- host
      textConnection(c("1,2,1", "3,4,2", "5,6,1"))
    },
    .package = "base"
  )

  for (host in list(NULL, "remote.example")) {
    args <- list(port = 8000, col.names = c("x", "y", ".class"))
    if (!is.null(host)) args$host <- host
    reader <- do.call(DSD_ReadSocket, args)
    tryCatch({
      expect_identical(connected_host, if (is.null(host)) "127.0.0.1" else host)
      points <- get_points(reader, n = 3)
      expect_equal(points, data.frame(x = c(1, 3, 5), y = c(2, 4, 6),
                                     .class = c(1, 2, 1)))
    }, finally = close_stream(reader))
  }
})

test_that("socket connection failures retain the host and underlying error", {
  skip_on_cran()
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  attempts <- 0L
  local_mocked_bindings(
    socketConnection = function(...) {
      attempts <<- attempts + 1L
      stop("connection refused")
    },
    .package = "base"
  )

  expect_error(
    DSD_ReadSocket(port = 8000, retry_args = list(times = 2, wait = 0)),
    "Opening DSD_ReadSocket (127.0.0.1:8000) failed after 2 tries. Last error: connection refused.",
    fixed = TRUE
  )
  expect_identical(attempts, 2L)
})

test_that("a real socket publisher streams data to the default reader", {
  skip_on_cran()
  skip_if_not_installed("httpuv")
  port <- tryCatch(httpuv::randomPort(), error = function(e) NA_integer_)
  skip_if(is.na(port), "Local port binding is unavailable")

  # Bound the whole workflow, including startup and reads, in a subprocess.
  result <- callr::r(function(reader, publisher, port) {
    library(stream)
    values <- data.frame(x = 1:20, y = 21:40)
    process <- publisher(DSD_Memory(values, loop = TRUE), port = port)
    on.exit(if (process$is_alive()) process$kill(), add = TRUE)
    dsd <- reader(port = port, col.names = c("x", "y"),
                  retry_args = list(times = 5, wait = 0.1))
    points <- tryCatch(get_points(dsd, n = 5), finally = close_stream(dsd))
    if (process$is_alive()) process$kill()
    list(points = points, alive = process$is_alive())
  }, args = list(reader = DSD_ReadSocket, publisher = publish_DSD_via_Socket,
                 port = port), timeout = 20)

  expect_equal(result$points, data.frame(x = as.numeric(1:5), y = as.numeric(21:25)))
  expect_false(result$alive)
})
