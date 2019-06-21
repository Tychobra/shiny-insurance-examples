output$generate_ppt_report <- downloadHandler(
  
  filename = function() {
    paste0("claims-report-as-of-", input$val_date, ".pptx")
  },
  
  content = function(file) {
    removeModal()

    
    example_ppt <- read_pptx() %>% 
      add_slide(layout = "Title Slide", master = "Office Theme") %>%
      ph_with_text(
        type = "ctrTitle", 
        str = c(
          "Example Client Name",
          "Workers' Compensation Claims Report")
        ) %>% 
      ph_with_text(
        type = "subTitle",
        str = c(
          paste0("Data Evaluated as of ", format(input$val_date, "%B %d, %Y")),
          paste0("Report Generated on ", format(Sys.Date(), "%B %d, %Y"))
        )
      ) %>% 
      ph_with_img(
        type = "ftr",
        src = "server/04-report-srv/images/tychobra_logo_blue_co_name.png"
      )
    
    print(example_ppt, target = file)
  }
)