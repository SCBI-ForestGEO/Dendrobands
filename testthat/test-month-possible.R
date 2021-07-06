library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)


test_that("Month is possible", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Test that month is between 1 and 12 and not NA
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
      select(tag, stemtag, survey.ID, year, month, day) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_months_possible)
})
