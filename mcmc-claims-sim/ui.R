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
        fluidRow(
          column(
            width = 12,
            actionButton(
              "tour", 
              "Take a Tour",
              class = "btn btn-info"
            )
          )
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
        introBox(
          actionButton(
            "run_freq", 
            "Run Simulation",
            icon = icon("download"),
            width = "100%",
            class = "example-css-selector"
          ),
          data.step = 1,
          data.intro = "This button runs the frequency severity simulation. Go ahead and click
          it. Then click the 'Next' button"
        ),
        br(),
        br(),
        introBox(
          sliderInput(
            inputId = "obs", 
            label = "# of Observations", 
            min = 1000, 
            max = 10000, 
            value = 2000, 
            step = 1000, 
            ticks = FALSE
          ),
          data.step = 3,
          data.intro = "This slider adjusts the number of frequency severity observations that the simulation runs.  An observation is one simulated frequency (i.e. number of claims) with a simulated severity for each
          claim.  (e.g. an observation could have 9 claims (frequency) each with varying ultimate loss amounts (severities) that average to 50,000. This example observation would have a total
          loss of 450,000.)"
        ),
        br(),
        hr(),
        introBox(
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
          data.step = 4,
          data.intro = "The frequency distribution randomly generates the number of claims in each observation.  Each distribution requires different
          parameters.  The poisson distribution with a lambda parameter of 10
          has a mean of 10 and a variance of 10.  For more info on these distributions
          see Appendix B of https://www.soa.org/files/pdf/edu-2009-fall-exam-c-table.pdf"
        ),
        br(),
        hr(),
        introBox(
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
          data.step = 5,
          data.intro = "The severity distribution randomly generates the ultimate dollar amount to settle each claim.  Just like the frequency distributions, each 
          severity distribution requires different parameters.  The
          lognormal distribution with a mu of 9 and a sigma of 2 has a mean of  59,874 and a standard deviation of 438,343.  For more info 
          on these distributions see Appendix A of https://www.soa.org/files/pdf/edu-2009-fall-exam-c-table.pdf"
        )
      )
    ),
    
    column(
      width = 9,
      fluidRow(
        column(
          width = 8,
          wellPanel(
            introBox(
              h3("Retention Limits", class = "well-title"),
              data.step = 6,
              data.intro = "Insurers often purchase excess policies to limit their exposure to large losses.  Two common
              retention limits available with excess policies are 'per claim limits' and 'aggregate' limits"
            ),
            fluidRow(
              column(
                width = 6,
                introBox(
                  numericInput(
                    inputId = "specific_lim", 
                    label = "Per Claim Limit", 
                    value = 250000
                  ),
                  data.step = 7,
                  data.intro = "The 'per claim limit' does exactly what you would expect.  It limits the retained loss per claim
                  to the per claim limit. e.g. if an insurer has an excess policy with a per claim limit of 250,000, the max that 
                  the insurer will pay on that claim is 250,000"
                )
              ),
              column(
                width = 6,
                introBox(
                  numericInput(
                    inputId = "agg_lim", 
                    label = "Aggregate (per observation) Limit", 
                    value = 750000
                  ),
                  data.step = 8,
                  data.intro = "The 'aggregate limit' (also often called the 'aggreagte stop loss') sets an upper limit on the 
                  amount that the insurer can lose in one observation.  The risk reduction value of an aggregate limit (at certain confidence levels) 
                  can be difficult to calculate directly from the probability distributions when you already have per claim limits. 
                  Simulations give us an easy way to quantify the financial implications of combining different per claim and aggregate and
                  limits"
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
              div(
                style="width: 400px",
                introBox(
                  div(),
                  data.step = 11,
                  data.intro = "Last but not least you can click on the above tabs to view a table of the output and to download all the claims"
                )
              ),
              br(),
              fluidRow(
                column(
                  width = 12,
                  introBox(
                    highchartOutput("hist_plot") %>% withSpinner(),
                    data.step = 2,
                    data.intro = "  
                    This histogram shows the distribution of ultimate losses per frequency / severity observation.  
                    The ultimate loss per observation is on the x-axis 
                    and the y-axis is looking at number of observations."
                  )
                )
              ),
              hr(),
              fluidRow(
                column(
                  width = 2
                ),
                column(
                  width = 8,
                  introBox(
                    sliderInput(
                      inputId = "ci", 
                      label = "Confidence Level",
                      value = 0.95,
                      max = 1.0,
                      min = 0.25,
                      step = 0.01,
                      width = '100%'
                    ),
                    data.step = 9,
                    data.intro = "Adjust the confidence level shown in the plots here"
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
                  introBox(
                    highchartOutput("hist_plot_total") %>% withSpinner(),
                    data.step = 10,
                    data.intro = "This plot shows the ultimate losses per claim gross of the selected retention limits.  As opposed to the plot above which is net
                    of retention limits."
                  )
                )
              )
            ),
            # tabPanel(
            #   title = "CDF",
            #   br(),
            #   plotOutput("cdf"),
            #   plotOutput("cdf_total")
            # ),
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
  ),
  singleton(
    tags$script(src = "js/shinytour.js")
  )
)
