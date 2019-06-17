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
    menuItem("Claims Table", tabName = "table", icon = icon("table")),
    br(),
    fluidRow(
      column(
        width = 11,
        actionButton(
          "generate_report_modal",
          "Create Report",
          icon = icon("download"),
          #class = "btn-lg",
          style = "width: 95%; color: #111"
        )
      )
    )
    #menuItem("Reports", tabName = "report", icon = icon("file-pdf-o"))
  )
)

body <- dashboardBody(
  tags$head(
    tags$link( 
      rel = "shortcut icon", 
      type = "image/png", 
      href = "https://res.cloudinary.com/dxqnb8xjb/image/upload/v1510505618/tychobra-logo-blue_d2k9vt.png"
    ),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "custom.js")
  ),
  tabItems(
    source("ui/01-dashboard-ui.R", local = TRUE)$value,
    source("ui/02-changes-ui.R", local = TRUE)$value,
    source("ui/03-claims-ui.R", local = TRUE)$value#,
    #source("ui/04-report-ui.R", local = TRUE)$value
  )
)

dashboardPage(
  header,
  sidebar,
  body,
  skin = "black"
)
