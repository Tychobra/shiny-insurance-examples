library(shiny)
library(highcharter)
library(shinythemes)
library(actuar)
library(DT)
library(dplyr)
library(rintrojs)
library(shinycssloaders)
library(tychobratools)

# turn off scientific notation
options(scipen=999)

freq_choices <- c("Poisson" = "poisson", 
                  "Binomial" = "binomial", 
                  "Negative Binomial" = "nbinomial")

sev_choices <- c("Lognormal" = "lognormal", 
                 "Pareto" = "pareto", 
                 "Weibull" = "weibull", 
                 "Gamma" = "gamma", 
                 "Exponential" = "exponential")