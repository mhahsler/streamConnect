test_that("the default socket reader uses IPv4 loopback", {
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  connected_host <- NULL
  local_mocked_bindings(
    socketConnection = function(host, port, server, open) {
      connected_host <<- host
      textConnection(c("1,2,1", "3,4,2", "5,6,1"))
    },
    .package = "base"
  )

  reader <- DSD_ReadSocket(port = 8000, col.names = c("x", "y", ".class"))
  on.exit(close_stream(reader), add = TRUE)

  expect_identical(connected_host, "127.0.0.1")
  points <- get_points(reader, n = 3)
  expect_equal(points$x, c(1, 3, 5))
  expect_equal(points$y, c(2, 4, 6))
})
