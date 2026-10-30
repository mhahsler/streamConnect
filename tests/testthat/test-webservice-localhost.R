# Tests starting a real local web service, reading expected stream data, and
# stopping the background process. This test is skipped on CRAN.

test_that("a real web service publishes and reads stream data", {
  skip_on_cran()
  skip_if_not_installed("httpuv")
  port <- tryCatch(httpuv::randomPort(), error = function(e) NA_integer_)
  skip_if(is.na(port), "Local port binding is unavailable")

  result <- callr::r(function(publisher, reader, port) {
    library(stream)
    task_file <- tempfile(fileext = ".R")
    on.exit(unlink(task_file), add = TRUE)
    process <- publisher(
      "DSD_Memory(data.frame(x = 1:20, y = 21:40), loop = TRUE)",
      port = port, task_file = task_file
    )
    on.exit(if (process$is_alive()) process$kill(), add = TRUE)
    remote <- reader(paste0("http://127.0.0.1:", port))
    points <- get_points(remote, n = 5)
    if (process$is_alive()) process$kill()
    list(points = points, alive = process$is_alive())
  }, args = list(publisher = publish_DSD_via_WebService,
                 reader = DSD_ReadWebService, port = port), timeout = 30)

  expect_equal(as.data.frame(result$points),
               data.frame(x = as.numeric(1:5), y = as.numeric(21:25)))
  expect_false(result$alive)
})
