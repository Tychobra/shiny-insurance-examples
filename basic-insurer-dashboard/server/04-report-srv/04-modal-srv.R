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

modal_val <- reactiveVal(0)

observeEvent(modal_val(), {
  removeModal()
})

output$generate_excel_report <- downloadHandler(
  filename = function(){
    paste0("claims-report-as-of-", input$val_date, ".xlsx")
  },
  content = function(file) {
    #hack to close modal
    modal_val(modal_val() + 1)
    
    #data prep
    #table 1
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
    
    table1 <- lr_current %>%
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
    
    names(table1) <- c("Accident Year", "Paid", "Case", "Reported", "Open", "Reported")
    
    #table 2
    
    out <- lr_current %>%
      select(claim_num, accident_date, claimant, state, status, paid, reported)
    
    lr_prior_out <- lr_prior %>%
      select(claim_num, paid, reported)
    
    table2 <- out %>%
      left_join(lr_prior_out, by = "claim_num") %>%
      mutate(
        paid_change = paid.x - paid.y,
        #case_change = case.x - case.y,
        reported_change = reported.x - reported.y
      ) %>%
      filter(paid_change >= 100000) %>%
      arrange(desc(paid_change))
    
    names(table2) <- c("Claim Number", "Account Date", "Claimant", "State", "Status", "Paid",
                       "Reported", "Paid", "Paid", "Reported")
    
    #Workbook
    to_download <- createWorkbook()
    
    addWorksheet(wb = to_download, sheetName = "Exhibit 1")
    addWorksheet(wb = to_download, sheetName = "Exhibit 2")
    
    setColWidths(
      to_download,
      1,
      cols = 1:6,
      widths = c(13,10,10,10,7,9)
    )
    
    setColWidths(
      to_download,
      2,
      cols = 1:11,
      widths = c(13, 12, 18, 6, 7, 9, 9, 9, 9, 9, 9)
    )
    
    lapply(1:10, function(x) {
    mergeCells(
      to_download,
      1,
      cols = 1:6,
      rows = x
    )})
    
    lapply(1:10, function(x) {
      mergeCells(
        to_download,
        2,
        cols = 1:5,
        rows = x
      )})
    
    insertImage(
      to_download,
      sheet = 1,
      file = "server/04-report-srv/images/tychobra_logo_blue_co_name.png",
      width = 4.61,
      height = 1.25,
      startRow = 1,
      startCol = 1,
      units = "in",
      dpi = 300
    )
    insertImage(
      to_download,
      sheet = 2,
      file = "server/04-report-srv/images/tychobra_logo_blue_co_name.png",
      width = 4.34,
      height = 1.25,
      startRow = 1,
      startCol = 1,
      units = "in",
      dpi = 300
    )
    
    writeData(
      to_download,
      1,
      "Example Client Name",
      startRow = 7,
      startCol = 1
    )
    
    writeData(
      to_download,
      1,
      "Workers' Compensation Claims Report",
      startRow = 8,
      startCol = 1
    )
    
    addStyle(
      to_download,
      sheet = 1,
      rows = 7:8,
      cols = 1,
      style = createStyle(fontSize = 20, textDecoration = "Bold", fontName = "Bahnschrift Light Condensed")
    )
    
    writeData(
      to_download,
      1,
      paste0("Date Evaluated as of ", format(input$val_date, "%B %d, %Y")),
      startRow = 9,
      startCol = 1
    )
    
    writeData(
      to_download,
      1,
      paste0("Report Generated on ", format(Sys.Date(), format = "%B %d, %Y")),
      startRow = 10,
      startCol = 1
    )
    
    addStyle(
      to_download,
      sheet = 1,
      rows = 9:10,
      cols = 1,
      style = createStyle(fontSize = 18, textDecoration = "Bold", fontName = "Bahnschrift Light Condensed")
    )
    
    writeData(
      to_download,
      2,
      "Example Client Name",
      startRow = 7,
      startCol = 1
    )
    
    writeData(
      to_download,
      2,
      "Workers' Compensation Claims Report",
      startRow = 8,
      startCol = 1
    )
    
    addStyle(
      to_download,
      sheet = 2,
      rows = 7:8,
      cols = 1,
      style = createStyle(fontSize = 20, textDecoration = "Bold", fontName = "Bahnschrift Light Condensed")
    )
    
    writeData(
      to_download,
      2,
      paste0("Date Evaluated as of ", format(input$val_date, "%B %d, %Y")),
      startRow = 9,
      startCol = 1
    )
    
    writeData(
      to_download,
      2,
      paste0("Report Generated on ", format(Sys.Date(), format = "%B %d, %Y")),
      startRow = 10,
      startCol = 1
    )
    
    addStyle(
      to_download,
      sheet = 2,
      rows = 9:10,
      cols = 1,
      style = createStyle(fontSize = 18, textDecoration = "Bold", fontName = "Bahnschrift Light Condensed")
    )
    
    
    writeData(
      to_download,
      1,
      table1,
      startRow = 14,
      startCol = 1
    )
    
    writeData(
      to_download,
      2,
      table2,
      startRow = 14,
      startCol = 1
    )
    
    addStyle(
      to_download,
      1,
      cols = 2:6,
      rows = 15:23,
      style = createStyle(numFmt = "COMMA"),
      gridExpand = TRUE
    )
    
    addStyle(
      to_download,
      2,
      cols = 6:11,
      rows = 15:21,
      style = createStyle(numFmt = "COMMA"),
      gridExpand = TRUE
    )
    
    saveWorkbook(to_download, file)
  }
)




