# Tests CSV/JSON/RDS decoding, HTTP errors, malformed payloads, child-process
# diagnostics, generated scripts, and single-POST updates with upload cleanup.
# Uses mocks without network connections; these tests run on CRAN.

make_response <- function(content_type, content, status = 200L) {
  structure(
    list(
      url = "http://example.invalid/",
      status_code = as.integer(status),
      headers = list(`Content-Type` = content_type),
      all_headers = list(),
      cookies = data.frame(),
      content = content
    ),
    class = "response"
  )
}

test_that("web service responses decode CSV, JSON, and RDS payloads", {
  csv_response <- make_response("text/csv", charToRaw("x,y\n1,2\n"))
  json_response <- make_response("application/json", charToRaw('[{"x":1,"y":2}]'))
  value <- data.frame(x = 1, y = 2)
  rds_response <- make_response("application/rds", serialize(value, NULL))

  csv <- streamConnect:::decode_response(csv_response)
  expect_named(csv, c("x", "y"))
  expect_equal(dim(csv), c(1L, 2L))
  expect_identical(csv$x, 1)
  expect_identical(csv$y, 2)
  expect_identical(streamConnect:::decode_response(json_response),
                   data.frame(x = 1L, y = 2L))
  expect_equal(streamConnect:::decode_response(rds_response), value)
})

test_that("empty-center error responses are recognized", {
  expect_true(streamConnect:::.check_error(data.frame(error = "0 centers")))
  expect_false(streamConnect:::.check_error(data.frame(x = 1)))
  expect_false(streamConnect:::.check_error(data.frame(error = c("a", "b"))))
})

test_that("publishers can write deployable plumber scripts without starting servers", {
  dsd_file <- tempfile(fileext = ".R")
  dsc_file <- tempfile(fileext = ".R")
  on.exit(unlink(c(dsd_file, dsc_file)))

  expect_identical(
    publish_DSD_via_WebService("DSD_Gaussians(k = 2)", port = 8000,
                               task_file = dsd_file, serve = FALSE),
    dsd_file
  )
  expect_identical(
    publish_DSC_via_WebService("DSC_DBSTREAM(r = .05)", port = 8000,
                               task_file = dsc_file, serve = FALSE),
    dsc_file
  )

  dsd_script <- readLines(dsd_file)
  dsc_script <- readLines(dsc_file)
  expect_true(any(grepl("DSD_Gaussians(k = 2)", dsd_script, fixed = TRUE)))
  expect_true(any(grepl("DSC_DBSTREAM(r = .05)", dsc_script, fixed = TRUE)))
  expect_true(any(grepl("/get_points", dsd_script, fixed = TRUE)))
  expect_true(any(grepl("/get_centers", dsc_script, fixed = TRUE)))
})

test_that("decoding rejects HTTP errors before reading their payloads", {
  for (status in c(400L, 404L, 500L, 503L)) {
    response <- make_response("application/rds", charToRaw("invalid RDS"), status)
    expect_error(streamConnect:::decode_response(response), class = "http_error")
  }
})

test_that("decoding rejects unsupported and malformed payloads", {
  expect_error(
    streamConnect:::decode_response(make_response("text/plain", charToRaw("hello"))),
    "Unsupported response content type: text/plain", fixed = TRUE
  )
  expect_error(streamConnect:::decode_response(
    make_response("application/json", charToRaw("{invalid"))
  ))
  expect_error(streamConnect:::decode_response(
    make_response("application/rds", charToRaw("invalid RDS"))
  ))
})

test_that("process startup diagnostics preserve child errors and stderr", {
  expect_identical(streamConnect:::process_error_message(list(
    get_result = function() stop("child startup failed"),
    read_all_error = function() stop("must not read stderr")
  )), "child startup failed")
  expect_identical(streamConnect:::process_error_message(list(
    get_result = function() NULL,
    read_all_error = function() "child stderr"
  )), "child stderr")
  expect_identical(streamConnect:::process_error_message(list(
    get_result = function() NULL,
    read_all_error = function() stop("stderr unavailable")
  )), "No error details were reported by the process.")
})

test_that("web service clients report HTTP failures", {
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  local_mocked_bindings(
    RETRY = function(...) make_response("text/plain", charToRaw("failed"), 503L),
    .package = "httr"
  )
  expect_error(DSD_ReadWebService("http://example.invalid"), class = "http_error")
  expect_error(DSC_WebService("http://example.invalid"), class = "http_error")
})

test_that("clusterer updates POST once and clean uploads on every outcome", {
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  object <- structure(list(url = "http://example.invalid"), class = "DSC_WebService")
  for (outcome in c("success", "http_error", "connection_error")) {
    calls <- 0L
    upload_path <- NULL
    local_mocked_bindings(
      POST = function(url, body, ...) {
        calls <<- calls + 1L
        upload_path <<- body$upload$path
        expect_identical(url, "http://example.invalid/update")
        expect_true(file.exists(upload_path))
        expect_equal(read.csv(upload_path), data.frame(x = 1:3, y = 4:6))
        if (outcome == "connection_error") stop("connection lost")
        make_response("text/plain", raw(),
                      if (outcome == "http_error") 500L else 200L)
      },
      .package = "httr"
    )
    dsd <- DSD_Memory(data.frame(x = 1:3, y = 4:6))
    if (outcome == "success") {
      expect_s3_class(update(object, dsd, n = 3), "response")
    } else if (outcome == "http_error") {
      expect_error(update(object, dsd, n = 3), class = "http_error")
    } else {
      expect_error(update(object, dsd, n = 3), "connection lost", fixed = TRUE)
    }
    expect_identical(calls, 1L)
    expect_false(file.exists(upload_path))
  }
})
