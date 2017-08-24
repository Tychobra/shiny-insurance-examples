library(shiny)

header <- dashboardHeader(
  title = "Claims Dashboard"
)

sidebar <- dashboardSidebar(
  dateInput(
    "val_date", 
    "Valuation Date",
    value = Sys.Date(),
    min = min(trans$accident_date),
    max = Sys.Date(),
    startview = "decade"
  ),
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Claim Changes", tabName = "changes", icon = icon("balance-scale")),
    menuItem("Claims Table", tabName = "table", icon = icon("table"))
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "custom.js")
  ),
  tabItems(
    source("ui/01-dashboard-ui.R", local = TRUE)$value,
    source("ui/02-changes-ui.R", local = TRUE)$value,
    tabItem(
      tabName = "table",
      fluidRow(
        box(
          width = 12,
          DT::dataTableOutput("trans_tbl")
        )
      )
    )
  )
)

dashboardPage(
  header,
  sidebar,
  body,
  skin = "black"
)
