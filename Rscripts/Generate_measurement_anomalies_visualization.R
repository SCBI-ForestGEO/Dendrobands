# Creates visualizations of all new measurements that are "anomalous"

library(ggplot2)
library(dplyr)
library(readr)
library(here)
library(lubridate)
library(stringr)

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




anomalies <- read_csv("testthat/reports/warnings/warnings_file.csv") %>% 
  filter(alert_name == "new_measure_too_different_from_previous")

dendroband_measurements <- dendroband_measurements %>% 
  filter(year == 2021, intraannual == 1) %>% 
  mutate(
    date = ymd(str_c(year, month, day, sep = "-")),
    stemtag = as.factor(stemtag)
  ) %>% 
  filter(!is.na(measure))


anomaly_tags <- anomalies %>% 
  pull(tag) %>% 
  unique()

anamoly_dendroband_measurements <- dendroband_measurements %>% 
  filter(tag %in% anomaly_tags)

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
filename <- file.path(here("testthat"), "reports/measurement_anomalies.png")
ggsave(filename, device = "png", width = 16 / 2, height = (16/2)*(7/8), units = "in", dpi = 300)

