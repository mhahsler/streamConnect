# Retry an Expression that Fails

Retries an expression that fails. This is mainly used when establishing
a connection.

## Usage

``` r
retry(f, times = 5, wait = 1, verbose = FALSE, operation = NULL)
```

## Arguments

- f:

  expression

- times:

  integer; number of times

- wait:

  number of seconds to wait in between tries.

- verbose:

  logical; show progress and errors.

- operation:

  name of the operation used in the error message.

## Value

the result of the expression f

## Examples

``` r
retry(1)
#> [1] 1
```
