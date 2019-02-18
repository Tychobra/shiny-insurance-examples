tabItem(
  tabName = "report",
  fluidRow(
    box(
      width = 12,
      br(),
      br(),
      column(
        4
      ),
      column(
        4,
        downloadButton(
          "generate_pdf_report",
          "Generate PDF Report",
          icon = icon("file-pdf-o"),
          class = "btn-lg btn-primary color_white",
          width = "100%"
        ),
        br(),
        br(),
        br()
      )
    )
  )
)
