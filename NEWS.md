# arules 0.0-6.1 (xx/xx/2024)

## Changes 
* starting a web service with plumber now tries if the service is up before
  returning.

# arules 0.0-6 (06/20/2024)

## Changes
* Added error messages for running servers in the background.
* Added support to get verbose output from curl.
* Added processx to suggested packages (is used by plumber and we 
  have it in the man page).
* Improved retry code.

# arules 0.0-2 (05/18/2024)

## Changes
* added retry to avoid issues with sockets not being established.

# arules 0.0-1 (05/16/2024)

Initial CRAN release