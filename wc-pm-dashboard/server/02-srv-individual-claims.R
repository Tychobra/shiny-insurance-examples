
#### filter the data
ind_filters <- reactive({
  req(
    input$ind_exclude_below,
    is.numeric(input$ind_exclude_below),
    input$ind_type,
    input$ind_nature,
    input$ind_gender
  )
  
  dat %>%
    filter(status %in% input$ind_status,
           type %in% input$ind_type,
           payment_fit > input$ind_exclude_below,
           nature_code %in% input$ind_nature,
           gender %in% input$ind_gender)
})

ind_filters_sim <- reactive({
  req(
    input$ind_exclude_below,
    is.numeric(input$ind_exclude_below),
    input$ind_type,
    input$ind_nature,
    input$ind_gender
  )
  
  preds %>%
    filter(status %in% input$ind_status,
           type %in% input$ind_type,
           payment_fit > input$ind_exclude_below,
           nature_code %in% input$ind_nature,
           gender %in% input$ind_gender)
})


### Render value boxes
severity_calc <- reactive({
  ind_filters() %>%
    summarise(severity = mean(payment_fit),
              n = n()
    )
})

severity_sd_calc <- reactive({
  ind_filters_sim() %>%
    summarise(payment_sim = sd(payment_sim)) %>%
    pull(payment_sim)
})

output$ind_claim_cts <- renderValueBox({
  valueBox(
    value = severity_calc()$n %>% dollar_fmt(currency = ""),
    subtitle = "Claim Counts",
    icon = icon("folder-open")
  )
})

output$ind_severity <- renderValueBox({
  valueBox(
    value = severity_calc()$severity %>% dollar_fmt(),
    subtitle = "Severity",
    icon = icon("bar-chart")
  )
})

output$ind_severity_sd <- renderValueBox({
  valueBox(
    value = severity_sd_calc() %>% dollar_fmt(),
    subtitle = "Severity Standard Deviation",
    icon = icon("arrows-h")
  )
})

### render plots
claims_plot_prep <- reactive({
  
  if (input$ind_plot_groups == "status") {
    group_1 <- list(
      data = ind_filters() %>%
        filter(status == "O"),
      name = "Open"
    )
    group_2 <- list(
      data = ind_filters() %>%
        filter(status == "C"),
      name = "Closed"
    )
  }
  
  if (input$ind_plot_groups == "type") {
    group_1 <- list(
      data = ind_filters() %>%
        filter(type == "M"),
      name = "Medical Only"
    )
    group_2 <- list(
      data = ind_filters() %>%
        filter(type == "C"),
      name = "Lost Time"
    )
  }
  
  group_1$data_xts <- xts(x = group_1$data$payment_fit, order.by = group_1$data$doa)
  group_2$data_xts <- xts(x = group_2$data$payment_fit, order.by = group_2$data$doa)

  list(
    "group_1" = group_1,
    "group_2" = group_2
  )
})

output$indiv_claims_plot <- renderHighchart({
  req(input$ind_exclude_below,
      # check that there is data; TODO: refine this check to actually do something useful
      nrow(claims_plot_prep()$group_1$data) > 0,
      cancelOutput = TRUE)
  groups <- claims_plot_prep()
  
  handle_click <- JS("function(event) {
                       $('html, body').animate({scrollTop:$(document).height()}, 'slow');
                       Shiny.onInputChange('hc_clicked', {series: this.series.index, index: this.index});
                     }")
  
  highchart(type = "stock") %>%
    hc_chart(
      type = "scatter",
      zoomType = "xy"
    ) %>%
    hc_title(text = "Average Predicted Payment Per Claim") %>%
    hc_subtitle(text = "Between Age 1 and Age 2") %>%
    hc_legend(
      enabled = TRUE
    ) %>%
    hc_plotOptions(
      scatter = list(
        allowPointSelect = TRUE,
        marker = list(
          symbol = "circle"
        ),
        borderWidth = 0,
        tooltip = list(
          crosshairs = TRUE,
          pointFormat = 'Predicted Payment: <b>{point.y}</b><br/>DOA: <b>{point.x:%Y-%m-%d}</b><br/>'
        ),
        point = list(
          events = list(
            click = handle_click
          )
        )
      )
    ) %>%
    hc_rangeSelector(
      selected = 4
    ) %>%
    hc_xAxis(
      #title = list(text = "Accident Date"),
      type = 'datetime'
    ) %>%
    hc_yAxis(
      title = list(text = "Predicted Payment")
    ) %>%
    hc_add_series(
      data = groups$group_1$data_xts,
      name = groups$group_1$name
    ) %>%
    hc_add_series(
      data = groups$group_2$data_xts,
      name = groups$group_2$name
    )
})

sel_claim <- reactive({
  req(input$hc_clicked)
  # [[1]] is the series
  # [[2]] is the row in the data
  point_clicked <- input$hc_clicked
  groups <- claims_plot_prep()
  
  # identify the series that the claim is in
  series <- groups[[point_clicked[[1]] + 1]]$data
  
  # extract single claim from series
  out <- series[point_clicked[[2]] + 1, ]
  
  out
})

sel_sim <- reactive({
  sel_claim_num <- sel_claim()$claim_num
  
  preds %>% filter(claim_num == sel_claim_num)
})

output$indiv_claim_sim <- renderHighchart({
  req(sel_claim()$pd_incr_act)
  payment_act <- sel_claim()$pd_incr_act
  
  hchart(
    sel_sim()$payment_sim,
    breaks = 30
  ) %>%
    hc_title(text = paste0("Payment Simulation for Claim ", sel_claim()$claim_num)) %>%
    hc_subtitle(text = "Predicted Distribution of Possible Payments between Age 1 and 2") %>%
    hc_exporting(
      enabled = TRUE,
      buttons = tychobratools::hc_btn_options()
    ) %>%
    hc_legend(enabled = FALSE) %>%
    hc_xAxis(
      title = list(text = "Predicted Distribution of Payments"),
      plotLines = list(
        list(
          label = list(
            text = paste0("Actual =", format(round(payment_act, 0), big.mark = ","))
          ),
          color = "#FF0000",
          width = 2,
          value = payment_act,
          zIndex = 5
        )
      ),
      floor = -10,
      minRange = 100
    ) %>%
    hc_yAxis(
      title = list(text = "Number of Observations")
    )
})
  
clm_vals_prep <- reactive({
  clm <- sel_claim()
  
  out <- clm %>% dplyr::select(-val, -ay, -ic_required) %>%
    # format values
    mutate(
      prob_open = paste0(round(prob_open* 100, 1), "%"),
      doa = as.character(doa),
      status = ifelse(status == "O", "Open", "Closed"),
      pd_total = dollar_fmt(pd_total),
      case_total = dollar_fmt(case_total),
      gender = ifelse(gender == "M", "Male", "Female"),
      type = ifelse(type == "C", "Lost Time", "Medical Only"),
      status_act = ifelse(status_act == "O", "Open", "Closed"),
      pd_incr_act = dollar_fmt(pd_incr_act),
      payment_fit = dollar_fmt(payment_fit)
    ) %>%
    tidyr::gather(value = "Value", key = "Characteristic") %>%
    as.data.frame()
  
  left_join(out, display_names, by = c("Characteristic" = "name")) %>%
    mutate(Characteristic = display_name) %>%
    dplyr::select(-display_name)
})

output$clm_char_tbl <- DT::renderDataTable({
  out <- clm_vals_prep()
  
  DT::datatable(
    out,
    rownames = FALSE,
    options = list(
      ordering = FALSE,
      dom = "t",
      pageLength = nrow(out)
    )
  )
})
