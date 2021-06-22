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
  
  # Test that status is either "alive" or "dead" & is not NA
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(status_valid = status %in% c("alive", "dead") & !is.na(status)) 
  
  # Test if all months are possible
  all_status_valid <- dendroband_measurements %>% 
    pull(status_valid) %>% 
    all() 
  
  # TODO: What do we do with
  # "considered dead Dec 2011, got measurements 2012, dead 2013+" case?
  
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/status_valid.csv")
  
  if(!all_status_valid){
    dendroband_measurements %>% 
      filter(!status_valid) %>% 
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_status_valid)
})
