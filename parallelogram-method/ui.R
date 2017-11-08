fluidPage(
  useShinyjs(),
  theme = shinytheme("flatly"),
  # Application title
  tags$head(
    tags$link(
      rel="icon",
      href="https://res.cloudinary.com/dxqnb8xjb/image/upload/v1509563497/tychobra-logo-blue_dacbnz.svg"
    )
  ),
  fluidRow(
    headerPanel(
      tags$div(
        a(
          img(
            src = "https://res.cloudinary.com/dxqnb8xjb/image/upload/v1509563497/tychobra-logo-blue_dacbnz.svg", 
            width = 50
          ), 
          href = "https://tychobra.com/shiny"
        ),
        h1("Parallelogram Method", style = "display: inline"),
        a(
          href = "https://github.com/Tychobra/shiny-insurance-examples/tree/master/parallelogram-method",
          icon("github", class="fa-lg pull-right")
        )
      ), 
      windowTitle = "Parallelogram"
    )
  ),
  
  # Sidebar with a slider input for number of bins 
  fluidRow(
    column(
      width = 5,
      class = "text-center",
      wellPanel(
        dateRangeInput(
          "effective_dates",
          label = "Effective Period",
          start = "2017-01-01",
          end = "2019-12-31",
          format = "mm/dd/yyyy",
          startview = "year"
        ),
        fluidRow(
          column(
            width = 6,
            selectInput(
              "fy_end",
              "Fiscal Year End",
              choices = c(
                "3/31" = "03-31",
                "6/30" = "06-30",
                "9/30" = "09-30",
                "12/31" = "12-31"
              ),
              selected = "12-31"
            )
          ),
          column(
            width = 6,
            selectInput(
              "policy_duration",
              "Policy Duration",
              choices = c(
                "6 months" = 182,
                "1 year" = 365,
                "2 year" = 730
              ),
              selected = 365
            )
          )
        )
      ),
      wellPanel(
        div(
          id = "rate_changes",
          fluidRow(
            column(
              width = 4,
              id = "rate_changes",
              dateInput(
                "rate_date_1",
                label = "Rate Change Date",
                value = "2016-07-01",
                format = "mm/dd/yyyy",
                startview = "year"
              )
            ),
            column(
              width = 4,
              numericInput(
                "rate_change_1",
                label = "Rate % Change",
                value = 5
              )
            ),
            column(
              width = 4,
              numericInput(
                "exposure_change_1",
                "Exposure % Change",
                value = -5
              )
            )
          )
        ),
        fluidRow(
          column(
            width = 6,
            actionButton(
              "add_rate_change",
              "Add Rate Change",
              width = "100%",
              class = "btn-primary"
            )
          ),
          column(
            width = 6,
            actionButton(
              "remove_rate_change",
              "Remove Rate Change",
              width = "100%",
              class = "btn-danger"
            )
          )
        )
      )
    ),
    
    # Show a plot of the generated distribution
    column(
      width = 7,
      plotOutput("para_plot") %>% withSpinner(type = 4),
      fluidRow(
        column(
          width = 12,
          class = "text-center",
          radioButtons(
            "plot_metric",
            label = NULL,
            inline = TRUE,
            choices = c(
              "Exposure %" = "exposure_pct", 
              "Exposure Total" = "exposure",
              "Earned Premium %" = "premium_pct",
              "Earned Premium Total" = "premium"
            )
          )
        )
      ),
      fluidRow(
        br(),
        column(
          width = 12,
          DT::dataTableOutput("rate_tbl"),
          br(),
          br()
        )
      )#,
      #verbatimTextOutput("debuggin")
    )
  )
)