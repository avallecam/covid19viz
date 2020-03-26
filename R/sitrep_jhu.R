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
#' @export jhu_sitrep_filter
#' @export jhu_sitrep_cumulative
#' @export jhu_sitrep_all_sources
#' @export jhu_sitrep_all_sources_tidy
#' @export jhu_sitrep_country_report
#' @export jhu_sitrep_cleandb_country_only
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
#' jhu_sitrep %>%
#'   jhu_sitrep_cleandb_country_only() %>%
#'   filter(country_region=="Australia") %>%
#'   avallecam::print_inf()
#'
#' jhu_sitrep_import(source = "confirmed") %>%
#'   jhu_sitrep_cleandb() %>%
#'   jhu_sitrep_filter(country_region="all") %>%
#'   jhu_sitrep_cumulative()
#'
#' jhu_sitrep_all_sources(country_region="Peru")
#'
jhu_sitrep_import <- function(source) {
  if (source=="confirmed") {
    path_start <- "https://raw.github.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
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
    path_start <- "https://raw.github.com/CSSEGISandData/COVID-19/master/csse_covid_19_data//time_series_covid19_deaths_global.csv"
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

jhu_sitrep_filter <- function(data,country_region="all") {
  if (country_region!="all") {
    data_filter <- data %>%
      filter(country_region=={{country_region}})
  } else {
    data_filter <- data
  }
  data_filter
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import
#' @param country_region input country name in english

jhu_sitrep_cumulative <- function(data) {
  data %>%
    group_by(country_region) %>%
    filter(dates==last(dates)) %>%
    ungroup() %>%
    summarise(tot_value=sum(value,na.rm = T)) %>%
    pull(tot_value)
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import

jhu_sitrep_all_sources <- function(country_region="all") {
  expand_grid(country_region={{country_region}},
              source=c("confirmed","deaths","recovered")) %>%
    # group_by(country_region,source) %>%
    # nest() %>%
    mutate(data=map(.x = source,.f = jhu_sitrep_import)) %>%
    mutate(data_clean=map(.x = data,.f = jhu_sitrep_cleandb)) %>%
    mutate(data_filter=pmap(.l = select(.,data=data_clean,country_region),
                            .f = jhu_sitrep_filter)) %>%
    mutate(sum_data=map_dbl(.x = data_filter,
                            .f = jhu_sitrep_cumulative)) %>%
    select(-data,-data_clean)
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import
#' @param data_filter default from jhu_sitrep_all_sources output

jhu_sitrep_all_sources_tidy <- function(data,data_filter=data_filter) {
  data %>%
    pull({{data_filter}}) %>%
    purrr::reduce(.f = full_join) %>%
    pivot_wider(id_cols = -source,names_from = source,values_from = value) %>%
    #aqui se agregan los valores por pais
    group_by(country_region,dates) %>%
    summarise_at(.vars = vars(confirmed,deaths,recovered),.funs = sum, na.rm=TRUE) %>%
    ungroup() %>%
    #continua
    mutate(confirmed_incidence=confirmed-lag(confirmed,default = 0),
           deaths_incidence=deaths-lag(deaths,default = 0),
           recovered_incidence=recovered-lag(recovered,default = 0)) %>%
    rename_at(.vars = vars(confirmed,deaths,recovered),.funs = ~str_replace(.x,"(.+)","\\1_cumulative")) %>%
    rename(date=dates)
    #%>%
    #mutate(province_state=if_else(is.na(province_state),"All country",province_state))
}

#' @describeIn jhu_sitrep_import clean jhu dataset
#' @inheritParams jhu_sitrep_import

jhu_sitrep_country_report <- function(country_region="Peru") {
  data_input <- jhu_sitrep_all_sources(country_region={{country_region}}) %>%
    jhu_sitrep_all_sources_tidy() %>%
    filter(confirmed_cumulative>0)

  f1 <- data_input %>%
    who_sitrep_ggline(y_cum_value = confirmed_cumulative,#color = province_state,
                      n_breaks = 10) #+
    #theme(legend.position="none")

  f2 <- data_input %>%
    who_sitrep_ggbar(y_inc_value = confirmed_incidence,#fill = province_state,
                     n_breaks=10) #+
    #theme(legend.position="none")

  f1 + f2
}

#' @describeIn jhu_sitrep_import import only numbers for the country
#' @inheritParams jhu_sitrep_import

jhu_sitrep_cleandb_country_only <- function(data) {
  data %>%
    pivot_longer(cols = -c(source,`Province/State`,`Country/Region`,Lat,Long),
                 names_to = "dates",values_to = "value") %>%
    janitor::clean_names() %>%
    mutate(dates=lubridate::mdy(dates)) %>%
    select(source,country_region,province_state,everything()) %>%
    group_by(source,country_region,dates) %>%
    summarise_at(.vars = vars(value),.funs = sum, na.rm=TRUE) %>%
    ungroup()
}

