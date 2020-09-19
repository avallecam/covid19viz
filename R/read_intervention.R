#' @title import mobility and intervention global data
#'
#' @description import mobility google reports, acasp and unesco data on interventions
#'
#' @describeIn read_google_global import google mobility reports
#'
#' @import tidyverse
#' @import readr
#' @import rio
#'
#' @return import external data sources on covid19 human behaviour or interventions
#'
#' @export read_google_global
#' @export read_google_region_list
#' @export read_google_region_country
#' @export read_acaps_governments
#' @export read_unesco_education
#'
#' @examples
#'
#' \dontrun{
#'
#' library(covid19viz)
#' library(tidyverse)
#'
#' # google mobility reports
#'
#' # global
#' read_google_global()
#'
#' # regional
#' # first: select country ISO
#' read_google_region_list()
#'
#' # second: read specific country data
#' peru <- read_google_region_country(country_iso = "PE")
#' peru %>% count(sub_region_1)
#'
#' # acaps data
#' read_acaps_governments()
#'
#' # unesco education data
#' read_unesco_education()
#'
#' }
#'

read_google_global <- function() {
  # source: https://www.google.com/covid19/mobility/
  readr::read_csv("https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv")
}

#' @describeIn read_google_global print list of files inside regional zip file
#' @inheritParams read_google_global

read_google_region_list <- function() {
  # source: https://www.google.com/covid19/mobility/
  url <- "https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip"
  # Generamos dos objetos temporales: un archivo y una carpeta
  tempfile <- tempfile() ; tempdir <- tempdir()
  # download zip
  curl::curl_download(url = url, destfile = tempfile)
  #unzip
  archivos <- utils::unzip(zipfile = tempfile,list = T)

  archivos %>%
    as_tibble() %>%
    mutate(country_iso=str_replace(Name,"^(....)_(..)_(.+)","\\2")) %>%
    select(country_iso,everything()) %>%
    print(n=Inf)
}

#' @describeIn read_google_global import regional mobility data for one country
#' @inheritParams read_google_global
#' @param country_iso two letter iso code for each country available in read_google_region_list()

read_google_region_country <- function(country_iso="PE") {
  # source: https://www.google.com/covid19/mobility/
  url <- "https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip"
  # Generamos dos objetos temporales: un archivo y una carpeta
  tempfile <- tempfile() ; tempdir <- tempdir()
  # download zip
  curl::curl_download(url = url, destfile = tempfile)
  #unzip
  archivos <- utils::unzip(zipfile = tempfile,list = T)
  # create iso
  archivos_out <- archivos %>%
    as_tibble() %>%
    mutate(country_iso=str_replace(Name,"^(....)_(..)_(.+)","\\2")) %>%
    # select(country_iso,everything())
    filter(country_iso=={{country_iso}}) %>%
    pull(Name)
  # read data
  regiondata <- readr::read_csv(utils::unzip(zipfile = tempfile, files = archivos_out, exdir = tempdir))
  return(regiondata)
}

#' @describeIn read_google_global import acaps dataset
#' @inheritParams read_google_global

read_acaps_governments <- function() {
  # source: https://www.acaps.org/covid19-government-measures-dataset
  rio::import(file = "https://www.acaps.org/sites/acaps/files/resources/files/acaps_covid19_government_measures_dataset.xlsx",which = 2) %>% as_tibble()
}

#' @describeIn read_google_global import unesco dataset
#' @inheritParams read_google_global

read_unesco_education <- function() {
  # source: https://en.unesco.org/covid19/educationresponse
  readr::read_csv("https://en.unesco.org/sites/default/files/covid_impact_education.csv")
}
