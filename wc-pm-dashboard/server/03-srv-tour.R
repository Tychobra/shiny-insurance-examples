
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
            intro = "This tab shows the aggregate results of the model predictions.  These outputs are displaying the summarization of 
            all of the predicted claims",
            position = "left"
          ),
          list(
            element = "#tour_3",
            intro = "The 'Metric' specificies either
            incremental payments from age 1 to age 2 or status at age 2"
          ),
          list(
            element = "#tour_4",
            intro = "The 'Filters' are used to remove claims from the data.  By default all the claims are included,
            but by adjusting the filters you can remove certain types of claims."
          ),
          list(
            element = "#tour_5",
            intro = "The boxes show the predicted total (left), the standard deviation of the predicted total (middle),
            and the actual total (right) for either payments or status"
          ),
          list(
            element = "#tour_6",
            intro = "The histogram shows the distribution of predicted payments or status for all claims.  The blue
            columns represent the probabilities predicted by the model.  The red line shows the actual amount."
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
