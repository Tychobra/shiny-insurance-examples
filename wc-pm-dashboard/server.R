
function(input, output, session) {
  
  output$debuggin <- renderPrint({
    
  })
  
  source("./server/01-srv-overview.R", local = TRUE)
  source("./server/02-srv-individual-claims.R", local = TRUE)
  source("./server/03-srv-tour.R", local = TRUE)
}

