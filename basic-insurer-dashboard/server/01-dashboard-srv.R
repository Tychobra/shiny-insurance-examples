### dashboard tab
dash_filters <- reactive({
  req(input$dash_status,
      input$dash_cutoff,
      input$dash_state)
  
  out <- val_tbl() %>%
    filter(reported >= input$dash_cutoff,
           state %in% input$dash_state)
  
  req(nrow(out) > 0)
  
  out
})

dash_metric <- reactive({
  
  hold <- dash_filters() %>%
            mutate(year = lubridate::year(accident_date))
  
  if (input$dash_metric %in% c("total", "severity")) {
    hold <- hold %>%
              filter(status %in% input$dash_status) %>%
              group_by(year) %>%
              summarise(paid = sum(paid),
                        case = sum(case),
                        reported = sum(reported),
                        n = n())
    if (input$dash_metric == "severity") {
      hold <- hold %>%
        # need to keep totals so that we can calculate weighted avg total
        # severity accurately for value boxes
        mutate(paid_total = paid,
               case_total = case,
               reported_total = reported,
               paid = paid_total / n,
               case = case_total / n,
               reported = reported_total / n)
    }
  } else {
    hold <- hold %>%
      group_by(year, status) %>%
      summarise(n = n()) %>%
      tidyr::spread(key = status, value = n, fill = 0) %>%
      rename(paid = Closed,
             case = Open) %>%
      mutate(reported = paid + case) %>%
      ungroup()
  }
  
  hold
})




dash_metric_boxes <- reactive({
  dat <- dash_metric() 
  dash_metric_input <- input$dash_metric
  
  dat <- dat %>%
    summarise(paid = sum(paid),
              case = sum(case),
              reported = sum(reported),
              n = n())
  
  if (dash_metric_input == "severity") {
    dat <- dat %>%
      mutate(paid = paid / n,
             case = case / n,
             reported = reported / n)
  }
  
  titles <- switch(
    dash_metric_input,
    "total" = c("Paid Loss & ALAE", "Case Reserve", "Reported Loss & ALAE"),
    "severity" = c("Paid Severity", "Case Reserve Severity", "Reported Severity"),
    "claims" = c("Closed Claim Counts", "Open Claim Counts", "Reported Claim Counts")
  )
  
  list(
    "dat" = dat,
    "titles" = titles
  )
})

output$paid_box <- renderValueBox({
  out <- dash_metric_boxes()
  valueBox2(
    format(round(out$dat$paid, 0), big.mark = ","),
    subtitle = out$titles[1],
    icon = icon("money"),
    backgroundColor = "#434348"
  )
})

output$case_box <- renderValueBox({
  out <- dash_metric_boxes()
  valueBox2(
    format(round(out$dat$case, 0), big.mark = ","),
    subtitle = out$titles[2],
    icon = icon("university"),
    backgroundColor = "#7cb5ec"
  )
})

output$reported_box <- renderValueBox({
  out <- dash_metric_boxes()
  valueBox2(
    format(round(out$dat$reported, 0), big.mark = ","),
    subtitle = out$titles[3],
    icon = icon("clipboard"),
    backgroundColor = "#f7a35c"
  )
})


ay_plot_prep <- reactive({
  dash_metric_input <- input$dash_metric
  val_date <- input$val_date
  status <- if (length(input$dash_status) == 2) "All" else paste0(input$dash_status, collapse=", ")
  states <- if (length(input$dash_state) == 4) "All" else paste0(input$dash_state, collapse=", ")
  cutoff <- input$dash_cutoff
  
  subtitle <- paste0(
    "Status: ", status, "; States: ", states, "; Excluding Claims Below: ", cutoff
  )
  
  titles <- switch(
    dash_metric_input,
    "total" = list(
      "title" = paste0("Reported Loss & ALAE as of ", val_date),
      "subtitle" = subtitle,
      "series" = c("Paid", "Case Reserve"),
      "y_axis" = "Loss & ALAE"
    ),
    "severity" = list(
      "title" = paste0("Reported Severity as of ", val_date),
      "subtitle" = subtitle,
      "series" = c("Paid Severity", "Case Reserve Severity"),
      "y_axis" = "Loss & ALAE"
    ),
    "claims" = list(
      "title" = paste0("Reported Claims as of ", val_date),
      "subtitle" = paste0("States: ", states, "; Excluding Claims Below: ", cutoff),
      "series" = c("Closed Claims", "Open Claims"),
      "y_axis" = "Claim Counts"
    )
  )
  
  list(
    "dat" = dash_metric(),
    "titles" = titles
  )
})

output$ay_plot <- renderHighchart({
  dat <- ay_plot_prep()$dat
  titles <- ay_plot_prep()$titles
  
  highchart() %>%
    hc_chart(type = "column") %>%
    hc_exporting(
      enabled = TRUE,
      buttons = tychobratools::hc_btn_options()
    ) %>%
    hc_legend(
      reversed = TRUE
    ) %>%
    hc_title(text = titles$title) %>%
    hc_subtitle(text = titles$subtitle) %>%
    hc_xAxis(
      categories = dat$year,
      title = list(text = "Accident Year")
    ) %>%
    hc_yAxis(
      title = list(text = titles$y_axis),
      stackLabels = list(
        enabled = TRUE,
        style = list(
          fontWeight = "bold",
          color = "#f7a35c",
          textOutline = NULL
        ),
        format = "{total:,.0f}"
      )
    ) %>%
    hc_plotOptions(
      column = list(stacking = 'normal')
    ) %>%
    hc_add_series(
      data = round(dat$case, 0),
      name = titles$series[2]
    ) %>%
    hc_add_series(
      data = round(dat$paid, 0),
      name = titles$series[1]
    ) 
})
