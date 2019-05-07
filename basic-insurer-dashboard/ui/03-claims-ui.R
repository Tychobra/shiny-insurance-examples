tabItem(
  tabName = "table",
  fluidRow(
    box(
      width = 12,
      DT::DTOutput("trans_tbl")
    )
  )
)
