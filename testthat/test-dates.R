library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

test_that("All years are valid", {
  current_year <- Sys.Date() %>% 
    str_sub(1, 4) %>% 
    as.numeric()
  
  here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    mutate(year_valid = between(year, 2010, current_year)) %>% 
    pull(year_valid) %>% 
    all() %>% 
    expect_true()
})
