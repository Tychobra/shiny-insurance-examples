library(shiny)
library(dplyr)
library(highcharter)
library(DT)
library(rhandsontable)
library(rmarkdown)
library(shinycssloaders)

n_rows <- 99
set.seed(1234)
claims <- data_frame(
  year = rep(c(2014, 2015, 2016), each = n_rows / 3),
  status = sample(c("O", "C"), n_rows, replace = TRUE),
  value = rlnorm(n_rows, meanlog = 9, sdlog = 1.7)
)
