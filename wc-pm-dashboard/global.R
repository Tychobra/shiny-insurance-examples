library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)
library(highcharter)
library(lubridate)
library(shinyWidgets)
library(xts)
library(tidyr)
library(DT)
library(rintrojs)
library(tychobratools)

### highcharter options
hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)


# save the data in this project
# need to do this so app can be deployed to shinyapps.io
#dat <- readRDS("../pm-loss-runs/data/shiny-model-fit-dat.RDS") %>%
#  arrange(doa)
#saveRDS(dat, "./data/shiny-model-fit-dat.RDS")
#preds <- readRDS("../pm-loss-runs/data/simulated/claim-payments.RDS") %>% 
#           mutate(ay = year(doa))
#saveRDS(preds, "./data/claim-payments.RDS")


# load data
dat <- readRDS("./data/shiny-model-fit-dat.RDS")

ay_choices <- unique(dat$ay)
status_choices <- unique(dat$status)
type_choices <- unique(dat$type)
nature_choices <- sort(unique(as.character(dat$nature_code)))

preds <- readRDS("./data/claim-payments.RDS")

dollar_fmt <- function(col, currency = "$") {
  round(col, 0) %>%
    format(big.mark = ",") %>%
    paste0(currency, " ", .)
}

display_names <- tribble(
  ~name, ~display_name,
  "ay", "Accident Year",
  "claim_num", "Claim Number",
  "doa", "Accident Date",
  "status", "Status",
  "pd_total", "Paid",
  "case_total", "Case Reserve",
  "gender", "Gender",
  "nature_code", "Nature Code",
  "type", "Type",
  "ic_required", "IC Required",
  "val", "Val",
  "status_act", "Actual Status",
  "pd_incr_act", "Actual Payment",
  "prob_open", "Probability Open",
  "payment_fit", "Predicted Payment"
)

