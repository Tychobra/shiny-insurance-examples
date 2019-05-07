tabItem(
  tabName = "claims",
  fluidRow(
    column(
      width = 9,
      fluidRow(
        valueBoxOutput("ind_claim_cts"),
        valueBoxOutput("ind_severity"),
        valueBoxOutput("ind_severity_sd")
      ),
      fluidRow(
        box(
          id = "tour_2_1",
          width = 12,
          highchartOutput(
            "indiv_claims_plot",
            height = '550px'
          ) %>% withSpinner()
        )
      )
    ),
    column(
      width = 3,
      fluidRow(
        box(
          title = "Plot Groups",
          width = 12,
          class = "text-center",
          radioButtons(
            inputId = "ind_plot_groups",
            label = NULL,
            choices = c("Status" = "status",
                       "Type" = "type"),
            selected = "status",
            inline = TRUE
          )
        ),
        box(
          title = "Filters",
          width = 12,
          conditionalPanel(
            condition = "input.ind_plot_groups == 'type'",
            div(
              class = "text-center",
              checkboxGroupInput(
                inputId = "ind_status", 
                label = "Claim Status", 
                choices = c("Open" = "O",
                            "Closed" = "C"), 
                selected = c("O", "C"),
                inline = TRUE              
              ) 
            )
          ),
          conditionalPanel(
            condition = "input.ind_plot_groups == 'status'",
            div(
              class = "text-center",
              checkboxGroupInput(
                inputId = "ind_type", 
                label = "Claim Type", 
                choices = c("Medical Only" = "M",
                            "Lost Time" = "C"), 
                selected = c("M", "C"),
                inline = TRUE
              )
            )
          ),
          br(),
          numericInput(
            "ind_exclude_below",
            "Exclude Payments Below",
            value = 0,
            min = 0
          ),
          br(),
          shinyWidgets::pickerInput(
            inputId = "ind_nature", 
            label = "Nature Code", 
            choices = nature_choices, 
            options = list(`actions-box` = TRUE), 
            multiple = TRUE,
            selected = nature_choices
          ),
          br(),
          div(
            class = "text-center",
            checkboxGroupInput(
              inputId = "ind_gender", 
              label = "Gender", 
              choices = c("Male" = "M",
                          "Female" = "F"), 
              selected = c("M", "F"),
              inline = TRUE
            )
          )
        ) 
      )
    )
  ),
  conditionalPanel(
    "input.hc_clicked != null",
    fluidRow(
      column(
        width = 9,
        fluidRow(
          box(
            id = "tour_2_2",
            width = 12,
            highchartOutput(
              "indiv_claim_sim",
              height = '550px'
            ) %>% withSpinner(),
            column(
              width = 12,
              sliderInput(
                "claim_cl",
                "Confidence Level",
                min = 1,
                max = 99,
                value = 95,
                step = 1
              )
            )
          )
        )
      ),
      column(
        width = 3,
        fluidRow(
          box(
            id = "tour_2_3",
            width = 12,
            DT::dataTableOutput("clm_char_tbl") %>% withSpinner()#,
            #verbatimTextOutput("debuggin")
          )
        )
      )
    )
  )
)
