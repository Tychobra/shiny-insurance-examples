hc_btn_options <- list(
  contextButton = list(
    menuItems = list(
      list(
        text = "Export to PDF",
        onclick = JS(
          "function () { this.exportChart({
          type: 'application/pdf'
          }); }"
        )
      ),
      list(
        text = "Export to SVG",
        onclick = JS(
          "function () { this.exportChart({
          type: 'image/svg+xml'
          }); }"
        )
      )
    )
  )
)

function(input, output) {

  output$claims <- renderPrint({
    ob_total() %>%
      filter(is.na(total_gross))
  })
  
  handson_claims <- reactive({
    if (is.null(input$hands_tbl)) {
      out <- claims
    } else {
      out <- hot_to_r(input$hands_tbl)
    }
    
    print(out)
    
    out
  })
    
  # trend the claims
  trend <- reactive({
    handson_claims() %>%
      mutate(value_trend = value * input$trend ^ (input$trend_to - year)) #%>%
      # remove the claim if year status or value are missing
      # TODO: find a way to do better validation on rhandsontable entry
      #filter(!is.na(year), !is.na(status), !is.na(value))
  })
  
  # identify shock claims
  shock <- reactive({
    trend() %>%
      mutate(shock = ifelse(value_trend > input$shock_cut, TRUE, FALSE))
  })
  
  # shock claims
  #shock <- reactive({
  #  trend() %>%
  #    filter(value_trend > input$shock_cut)
  #})
  
  # develop open non-shock claims
  # develop only the open claims
  dev_df <- reactive({
    data_frame(
      year = c(2014, 2015, 2016),
      dev = c(input$dev_2014, input$dev_2015, input$dev_2016)  
    )
  })
  
  dev_wtd <- reactive({
    # find open dollars vs closed dollars to leverage development factors
    open_closed <- shock() %>%
      filter(shock == FALSE) %>%
      group_by(year, status) %>%
      summarise(value_trend = sum(value_trend))
    
    py_df <- open_closed %>% 
      ungroup() %>%
      group_by(year) %>%
      summarise(value_trend_year = sum(value_trend))
    
    py_df <- left_join(py_df, dev_df(), by = "year")
    
    left_join(open_closed, py_df, by = "year") %>%
      mutate(pct = value_trend / value_trend_year,
             dev_fct = ifelse(status == "O", 1 / pct * dev, 1)) %>%
      dplyr::select(year, status, dev_fct)
    
  })
  
  dev <- reactive({
    left_join(shock(), dev_wtd(), by = c("year", "status")) %>%
      mutate(value_trend_dev = ifelse(shock, value_trend, value_trend * dev_fct))
  })
  
  # run the simulation
  ult <- eventReactive(input$run_sim, {
    n <- 5000
    set.seed(1234)
    freq <- rpois(n, lambda = input$exposure * 0.05)
    emp_dist <- dev() %>%
                  filter(shock == FALSE) %>%
                  pull(value_trend_dev)
    
    lapply(
      freq,
      function(x) {
          sample(
            emp_dist,
            size = x,
            replace = TRUE
          )
      }
    )
  })
  
  # convert list of claims into data.frame
  tidy_claims <- reactive({
    
    ult_hold <- ult()
    
    out <- lapply(1:length(ult_hold), function(x) {
      data.frame("sim" = x, "severity" = ult_hold[[x]])
    })
    
    out <- bind_rows(out) %>%
      mutate(severity = round(severity, 2))
    
    shock_prob <- isolate({input$shock_prob})
    
    if (shock_prob > 0) {
      out$shock <- rbinom(n = nrow(out), size = 1, prob = shock_prob)  
    } else {
      out$shock <- 0
    }
    out
  })
  
  # replace shock claims with shock severities
  shock_sev <- reactive({
    empirical_shock <- isolate({dev() %>% filter(shock == TRUE)})
    
    sim_shock <- tidy_claims() %>%
                   dplyr::filter(shock == 1)
    sim_non_shock <- tidy_claims() %>%
                       dplyr::filter(shock == 0)
    
    sim_shock$severity <- rnorm(nrow(sim_shock), mean = mean(empirical_shock$value_trend), sd = isolate({input$shock_cut}))
    
    bind_rows(list(sim_shock, sim_non_shock)) %>%
      arrange(desc(sim))
  })
  
  below_retention <- reactive({
    if (is.na(input$retention)) {
      out <- shock_sev() %>%
        mutate(severity_lim = severity)  
    } else {
      out <- shock_sev() %>%
        mutate(severity_lim = pmin(severity, input$retention))
    }
    
    out
  })
  
  # total loss by observation
  ob_total <- reactive({
    out <- below_retention() %>%
      group_by(sim) %>%
      summarise(total_gross = sum(severity),
                total_net_specific = sum(severity_lim))
    
    if (is.na(input$agg_lim)) {
      out <- out %>%
        mutate(total_net_agg = total_net_specific)
    } else {
      out <- out %>%
        mutate(total_net_agg = pmin(total_net_specific, input$agg_lim))
    }
    
    out
  })
  
  
  #' plot_func(
  #'   ob_total()$total_net_agg, 
  #'   quantile(agg, input$cl / 100), 
  #'   title = "Losses & ALAE: Net of Retention"
  #' )
  plot_func <- function(dat, quant, title) {
    
    mean_val <- mean(dat) %>% round(., 0)
    
    # need to remove name from quantile calculation to show it in plot
    quant_sel <- quant %>% 
      unname() %>%
      round(0)
    quant_pct <- names(quant)
    
    
    hchart(dat) %>% 
      hc_title(text = title) %>%
      hc_exporting(
        enabled = TRUE,
        buttons = list(
          contextButton = list(
            menuItems = list(
              list(
                text = "Export to PDF",
                onclick = JS(
                  "function () { 
                     this.exportChart({
                       type: 'application/pdf'
                     }); 
                  }"
                )
              ),
              list(
                text = "Export to SVG",
                onclick = JS(
                  "function () { 
                     this.exportChart({
                       type: 'image/svg+xml'
                     }); 
                   }"
                )
              )
            )
          )
        )
      ) %>%
      hc_legend(enabled = FALSE) %>%
      hc_xAxis(
        title = list(text = "Net Loss"),
        plotLines = list(
          list(
            label = list(
              text = paste0("mean = ", format(mean_val, big.mark = ","))
            ),
            color = "#FF0000",
            width = 2,
            value = mean_val,
            zIndex = 5
          ),
          list(
            label = list(text = paste0(quant_pct, " Confidence Level = ", format(quant_sel, big.mark = ","))),
            color = "#FF0000",
            width = 2,
            value = quant_sel,
            zIndex = 5
          )
        )
      ) %>%
      hc_yAxis(
        title = list(text = "Number of Observations")
      )
  }
  
  quant_net <- reactive({
    quantile(ob_total()$total_net_agg, input$cl / 100)
  })
  
  output$hist_plot <- renderHighchart({
    agg <- ob_total()$total_net_agg
    plot_func(
      agg, 
      quant_net(), 
      title = "Losses & ALAE: Net of Retention"
    )
  })
  
  output$hist_plot_total <- renderHighchart({
    totes <- ob_total()$total_gross
    plot_func(
      totes, 
      quantile(totes, input$cl / 100), 
      title = "Losses & ALAE: Gross of Retention"
    )
  })
  
  # handsontable inputs
  output$hands_tbl <- renderRHandsontable({
    rhandsontable(handson_claims()) %>%
      hot_col("year", format = "0000") %>%
      hot_col("value", format="0,0", language = "en-US") %>%
      hot_validate_numeric(cols = 1, min = 1950, max = 2017, allowInvalid = TRUE) %>%
      hot_validate_character(cols = 2, choices = c("O", "C"), allowInvalid = TRUE) #%>%
      #hot_validate_numeric(cols = 3, min = -Inf, max = Inf, allowInvalid = TRUE)
  })
  
  output$hands_output <- renderRHandsontable({
    out <- dev() %>%
             dplyr::select(-year, -status, -value) %>%
             .[, c(1, 2, 4)]
    
    names(out) <- c("Trended", "Shock", "Developed")
    
    rhandsontable(out, readOnly = TRUE, rowHeaderWidth=0) %>%
      hot_col(c("Trended", "Developed"), format="0,0", language = "en-US")
  })
  
  # downloadable report
  output$download_report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        exposure = input$exposure,
        frequency = input$freq,
        retention_per_claim = input$retention,
        retention_aggregate = input$agg_lim,
        trend = input$trend,
        trend_year = input$trend_to,
        development = dev_df(),
        shock_cutoff = input$shock_cut,
        shock_prob = input$shock_prob,
        plot_func = plot_func,
        plot_args = list(
          list(
            dat = ob_total()$total_net_agg,
            quant = quantile(ob_total()$total_net_agg, input$cl / 100),
            title = "Loss and ALAE: Net of Retention"
          ),
          list(
            dat = ob_total()$total_gross,
            quant = quantile(ob_total()$total_gross, input$cl / 100),
            title = "Loss & ALAE: Gross of Retention"
          )
        ),
        claims = handson_claims()
      )
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(
        tempReport, 
        output_file = file,
        params = params,
        envir = new.env(parent = globalenv())
      )
    }
  )
  
}
