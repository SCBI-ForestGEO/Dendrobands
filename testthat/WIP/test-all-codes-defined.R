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
  
  # Load codes from GitHub
  codes <- here("data/metadata/codes_metadata.csv") %>% 
    read_csv() %>% 
    # Delete rows that don't correspond to actual codes
    filter(!is.na(Description))
  
  
  
  # What do comma's and ; mean?
  dendroband_measurements <- dendroband_measurements %>% 
    filter(!is.na(codes)) %>% 
    mutate(
      codes = str_replace_all(codes, " ", ""),
      codes_list = str_split(string = codes, pattern = regex(";|,|:"))
    )
  
  dendroband_measurements$code_defined <- sapply(dendroband_measurements$codes_list, function(x){all(x %in% codes$Code)})
  dendroband_measurements <- dendroband_measurements %>% 
    select(-codes_list)
  
  # Test if all months are possible
  all_codes_defined <- dendroband_measurements %>% 
    pull(code_defined) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/code_defined.csv")
  
  if(!all_codes_defined){
    dendroband_measurements %>% 
      filter(!code_defined) %>% 
      write_csv(file = filename)
    
    dendroband_measurements %>% 
      filter(!code_defined) %>% 
      count(codes) %>% 
      arrange(desc(n)) %>% 
      knitr::kable()
    
    
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_codes_defined)
})
