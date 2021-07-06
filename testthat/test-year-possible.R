library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

test_that("Year is possible", {
  # Get current year
  current_year <- Sys.Date() %>% 
    str_sub(1, 4) %>% 
    as.numeric()
  
  dendroband_measurements <- 
    # Load all csv's at once
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # Test that year is between 2010-current year and not NA
    mutate(year_valid = between(year, 2010, current_year) & !is.na(year)) 
  
  # Test & write report if any errors
  all_years_valid <- dendroband_measurements %>% 
    pull(year_valid) %>% 
    all() 
  
  if(!all_years_valid){
    filename <- here("testthat/reports/year_possible.csv")
    
    dendroband_measurements %>% 
      filter(!year_valid) %>% 
      select(tag, stemtag, survey.ID, year, month, day) %>%
      write_csv(file = filename)
  }
  
  expect_true(all_years_valid)
})
