# Generate reports looking at latest raw dendrobands raw data 
## this script is run automatically when there is a push 

# Set up ------
# clear environment
rm(list = ls())

# load libraries
library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(lubridate)

## Load all master data files into a single data frame 
master_data_filenames <- dir(path = here("data"), pattern = "scbi.dendroAll*", full.names = TRUE)

dendroband_measurements <- NULL
for(i in 1:length(master_data_filenames)){
  dendroband_measurements <- 
    bind_rows(
      dendroband_measurements,
      read_csv(master_data_filenames[i], col_types = cols(dbh = col_double(), dendDiam = col_double()))
    )
}

# Needed to write csv's consisting of only original variables
orig_master_data_var_names <- names(dendroband_measurements)

# Add date column
dendroband_measurements <- dendroband_measurements %>% 
  mutate(date = ymd(str_c(year, month, day, sep = "-")))

# Run tests only on data from 2021 onwards
# TODO: Run tests on all data and fix all past errors
dendroband_measurements <- dendroband_measurements %>%
  filter(ymd(str_c(year, month, day, sep = "-")) > ymd("2021-01-01") )






# Run all tests & checks ----
# prepare report files
require_field_fix_error_file <- NULL
will_auto_fix_error_file <- NULL
warning_file <- NULL



## Error: Is day possible? ----
alert_name <- "day_not_possible"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
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
  ) %>% 
  filter(!day_possible)

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)



## Error: Is month is possible? ----
alert_name <- "month_not_possible"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(!between(month, 1, 12) | is.na(month)) 

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)



## Error: Is year possible? ----
alert_name <- "year_not_possible"

# Get current year
current_year <- Sys.Date() %>% 
  str_sub(1, 4) %>% 
  as.numeric()

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(!between(year, 2010, current_year) | is.na(year))

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)



## Error: Status of stem is 1) not missing and 2) is "alive" or "dead"? ----
alert_name <- "status_not_valid"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(!status %in% c("alive", "dead") | is.na(status))

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)



## Error: Is measure possible: between 0 & 250? ----
measure_limit <- 250
alert_name <- "measure_not_possible"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(!between(measure, 0, measure_limit))

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)



## Error: Are all codes defined? ----
alert_name <- "code_not_defined"

# Load codes table
codes <- here("data/metadata/codes_metadata.csv") %>% 
  read_csv() %>% 
  # Delete rows that don't correspond to actual codes
  filter(!is.na(Description))

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(!is.na(codes)) %>% 
  mutate(
    # Remove spaces
    codes = str_replace_all(codes, " ", ""),
    # In cases where there are multiple codes input at once, split by ; or , or :
    codes_list = str_split(string = codes, pattern = regex(";|,|:"))
  ) 

stems_to_alert$code_defined <- sapply(stems_to_alert$codes_list, function(x){all(x %in% codes$Code)})

stems_to_alert <- stems_to_alert %>% 
  filter(!code_defined)

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)



## Warning: Is difference between new & previous measurement <= 10?  ----
threshold <- 10
alert_name <- "new_measure_too_different_from_previous"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  arrange(tag, stemtag, date) %>% 
  group_by(tag, stemtag) %>% 
  mutate(
    diff_from_previous_measure = measure - lag(measure),
    measure_is_reasonable = abs(diff_from_previous_measure) < threshold
  ) %>%
  filter(!measure_is_reasonable)

# Append to report
warning_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(warning_file)






## Error: Is measure recorded: if measure is missing, then code = RE, DS, or DC ----
# Test that if measure is missing, then codes = RE is there
alert_name <- "measure_not_recorded"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  mutate(missing_RE_code = !is.na(measure) | str_detect(codes, regex("RE|DC|DS"))) %>% 
  filter(!missing_RE_code)

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)







