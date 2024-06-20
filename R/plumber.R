
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

run_plumber_task_file <-
  function(task_file,
    port,
    serve = TRUE,
    background = TRUE,
    debug = FALSE
    ) {
    if (debug) {
      message("The plumber script was written to: ", task_file)
      plumber::pr_run(plumber::pr(task_file), port = port, docs = TRUE)
      return()
    }
    
    if (!serve)
      return(task_file)
      
    
    if (background) {
      pr <- callr::r_bg(function(task_file, port)
      {
        plumber::pr_run(plumber::pr(task_file), port = port, docs = FALSE)
      },
        args = list(task_file = task_file, port = port))

      Sys.sleep(1)
      if(!pr$is_alive()) {
        # check if the port was blocked
        if (inherits(try(httpuv::randomPort(min = port, max = port), 
                         silent = TRUE), "try-error")) 
          stop("port ", port, " cannot be opened.")
        
        stop(get(".Last.error"), 
             "\nRerun with 'background = FALSE' to debug the issue.")
      }
      
      return(pr)
    }
    
    ### run as main process
    plumber::pr_run(plumber::pr(task_file), port = port, docs = FALSE)
    
  }

decode_response <- function(resp) {
  ## complains about missing encoding for json
  
  switch(
    httr::http_type(resp),
    "application/json" = jsonlite::fromJSON(
      suppressMessages(httr::content(resp, as = "text")),
      simplifyVector = FALSE,
      simplifyDataFrame = TRUE,
      simplifyMatrix = FALSE
    ),
    "text/csv" = readr::read_csv(suppressMessages(httr::content(resp, as = "text")), show_col_types = FALSE),
    "application/rds" = unserialize(suppressMessages(httr::content(resp, as = "raw")))
  )
}