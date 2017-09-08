observeEvent(input$tour, {
  introjs(
    session,
    options = list(
      steps = list(
        list(
          element = "#tour_1",
          intro = "This button runs the frequency severity simulation. Go ahead and click
          it. Then click the 'Next' button"
        ),
        list(
          element = "#tour_2",
          intro = "This histogram shows the distribution of ultimate losses per frequency / severity observation.  
          The ultimate loss per observation is on the x-axis 
          and the y-axis is looking at number of observations."
        ),
        list(
          element = "#tour_3",
          intro = "This slider adjusts the number of frequency severity observations that the simulation runs.  An observation is one simulated frequency (i.e. number of claims) with a simulated severity for each
          claim.  (e.g. an observation could have 9 claims (frequency) each with varying ultimate loss amounts (severities) that average to 50,000. This example observation would have a total
          loss of 450,000.)"
        ),
        list(
          element = "#tour_4",
          intro = "The frequency distribution randomly generates the number of claims in each observation.  
          For more info on these distributions see Appendix B of https://www.soa.org/files/pdf/edu-2009-fall-exam-c-table.pdf"
        ),
        list(
          element = "#tour_5",
          intro = "The severity distribution randomly generates the ultimate dollar amount to settle each claim.  
          For more info on these distributions see Appendix A of https://www.soa.org/files/pdf/edu-2009-fall-exam-c-table.pdf"
        ),
        list(
          element = "#tour_6",
          intro = "Insurers often purchase excess reinsurance policies to limit their exposure to large losses.  Two common
          ways for an insurer to limit its exposure to large losses are to purchase 'per claim limits' and 'aggregate' limits"
        ),
        list(
          element = "#tour_7",
          intro = "The 'per claim limit' caps the retained loss on an individual claim e.g. if an insurer has an excess 
          policy with a per claim limit of 250,000, the max that the insurer will pay on that claim is 250,000"
        ),
        list(
          element = "#tour_8",
          intro = "The 'aggregate limit' (also often called the 'aggreagte stop loss') sets an upper limit on the 
          amount that the insurer can lose in one frequency severity observation."
        ),
        list(
          element = "#tour_9",
          intro = "Adjust the confidence level shown in the plots here"
        ),
        list(
          element = "#tour_10",
          intro = "This plot shows the ultimate losses per claim gross of the selected retention limits.  As opposed to the plot above which is net
          of retention limits."
        ),
        list(
          element = ".nav-tabs",
          intro = "Last but not least you can click on these tabs to view a table of the output and to download all the claims"
        )
      )
    )
  )
})
