library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)

threshold <- 10


test_that("Measure is reasonable", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double()))
  
  
  # Create variable that tests if each row passes condition
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(date = ymd(str_c(year, month, day, sep = "-"))) %>% 
    arrange(tag, stemtag, date) %>% 
    group_by(tag, stemtag) %>% 
    mutate(
      diff_from_previous_measure = measure - lag(measure),
      measure_is_reasonable = abs(diff_from_previous_measure) < threshold | new.band != 0,
      # measure_is_reasonable = ifelse(!lead(measure_is_reasonable), FALSE, measure_is_reasonable)
    ) 
  

  # Create error/warning flag
  report_flag <- dendroband_measurements %>% 
    pull(measure_is_reasonable) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/measure_is_reasonable.csv")
  
  if(!report_flag){
    dendroband_measurements %>% 
      filter(!measure_is_reasonable) %>% 
      select(tag, stemtag, survey.ID, year, month, day, sp, quadrat, measure, new.band, diff_from_previous_measure) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(report_flag)
})
