library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)






test_that("All codes defined", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Load codes table
  codes <- here("data/metadata/codes_metadata.csv") %>% 
    read_csv() %>% 
    # Delete rows that don't correspond to actual codes
    filter(!is.na(Description))
  
  # Extract codes
  dendroband_measurements <- dendroband_measurements %>% 
    filter(!is.na(codes)) %>% 
    mutate(
      # Remove spaces
      codes = str_replace_all(codes, " ", ""),
      # In cases where there are multiple codes input at once, split by ; or , or :
      codes_list = str_split(string = codes, pattern = regex(";|,|:"))
    )
  
  dendroband_measurements$code_defined <- sapply(dendroband_measurements$codes_list, function(x){all(x %in% codes$Code)})
  dendroband_measurements <- dendroband_measurements %>% 
    select(-codes_list)
  
  # Test that all codes are defined
  all_codes_defined <- dendroband_measurements %>% 
    pull(code_defined) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/code_defined.csv")
  
  if(!all_codes_defined){
    dendroband_measurements %>% 
      filter(!code_defined) %>% 
      select(tag, stemtag, survey.ID, year, month, day, sp, quadrat, codes) %>%
      write_csv(file = filename)
    
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_codes_defined)
})








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








test_that("Day is possible", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Test that day is valid depending on month and not NA
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(
      day_possible = 
        case_when(
          month == 1 ~ between(day, 1, 31) & !is.na(day),
          month == 2 ~ between(day, 1, 29) & !is.na(day),
          month == 3 ~ between(day, 1, 31) & !is.na(day),
          month == 4 ~ between(day, 1, 30) & !is.na(day),
          month == 5 ~ between(day, 1, 31) & !is.na(day),
          month == 6 ~ between(day, 1, 30) & !is.na(day),
          month == 7 ~ between(day, 1, 31) & !is.na(day),
          month == 8 ~ between(day, 1, 31) & !is.na(day),
          month == 9 ~ between(day, 1, 30) & !is.na(day),
          month == 10 ~ between(day, 1, 31) & !is.na(day),
          month == 11 ~ between(day, 1, 30) & !is.na(day),
          month == 12 ~ between(day, 1, 31) & !is.na(day),
          TRUE ~ FALSE
        )
    )
  
  # Test if all days are possible
  all_days_possible <- dendroband_measurements %>% 
    pull(day_possible) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/day_possible.csv")
  
  if(!all_days_possible){
    dendroband_measurements %>% 
      filter(!day_possible) %>% 
      select(tag, stemtag, survey.ID, year, month, day) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_days_possible)
})









test_that("Measure is possible", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Test that measure is valid depending on month and not NA
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(measure_possible = measure <= 250)
  
  # Test if all measures are possible
  all_measures_possible <- dendroband_measurements %>% 
    pull(measure_possible) %>% 
    all() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/measure_possible.csv")
  
  if(!all_measures_possible){
    dendroband_measurements %>% 
      filter(!measure_possible) %>% 
      select(tag, stemtag, survey.ID, year, month, day, sp, quadrat, measure) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(all_measures_possible)
})








threshold <- 10


test_that("Measure is reasonable", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  
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
    filter(!is.na(measure_is_reasonable)) %>% 
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









test_that("All measures recorded", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # For this test only consider stems for 2021 onwards. See GitHub Issue #61
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-01-01") )
  
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







test_that("survey ID increases", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-01-01") )
  
  # Create variable that tests if each row passes condition
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(date = ymd(str_c(year, month, day, sep = "-"))) %>% 
    arrange(date, tag, stemtag) %>% 
    mutate(
      # Get consecutive row-by-row difference in survey.ID
      survey_ID_diff_from_prev_row = survey.ID - lag(survey.ID),
      # Floating point arithmetic issues
      # https://stackoverflow.com/questions/9508518/why-are-these-numbers-not-equal
      survey_ID_diff_from_prev_row = round(survey_ID_diff_from_prev_row, 5),
      # ID which rows have correct differences: 0 within survey, 
      # 0.01 between survey, 1 between fall and spring biannual
      survey_ID_incorrectly_numbered = case_when(
        # TODO: deal with diff == 0 but date differs.
        # this means the survey ID didn't increment correctly
        survey_ID_diff_from_prev_row == 0 ~ FALSE,
        survey_ID_diff_from_prev_row == 0.01 ~ FALSE,
        survey_ID_diff_from_prev_row == 1 ~ FALSE,
        TRUE ~ TRUE
      ),
      # If a row is flagged as being incorrectly numbered, then flag
      # previous row as well
      #survey_ID_incorrectly_numbered = ifelse(lead(survey_ID_incorrectly_numbered), TRUE, survey_ID_incorrectly_numbered)
    )
  
  # Create error/warning flag
  report_flag <- dendroband_measurements %>% 
    pull(survey_ID_incorrectly_numbered) %>% 
    any() 
  
  # If any errors, write report. Otherwise, delete any existing reports
  filename <- here("testthat/reports/survey_ID_incorrectly_numbered.csv")
  
  if(!report_flag){
    dendroband_measurements %>% 
      filter(survey_ID_incorrectly_numbered) %>% 
      select(tag, stemtag, survey.ID, year, month, day, survey_ID_diff_from_prev_row) %>%
      write_csv(file = filename)
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  expect_true(report_flag)
})








min_caliper_width <- 3
max_caliper_width <- 200

test_that("Warning that dendroband needs replacing or fixing", {
  # Load all csv's at once
  dendroband_measurements <- 
    here("data") %>% 
    dir(path = ., pattern = "scbi.dendroAll*", full.names = TRUE) %>%
    map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
  # Create variable that tests if each row passes condition
  dendroband_measurements <- dendroband_measurements %>% 
    mutate(
      band_needs_replacing = !between(measure, min_caliper_width, max_caliper_width)
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
      select(tag, stemtag, survey.ID, year, month, day, sp, quadrat, measure, codes) %>%
      write_csv(file = filename)
    
    # TODO: Write code that appends "RE" to codes for those stems that
    # need new bands installed
  } else {
    if(file.exists(filename)) file.remove(filename)
  }
  
  # Not needed since we are only returning a warning
  expect_true(TRUE)
})







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
    mutate(year_valid = between(year, 2010, current_year) & !is.na(year)) %>% 
    # TODO: remove this later. start with a clean slate for Wednesday July 7
    filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-07-05") )
  
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






