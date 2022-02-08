# Script that takes "cleaned" version of data ready for analysis in
# data/scbi.dendroAll_YEAR.csv and checks for errors that require field
# fixes listed in testthat/README.md.
#
# HOT TIP: To get a bird's eye view of what this code is doing, turn on
# "code folding" by going to RStudio menu -> Edit -> Folding -> Collapse all.



# Set up ------
# clear environment
rm(list = ls())

# load libraries
library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(ggplot2)
library(lubridate)

## Load all master data files into a single data frame 
master_data_filenames <- dir(path = here("data"), pattern = "scbi.dendroAll*", full.names = TRUE)

dendroband_measurements_all_years <- NULL
for(i in 1:length(master_data_filenames)){
  dendroband_measurements_all_years <- 
    bind_rows(
      dendroband_measurements_all_years,
      read_csv(master_data_filenames[i], col_types = cols(dbh = col_double(), dendDiam = col_double()))
    )
}



# DO THIS: Set current year
current_year <- 2021

# Needed to write csv's consisting of only original variables
orig_master_data_var_names <- names(dendroband_measurements_all_years)

# Add date column
dendroband_measurements_all_years <- dendroband_measurements_all_years %>% 
  mutate(date = ymd(str_c(year, month, day, sep = "-")))

# Run tests only on data from current year onwards
dendroband_measurements <- dendroband_measurements_all_years %>%
  filter(date > ymd(str_c(current_year, "-01-01")))

# Assign biannual survey ID's
spring_biannual_survey_ID <- min(dendroband_measurements$survey.ID)
fall_biannual_survey <- str_c("resources/raw_data/", current_year, "/data_entry_biannual_fall", current_year, ".csv") %>% 
  here()
fall_biannual_survey_ID <- ifelse(file.exists(fall_biannual_survey), max(dendroband_measurements$survey.ID), NA)




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



## Error: Is measure recorded: if measure is missing, then appropriate code must be entered ----
# Test that if measure is missing, then codes = RE is there
alert_name <- "measure_not_recorded"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  mutate(missing_RE_code = !is.na(measure) | str_detect(codes, regex("RE|DC|DS|DN|Q|B"))) %>% 
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




## Error: Anomaly detection for biannual: Is difference between new & previous measurement too big (unless new band is installed)? ----
alert_name <- "new_measure_too_different_from_previous_biannual"

if(!is.na(fall_biannual_survey_ID)){
  # Compute +/- 3SD of growth by species: used to detect anomalous growth below
  growth_by_sp <- dendroband_measurements_all_years %>% 
    # Only previous year spring and fall biannual values
    filter(year == current_year - 1) %>% 
    filter(survey.ID %in% c(min(survey.ID), max(survey.ID))) %>% 
    # Compute growth
    group_by(tag, stemtag) %>%
    mutate(growth = measure - lag(measure)) %>% 
    filter(!is.na(growth)) %>% 
    slice(n()) %>% 
    # 99.7% of values i.e. +/- 3 SD
    group_by(sp) %>% 
    summarize(lower = quantile(growth, probs = 0.003/2), upper = quantile(growth, probs = 1-0.003/2), n = n()) %>% 
    arrange(desc(n))
  
  stems_to_alert <- dendroband_measurements %>% 
    filter(survey.ID %in% c(spring_biannual_survey_ID, fall_biannual_survey_ID)) %>% 
    # Compute growth
    group_by(tag, stemtag) %>% 
    mutate(growth = measure - lag(measure)) %>% 
    filter(!is.na(growth)) %>% 
    slice(n()) %>% 
    # See if growth is in 99.7% confidence interval
    left_join(growth_by_sp, by = "sp") %>% 
    mutate(measure_is_reasonable = between(growth, lower, upper)) %>% 
    filter(!measure_is_reasonable) %>% 
    mutate(tag_sp = str_c(tag, ": ", sp))  
  
  # TODO: See if anomalous measure has been verified/double-checked in raw-data form
  # TODO: Remove if measurement has been verified
  
  # Append to report
  require_field_fix_error_file <- stems_to_alert %>% 
    mutate(alert_name = alert_name) %>% 
    select(alert_name, all_of(orig_master_data_var_names)) %>% 
    bind_rows(require_field_fix_error_file)
}


