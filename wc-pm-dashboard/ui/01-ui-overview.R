tabItem(
  tabName = "dashboard",
  div(
    style="width: 0",
    div(id="tour_1")
  ),
  fluidRow(
    id = "tour_2",
    column(
      width = 9,
      fluidRow(
        id = "tour_5",
        valueBoxOutput("predicted_mean_open"),
        valueBoxOutput("predicted_sd"),
        valueBoxOutput("actual_open_claims")
      ),
      fluidRow(
        id = "tour_6",
        box(
          width = 12,
          conditionalPanel(
            condition = "input.metric == 'status'",
            highchartOutput("open_per_sim_plot") %>% withSpinner()
          ),
          conditionalPanel(
            condition = "input.metric == 'payment'",
            highchartOutput("payment_per_sim_plot") %>% withSpinner()
          ),
          column(
            width = 12,
            id = "tour_7",
            class = "text-center",
            br(),
            sliderInput(
              "overview_interval",
              "Confidence Interval",
              value = c(5, 95),
              min = 0,
              max = 100,
              post = "%",
              step = 1
            ) 
          )
        )
      )#,
      #verbatimTextOutput("debuggin")
    ),
    column(
      width = 3,
      fluidRow(
        id = "tour_3",
        box(
          title = "Metric",
          width = 12,
          div(
            class = "text-center",
            radioButtons(
              inputId = "metric",
              label = NULL,
              choices = c("Payments" = "payment",
                          "Status" = "status"),
              selected = "payment",
              inline = TRUE
            )
          )
        )
      ),
      fluidRow(
        id = "tour_4",
        box(
          title = "Filters",
          width = 12,
          shinyWidgets::pickerInput(
            inputId = "ay_filter", 
            label = "Accident Year", 
            choices = ay_choices, 
            options = list(`actions-box` = TRUE), 
            multiple = TRUE,
            selected = ay_choices
          ),
          br(),
          div(
            class = "text-center",
            checkboxGroupInput(
              inputId = "overview_type", 
              label = "Claim Type", 
              choices = c("Medical Only" = "M",
                          "Lost Time" = "C"), 
              selected = c("M", "C"),
              inline = TRUE
            )
          )
        )
      )
    )
  )
)
