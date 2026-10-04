# R package streamConnect - Connecting Stream Mining Components Using Sockets and Web Services

[![Package on
CRAN](https://www.r-pkg.org/badges/version/streamConnect)](https://CRAN.R-project.org/package=streamConnect)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/streamConnect)](https://CRAN.R-project.org/package=streamConnect)
![License](https://img.shields.io/cran/l/streamConnect)[![r-universe
status](https://mhahsler.r-universe.dev/badges/streamConnect)](https://mhahsler.r-universe.dev/streamConnect)

**Maintainer:** [Michael Hahsler](https://michael.hahsler.net)

The R package is part of the
[stream](https://michael.hahsler.net/stream) ecosystem. It adds
functionality to connect stream mining components from the `stream`
package using sockets and Web services. The package can be used to
create distributed workflows and plumber-based Web services that can be
deployed on most common cloud services.

To cite package ‘streamConnect’ in publications use:

> Hahsler M (????). *streamConnect: Connecting Stream Mining Components
> Using Sockets and Web Services*. R package version 0.0.7,
> <http://michael.hahsler.net/streamConnect/>.

``` R
@Manual{,
  title = {streamConnect: Connecting Stream Mining Components Using Sockets and Web Services},
  author = {Michael Hahsler},
  note = {R package version 0.0.7},
  url = {http://michael.hahsler.net/streamConnect/},
}
```

## Installation

**Stable CRAN version:** Install from within R with

``` r

install.packages("streamConnect")
```

**Current development version:** Install from
[r-universe.](https://mhahsler.r-universe.dev/streamConnect)

``` r

install.packages("streamConnect",
    repos = c("https://mhahsler.r-universe.dev",
              "https://cloud.r-project.org/"))
```

## Examples

See the [Getting Started with
streamConnect](https://michael.hahsler.net/streamConnect/articles/streamConnect.html)
vignette for examples.

## Acknowledgements

The development of the stream package was supported in part by NSF CMMI
1728612.

## References

Michael Hahsler, Matthew Bolaños, and John Forrest. [stream: An
extensible framework for data stream clustering research with
R.](https://dx.doi.org/10.18637/jss.v076.i14) *Journal of Statistical
Software,* 76(14), February 2017.
