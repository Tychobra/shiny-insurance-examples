### table tab
output$trans_tbl <- DT::renderDT({
  out <- val_tbl() %>%
    dplyr::mutate(status = as.factor(status),
                  state = as.factor(state)) %>%
    dplyr::select(-payment, -transaction_date, -trans_num)
  
  datatable(
    out,
    rownames = FALSE,
    class = "cell-border stripe compact",
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
      ),
      pageLength = 15
    )
  ) %>%
    formatCurrency(
      columns = 7:9,
      currency = "",
      digits = 0
    )
}, server = FALSE)
