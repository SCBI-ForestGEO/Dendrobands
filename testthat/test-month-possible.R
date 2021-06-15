library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

test_that("Month is possible", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double()))
  
  # Test that month is between 2010-current year and not NA
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(month_possible = between(month, 1, 12) & !is.na(month)) 
  
  # Test if all months are possible
  all_months_possible <- dendroband_measurements %>% 
    pull(month_possible) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/month_possible.csv")
  
  if(!all_months_possible){
    dendroband_measurements %>% 
      filter(!month_possible) %>% 
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_months_possible)
})
