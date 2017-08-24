# info box
observeEvent(input$rmv, {
  removeUI(
    selector = ".info-collapsible"
  )
})


dat_filtered <- reactive({
  req(input$ay_filter)
  preds %>%
    filter(ay %in% input$ay_filter,
           type %in% input$overview_type)
})

open_per_sim <- reactive({
  dat_filtered() %>%
    group_by(sim_num) %>%
    summarise(n_open = sum(status_sim))
})

actual_open <- reactive({
  actual_open <- dat %>%
    filter(ay %in% input$ay_filter,
           type %in% input$overview_type) %>%
    mutate(open = ifelse(status_act == "O", 1, 0))
  
  sum(actual_open$open)
})

payments_per_sim <- reactive({
  dat_filtered() %>%
    group_by(sim_num) %>%
    summarise(payment_sim = sum(payment_sim))
})

actual_payment <- reactive({
  req(input$ay_filter,
      input$overview_type)
  
  out <- dat %>%
    filter(year(doa) %in% input$ay_filter,
           type %in% input$overview_type)
  
  sum(out$pd_incr_act)
  
})

value_box_data <- reactive({
  if (input$metric == 'status') {
    out <- list(
      "predicted" = list(
        "data" = open_per_sim()$n_open %>% 
                   mean() %>%
                   round(0),
        "title" = "Average Predicted Open Claims"
      ),
      "sd" = list(
        "data" = open_per_sim()$n_open %>% 
          sd() %>%
          round(0),
        "title" = "Standard Deviation of Prediction"
      ),
      "actual" = list(
        "data" = actual_open(),
        "title" = "Actual Open Claims"
      )
    )
  }
  
  if (input$metric == "payment") {
     out <- list(
       "predicted" = list(
         "data" = payments_per_sim() %>% 
                    pull(payment_sim) %>% 
                    mean() %>% 
                    round(0) %>%
                    format(big.mark = ","),
         "title" = "Average Predicted Payments"
       ),
       "sd" = list(
         "data" = payments_per_sim() %>% 
                    pull(payment_sim) %>% 
                    sd() %>% 
                    round(0) %>%
                    format(big.mark = ","),
         "title" = "Standard Deviation of Prediction"
       ),
       "actual" = list(
         "data" = actual_payment() %>%
                    round(0) %>%
                    format(big.mark = ","),
         "title" = "Actual Claim Payments"
       )
     )
   }
  
  out
})


output$predicted_mean_open <- renderValueBox({
  vals <- value_box_data()$predicted
  
  valueBox(
    value = vals$data,
    subtitle = vals$title,
    icon = icon("bullseye")
  )
})

output$predicted_sd <- renderValueBox({
  vals <- value_box_data()$sd
  
  valueBox(
    value = vals$data,
    subtitle = vals$title,
    icon = icon("arrows-h")
  )
})

output$actual_open_claims <- renderValueBox({
  vals <- value_box_data()$actual
  
  valueBox(
    value = vals$data,
    subtitle = vals$title,
    icon = icon("check-square-o")
  )
})

output$open_per_sim_plot <- renderHighchart({
  
  hchart(open_per_sim()$n_open) %>%
    hc_title(text = "Claim Status Simulation") %>%
    hc_subtitle(text = "Predicting Status at Age 2 given data at Age 1") %>%
    hc_exporting(
      enabled = TRUE,
      buttons = tychobratools::hc_btn_options()
    ) %>%
    hc_legend(enabled = FALSE) %>%
    
    hc_xAxis(
      title = list(text = "Simulated Number of Open Claims"),
      plotLines = list(
        list(
          label = list(
            text = paste0("Actual Open at Age 2 =", format(round(actual_open(), 0), big.mark = ","))
          ),
          color = "#FF0000",
          width = 2,
          value = actual_open(),
          zIndex = 5
        )
      )
    ) %>%
    hc_yAxis(
      title = list(text = "Number of Observations")
    )
})

output$payment_per_sim_plot <- renderHighchart({
  
  hchart(payments_per_sim()$payment_sim) %>%
    hc_title(text = "Claim Payments Simulation") %>%
    hc_subtitle(text = "Between Age 1 and Age 2") %>%
    hc_exporting(
      enabled = TRUE,
      buttons = tychobratools::hc_btn_options()
    ) %>%
    hc_legend(enabled = FALSE) %>%
    hc_xAxis(
      title = list(text = "Simulated Payments"),
      plotLines = list(
        list(
          label = list(
            text = paste0("Actual =", format(round(actual_payment(), 0), big.mark = ","))
          ),
          color = "#FF0000",
          width = 2,
          value = actual_payment(),
          zIndex = 5
        )
      )
    ) %>%
    hc_yAxis(
      title = list(text = "Number of Observations")
    )
})
