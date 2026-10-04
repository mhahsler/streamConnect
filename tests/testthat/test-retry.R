test_that("retry returns the value of a successful expression", {
  expect_equal(retry(1 + 1, times = 1), 2)
})

test_that("retry keeps trying until the expression succeeds", {
  attempts <- 0L
  result <- retry({
    attempts <- attempts + 1L
    if (attempts < 3L) stop("not ready")
    "ready"
  }, times = 3, wait = 0)

  expect_identical(result, "ready")
  expect_identical(attempts, 3L)
})

test_that("retry reports the operation and number of attempts on failure", {
  expect_error(
    retry(stop("still unavailable"), times = 2, wait = 0,
          operation = "Connecting to test service"),
    "Connecting to test service failed after 2 tries. Last error: still unavailable"
  )
})
