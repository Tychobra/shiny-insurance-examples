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
      ph_with_img_at(
        src = "server/04-report-srv/images/tychobra_logo_blue_co_name.png",
        height = 1.5,
        width = 4,
        left = 3,
        top = 0
      ) %>% 
      add_slide(layout = "Blank", master = "Office Theme") %>% 
      ph_with_text(
        type = "ftr",
        str = c(
          "Exhibit 1",
          "Summary of Loss & ALAE",
          paste0("Evaluated as of ", format(input$val_date, "%B %d, %Y"))
          )
      ) %>% 
      ph_with(
        value = data.frame(x = 1:2),
        location = ph_location_fullsize()
      ) %>%
      add_slide(layout = "Title and Content", master = "Office Theme") %>% 
      ph_with_table_at(
        value = data.frame(y = 5:10),
        left = 2,
        top = 0.5,
        width = 4,
        height = 5
      ) %>% 
      ph_with_text(
        type = "dt",
        str = c(
          "Exhibit 2",
          "Claims with charge in paid >= 100,000",
          paste0("Evaluated as of ", format(input$val_date, "%B %d, %Y"))
        )
      )
      
    
    print(example_ppt, target = file)
  }
)