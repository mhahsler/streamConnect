# Changelog

## streamConnect 0.1.2 (10/30/2026)

- Expanded tests cover local socket and web service streaming,
  unavailable-port examples, HTTP failures, upload cleanup, and retry
  limits. Tests involving local ports or localhost examples are skipped
  on CRAN.
- Local connections use `127.0.0.1` (the IPv4 loopback address for
  localhost) by default, avoiding hostname resolution. Examples use the
  same address.
- Man page examples catch local connection warnings and errors; the
  vignette skips port-dependent code when ports are unavailable.
- Removed `has_localhost_server()`; examples now handle connection
  failures directly.

## streamConnect 0.1.1 (10/26/2026)

CRAN release: 2026-10-29

- prevent examples to be executed when localhost is unavailable (during
  CRAN testing).

## streamConnect 0.1.0 (10/22/2026)

CRAN release: 2026-10-23

### Changes

- starting a web service with plumber now tries if the service is up
  before returning.
- Background socket and web service startup failures now report errors
  from the child process, and retry failures include the final
  underlying error.
- Web service clients now report unsuccessful HTTP responses and
  unsupported response content types instead of returning incomplete
  results.
- Clusterer updates use a single POST request to avoid duplicate updates
  after uncertain failures, report unsuccessful responses, and always
  clean up the temporary upload file.

## streamConnect 0.0-6 (06/20/2024)

CRAN release: 2024-06-20

### Changes

- Added error messages for running servers in the background.
- Added support to get verbose output from curl.
- Added processx to suggested packages (used by plumber and referenced
  in the help pages).
- Improved retry code.

## streamConnect 0.0-2 (05/18/2024)

CRAN release: 2024-05-19

### Changes

- added retry to avoid issues with sockets not being established.

## streamConnect 0.0-1 (05/16/2024)

CRAN release: 2024-05-17

Initial CRAN release.
