# Testing anomaly detector based on growth rate ------
## Load data ----
# First run generate_reports.R up to and including 
# "new_measure_too_different_from_previous" tests
library(tidyr)
library(rsample)
library(purrr)

dendroband_measurements_2020 <- NULL
for(i in 1:length(master_data_filenames)){
  dendroband_measurements_2020 <- 
    bind_rows(
      dendroband_measurements_2020,
      read_csv(master_data_filenames[i], col_types = cols(dbh = col_double(), dendDiam = col_double()))
    )
}

dendroband_measurements_2020 <- dendroband_measurements_2020 %>% 
  filter(year == 2020) %>% 
  mutate(
    date = ymd(str_c(year, month, day, sep = "-")),
    stemtag = as.factor(stemtag)
  ) %>% 
  filter(!is.na(measure)) %>% 
  # consider only biweekly stems
  filter(intraannual == 1)  



## Plot growth of randomly selected biweekly quru stems ----
dendroband_measurements_2020 %>% 
  select(tag, stemtag, sp, date, measure) %>% 
  filter(sp == "quru") %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>% 
  filter(tag_stemtag %in% sample(unique(tag_stemtag), 16)) %>% 
  ggplot(aes(x=date, y=measure)) +
  geom_point() +
  geom_smooth(method = "lm", se=FALSE) +
  facet_wrap(~tag)


# Compute and plot daily growth rate ----
growth_rates <- dendroband_measurements_2020 %>% 
  select(tag, stemtag, sp, date, measure) %>% 
  group_by(tag, stemtag) %>% 
  # Only for values up to this date:
  # filter(date < ymd("2020-06-22")) %>% 
  slice(1, n()) %>% 
  mutate(
    days_elapsed = as.numeric(date - lag(date)),
    diff_measure = measure - lag(measure),
    growth_per_day = diff_measure/days_elapsed
  ) %>% 
  filter(!is.na(days_elapsed), !is.na(growth_per_day)) 

# Plot
ggplot(growth_rates, aes(x=sp, y = growth_per_day)) +
  geom_boxplot() +
 # geom_jitter(width = 0.05, alpha = 0.2, col = "orange") +
  labs(
    x = "species", y = "Growth (mm) per day", 
    title = "2020 growth rates for all dendrobanded trees"
  ) 

# Quantiles
growth_rates %>% 
  group_by(sp) %>% 
  summarize(lower = quantile(growth_per_day, 0.005), upper = quantile(growth_per_day, 1-0.005), count = n()) %>% 
  arrange(count) %>% 
  filter(sp == "quru")

# From Generate_reports.R
dendroband_measurements %>% 
  arrange(tag, stemtag, date) %>% 
  group_by(tag, stemtag) %>% 
  mutate(
    # Absolute difference
    diff_measure = measure - lag(measure),
    measure_is_reasonable = (abs(diff_measure) < threshold) | lag(new.band == 1),
    # Relative difference
    days_elapsed = as.numeric(date - lag(date)),
    growth_per_day = diff_measure/days_elapsed
  ) %>%
  filter(!measure_is_reasonable) %>% 
  select(tag, stemtag, sp, date, diff_measure, days_elapsed, growth_per_day)




