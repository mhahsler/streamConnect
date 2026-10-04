
complete_plumber_task_file <- function(template, task_file, ...) {
  if (is.null(task_file))
    task_file <- tempfile(pattern = "plumber_", fileext = ".R")
  
  env <- list2env(list(...))
  env$task_file <- task_file
  
  task <- stringr::str_interp(paste0(
    readr::read_lines(system.file(paste0(
      "plumber/", template
    ), package = "streamConnect")), collapse = '\n'
  ), env = env)
  readr::write_file(paste0(task, "\n"), file = task_file)
  
  task_file
}

process_error_message <- function(process) {
  result <- tryCatch(
    process$get_result(),
    error = function(e) conditionMessage(e)
  )

  if (is.character(result) && length(result) && nzchar(result[1]))
    return(paste(result, collapse = "\n"))

  error_output <- tryCatch(process$read_all_error(), error = function(e) "")
  if (nzchar(error_output))
    return(error_output)

  "No error details were reported by the process."
}

run_plumber_task_file <-
  function(task_file,
    port,
    serve = TRUE,
    background = TRUE,
    debug = FALSE
    ) {
    if (debug) {
      message("The plumber script was written to: ", task_file)
      plumber::pr_run(plumber::plumb(task_file), port = port, docs = TRUE)
      return()
    }
    
    if (!serve)
      return(task_file)
      
    
    if (background) {
      pr <- callr::r_bg(function(task_file, port)
      {
        plumber::pr_run(plumber::plumb(task_file), port = port, docs = FALSE)
      },
        args = list(task_file = task_file, port = port))

      Sys.sleep(1)
      
      # check if we can get a response for info on the port.
      resp <-
        httr::RETRY("GET", stringr::str_interp("http://localhost:${port}/info"), 
                    quiet = TRUE)
      if (httr::http_error(resp)) {
        response_error <- tryCatch(
          httr::stop_for_status(resp),
          error = function(e) conditionMessage(e)
        )

        if (!pr$is_alive()) {
          stop("Failed to start the Web service:\n",
               response_error, "\n", process_error_message(pr))
        }

        pr$kill()
        stop("Failed to start the Web service:\n", response_error)
      }
      
      # process should still be running.
      if(!pr$is_alive()) {
        # check if the port was blocked
        if (inherits(try(httpuv::randomPort(min = port, max = port), 
                         silent = TRUE), "try-error")) 
          stop("port ", port, " cannot be opened. Already in use?")
        
        stop("The Web service process exited during startup:\n",
             process_error_message(pr),
             "\nRerun with 'background = FALSE' to debug the issue.")
      }
      
      return(pr)
    }
    
    ### run as main process
    plumber::pr_run(plumber::pr(task_file), port = port, docs = FALSE)
    
  }

decode_response <- function(resp) {
  httr::stop_for_status(resp)

  content_type <- httr::http_type(resp)
  ## complains about missing encoding for json
  
  switch(
    content_type,
    "application/json" = jsonlite::fromJSON(
      suppressMessages(httr::content(resp, as = "text")),
      simplifyVector = FALSE,
      simplifyDataFrame = TRUE,
      simplifyMatrix = FALSE
    ),
    "text/csv" = readr::read_csv(I(suppressMessages(httr::content(resp, as = "text"))), show_col_types = FALSE),
    "application/rds" = unserialize(suppressMessages(httr::content(resp, as = "raw"))),
    stop("Unsupported response content type: ", content_type)
  )
}