## Error: Anomaly detection for biweekly: Is diff between new & previous measurement too big (unless new band is installed)?  ----
threshold <- 10
alert_name <- "new_measure_too_different_from_previous"

# Find stems with error
stems_to_alert <- dendroband_measurements %>% 
  filter(intraannual == 1) %>% 
  arrange(tag, stemtag, date) %>% 
  group_by(tag, stemtag) %>% 
  mutate(
    diff_from_previous_measure = measure - lag(measure),
    measure_is_reasonable = (abs(diff_from_previous_measure) < threshold) | lag(new.band == 1)
  ) %>%
  filter(!measure_is_reasonable) %>% 
  mutate(tag_sp = str_c(tag, ": ", sp)) %>% 
  mutate(survey.ID = str_pad(survey.ID, width = 7, side = "right", pad = "0"))

# See if anomalous measure has been verified/double-checked in raw-data form
stems_to_alert$verified <- NA
for(i in 1:nrow(stems_to_alert)){
  # Get info for particular anomaly:
  anomaly_survey_id <- stems_to_alert$survey.ID[i]
  anomaly_tag <- stems_to_alert$tag[i]
  anomaly_stemtag <- stems_to_alert$stemtag[i]
  
  anomaly_raw_data_file <- str_c(
    "resources/raw_data/2021/data_entry_intraannual_", 
    # Because of differences in survey.ID variable and filename
    # Ex: 2021.02 vs 2021-02:
    anomaly_survey_id %>% str_replace("\\.", "-"), 
    ".csv"
  )
  
  # Special case for fall survey
  if(file.exists(fall_biannual_survey)){
    if(stems_to_alert$survey.ID[i] == fall_biannual_survey_ID) {
      anomaly_raw_data_file <- "resources/raw_data/2021/data_entry_biannual_fall2021.csv"
    }
  }
  
  stems_to_alert$verified[i] <- anomaly_raw_data_file %>% 
    read_csv(show_col_types = FALSE) %>% 
    filter(tag == anomaly_tag & stemtag == anomaly_stemtag) %>% 
    pull(measure_verified) 
}

# Remove if measurement has been verified
stems_to_alert <- stems_to_alert %>% 
  mutate(verified = ifelse(is.na(verified), FALSE, verified)) %>% 
  filter(!verified)

# Append to report
require_field_fix_error_file <- stems_to_alert %>% 
  mutate(survey.ID = as.numeric(survey.ID)) %>% 
  mutate(alert_name = alert_name) %>% 
  select(alert_name, all_of(orig_master_data_var_names)) %>% 
  bind_rows(require_field_fix_error_file)

# Display anomalies (if any) in README
anomaly_plot_filename <- here("testthat/reports/measurement_anomalies.png")

anamoly_dendroband_measurements <- dendroband_measurements %>% 
  filter(!is.na(measure) & tag %in% stems_to_alert$tag) %>% 
  mutate(stemtag = factor(stemtag)) %>% 
  mutate(tag_sp = str_c(tag, ": ", sp))

if(nrow(anamoly_dendroband_measurements) > 0){
  anomaly_plot <- anamoly_dendroband_measurements %>% 
    ggplot(aes(x = date, y = measure, col = stemtag)) +
    geom_point() +
    geom_line() +
    geom_point(data = stems_to_alert, col = "black", size = 4, shape = 18) +
    facet_wrap(~tag_sp, scales = "free_y") +
    theme_bw() +
    geom_vline(xintercept = ymd("2021-07-21"), col = "black", linetype = "dashed") +
    geom_vline(data = anamoly_dendroband_measurements %>% filter(new.band == 1), aes(xintercept = date)) + 
    labs(
      x = "Biweekly survey date",
      y = "Measure recorded",
      title = "Stems with an anomalous measure: abs diff > 10mm, marked with diamond",
      subtitle = "Dashed line = CI activation date, solid lines (if any) = new band install date"
    )
  
  ggsave(
    filename = anomaly_plot_filename, 
    plot = anomaly_plot,
    device = "png", 
    width = 16 / 2, height = (16/2)*(7/8), 
    units = "in", dpi = 300
  )
} else if (file.exists(anomaly_plot_filename)){
  file.remove(anomaly_plot_filename)
}



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


