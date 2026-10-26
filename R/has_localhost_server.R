#' Check Whether a Localhost Server Can Be Used
#'
#' Temporarily opens a server socket and connects to it through `localhost`.
#' Both sockets are closed after the check. No existing server is required.
#'
#' @param port local port used for the check. An occupied port causes the check
#'   to return `FALSE`.
#' @return `TRUE` if the port can be opened and reached through `localhost`,
#'   otherwise `FALSE`.
#' @export
has_localhost_server <- function(port = 8000) {
  tryCatch({
    server <- serverSocket(port)
    on.exit(close(server), add = TRUE)
    client <- socketConnection(host = "localhost", port = port,
                               open = "r+", timeout = 1)
    on.exit(close(client), add = TRUE)
    TRUE
  }, warning = function(w) FALSE, error = function(e) FALSE)
}
