# Tests immediate success, retries, exhausted attempts, final error messages,
# NULL results, and warning suppression. These tests run on CRAN.

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

test_that("retry stops immediately after success", {
  attempts <- 0L
  expect_identical(retry({
    attempts <- attempts + 1L
    "done"
  }, times = 5, wait = 0), "done")
  expect_identical(attempts, 1L)
})

test_that("retry reports the final error after exhausting attempts", {
  attempts <- 0L
  expect_error(retry({
    attempts <- attempts + 1L
    stop(paste("failure", attempts))
  }, times = 3, wait = 0, operation = "Test operation"),
  "Test operation failed after 3 tries. Last error: failure 3.", fixed = TRUE)
  expect_identical(attempts, 3L)
})

test_that("retry preserves NULL and suppresses transient warnings", {
  expect_null(retry(NULL, times = 1, wait = 0))
  expect_warning(expect_identical(retry({
    warning("transient warning")
    42L
  }, times = 1, wait = 0), 42L), NA)
})
