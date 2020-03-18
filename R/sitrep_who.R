#' @title who sitrep data management and visualization
#'
#' @description clean and plot who sitrep
#'
#' @describeIn who_sitrep_import import data from github
#'
#' @param update string of date to update
#'
#' @import readr
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @import forcats
#' @import ggplot2
#' @import patchwork
#'
#' @return report per country_region using digitalized who sitreps
#'
#' @export who_sitrep_import
#' @export who_sitrep_cleandb
#' @export who_sitrep_ggline
#' @export who_sitrep_ggbar
#' @export who_sitrep_country_report
#'
#' @examples
#'
#' library(covid19viz)
#' library(tidyverse)
#'
#' who_sitrep <- who_sitrep_import(update = "2020-03-10")
#'
#' who_sitrep %>%
#'     who_sitrep_cleandb() %>%
#'     filter(country_region=="Peru")
#'
#' who_sitrep %>%
#'     who_sitrep_cleandb() %>%
#'     who_sitrep_ggline(country_region = "Peru",
#'                       y_cum_value = n_cum_conf,
#'                       color = class, n_breaks = 10)
#'

who_sitrep_import <- function(update) {
  path_file <- {{update}}
  path_start <- "https://raw.github.com/fkrauer/COVID-19/master/data/WHO_COVID19_ALL_ADM0_"
  who_sitrep <- read_csv(file = str_c(path_start,update,".csv"))
}

#' @describeIn who_sitrep_import clean who dataset
#' @inheritParams who_sitrep_import
#' @param data input of raw who dataset

who_sitrep_cleandb <- function(data) {
  data %>%
    mutate(class=fct_explicit_na(class)) %>%
    mutate_at(.vars = vars(n_cum_deaths,n_inc_conf,n_inc_deaths),.funs = ~replace_na(.x,0)) %>%
    rename(country_region=country)
}

#' @describeIn who_sitrep_import plot a ggplot geom_line
#' @inheritParams who_sitrep_import
#' @param country_region string of country_region name
#' @param y_cum_value cumulative variable
#' @param color colo of attribute
#' @param n_breaks y axis breaks

who_sitrep_ggline <- function(data,country_region="Peru",y_cum_value,color,n_breaks=5) {
  data %>%
    # mutate(class=fct_explicit_na(class)) %>%
    # mutate_at(.vars = vars(n_cum_deaths,n_inc_conf,n_inc_deaths),.funs = ~replace_na(.x,0)) %>%
    filter(country_region == {{country_region}}) %>%
    ggplot(aes(x = date,y = {{y_cum_value}},color={{color}})) +
    geom_line() +
    geom_point() +
    scale_y_continuous(breaks= scales::pretty_breaks(n = {{n_breaks}})) +
    scale_x_date(date_breaks = "1 day",date_labels = "%b-%d") +
    scale_color_viridis_d() +
    labs(title = {{country_region}},caption = "Data: WHO situation report") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}

#' @describeIn who_sitrep_import plot a ggplot geom_col
#' @inheritParams who_sitrep_import
#' @param y_inc_value incidence variable
#' @param fill fill of attribute

who_sitrep_ggbar <- function(data,country_region="Peru",y_inc_value,fill,n_breaks=5) {
  data %>%
    # mutate(class=fct_explicit_na(class)) %>%
    # mutate_at(.vars = vars(n_cum_deaths,n_inc_conf,n_inc_deaths),.funs = ~replace_na(.x,0)) %>%
    filter(country_region == {{country_region}}) %>%
    ggplot(aes(x = date,y = {{y_inc_value}},fill={{fill}})) +
    geom_col() +
    scale_y_continuous(breaks= scales::pretty_breaks(n = {{n_breaks}})) +
    scale_x_date(date_breaks = "1 day",date_labels = "%b-%d") +
    scale_fill_viridis_d() +
    labs(title = {{country_region}},caption = "Data: WHO situation report") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),)
}

#' @describeIn who_sitrep_import create a full unified report
#' @inheritParams who_sitrep_import

who_sitrep_country_report <- function(update,country_region) {

  who_sitrep <- who_sitrep_import(update = {{update}})

  country_name <- {{country_region}}

  f0 <- who_sitrep %>%
    who_sitrep_cleandb() %>%
    filter(country_region==country_name) %>%
    tail(4) %>%
    gridExtra::tableGrob()

  f1 <- who_sitrep %>%
    who_sitrep_cleandb() %>%
    who_sitrep_ggline(country_region = country_name,
                      y_cum_value = n_cum_conf,
                      color = class, n_breaks = 10)
  f3 <- who_sitrep %>%
    who_sitrep_cleandb() %>%
    who_sitrep_ggline(country_region = country_name,
                      y_cum_value = n_cum_deaths,
                      color = class, n_breaks = 10)
  f2 <- who_sitrep %>%
    who_sitrep_cleandb() %>%
    who_sitrep_ggbar(country_region = country_name,
                     y_inc_value = n_inc_conf,
                     fill = class)
  f4 <- who_sitrep %>%
    who_sitrep_cleandb() %>%
    who_sitrep_ggbar(country_region = country_name,
                     y_inc_value = n_inc_deaths,
                     fill = class)

  #library(patchwork)
  # design <- c(
  #   area(1,2),
  #   area(3,4),
  #   area(5,5),
  #   area(5,5),
  # )
  (f1 | f2) / (f3 | f4) / (f0) #+
  #plot_layout(design = design)

}
