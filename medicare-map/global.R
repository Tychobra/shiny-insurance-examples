library(shiny)
library(dplyr)
library(highcharter)
library(shinyWidgets)
library(DT)
library(tidyr)
library(shinythemes)
library(tychobratools)

# load data
if (file.exists("data/spending-hospital.RDS")) {
  hospitals <- readRDS("data/spending-hospital.RDS")
  states <- readRDS("data/spending-state.RDS")
} else {
  # see "data-prep.R" file.  It will create the `dat` data frame
  # and load it in the global environment
  source("data-prep.R")
}

# choice options for inputs
period_choices <- unique(states$period)
type_choices <- unique(states$claim_type)

nation_n_hospitals <- unique(hospitals$hospital) %>%
                        length()

nation_n_providers <- unique(hospitals$provider_id) %>%
  length()

# download data to draw map
mapdata <- download_map_data("countries/us/us-all")

# highcharter options 
hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)
rm(hcoptslang)
