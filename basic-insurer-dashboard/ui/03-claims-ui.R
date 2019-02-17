tabItem(
  tabName = "table",
  fluidRow(
    box(
      width = 12,
      DT::dataTableOutput("trans_tbl")
    )
  )
)
