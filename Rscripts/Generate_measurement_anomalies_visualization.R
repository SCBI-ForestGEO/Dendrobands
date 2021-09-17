# Creates visualizations of all new measurements that are "anomalous" ----
# i.e. tagged "new_measure_too_different_from_previous"
library(ggplot2)
library(dplyr)
library(readr)
library(here)
library(lubridate)
library(stringr)

# Load all master data files into a single data frame ----
master_data_filenames <- dir(path = here("data"), pattern = "scbi.dendroAll*", full.names = TRUE)

dendroband_measurements <- NULL
for(i in 1:length(master_data_filenames)){
  dendroband_measurements <- 
    bind_rows(
      dendroband_measurements,
      read_csv(master_data_filenames[i], col_types = cols(dbh = col_double(), dendDiam = col_double()))
    )
}

# Focus for now only on 2021 biweekly measurements
# TODO: later include biannual
dendroband_measurements <- dendroband_measurements %>% 
  filter(year == 2021, intraannual == 1) %>% 
  mutate(
    date = ymd(str_c(year, month, day, sep = "-")),
    stemtag = as.factor(stemtag)
  ) %>% 
  filter(!is.na(measure))



# Pull out all anomalous measurements ----
anomaly_tags <- 
  "testthat/reports/warnings/warnings_file.csv" %>% 
  read_csv() %>% 
  filter(alert_name == "new_measure_too_different_from_previous") %>% 
  pull(tag) %>% 
  unique()

anamoly_dendroband_measurements <- dendroband_measurements %>% 
  filter(tag %in% anomaly_tags)


# Plot ----
anamoly_dendroband_measurements %>% 
  filter(tag %in% anomaly_tags) %>% 
  ggplot(aes(x = date, y = measure, col = stemtag)) +
  geom_point() + 
  geom_line() +
  facet_wrap(~tag, scales = "free_y", ncol = 4) +
  theme_bw() +
  geom_vline(xintercept = ymd("2021-07-21"), col = "black", linetype = "dashed") +
  geom_vline(data = anamoly_dendroband_measurements %>% filter(new.band == 1), aes(xintercept = date)) + 
  labs(
    x = "Biweekly survey date",
    y = "Measure recorded",
    title = "All stems with at least one difference in dendroband measures > 10mm",
    subtitle = "Dashed line = continuous integration activation date, solid lines (if any) = new band installation dates"
  )

# Write to file
file.path(here("testthat"), "reports/measurement_anomalies.png") %>% 
  ggsave(device = "png", width = 16 / 2, height = (16/2)*(7/8), units = "in", dpi = 300)






# Test ground -----
anamoly_dendroband_measurements %>% 
  filter(tag == 12025) %>% 
  slice(1:2) %>% 
  select(date, measure) %>% 
  mutate(
    diff_date = date - lag(date),
    diff_date = as.numeric(diff_date),
    diff_measure = measure - lag(measure),
    rate = diff_measure/diff_date
  )


dendroband_measurements <- NULL
for(i in 1:length(master_data_filenames)){
  dendroband_measurements <- 
    bind_rows(
      dendroband_measurements,
      read_csv(master_data_filenames[i], col_types = cols(dbh = col_double(), dendDiam = col_double()))
    )
}

dendroband_measurements <- dendroband_measurements %>% 
  filter(year == 2020) %>% 
  mutate(
    date = ymd(str_c(year, month, day, sep = "-")),
    stemtag = as.factor(stemtag)
  ) %>% 
  filter(!is.na(measure))

growth_rates <- dendroband_measurements %>% 
  select(tag, stemtag, sp, date, measure) %>% 
  group_by(tag, stemtag, sp) %>% 
  slice(c(1,n())) %>% 
  mutate(
    diff_date = date - lag(date),
    diff_date = as.numeric(diff_date),
    diff_measure = measure - lag(measure),
    rate = diff_measure/diff_date
  ) %>% 
  filter(!is.na(diff_date) & !is.na(rate)) %>% 
  select(-c(date, measure))

ggplot(growth_rates, aes(x=sp, y = rate)) +
  geom_boxplot() +
  labs(
    x = "species", y = "Growth (mm) per day", 
    title = "2020 growth rates for all dendrobanded trees"
  )

file.path(here("testthat"), "reports/growth_rates_2020.png") %>% 
  ggsave(device = "png", width = 16 / 2, height = (16/2)*(7/8), units = "in", dpi = 300)
