library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)


test_that("All measures recorded", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Test that if measure is missing, then codes = RE is there
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(missing_RE_code = !is.na(measure) | str_detect(codes, "RE"))
  
  # Create error/warning flag
  report_flag <- dendroband_measurements %>% 
    pull(missing_RE_code) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/all_measures_recorded.csv")
  
  if(!report_flag){
    dendroband_measurements %>% 
      filter(!missing_RE_code) %>% 
      select(tag, stemtag, survey.ID, year, month, day, sp, quadrat, measure, codes) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(report_flag)
})
