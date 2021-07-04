library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

test_that("Day is possible", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double()))
  
  # Test that day is valid depending on month and not NA
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(
      day_possible = 
        case_when(
          month == 1 ~ between(day, 1, 31) & !is.na(day),
          month == 2 ~ between(day, 1, 29) & !is.na(day),
          month == 3 ~ between(day, 1, 31) & !is.na(day),
          month == 4 ~ between(day, 1, 30) & !is.na(day),
          month == 5 ~ between(day, 1, 31) & !is.na(day),
          month == 6 ~ between(day, 1, 30) & !is.na(day),
          month == 7 ~ between(day, 1, 31) & !is.na(day),
          month == 8 ~ between(day, 1, 31) & !is.na(day),
          month == 9 ~ between(day, 1, 30) & !is.na(day),
          month == 10 ~ between(day, 1, 31) & !is.na(day),
          month == 11 ~ between(day, 1, 30) & !is.na(day),
          month == 12 ~ between(day, 1, 31) & !is.na(day),
          TRUE ~ FALSE
        )
    )
  
  # Test if all days are possible
  all_days_possible <- dendroband_measurements %>% 
    pull(day_possible) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/day_possible.csv")
  
  if(!all_days_possible){
    dendroband_measurements %>% 
      filter(!day_possible) %>% 
      select(tag, stemtag, survey.ID, year, month, day) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_days_possible)
})
