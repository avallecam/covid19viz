
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covid19viz

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/covid19viz)](https://cran.r-project.org/package=covid19viz)
<!-- badges: end -->

The goal of `covid19viz` is to access and summarize WHO sitreps for
covid-19 in simple graphics.

This package works using two data repositories:

  - digitalized WHO sitreps by [Fabienne
    Krauer](https://twitter.com/FabiKrauer) available in
    [fkrauer/COVID-19](https://github.com/fkrauer/COVID-19).

  - Johns Hopkins University (JHU CSSE) available in
    [CSSEGISandData/COVID-19](https://github.com/CSSEGISandData/COVID-19).

## Installation

<!--
You can install the released version of covid19viz from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("covid19viz")
```
-->

You can install the development version of `covid19viz` using:

``` r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("avallecam/covid19viz")
```

## Quick Example

### with WHO sitreps

``` r
library(covid19viz)

# paste last update available at
# https://github.com/fkrauer/COVID-19
update <- "2020-03-10"

# apply
who_sitrep_country_report(
  update = update,
  country_region = "Brazil")
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

### with JHU collection

``` r
library(covid19viz)
library(tidyverse)

#import all data at once
jhu_sitrep_peru <- jhu_sitrep_all_sources(country_region="Peru")

jhu_sitrep_peru
#> # A tibble: 3 x 4
#>   country_region source    data_filter       sum_data
#>   <chr>          <chr>     <list>               <dbl>
#> 1 Peru           confirmed <tibble [56 x 7]>      117
#> 2 Peru           deaths    <tibble [56 x 7]>        0
#> 3 Peru           recovered <tibble [56 x 7]>        1

#transform to tidy format
jhu_sitrep_peru %>% 
  jhu_sitrep_all_sources_tidy() %>% 
  arrange(desc(confirmed_cumulative)) %>% 
  glimpse()
#> Observations: 56
#> Variables: 11
#> $ country_region       <chr> "Peru", "Peru", "Peru", "Peru", "Peru", "...
#> $ province_state       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ lat                  <dbl> -9.19, -9.19, -9.19, -9.19, -9.19, -9.19,...
#> $ long                 <dbl> -75.0152, -75.0152, -75.0152, -75.0152, -...
#> $ date                 <date> 2020-03-17, 2020-03-16, 2020-03-15, 2020...
#> $ confirmed_cumulative <dbl> 117, 86, 43, 38, 28, 15, 11, 11, 7, 6, 1,...
#> $ deaths_cumulative    <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
#> $ recovered_cumulative <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
#> $ confirmed_incidence  <dbl> 31, 43, 5, 10, 13, 4, 4, 0, 1, 5, 1, 0, 0...
#> $ deaths_incidence     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
#> $ recovered_incidence  <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
```

``` r
jhu_sitrep_country_report(country_region = "Peru")
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" style="display: block; margin: auto;" />
