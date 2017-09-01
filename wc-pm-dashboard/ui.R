

header <- dashboardHeader(
  title = "PM Dashboard"
)

sidebar <- dashboardSidebar(
  
  sidebarMenu(
    id = "sidebar",
    menuItem("Overview", tabName="dashboard", icon = icon("dashboard")),
    menuItem("Individual Claims", tabName = "claims", icon = icon("folder")),
    column(
      width = 12,
      br(),
      actionButton("tour", "Tour this Tab", width='100%', style="margin: 0", class="btn btn-info")  
    )
  )
)

body <- dashboardBody(
  introjsUI(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "custom.js"),
    tags$script(src = "introjs-tour.js")
  ),
  tabItems(
    source("./ui/01-ui-overview.R", local = TRUE)$value,
    source("./ui/02-ui-individual-claims.R", local = TRUE)$value
  )
)

dashboardPage(
  header,
  sidebar,
  body,
  skin = "black"
)