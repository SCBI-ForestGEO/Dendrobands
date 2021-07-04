library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)


min_caliper_width <- 3
max_caliper_width <- 200

test_that("Warning that dendroband needs replacing or fixing", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double()))
  
  # Create variable that tests if each row passes condition
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(
      band_needs_replacing = !between(measure, min_caliper_width, max_caliper_width) & codes != "RE"
    )
  
  # Create error/warning flag
  report_flag <- dendroband_measurements %>% 
    pull(band_needs_replacing) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/warnings/band_needs_replacing.csv")
  
  if(!report_flag){
    dendroband_measurements %>% 
      filter(band_needs_replacing) %>% 
      write_csv(file = filename)
    
    # TODO: Write RE code for those stems that need RE
    
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  # Not needed since we are only returning a warning
  expect_true(TRUE)
})
