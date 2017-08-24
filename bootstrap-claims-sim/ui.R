fluidPage(
  includeCSS("www/css/styles.css"),
  # Application title
  fluidRow(
    tags$head(
      tags$link(
        rel="icon", 
        href="https://res.cloudinary.com/dxqnb8xjb/image/upload/v1499450435/logo-blue_hnvtgb.png"
      )
    ),
    headerPanel(
      tags$div(
        a(
          img(
            src = "img/logo-blue.png", 
            width = 50
          ), 
          href = "https://tychobra.com/dashboards",
          title="Tychobra"
        ),
        h1("Bootstrap Loss Simulation")#,
          # style="display: inline-block")#,
        # fluidRow(
        #   column(
        #     width = 12,
        #     actionButton(
        #       "tour", 
        #       "Take a Tour",
        #       class = "btn btn-info"
        #     ),
        #     h3(" or checkout the ", 
        #        a(
        #          href = "https://github.com/merlinoa/claims-sim-general/blob/master/README.md", 
        #          "README"
        #        ), 
        #        "for more information",
        #        style="display: inline-block"
        #     )
        #   )
        # )
      ), 
      windowTitle = "Bootstrap Simulation"
    )
  ),

  fluidRow(
    column(
      width = 3,
      br(),
      br(),
      wellPanel(
        fluidRow(
          column(
            width = 12,
            actionButton(
              "run_sim",
              "Run Simulation",
              class="btn btn-primary",
              width = '100%',
              icon = icon("play")
            )
          )
        ),
        br(),
        fluidRow(
          column(
            width = 6,
            numericInput(
              "exposure",
              "Exposure",
              value = 3000,
              step = 100
            )
          ),
          column(
            width = 6,
            numericInput(
              "freq",
              "Frequency",
              value = 0.05,
              step = 0.01
            )
          )
        )
      ),
      wellPanel(
        fluidRow(
          h3("Retentions", class="well-title"),
          column(
            width = 6,
            numericInput(
              "retention",
              "Per Claim",
              value = 1000000,
              step = 10000
            )
          ),
          column(
            width = 6,
            numericInput(
              "agg_lim",
              "Aggregate",
              value = 20000000,
              step = 25000
            )
          )
        )
      ),
      conditionalPanel(
        "input.run_sim > 0",
        wellPanel(
          fluidRow(
            column(
              width = 12,
              downloadButton(
                "download_report",
                "Download Report",
                style="width: 100%",
                icon = icon("download"),
                class = "btn btn-primary"
              )
            )
          )
        )
      )
    ),
    column(
      width = 9,
      tabsetPanel(
        tabPanel(
          "Simulation Output",
          br(),
          fluidRow(
            column(
              width = 2
            ),
            conditionalPanel(
              'input.run_sim > 0',
              column(
                width = 8,
                sliderInput(
                  "cl",
                  "Confidence Level",
                  value = 95,
                  min = 1,
                  max = 99,
                  step = 1,
                  width = '100%'
                )
              )
            )
          ),
          highchartOutput("hist_plot") %>% withSpinner(),
          highchartOutput("hist_plot_total") %>% withSpinner()
          #verbatimTextOutput("claims")    
        ),
        tabPanel(
          "Data Input",
          br(),
          fluidRow(
            column(
              width = 7,
              fluidRow(
                column(
                  width = 5,
                  div(
                    style = "margin-right: -30px",
                    rHandsontableOutput("hands_tbl")
                  )
                ),
                column(
                  width = 7,
                  rHandsontableOutput("hands_output") 
                )
              )
            ),
            column(
              width = 5,
              wellPanel(
                h3("Trend", class="well-title"),
                fluidRow(
                  column(
                    width = 6,
                    numericInput(
                      "trend",
                      "Annual Rate",
                      value = 1.05,
                      step = 0.01
                    )
                  ),
                  column(
                    width = 6,
                    sliderInput(
                      "trend_to",
                      "Year To",
                      min = 2017,
                      max = 2020,
                      value = 2017,
                      sep = ""
                    )
                  )
                )
              ),
              wellPanel(
                h3("Development", class="well-title"),
                fluidRow(
                  column(
                    width = 6,
                    style = "text-align: center",
                    h5("Accident Year")
                  ),
                  column(
                    width = 6,
                    style = "text-align: center",
                    h5("CDF")
                  )
                ),
                fluidRow(
                  hr(style="margin: 5px"),
                  column(
                    width = 6,
                    style = "text-align: center",
                    h5("2014")
                  ),
                  column(
                    width = 6,
                    numericInput(
                      "dev_2014",
                      label = NULL,
                      value = 1.2,
                      step = 0.01
                    )
                  )
                ),
                fluidRow(
                  hr(style="margin: 5px"),
                  column(
                    width = 6,
                    style = "text-align: center",
                    h5("2015")
                  ),
                  column(
                    width = 6,
                    numericInput(
                      "dev_2015",
                      label = NULL,
                      value = 1.5,
                      step = 0.01
                    )
                  )
                ),
                fluidRow(
                  hr(style="margin: 5px"),
                  column(
                    width = 6,
                    style = "text-align: center",
                    h5("2016")
                  ),
                  column(
                    width = 6,
                    numericInput(
                      "dev_2016",
                      label = NULL,
                      value = 3.75,
                      step = 0.01
                    )
                  )
                )
              ),
              wellPanel(
                h3("Shock Loss", class="well-title"),
                fluidRow(
                  column(
                    width = 6,
                    numericInput(
                      "shock_cut",
                      "Cutoff",
                      value = 1000000,
                      step = 25000
                    )
                  ),
                  column(
                    width = 6,
                    numericInput(
                      "shock_prob",
                      "Probability",
                      value = round(2/195, 4),
                      step = 0.0001
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
)
