function(input, output) {
  
  states_filtered <- reactive({
    states %>%
      filter(
        period %in% input$period_filter,
        claim_type %in% input$type_filter) %>%
      group_by(state) %>%
      summarise(value = sum(avg_state))
  })
  
  init_states <- data_frame("abb" = character(0), "name" = character(0))
  sel_states_val <- reactiveVal(value = init_states)
  
  observeEvent(input$sel_state, {
    current_selection <- sel_states_val()
    updated_selection <- list(as_tibble(input$sel_state[c("abb", "name")]), current_selection)
    sel_states_val(dplyr::bind_rows(updated_selection))
  })
  
  observeEvent(input$unsel_state, {
    updated_selection <- sel_states_val() %>%
      filter(abb != input$unsel_state$abb)
    sel_states_val(updated_selection)
  })
  
  # clear selected states after filter applied
  observeEvent(states_filtered(), {
    sel_states_val(init_states)
  })
  
  output$states_map <- renderHighchart({
    hold_states <- states_filtered()
    
    state_select = JS("function(event) {
       Shiny.onInputChange('sel_state', { abb: event.target['hc-a2'], name: event.target.name, nonce: Math.random() });
    }")
    
    state_unselect = JS("function(event) {
      // Queue is defined in www/sender-queue.js
      queue.send('unsel_state', { abb: event.target['hc-a2'], nonce: Math.random()})
    }")
    
    highchart(type = "map") %>%
      hc_exporting(
        enabled = TRUE,
        buttons = tychobratools::hc_btn_options()
      ) %>%
      hc_add_series(
        mapData = mapdata, 
        data = list_parse(hold_states), 
        joinBy = c("hc-a2", "state"),
        allAreas = FALSE,
        dataLabels = list(enabled = TRUE, format = '{point.value:,.0f}'),
        name = "Spending by Claim",
        tooltip = list(
          valueDecimals = 0, 
          valuePrefix = "$"
        )
      ) %>% 
      hc_plotOptions(
        series = list(
          allowPointSelect = TRUE,
          states = list(
            select = list(
              color = "#32cd32"
            )
          ),
          point = list(
            events = list(
              unselect = state_unselect,
              select = state_select
            )
          )
        )        
      ) %>%
      hc_colorAxis(auxpar = NULL) %>%
      hc_title(text = "Madicare Spending by Claim") %>%
      hc_subtitle(text = "2015 Q4")
  })
  
  hospitals_filtered <- reactive({
    
    out <- hospitals %>%
      filter(
        period %in% input$period_filter,
        claim_type %in% input$type_filter) 
    
    
    # filter by selected state if a state is clicked on
    if (nrow(sel_states_val()) > 0) {
      out <- out %>%
        filter(state %in% sel_states_val()$abb)
    }
    
    out
  })
  
  hospitals_grouped <- reactive({
    hospitals_filtered() %>%
      select(-state) %>%
      group_by(hospital, provider_id) %>%
      summarise(
        value = sum(avg_hospital)
      ) %>%
      arrange(desc(value)) 
  })
  
  output$hospitals_tbl_title <- renderText({
    if (nrow(sel_states_val()) == 0) {
      out <- "Nationwide Hospitals"
    } else {
      state_names <- paste(sel_states_val()$name, collapse = ", ")
      out <- paste0(state_names, " Hospitals")
    }
    out
  })
  
  output$hospitals_tbl <- DT::renderDataTable({
    
    DT::datatable(
      hospitals_grouped(),
      selection = list(
        mode = 'single',
        selected = 1
      ),
      colnames = c(
        "Hospital",
        "Provider ID",
        "Total Average Spending (All categories)"
      ),
      rownames = FALSE,
      options = list(
        dom = 'tp'
      )
    ) %>%
      formatCurrency(
        column = 3,
        currency = "",
        digits = 0
      )
  })
  
  output$sel_state_name <- renderText({
    if (nrow(sel_states_val()) == 0) {
      "Nation"
    } else {
      paste0(sel_states_val()$name, collapse = ", ")
    }
  })
  
  state_provider_counts <- reactive({
    hospitals_filtered() %>%
      summarise(
        n_hospitals = n_distinct(hospital),
        n_providers = n_distinct(provider_id)
      ) 
  })
  
  state_provider_stats <- reactive({
    hospitals_grouped() %>%
      ungroup() %>%
      summarise(
        median_value = median(value),
        max_value = max(value),
        min_value = min(value)
      )
  })
  
  nation_provider_stats <- reactive({
    states_filtered() %>%
      ungroup() %>%
      summarise(
        median_value = median(value),
        max_value = max(value),
        min_value = min(value)
      )
  })
  
  output$state_locations <- DT::renderDataTable({
    counts <- state_provider_counts() %>%
      gather(key = "key", value = "value")
    
    out <- counts %>%
      mutate(key = c("# Hospitals", "# Providers"))
    
    col_headers <- htmltools::withTags(table(
      class = 'display',
      thead(
        tr(
          th(colspan = 2, 'Locations')
        )
      )
    ))
    
    datatable(
      out,
      rownames = FALSE,
      container = col_headers,
      options = list(
        ordering = FALSE,
        dom = 't'
      ),
      selection = "none"
    ) %>%
      formatCurrency(
        column = 2,
        currency = "",
        digits = 0
      )
  })
  
  
  output$state_meta_tbl <- DT::renderDataTable({
    
    state <- state_provider_stats() %>%
      gather(key = "key", value = "value")
    
    out <- state %>%
      mutate(key = c("Median Provider", 
                     "Most Expensive Provider",
                     "Cheapest Provider"
                     ))
    col_headers <- htmltools::withTags(table(
      class = 'display',
      thead(
        tr(
          th(colspan = 2, 'Provider Statistics')
        )
      )
    ))
    
    datatable(
      out,
      rownames = FALSE,
      container = col_headers,
      options = list(
        ordering = FALSE,
        dom = 't'
      ),
      selection = "none"
    ) %>%
      formatCurrency(
        column = 2,
        currency = "",
        digits = 0
      )
  })
  
  output$single_hospital_tbl_title <- renderText({
    if (is.null(input$hospitals_tbl_rows_selected)) {
      out <- "Click Table to View Individual Hospital Details"
    } else {
      sel_provider <- hospitals_grouped()[input$hospitals_tbl_rows_selected, ]$provider_id
      out <- hospitals_filtered() %>%
        filter(provider_id == sel_provider) %>%
        pull(hospital)
    }
    out[1]
  })
  
  output$single_hospital_tbl <- renderDataTable({
    
    req(input$hospitals_tbl_rows_selected)
    sel_provider <- hospitals_grouped()[input$hospitals_tbl_rows_selected, ]$provider_id
    
    out <- hospitals_filtered() %>%
      filter(provider_id == sel_provider) %>%
      select(period, claim_type, avg_hospital, avg_nation) %>%
      arrange(desc(avg_hospital))
    
    
    col_headers <- htmltools::withTags(table(
      class = 'display',
      thead(
        tr(
          th(rowspan = 2, 'Hospital Visit Period'),
          th(rowspan = 2, 'Claim Type'),
          th(colspan = 2, 'Average Claim')
        ),
        tr(
          th('Per Hospital'),
          th('National')
        )
      )
    ))
    
    datatable(
      out,
      container = col_headers,
      rownames = FALSE,
      options = list(
        dom = "tp",
        ordering = FALSE
      ),
      selection = "none"
    ) %>%
      formatCurrency(
        columns = 3:4,
        digits = 0,
        currency = ""
      )
  })
}
