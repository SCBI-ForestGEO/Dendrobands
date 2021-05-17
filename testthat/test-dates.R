library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

test_that("All years are valid", {
  current_year <- Sys.Date() %>% 
    str_sub(1, 4) %>% 
    as.numeric()
  
  # For all .csv's, test that year is between 2010-current year and not NA
  dendroband_measurements <- here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    mutate(year_valid = between(year, 2010, current_year) & !is.na(year)) 
  
  all_years_valid <- dendroband_measurements %>% 
    pull(year_valid) %>% 
    all() 
  
  # Write report if any errors
  if(!all_years_valid){
    filename <- here("testthat/reports", str_c(Sys.Date(), "_year_issues.csv"))
    
    dendroband_measurements %>% 
      filter(!year_valid) %>% 
      write_csv(file = filename)
  }
  
  expect_true(all_years_valid)
})
