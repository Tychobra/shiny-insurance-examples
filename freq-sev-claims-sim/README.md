Frequency Severity Claims Simulation
==================

This Shiny application generates frequency/severity insurance claims simulations.  A frequency severity simulation is a very simple Markov Chain Monte Carlo (MCMC).

[LIVE APP](https://tychobra.shinyapps.io/freq-sev-claims-sim/).

## Video

[![Frequency Severity Simulation](https://res.cloudinary.com/dxqnb8xjb/image/upload/v1498564641/claims-fs-sim_fvmw15.png)](https://youtu.be/aiggRsQe8xE)


## Background

Insurers are interested in the probabilities that their exposures will result in certain loss amounts.  One quick way insurers estimate probabilities for these loss amounts is to run frequency/severity claims simulations.

A frequency/severity claims simulation randomly simulates a frequency (i.e. number of claims), and then simulates a random severity (i.e. loss amount) for each of these claims.  The severity simulation represents the total loss amount to settle each claim.  We refer to each of these frequency/severity simulations as an observation.  e.g. An observation with 4 claims might look like this:

| Claim ID | Loss Amount |
|:--------:|------------:|
|  A       |   100,000   |
|  B       |    50,000   |
|  C       |   180,000   |
|  D       |     5,000   |
| **Total**|  **335,000**|

Once we have simulated the claims, we can then easily apply per claim and aggregate (i.e. per observation) retention limits to the simulated claims.  In our example above, a 100,000 per claim retention limit would give us the following:

| Claim ID | Loss Amount | Retained Loss Amount | Excess Loss Amount | 
|:--------:|------------:|---------------------:|-------------------:|
|   A      |   100,000   |    100,000           |         0          |
|   B      |    50,000   |     50,000           |         0          |
|   C      |   180,000   |    100,000           |    80,000          |
|   D      |     5,000   |      5,000           |         0          |
| **Total**| **335,000** |  **255,000**         |  **80,000**        |

In our example observation above, the excess reinsurance contract with a per claim retention limit of 100,000 paid 80,000 in excess recoveries.  We did not apply an aggregate limit.  This is just one example observation.  By simulating many observations we can use the distribution of the observations to estimate the probabilities of experiencing different loss amounts.  We can use different combinations of frequency and severity distributions and a variety of retention limits to resemble the insurer's exposures.

## This App

This app has options to use several differenct probability distributions from the [Tables for CAS Actuarial Exam C/4](http://www.math.purdue.edu/~jbeckley/WD/STAT%20479/S13/edu-2009-fall-exam-c-table.pdf) to generate the frequency and severity simulations.  The app also allows the user to select a per claim retention limit and an aggregate (per observation) retention limit.

## Further Improvements to the Simulation

This app makes fairly simple frequency/severity simulations.  To make simulations more accurately resemble actual claims payments insurers will generally include:

- Multiple frequency and severity distributions to represent different types of claims
- A variety of retention limits and deductibles
- Severity simulations that simulate payments over time as opposed to a single total loss simulation
