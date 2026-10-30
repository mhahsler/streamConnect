# Tests that all six port-using man page examples handle simulated warnings
# and errors, and that the vignette renders when ports are unavailable.
# These tests are skipped on CRAN.

test_that("port examples handle unavailable ports and warnings", {
  skip_on_cran()
  skip_if_not_installed("httpuv")
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  topics <- c("DSD_ReadSocket", "DSD_ReadWebService", "DSC_WebService",
              "publish_DSD_via_Socket", "publish_DSD_via_WebService",
              "publish_DSC_via_WebService")
  man_dir <- test_path("..", "..", "man")
  rd_database <- if (!dir.exists(man_dir)) tools::Rd_db("streamConnect") else NULL

  for (mode in c("error", "warning")) {
    # Fail before any server is created, even if a guard regresses.
    local_mocked_bindings(
      randomPort = function(...) {
        if (mode == "warning") warning("simulated unavailable local port")
        stop("simulated unavailable local port")
      },
      .package = "httpuv"
    )
    for (topic in topics) {
      rd <- if (is.null(rd_database)) {
        tools::parse_Rd(file.path(man_dir, paste0(topic, ".Rd")))
      } else rd_database[[paste0(topic, ".Rd")]]
      example_file <- tempfile(fileext = ".R")
      tryCatch({
        tools::Rd2ex(rd, out = example_file)
        env <- new.env(parent = asNamespace("streamConnect"))
        expect_message(
          expect_warning(eval(parse(example_file), envir = env), NA),
          paste0("localhost ", mode, ":.*simulated unavailable local port"),
          info = topic
        )
        expect_false(exists("rp1", envir = env, inherits = FALSE), info = topic)
      }, finally = unlink(example_file))
    }
  }
})

test_that("the vignette renders with unavailable local ports", {
  skip_on_cran()
  skip_if_not_installed("httpuv")
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("testthat", minimum_version = "3.2.0")
  skip_if_not(rmarkdown::pandoc_available(), "Pandoc is unavailable")
  source <- test_path("..", "..", "vignettes", "streamConnect.Rmd")
  skip_if_not(file.exists(source), "Vignette source is unavailable")
  local_mocked_bindings(
    randomPort = function(...) stop("simulated unavailable local port"),
    .package = "httpuv"
  )
  output_dir <- tempfile("vignette-no-ports-")
  dir.create(output_dir)
  on.exit(unlink(output_dir, recursive = TRUE), add = TRUE)
  input <- file.path(output_dir, "streamConnect.Rmd")
  expect_true(file.copy(source, input))
  env <- new.env(parent = globalenv())
  output <- rmarkdown::render(input, envir = env, quiet = TRUE)
  expect_true(file.exists(output))
  expect_identical(env$run_code, FALSE)
  for (name in c("socket_process", "clusterer_process", "source_process")) {
    expect_false(exists(name, envir = env, inherits = FALSE))
  }
})
