
function(input, output, session) {
  
  output$debuggin <- renderPrint({
    #input$hc_clicked
    #sel_claim()
    clm_vals_prep()
  })
  
  source("./server/01-srv-overview.R", local = TRUE)
  source("./server/02-srv-individual-claims.R", local = TRUE)
  source("./server/03-srv-tour.R", local = TRUE)
  
  #observeEvent(input$tour, {
  #  introjs(
  #    session#,
      # TODO: custom shiny input for onchange
      #events = list(
      #  "onchange" = "console.log('Hello there', this._currentStep)"
      #)
  #  )
    
    # move to overview dashboard tab
    #updateTabsetPanel(session, inputId = "sidebar", selected = "dashboard")
  #})
  
  #observeEvent(input$tour_claims, {
  #  introjs(session)
  #})
}

