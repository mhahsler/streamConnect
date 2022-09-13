
complete_plumber_task_file <- function(template, task_file, ...) {
  if (is.null(task_file))
    task_file <- tempfile(pattern = "plumber_", fileext = ".R")
  
  env <- list2env(list(...))
  env$task_file <- task_file
  
  readr::write_file(stringr::str_interp(paste0(
    readr::read_lines(system.file(paste0(
      "plumber/", template
    ), package = "streamConnect")), collapse = '\n'
  ), env = env), file = task_file)
  
  task_file
}

run_plumber_task_file <- function(task_file, port, debug = FALSE, serve = TRUE) {
  if (debug) {
    cat("The plumber script can be found here:", task_file, "\n")
    file.show(task_file)
    plumber::pr_run(plumber::pr(task_file), port = port, docs = TRUE)
    return()
  }
  
  if (serve)
    callr::r_bg(function(task_file, port)
    {
      plumber::pr_run(plumber::pr(task_file), port = port, docs = FALSE)
    },
      args = list(task_file = task_file, port = port))
  else
    cat("plumber script written to", task_file, "\n")
}

decode_response <- function(resp) {
## complains about missing encoding for json
  suppressMessages(d <- httr::content(resp, as = "text"))
  switch(
    httr::http_type(resp),
    "application/json" = jsonlite::fromJSON(
      d,
      simplifyVector = FALSE,
      simplifyDataFrame = TRUE,
      simplifyMatrix = FALSE
    ),
    "text/csv" = readr::read_csv(d, show_col_types = FALSE)
  )
}