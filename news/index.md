# Changelog

## streamConnect 0.0.7 (unpublished)

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
