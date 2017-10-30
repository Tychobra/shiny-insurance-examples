
fluidPage(
  theme = shinytheme("flatly"),
  includeCSS("www/custom.css"),
  tags$head(
    tags$link(
      rel="icon",
      href="https://res.cloudinary.com/dxqnb8xjb/image/upload/v1499450435/logo-blue_hnvtgb.png"
    ),
    tags$script(src = "sender-queue.js")
  ),
  fluidRow(
    headerPanel(
      div(
        a(
          img(
            src = "https://res.cloudinary.com/dxqnb8xjb/image/upload/v1499450435/logo-blue_hnvtgb.png", 
            width = 50
          ), 
          href = "https://tychobra.com/shiny"
        ),
        h1("Medicare Spending", style = "display: inline")
      ),
      windowTitle = "Medicare Spending"
    )
  ),
  absolutePanel(
    draggable = TRUE,
    top = 150,
    right = 10,
    width = 250,
    wellPanel(
      fluidRow(
        column(
          width = 12,
          class = "text-center",
          h3(
            textOutput("sel_state_name")
          )
        ),
        column(
          width = 12,
          DT::dataTableOutput("state_locations"),
          DT::dataTableOutput("state_meta_tbl")
        )  
      )
    )
  ),
  fluidRow(
    column(
      width = 3,
      wellPanel(
        h3("Claim Filters", class = "text-center"),
        br(),
        checkboxGroupInput(
          inputId = "period_filter",
          label = "Hospital Visit Period",
          choices = c(
            "During Visit" = "during",                              
            "1 to 30 days After Visit" = "after_1_30",
            "1 to 3 days Before Visit" = "prior_1_3"),
          selected = c("during", "after_1_30", "prior_1_3")
        ),
        shinyWidgets::pickerInput(
          inputId = "type_filter", 
          label = "Claim Type", 
          choices = type_choices, 
          options = list(
            `actions-box` = TRUE,
            `selected-text-format`="count"
          ), 
          multiple = TRUE,
          selected = type_choices
        )
      )
    ),
    column(
      width = 9,
      highchartOutput(
        "states_map",
        height = 600
      )
    )
  ),
  fluidRow(
    br(),
    hr(),
    column(
      width = 6,
      fluidRow(
        column(
          width = 12,
          class = "text-center",
          h2(
            textOutput("hospitals_tbl_title")
          )
        ),
        column(
          width = 12,
          DT::dataTableOutput("hospitals_tbl")
        )
      )
    ),
    column(
      width = 6,
      fluidRow(
        column(
          width = 12,
          class = "text-center",
          h2(
            textOutput("single_hospital_tbl_title")
          )
        ),
        column(
          width = 12,
          DT::dataTableOutput("single_hospital_tbl")
        )
      )
    ),
    br()
  )
)

