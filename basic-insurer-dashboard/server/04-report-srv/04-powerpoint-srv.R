output$generate_ppt_report <- downloadHandler(
  
  filename = function() {
    paste0("claims-report-as-of-", input$val_date, ".pptx")
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
    
    footers = as.character(as.vector(table1[10,]))
    for (i in 2:6) {
      footers[[i]] <- format(as.numeric(footers[[i]]), big.mark = ",")
    }
    
    table1 <- table1[1:8, ]
    
    names(table1) <- c("Accident Year", "Paid", "Case", "Reported1", "Open", "Reported2")

    table1 <- flextable(table1) %>% 
      set_header_labels(Reported1 = "Reported", Reported2 = "Reported") %>% 
      add_header_row(
        top = TRUE,
        values = c(
          "",
          rep("Loss & ALAE", 3),
          rep("Number of Claims", 2)
        ) 
      ) %>% 
      merge_h(part = "header") %>% 
      add_footer_row(values = footers, colwidths = rep(1, 6)) %>% 
      width(width = 1.25) %>% 
      height_all(height = 0.5) %>% 
      colformat_num(col_keys = c("Paid", "Case", "Reported1", "Open"),
                    big.mark = ",", digits = 0) %>% 
      theme_booktabs() %>% 
      align(align = "center", part = "header")
      
    
    #table 2
    
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
    
    table2 <- table2[1:4,]
    
    names(table2) <- c(
      "Claim Number", 
      "Accident Date", 
      "Claimant", 
      "State", 
      "Status", 
      "Paid1",
      "Reported1",
      "Paid2",
      "Reported2",
      "Paid3",
      "Reported3"
    )

    table2 <- flextable(table2) %>% 
      set_header_labels(Paid1 = "Paid", Paid2 = "Paid", Paid3 = "Paid",
                        Reported1 = "Reported", Reported2 = "Reported", Reported3 = "Reported") %>% 
      add_header_row(
        top = TRUE, 
        values = c(
          rep("", 5),
          rep(paste0("As of ", format(input$val_date, "%B %d, %Y")), 2),
          rep(paste0("As of ", format(input$val_date - years(1), "%B %d, %Y")), 2),
          rep("Change", 2)
        )
      ) %>% 
      merge_h(part = "header") %>% 
      width(width = 0.8) %>% 
      height_all(height = 0.75) %>% 
      colformat_num(col_keys = c("Paid1", "Reported1", "Paid2",
                                 "Reported2", "Paid3", "Reported3"),
                    big.mark = ",", digits = 0) %>% 
      theme_booktabs() %>% 
      align(align = "center", part = "header")
    
    ppt_report <- read_pptx() %>% 
      add_slide(layout = "Title Slide", master = "Office Theme") %>%
      ph_with_text(
        type = "ctrTitle", 
        str = c(
          "Example Client Name",
          "Workers' Compensation Claims Report")
        ) %>% 
      ph_with(
        location = ph_location_type(type = "subTitle"),
        value = c(
          paste0("Data Evaluated as of ", format(input$val_date, "%B %d, %Y")),
          paste0("Report Generated on ", format(Sys.Date(), "%B %d, %Y"))
        )
      ) %>% 
      ph_with_img_at(
        src = "server/04-report-srv/images/tychobra_logo_blue_co_name.png",
        height = 1.5,
        width = 6,
        left = 2,
        top = 0
      ) %>% 
      add_slide(layout = "Blank", master = "Office Theme") %>% 
      ph_with(
        location = ph_location_type(type = "ftr"),
        value = c(
          "Exhibit 1",
          "Summary of Loss & ALAE",
          paste0("Evaluated as of ", format(input$val_date, "%B %d, %Y"))
          )
      ) %>% 
      ph_with_flextable_at(
        value = table1,
        left = 1.3,
        top = 0.6
      ) %>%
      add_slide(layout = "Title and Content", master = "Office Theme") %>% 
      ph_with(
        location = ph_location_type(type = "ftr"),
        value = c(
          "Exhibit 2",
          "Claims with charge in paid >= 100,000",
          paste0("Evaluated as of ", format(input$val_date, "%B %d, %Y"))
        )
      ) %>% 
      ph_with_flextable_at(
        value = table2,
        left = 0.55,
        top = 1
      )
      
    
    print(ppt_report, target = file)
  }
)