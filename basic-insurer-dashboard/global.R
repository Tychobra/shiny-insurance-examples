library(shiny)
library(shinydashboard)
library(tibble)
library(dplyr)
library(highcharter)
library(DT)
library(lubridate)
library(tidyr)
library(shinyWidgets)

trans <- readRDS("./data/trans.RDS")

state_choices <- unique(trans$state)
ay_choices <- trans %>%
                mutate(year = year(accident_date)) %>%
                .[["year"]] %>%
                unique() %>%
                sort()

my_colors <- c("#434348", "#7cb5ec")

hcoptslang <- getOption("highcharter.lang")
hcoptslang$thousandsSep <- ","
options(highcharter.lang = hcoptslang)

valueBox2 <- function (value, subtitle, icon = NULL, color = "#7cb5ec", width = 4, 
                       href = NULL) 
{
  if (!is.null(icon)) 
    #tagAssert(icon, type = "i")
  boxContent <- div(class = "small-box", style = paste0("background-color: ", color, ";"), 
                    div(class = "inner", h3(value), p(subtitle)), if (!is.null(icon)) 
                      div(class = "icon-large", icon))
  if (!is.null(href)) 
    boxContent <- a(href = href, boxContent)
  div(class = if (!is.null(width)) 
    paste0("col-sm-", width), boxContent)
}

display_names <- tribble(
  ~data_name, ~display_name,
  "claim_num", "Claim Number",
  "accident_date", "Accident Date",
  "state", "State",
  "claimant", "Claimant Name",
  "report_date", "Report Date",
  "status", "Status",
  "payment", "Payment",
  "case", "Case Reserve",
  "transaction_date", "Transaction Date",
  "trans_num", "Transcation Number",
  "paid", "Paid Loss",
  "reported", "Reported Loss"
)

#' show_names
#' 
#' @param nms character vector of names from the data
#' 
#' @examples 
#' show_names(names(trans))
#'
show_names <- function(nms) {
  nms_tbl <- data_frame(data_name = nms)
  
  nms_tbl <- left_join(nms_tbl, display_names, by = "data_name") %>%
               mutate(display_name = ifelse(is.na(display_name), data_name, display_name))
  nms_tbl$display_name
}

hc_btn_options <- list(
  contextButton = list(
    menuItems = list(
      list(
        text = "Export to PDF",
        onclick = JS(
          "function () { this.exportChart({
             type: 'application/pdf'
           }); }"
        )
      ),
      list(
        text = "Export to SVG",
        onclick = JS(
          "function () { this.exportChart({
             type: 'image/svg+xml'
          }); }"
        )
      )
    )
  )
)