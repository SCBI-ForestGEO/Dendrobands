library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)


test_that("All status", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Test that status is either "alive" or "dead" & is not NA
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(status_valid = status %in% c("alive", "dead") & !is.na(status)) 
  
  # Test if all statuses are possible
  all_status_valid <- dendroband_measurements %>% 
    pull(status_valid) %>% 
    all() 

  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/status_valid.csv")
  
  if(!all_status_valid){
    dendroband_measurements %>% 
      filter(!status_valid) %>% 
      select(tag, stemtag, survey.ID, year, month, day, sp, quadrat, status) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_status_valid)
})
