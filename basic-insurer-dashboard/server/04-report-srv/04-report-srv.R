output$generate_pdf_report <- downloadHandler(
  # For PDF output, change this to "report.pdf"
  filename = function(){
    paste0("claims-report-as-of-", input$val_date, ".pdf")
  },
  content = function(file) {
    removeModal()
    
    # Copy the report file to a temporary directory before processing it, in
    # case we don't have write permissions to the current working dir (which
    # can happen when deployed).
    #tempReport <- file.path(tempdir(), "report.Rmd")
    
    #file.copy("report.Rmd", tempReport, overwrite = TRUE)
    
    # Set up parameters to pass to Rmd document
    params_ <- list(
      data = trans, 
      val_date = ymd(input$val_date)
    )
    
    # Knit the document, passing in the `params` list, and eval it in a
    # child of the global environment (this isolates the code in the document
    # from the code in this app).
    withProgress(
      rmarkdown::render(
        "server/04-report-srv/claims_report.Rmd", 
        output_file = file,
        params = params_,
      ),
      message = "Generating PDF Report..."
    )
    
    #sendSweetAlert(session = session,
    #               title = "Success!",
    #               text = paste0("Report for ", member_(), " successfully generated!"),
    #               type = "success")
  }
)