output$generate_excel_report <- downloadHandler(
  filename = function(){
    paste0("claims-report-as-of-", input$val_date, ".xlsx")
  },
  content = function(file) {
    removeModal()
    
    
    eval_ <- input$val_date
    
    lr_current <- val_tbl()
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
      summaryrow::blank_row() %>%
      summaryrow::totals_row(
        cols = 2:6,
        label_col = 1
      )
    
    names(table1) <- c("Accident Year", "Paid", "Case", "Reported", "Open", "Reported")
    
    #
    #table 2
    #
    
    out <- lr_current %>%
      select(claim_num, accident_date, claimant, state, status, paid, reported)
    
    lr_prior_out <- lr_prior %>%
      select(claim_num, paid, reported)
    
    table2 <- out %>%
      left_join(lr_prior_out, by = "claim_num") %>%
      mutate(
        paid_change = paid.x - paid.y,
        reported_change = reported.x - reported.y
      ) %>%
      filter(paid_change >= 100000) %>%
      arrange(desc(paid_change)) %>%
      summaryrow::blank_row() %>%
      summaryrow::totals_row(
        cols = 10:11,
        label_col = 1
      )
    
    names(table2) <- c(
      "Claim Number", 
      "Accident Date", 
      "Claimant", 
      "State", 
      "Status", 
      rep(c("Paid", "Reported"), times = 3)
    )
    
    ##
    #Workbook
    ##
    
    to_download <- createWorkbook()
    
    addWorksheet(wb = to_download, sheetName = "Cover Page")
    addWorksheet(wb = to_download, sheetName = "Exhibit 1")
    addWorksheet(wb = to_download, sheetName = "Exhibit 2")
    
    
    #Set table widths
    
    setColWidths(
      to_download,
      2,
      cols = 1:6,
      widths = c(12, 12, 12, 12, 12, 12)
    )
    
    setColWidths(
      to_download,
      3,
      cols = 1:11,
      widths = c(13, 12, 18, 9, 9, 9, 9, 9, 9, 9, 9)
    )
    
    #Merge top rows to be the width of the first 6 (sheet 1) or 5 (sheet 2) columns
    
    
    ### Cover Page
    insertImage(
      to_download,
      sheet = 1,
      file = "server/04-report-srv/images/tychobra_logo_blue_co_name.png",
      width = 5,
      height = 1.25,
      startRow = 1,
      startCol = 1,
      units = "in",
      dpi = 300
    )
    
    writeData(
      to_download,
      sheet = 1,
      c(
        "  Example Client Name",
        "  Workers' Compensation Report",
        paste0("   Evaluated as of ", format(input$val_date, "%B %d, %Y")),
        paste0("   Report Generated ", format(Sys.Date(), "%B %d, %Y"))
      ),
      startRow = 10,
      startCol = 1
    )
    addStyle(
      to_download,
      sheet = 1,
      rows = 10:11,
      cols = 1,
      style = createStyle(
        fontSize = "24",
        textDecoration = "bold"
      )
    )
    addStyle(
      to_download,
      sheet = 1,
      rows = 12:13,
      cols = 1,
      style = createStyle(
        fontSize = "18"
      )
    )
    showGridLines(
      to_download,
      sheet = 1,
      showGridLines = FALSE
    )
    
    # Exhibits I and II
    writeData(
      to_download,
      sheet = 2,
      x = c(
        "Example Client Name",
        "Workers' Compensation Claims Report",
        "Summary of Loss and ALAE",
        paste0("Evaluated as of ", format(input$val_date, "%B %d, %Y"))
      )
    )
    writeData(
      to_download,
      sheet = 3,
      x = c(
        "Example Client Name",
        "Workers' Compensation Claims Report",
        "Claims with Change in Paid >= 100K",
        paste0("Evaluated as of ", format(input$val_date, "%B %d, %Y"))
      )
    )
    
    excel_helpers$exhibit_header_right(
      to_download,
      sheet = 2,
      start_row = 1,
      start_col = 6,
      x = c(
        "Exhibit I",
        "Sheet 1"
      )
    )
    excel_helpers$exhibit_header_right(
      to_download,
      sheet = 3,
      start_row = 1,
      start_col = 11,
      x = c(
        "Exhibit II",
        "Sheet 1"
      )
    )
    
    #Tables and formatting
    
    writeData(
      to_download,
      2,
      table1,
      startRow = 9,
      startCol = 1,
      headerStyle = createStyle(
        textDecoration = "Bold", 
        halign = "center",
        border = "bottom"
      )
    )
    
    writeData(
      to_download,
      3,
      table2,
      startRow = 9,
      startCol = 1,
      headerStyle = createStyle(
        textDecoration = "Bold", 
        halign = "center",
        border = "bottom"
      )
    )
    
    excel_helpers$create_header_row(
      to_download,
      2,
      list(
        list("Loss & ALAE", 3),
        list("Number of Claims", 2)
      ),
      startRow = 8,
      startCol = 2
    )
    
    excel_helpers$create_header_row(
      to_download,
      3,
      list(
        list(paste0("As of ", format(input$val_date, "%B %d, %Y")), 2),
        list(paste0("As of ", format(input$val_date - years(1), "%B %d, %Y")), 2),
        list("Change", 2)
      ),
      startRow = 8,
      startCol = 6
    )
    
    addStyle(
      to_download,
      2,
      cols = 2:6,
      rows = 10:19,
      style = createStyle(numFmt = "COMMA"),
      gridExpand = TRUE
    )
    addStyle(
      to_download,
      2,
      cols = 1,
      rows = 10:19,
      style = createStyle(halign = "center"),
      gridExpand = TRUE
    )
    
    addStyle(
      to_download,
      3,
      cols = 6:11,
      rows = 10:19,
      style = createStyle(numFmt = "COMMA"),
      gridExpand = TRUE
    )
    
    addStyle(
      to_download,
      3,
      cols = 1,
      rows = 10:19,
      style = createStyle(halign = "center"),
      gridExpand = TRUE
    )
    
    
    
    saveWorkbook(to_download, file)
  }
)