## Error: Is survey ID valid: survey ID increments only in units of 0.01, except jump from fall to spring biannual ----
alert_name <- "survey_ID_increment_wrong"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  arrange(date, tag, stemtag) %>% 
  # Get row-by-row consecutive difference in survey.ID. Note we round 
  # b/c of weird floating point arithmetic issues
  # (See https://stackoverflow.com/questions/9508518/)
  mutate(
    survey_ID_diff_from_prev_row = survey.ID - lag(survey.ID),
    survey_ID_diff_from_prev_row = round(survey_ID_diff_from_prev_row, 5)
  ) %>% 
  mutate(
    survey_ID_correctly_numbered = case_when(
      # Within survey diff should be 0
      survey_ID_diff_from_prev_row == 0 ~ TRUE,
      # Between consecutive surveys diff should be 0.01
      survey_ID_diff_from_prev_row == 0.01 & date != lag(date) ~ TRUE,
      # Only time diff shouldn't be 0 or 0.01 is jump from fall to spring biannual (different year)
      (!survey_ID_diff_from_prev_row %in% c(0, 0.01)) & (year(date) == year(lag(date)) + 1) ~ TRUE,
      # Otherwise increment
      TRUE ~ FALSE
    )
  ) %>% 
  # Remove 1st row b/c diff in survey ID doesn't exist.
  slice(-1) %>%
  filter(!survey_ID_correctly_numbered)

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)





## Warning: Does dendroband needs fixing or replacing? ----
alert_name <- "dendroband_needs_fixing_or_replacing"

min_caliper_width <- 3
max_caliper_width <- 200

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(!between(measure, min_caliper_width, max_caliper_width))

# Append to report
warning_file <- stems_to_alert %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(warning_file)









# Clean and save files ----

## Field fix errors ----
report_filepath <- here("testthat/reports/requires_field_fix/require_field_fix_error_file.csv")
trace_of_reports_filepath <- here("testthat/reports/trace_of_reports/require_field_fix_error_file.csv")

if(nrow(require_field_fix_error_file) != 0){
  # If any field fix errors exist:
  
  # Clean & sort report
  require_field_fix_error_file <- require_field_fix_error_file %>% 
    filter(!is.na(tag)) %>% 
    arrange(quadrat, tag, stemtag)
  
  # Write report 
  require_field_fix_error_file %>% 
    write_csv(file = report_filepath)
  
  # Append report to trace of reports to keep track of all the issues
  if(file.exists(trace_of_reports_filepath)){
    trace_of_reports <- read_csv(file = trace_of_reports_filepath)
  } else {
    trace_of_reports <- NULL
  }
  
  trace_of_reports %>% 
    bind_rows(require_field_fix_error_file) %>% 
    distinct() %>% 
    write_csv(file = trace_of_reports_filepath)
  
} else { 
  # If no field fix errors exist, then delete previous report:
  if(file.exists(report_filepath)) {
    file.remove(report_filepath)
  }
}

## Warnings ----
report_filepath <- here("testthat/reports/warnings/warnings_file.csv")
trace_of_reports_filepath <- here("testthat/reports/trace_of_reports/warnings_file.csv")

if(nrow(warning_file) != 0){
  # If any warnings exist:
  
  # Clean & sort report
  warning_file <- warning_file %>% 
    filter(!is.na(tag)) %>% 
    arrange(alert_name, quadrat, tag, stemtag)
  
  # Write report 
  warning_file %>% 
    write_csv(file = report_filepath)
  
  # Append report to trace of reports to keep track of all the issues
  if(file.exists(trace_of_reports_filepath)){
    trace_of_reports <- read_csv(file = trace_of_reports_filepath)
  } else {
    trace_of_reports <- NULL
  }
  
  trace_of_reports %>% 
    bind_rows(warning_file) %>% 
    distinct() %>% 
    write_csv(file = trace_of_reports_filepath)
  
} else {
  # If no warnings exist, then delete previous report:
  if (file.exists(report_filepath)) {
    file.remove(report_filepath)
  }
}


