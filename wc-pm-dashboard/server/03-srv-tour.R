
observeEvent(input$tour, {
  if (input$sidebar == "dashboard") {
    introjs(
      session,
      options = list(
        steps = list(
          list(
            element = "#tour_1",
            intro = "This dashboard uses a support vector machine (SVM) and a generalized additive model (GAM) to predict claim
            status and incremental payment amounts at development age 2 for 7,119 workers' compensation claims. The model was fit using  
            several predictor variables including claim status, paid, and case at age 1, the nature code of the accident, claim type (medical only or lost time), 
            and gender."
          ),
          list(
            element = "#tour_2",
            intro = "This tab shows the aggregate results of the model predictions.  These outputs are displaying a summarization of 
            all of the predicted claim amounts combined",
            position = "left"
          ),
          list(
            element = "#tour_3",
            intro = "The 'Metric' allows you to select either
            incremental payments from age 1 to age 2 or status at age 2 (status can be 'open' or 'closed')."
          ),
          list(
            element = "#tour_4",
            intro = "The 'Filters' allow you to remove claims from the data.  By default all the claims are included,
            but by adjusting the filters you can remove certain types of claims."
          ),
          list(
            element = "#tour_5",
            intro = "The boxes show the predicted total (left), the standard deviation of the predicted total (middle),
            and the actual total (right) (In this example app, we know the actual results, but in a production
            application the actual results would not have occurred yet.)"
          ),
          list(
            element = "#tour_6",
            intro = "The grey columns represent the distribution of possible outcomes predicted by the model.  You can
            download the plot by clicking the button in the top-right corner"
          ),
          list(
            element = "#tour_7",
            intro = "You can adjust the predicted confidence interval here which will be displayed with the blue lines 
            in the plot.  The actual amount is displayed with a green line if it is within the selected confidence interval
            and a red line if it lies outside the interval."
          )
        )
      )
    )
  } else {
    introjs(
      session,
      options = list(
        steps = list(
          list(
            element = "#tour_2_1",
            intro = "This plot shows the average predicted incremental payment for each claim.  Click on a point to get individual claim detail",
            position = "bottom"
          ),
          list(
            element = "#tour_2_2",
            intro = "Here we have the predicted distribution of possible payments for the selected claim",
            position = "top"
          ),
          list(
            element = "#tour_2_3",
            intro = "The characteristics of the selected claim can be viewed here",
            position = "top"
          )
        )
      )
    )
  }
})
