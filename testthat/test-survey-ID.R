library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)

test_that("survey ID increases", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double()))
  
  # Create variable that tests if each row passes condition
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(date = ymd(str_c(year, month, day, sep = "-"))) %>% 
    arrange(date, tag, stemtag) %>% 
    mutate(
      # Get consecutive row-by-row difference in survey.ID
      diff_from_previous = survey.ID - lag(survey.ID),
      # Floating point arithmetic issues
      # https://stackoverflow.com/questions/9508518/why-are-these-numbers-not-equal
      diff_from_previous = round(diff_from_previous, 5),
      # ID which rows have correct differences: 0 within survey, 
      # 0.01 between survey, 1 between fall and spring biannual
      survey_ID_correctly_numbered = case_when(
        diff_from_previous == 0 ~ TRUE,
        diff_from_previous == 0.01 ~ TRUE,
        diff_from_previous == 1 ~ TRUE,
        TRUE ~ FALSE
      ),
      # If a row is flagged as being incorrectly numbered, then flag
      # previous row as well
      survey_ID_correctly_numbered = ifelse(!lead(survey_ID_correctly_numbered), FALSE, survey_ID_correctly_numbered)
    )

  # Create error/warning flag
  report_flag <- dendroband_measurements %>% 
    pull(survey_ID_correctly_numbered) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/survey_ID_correctly_numbered.csv")
  
  if(!report_flag){
    dendroband_measurements %>% 
      filter(!survey_ID_correctly_numbered) %>% 
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(report_flag)
})
