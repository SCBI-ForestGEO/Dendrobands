library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

test_that("Measure is possible", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double()))
  
  # Test that measure is valid depending on month and not NA
  # TODO: Ask Krista about NA's and over 200
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(measure_possible = measure <= 200 & !is.na(measure))
  
  
  
  
  # Test if all days are possible
  all_measures_possible <- dendroband_measurements %>% 
    pull(measure_possible) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/measure_possible.csv")
  
  if(!all_measures_possible){
    dendroband_measurements %>% 
      filter(!measure_possible) %>% 
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_measures_possible)
})
