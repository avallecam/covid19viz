#' @title jhu sitrep data management and visualization
#'
#' @description clean and plot jhu sitrep
#'
#' @describeIn jhu_sitrep_import import data from github
#'
#' @param source string of source to use: "confirmed","deaths" or "recovered"
#'
#' @import readr
#' @import dplyr
#' @import tidyr
#' @import purrr
#'
#' @return import and cleaned jhu dataset
#'
#' @export jhu_sitrep_import
#' @export jhu_sitrep_cleandb
#' @export jhu_sitrep_cummulative
#' @export jhu_sitrep_cummulative_all_sources
#'
#' @examples
#'
#' library(covid19viz)
#' library(tidyverse)
#'
#' jhu_sitrep <- jhu_sitrep_import(source = "confirmed")
#'
#' jhu_sitrep %>%
#'   jhu_sitrep_cleandb() %>%
#'   filter(country_region=="Peru") %>%
#'   arrange(desc(dates))
#'
#' jhu_sitrep_import(source = "confirmed") %>%
#'   jhu_sitrep_cleandb() %>%
#'   jhu_sitrep_cummulative()
#'
#' jhu_sitrep_cummulative_all_sources(country_region="Peru")
#'
jhu_sitrep_import <- function(source) {
  if (source=="confirmed") {
    path_start <- "https://raw.github.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
    jhu_sitrep <- read_csv(file = path_start) %>%
      mutate(source=source) %>%
      select(source,everything())
  }

  if (source=="deaths") {
    path_start <- "https://raw.github.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
    jhu_sitrep <- read_csv(file = path_start) %>%
      mutate(source=source) %>%
      select(source,everything())
  }

  if (source=="recovered") {
    path_start <- "https://raw.github.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
    jhu_sitrep <- read_csv(file = path_start) %>%
      mutate(source=source) %>%
      select(source,everything())
  }
  jhu_sitrep
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import
#' @param data input of raw jhu dataset

jhu_sitrep_cleandb <- function(data) {
  data %>%
    pivot_longer(cols = -c(source,`Province/State`,`Country/Region`,Lat,Long),
                 names_to = "dates",values_to = "value") %>%
    janitor::clean_names() %>%
    mutate(dates=lubridate::mdy(dates)) %>%
    select(source,country_region,province_state,everything())
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import
#' @param country_region input country name in english

jhu_sitrep_cummulative <- function(data,country_region="all") {
  if (country_region!="all") {
    data_filter <- data %>%
      filter(country_region=={{country_region}})
  } else {
    data_filter <- data
  }
  data_filter %>%
    group_by(country_region) %>%
    filter(dates==last(dates)) %>%
    ungroup() %>%
    summarise(tot_value=sum(value)) %>%
    pull(tot_value)
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import

jhu_sitrep_cummulative_all_sources <- function(country_region="all") {
  expand_grid(country_region={{country_region}},
              source=c("confirmed","deaths","recovered")) %>%
    mutate(data=map(.x = source,.f = jhu_sitrep_import)) %>%
    mutate(data_clean=map(.x = data,.f = jhu_sitrep_cleandb)) %>%
    mutate(sum_data=pmap_dbl(.l = select(.,data=data_clean,country_region),
                             .f = jhu_sitrep_cummulative))
}
