


#' loss_run
#' 
#' view losses as of a specific date
#' 
#' @param val_date
#' 
loss_run <- function(val_date) {
  trans %>%
    filter(transaction_date <= val_date) %>%
    group_by(claim_num) %>%
    top_n(1, wt = trans_num) %>%
    ungroup() %>%
    mutate(reported = paid + case) %>%
    arrange(desc(transaction_date))
}


function(input, output) {
  
  
  val_tbl <- reactive({
    req(input$val_date)
    loss_run(input$val_date)
  })
  
  source("server/01-dashboard-srv.R", local = TRUE)
  source("server/02-changes-srv.R", local = TRUE)
  source("server/03-claims-srv.R", local = TRUE)

}
