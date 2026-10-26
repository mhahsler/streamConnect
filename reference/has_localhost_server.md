# Check Whether a Localhost Server Can Be Used

Temporarily opens a server socket and connects to it through
`localhost`. Both sockets are closed after the check. No existing server
is required.

## Usage

``` r
has_localhost_server(port = 8000)
```

## Arguments

- port:

  local port used for the check. An occupied port causes the check to
  return `FALSE`.

## Value

`TRUE` if the port can be opened and reached through `localhost`,
otherwise `FALSE`.
