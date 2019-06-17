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
          align = 'center',
          downloadButton2(
            "generate_excel_report",
            "Create Excel Report",
            icon = icon("file-excel"),
            style = "width: 100%"
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


output$generate_excel_report <- downloadHandler(
  filename = function(){
    paste0("claims-report-as-of-", input$val_date, ".xlsx")
  },
  content = function(file) {
    #data prep
    params <- list(
      data = trans, 
      val_date = ymd(input$val_date)
    )
    
    data_ <- if (length(params$data) == 1) readRDS("../../data/trans.RDS") else params$data
    eval_ <- params$val_date
    
    loss_run <- function(val_date) {
      data_ %>%
        filter(transaction_date <= val_date) %>%
        group_by(claim_num) %>%
        top_n(1, wt = trans_num) %>%
        ungroup() %>%
        mutate(reported = paid + case) %>%
        arrange(desc(transaction_date))
    }
    
    lr_current <- loss_run(eval_)
    lr_prior <- loss_run(eval_ - years(1))
    
    by_ay <- lr_current %>%
      mutate(
        year = as.character(lubridate::year(accident_date)),
        n_open = ifelse(status == "Open", 1, 0)
      ) %>%
      group_by(year) %>%
      summarize(
        paid = sum(paid),
        case = sum(case),
        reported = sum(reported),
        n_open = sum(n_open),
        n = n()
      ) %>%
      ungroup() %>%
      totals_row(
        cols = 2:6,
        label_col = 1
      )
    
    names(by_ay) <- c("Accident Year", "Paid", "Case", "Reported", "Open", "Reported")
    
    #Workbook
    to_download <- createWorkbook()
    
    addWorksheet(wb = to_download, sheetName = "Claims Report")
    
    insertImage(
      to_download,
      sheet = 1,
      file = "server/04-report-srv/images/tychobra_logo_blue_co_name.png",
      width = 5.32,
      height = 1.37,
      startRow = 1,
      startCol = 1,
      units = "in",
      dpi = 300
    )
    
    writeData(
      to_download,
      1,
      "Example Client Name",
      startRow = 1,
      startCol = 9
    )
    
    writeData(
      to_download,
      1,
      "Workers' Compensation Claims Report",
      startRow = 2,
      startCol = 9
    )
    
    addStyle(
      to_download,
      sheet = 1,
      rows = 1:2,
      cols = 9,
      style = createStyle(fontSize = 20)
    )
    
    writeData(
      to_download,
      1,
      paste0("Date Evaluated as of ", format(input$val_date, "%B %d, %Y")),
      startRow = 3,
      startCol = 9
    )
    
    writeData(
      to_download,
      1,
      paste0("Report Generated on ", format(Sys.Date(), format = "%B %d, %Y")),
      startRow = 4,
      startCol = 9
    )
    
    addStyle(
      to_download,
      sheet = 1,
      rows = 3:4,
      cols = 9,
      style = createStyle(fontSize = 18)
    )
    
    writeData(
      to_download,
      1,
      by_ay,
      startRow = 6,
      startCol = 1
    )
    
    saveWorkbook(to_download, file)
  }
)




