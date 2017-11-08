function(input, output) {
  #output$debuggin <- renderPrint({
  #  group_by_fy()
  #  #per_day()
  #}) 
  
  policies <- reactive({
    start_date <- input$effective_dates[1]
    end_date <- input$effective_dates[2]
    
    num_days <- as.numeric(end_date - start_date)
    
    policy_dur <- as.numeric(input$policy_duration)
    # one policy written each day during and before period
    policy_effective_dates <- start_date + days(-policy_dur:num_days)
    
    policies <- data_frame(
      effective_date = rep(policy_effective_dates, each = policy_dur),
      # each policy is 1 exposure
      # this can be adjusted to simulate e.g. a decrease in exposure after a rate increase
      exposure_weight = 1,
      age = rep(0:(policy_dur - 1), times = length(policy_effective_dates)),
      rate = 1
    )
    
    policies %>%
      mutate(in_force_date = effective_date + days(age)) %>%
      select(-age)
  })
  
  rate_change_inputs <- reactive({
    changes <- 1:rate_change_counter()
    
    out <- lapply(changes, function(i) {
      req(input[[paste0("rate_date_", i)]])
      list(
        date = input[[paste0("rate_date_", i)]],
        rate_change = input[[paste0("rate_change_", i)]],
        exposure_change = input[[paste0("exposure_change_", i)]]
      )
    })
  })
  
  rate_change_calc <- reactive({
   
    rate_inputs <- rate_change_inputs()
    print(rate_inputs)
    hold <- policies()
    
    for (i in seq_along(rate_inputs)) {
      hold <- hold %>%
        mutate(
          # simulate a rate change
          rate = ifelse(effective_date >= rate_inputs[[i]]$date, rate * (1 + rate_inputs[[i]]$rate_change / 100), rate),
          # simulate decrease in exposure
          exposure_weight = ifelse(effective_date >= rate_inputs[[i]]$date, exposure_weight * (1 + rate_inputs[[i]]$exposure_change / 100), exposure_weight)
        ) %>%
        filter(
          in_force_date >= input$effective_dates[1],
          in_force_date <= input$effective_dates[2]
        )
    }
    hold
  })
  
  per_day <- reactive({
    rate_change_calc() %>%
      group_by(in_force_date, rate) %>%
      summarise(exposure = sum(exposure_weight)) %>%
      mutate(
        exposure_pct = exposure / sum(exposure),
        premium = exposure * rate,
        premium_pct = premium / sum(premium)) 
  })
  
  fy_ends <- reactive({
    all_years <- year(input$effective_dates[1]):year(input$effective_dates[2])
    
    all_fy_ends <- vector("character", length = length(all_years))
    for (i in seq_along(all_years)) {
      all_fy_ends[i] <- as.character(paste0(all_years[i], "-", input$fy_end))
    }
    
    all_fy_ends
  })
  
  y_lab <- reactive({
    switch(input$plot_metric,
           "exposure_pct" = list(
             title = "% of in force exposure",
             format = function(x) round(x * 100, 1) %>% paste0("%")
           ), 
           "exposure" = list(
             title = "Total Exposure Units",
             format = function(x) x
           ),
           "premium_pct" = list(
             title = "% of earned premium",
             format = function(x) round(x * 100, 1) %>% paste0("%")
           ),
           "premium" = list(
             title = "Total Exposure Units",
             format = function(x) paste0("$", x)
           )
    )
  })
  
  output$para_plot <- renderPlot({
    
    hold <- per_day()
    hold$rate <- as.factor(round(hold$rate, 4))
    hold_fy_ends <- fy_ends()
    hold_y_lab <- y_lab()
    
    
    metric <- input$plot_metric
    ggplot(hold, aes_string(x = "in_force_date", y = input$plot_metric, fill = "rate")) + 
      geom_area(alpha = 0.75) +
      labs(fill='Rate Level') +
      ylab(hold_y_lab$title) +
      scale_y_continuous(labels = hold_y_lab$format) +
      xlab("") +
      theme_minimal() + 
      geom_vline(xintercept = as.Date(hold_fy_ends), alpha = 0.5, linetype = "dashed") 
    
  })
  
  group_by_fy <- reactive({
    fy_ending_month <- substr(input$fy_end, 1, 2) %>%
                         as.numeric()
    
    
    per_day() %>%
      mutate(
        fy = ifelse(month(in_force_date) <= fy_ending_month, year(in_force_date), year(in_force_date) + 1),
        weighted_exposure = exposure * rate) %>%
      ungroup() %>%
      group_by(fy) %>%
      summarise(
        exposure = sum(exposure),
        exposure_weighted = sum(weighted_exposure),
        rate_factor = exposure_weighted / exposure,
        premium = sum(premium)) %>%
      select(fy, rate_factor, premium)
  })
  
  output$rate_tbl <- DT::renderDataTable({
    hold <- group_by_fy()
    
    hold_fy_end <- gsub(pattern = "-", replacement = "/", x = input$fy_end, fixed = TRUE)
    hold$fy <- paste0(hold_fy_end, "/", hold$fy)
    
    DT::datatable(
      hold,
      rownames = FALSE,
      colnames = c(
        "Fiscal Year Ending",
        "AVG EP Rate Level",
        "Earned Premium"
      ),
      selection = "none",
      extensions = "Buttons",
      options = list(
        dom = "Bt",
        buttons = c("excel", "csv"),
        ordering = FALSE,
        columnDefs = list(
          list(targets = 0, class = "dt-center")
        ),
        pageLength = nrow(hold)
      )
    ) %>%
      formatCurrency(
        col = 3,
        digits = 0,
        currency = ""
      ) %>%
      formatRound(
        col = 2,
        digits = 4
      )
  })
  
  rate_change_counter <- reactiveVal(value = 1)
  
  observeEvent(input$add_rate_change, {
    # increment number of rate changes in `rate_change_counter``
    num <- rate_change_counter() + 1
    rate_change_counter(num)
    print(rate_change_counter())
    insertUI(
      selector = "#rate_changes",
      where = "beforeEnd",
      ui = fluidRow(
        id = paste0("rate_", num),
        column(
          width = 4,
          dateInput(
            paste0("rate_date_", num),
            label = NA,
            value = as.Date("2016-07-01") + lubridate::years(num - 1),
            format = "mm/dd/yyyy",
            startview = "year"
          )
        ),
        column(
          width = 4,
          numericInput(
            paste0("rate_change_", num),
            label = NULL,
            value = 5
          )
        ),
        column(
          width = 4,
          numericInput(
            paste0("exposure_change_", num),
            label = NULL,
            value = -5
          )
        )
      )
    )
  }, priority = 10)
  
  observeEvent(input$remove_rate_change, {
    num <- rate_change_counter()
    
    id <- paste0("#rate_", num)
    
    removeUI(
      selector = id
    )
    
    # decrement `rate_change_counter()`
    rate_change_counter(num - 1)
  })
  
  observeEvent(rate_change_counter(), {
    if (rate_change_counter() == 1) {
      shinyjs::disable(id = "remove_rate_change")
    } else {
      shinyjs::enable(id = "remove_rate_change")
    }
  })
}