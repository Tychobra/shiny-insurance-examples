
function(input, output, session) {
  
  
  val_tbl <- reactive({
    req(input$val_date)
    loss_run(input$val_date)
  })
  
  source("server/01-dashboard-srv.R", local = TRUE)
  source("server/02-changes-srv.R", local = TRUE)
  source("server/03-claims-srv.R", local = TRUE)
  
  source("server/04-report-srv/04-report-srv.R", local = TRUE)
  source("server/04-report-srv/04-modal-srv.R", local = TRUE)
  source("server/04-report-srv/04-powerpoint-srv.R", local = TRUE)
  source("server/04-report-srv/04-excel-srv.R", local = TRUE)

}
