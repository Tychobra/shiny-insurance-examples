fluidPage(
  introjsUI(),
  theme = shinytheme("spacelab"),
  includeCSS("ractuary-style.css"),
  fluidRow(
    br(),
    headerPanel(
      tags$div(
        a(
          img(
            src = "https://res.cloudinary.com/dxqnb8xjb/image/upload/v1499450435/logo-blue_hnvtgb.png", 
            width = 50
          ), 
          href = "https://tychobra.com/shiny"
        ),
        h1("Frequency/Severity Loss Simulation"),
        actionButton(
          "tour", 
          "Take a Tour",
          class = "btn btn-info pull-right"
        )
      ), 
      windowTitle = "Loss Simulation"
    )
  ),
  
  br(),
  
  fluidRow(
    column(
      width = 3, 
      wellPanel(
        div(
          id = "tour_1",
          actionButton(
            "run_freq", 
            "Run Simulation",
            icon = icon("download"),
            width = "100%",
            class = "example-css-selector"
          )
        ),
        br(),
        br(),
        div(
          id = "tour_3",
          sliderInput(
            inputId = "obs", 
            label = "# of Observations", 
            min = 1000, 
            max = 10000, 
            value = 2000, 
            step = 1000, 
            ticks = FALSE
          )
        ),
        br(),
        hr(style="border-color: #000"),
        div(
          id = "tour_4",
          h3("Frequency", class = "well-title"),
          selectInput(
            inputId = "freq_dist", 
            label = "Distribution",
            choices = freq_choices
          ),
          h4("Parameters"),
          fluidRow(
            uiOutput("freq_param_boxes") 
          ),
          h4("Distribution Summary Stats"),
          fluidRow(
            column(
              6,
              style = "text-align: center",
              textOutput("implied_freq_mean_out")
            ),
            column(
              6,
              style = "text-align: center",
              textOutput("implied_freq_sd_out")
            )
          )
        ),
        br(),
        hr(style="border-color: #000"),
        div(
          id = "tour_5",
          h3("Severity", class = "well-title"),
          selectInput(
            inputId = "sev_dist", 
            label = "Distribution",
            choices = sev_choices
          ),
          h4("Parameters"),
          fluidRow(
            uiOutput("sev_param_boxes") 
          ),
          h4("Distribution Summary Stats"),
          fluidRow(
            column(
              6,
              style = "text-align: center",
              textOutput("implied_sev_mean_out")
            ),
            column(
              6,
              style = "text-align: center",
              textOutput("implied_sev_sd_out")
            )
          )
        )
      )
    ),
    
    column(
      width = 9,
      fluidRow(
        column(
          width = 2
        ),
        column(
          width = 8,
          wellPanel(
            h3(
              id = "tour_6",
              class = "well-title",
              "Retention"
            ),
            fluidRow(
              column(
                width = 6,
                id = "tour_7",
                numericInput(
                  inputId = "specific_lim", 
                  label = "Per Claim", 
                  value = 250000
                )
              ),
              column(
                width = 6,
                id = "tour_8",
                numericInput(
                  inputId = "agg_lim", 
                  label = "Aggregate (per observation)", 
                  value = 750000
                )
              )
            )
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          tabsetPanel(
            tabPanel(
              title = "Histogram",
              br(),
              fluidRow(
                column(
                  id = "tour_2",
                  width = 12,
                  highchartOutput("hist_plot") %>% withSpinner()
                )
              ),
              hr(),
              fluidRow(
                column(
                  width = 2
                ),
                column(
                  width = 8,
                  id = "tour_9",
                  sliderInput(
                    inputId = "ci", 
                    label = "Confidence Level",
                    value = 0.95,
                    max = 1.0,
                    min = 0.25,
                    step = 0.01,
                    width = '100%'
                  )
                ),
                column(
                  width = 2
                )
              ),
              hr(),
              fluidRow(
                column(
                  width = 12,
                  id = "tour_10",
                  highchartOutput("hist_plot_total") %>% withSpinner()
                )
              ),
              hr(),
              fluidRow(
                column(
                  12,
                  highchartOutput("hist_plot_ceded") %>% withSpinner()
                )
              )
            ),
            tabPanel(
              title = "Confidence Level Table",
              br(),
              DT::dataTableOutput("sorter")
            ),
            tabPanel(
              title = "Download",
              br(),
              wellPanel(
                h3("Download All Claims"),
                p("Claim loss amounts are gross of any retention limits.  Each
                  row represents one frequency/severity observation"),
                downloadButton("download_claims", "Download Claims")
              )
            )
          )
        )
      )
    )
  )
)
