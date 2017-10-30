library(dplyr)
library(httr)
library(jsonlite)

# downloaded data.gov
spending <- httr::GET("https://data.medicare.gov/api/views/nrth-mfg3/rows.json") %>%
              httr::content(as = "text") %>%
              jsonlite::fromJSON()

hospitals <- dplyr::as_data_frame(spending$data)

names(hospitals) <- spending$meta$view$columns$name

# only select columns that we want
hospitals <- hospitals %>% 
  dplyr::select(
    hospital = Hospital_Name, 
    provider_id = Provider_ID, 
    state = State, 
    period = Period, 
    claim_type = Claim_Type, 
    avg_hospital = Avg_Spending_Per_Episode_Hospital, 
    avg_state = Avg_Spending_Per_Episode_State,
    avg_nation = Avg_Spending_Per_Episode_Nation)


# convert numeric columns to numeric
hospitals[, 6:8] <- lapply(hospitals[, 6:8], function(col) {
  col %>%
    as.numeric()
})

# shorten period categories
period_remap <- tibble(
  old_period = c(
    "During Index Hospital Admission",                              
    "1 through 30 days After Discharge from Index Hospital Admission",
    "Complete Episode",                                               
    "1 to 3 days Prior to Index Hospital Admission"),
  new_period = c("during", "after_1_30", "all", "prior_1_3")
)

hospitals <- left_join(hospitals, period_remap, by = c("period" = "old_period")) %>%
  mutate(period = new_period) %>%
  select(-new_period)

# we do not need the period "all" which is just a sum of all the other periods
hospitals <- hospitals %>% 
  filter(period != "all")

# prep data by state
states <- hospitals %>%
  select(state, period, claim_type, avg_state) %>%
  group_by(state, period, claim_type) %>%
  slice(1) %>%
  ungroup()

# save
saveRDS(hospitals, file = "data/spending-hospital.RDS")
saveRDS(states, file = "data/spending-state.RDS")
