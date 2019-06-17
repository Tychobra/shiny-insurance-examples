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
            style = "width: 160px"
          )
        )
      ),
      br(),
      fluidRow(
        column(
          width = 12,
          align = 'center',
          downloadButton2(
            "generate_excel_report",
            "Create Excel Report",
            icon = icon("file-excel"),
            style = "width: 160px"
          )
        )
      ),
      title = "Download Report",
      size = "s",
      footer = list(
        modalButton("Cancel")
      )
    )
  )
})
