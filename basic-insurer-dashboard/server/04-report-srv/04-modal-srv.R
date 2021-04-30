observeEvent(input$generate_report_modal, {
  showModal(
    modalDialog(
      fluidRow(
        column(
          width = 12,
          align = "center",
          downloadButton2(
            "generate_pdf_report",
            "Create PDF Report",
            icon = icon("file-pdf-o"),
            style = "width: 100%"
          )
        )
      ),
      br(),
      fluidRow(
        column(
          width = 12,
          align = "center",
          downloadButton2(
            "generate_excel_report",
            "Create Excel Report",
            icon = icon("file-excel"),
            style = "width: 100%"
          )
        )
      ),
      # br(),
      # fluidRow(
      #   column(
      #     width = 12,
      #     align = "center",
      #     downloadButton2(
      #       "generate_ppt_report",
      #       "Create PowerPoint Report",
      #       icon = icon("file-powerpoint"),
      #       style = "width: 100%"
      #     )
      #   )
      # ),
      title = "Download Report",
      size = "s",
      footer = list(
        modalButton("Cancel")
      )
    )
  )
})
