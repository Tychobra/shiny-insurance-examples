


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
  
  ### table tab
  output$trans_tbl <- DT::renderDataTable({
    out <- val_tbl() %>%
             dplyr::mutate(status = as.factor(status),
                           state = as.factor(state)) %>%
             dplyr::select(-payment, -transaction_date, -trans_num)
    
    datatable(
      out,
      rownames = FALSE,
      colnames = show_names(names(out)),
      extensions = "Buttons",
      filter = 'top',
      options = list(
        dom = 'Bfrtip',
        scrollX = TRUE,
        buttons = list(
          'colvis', 
          list(
            extend = 'collection',
            buttons = c('csv', 'excel', 'pdf'),
            text = 'Download'
          )
        )
      )
    ) %>%
      formatCurrency(
        columns = 7:9,
        currency = "",
        digits = 0
      )
  }, server = FALSE)

}
