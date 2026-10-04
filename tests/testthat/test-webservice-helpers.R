make_response <- function(content_type, content) {
  structure(
    list(
      url = "http://localhost/",
      status_code = 200L,
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

  expect_equal(as.numeric(as.matrix(streamConnect:::decode_response(csv_response))),
               as.numeric(as.matrix(value)))
  expect_equal(as.numeric(as.matrix(streamConnect:::decode_response(json_response))),
               as.numeric(as.matrix(value)))
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
