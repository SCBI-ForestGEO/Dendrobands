# Test ground -----
library(tidyr)

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
  filter(!is.na(measure))





dendroband_measurements_2020 %>% 
  filter(intraannual == 1) %>% 
  select(tag, stemtag, sp, date, measure) %>% 
  group_by(tag, stemtag) %>% 
  filter(tag %in% c(10671, 12025, 30225)) %>% 
  ggplot(aes(x=date, y=measure)) +
  geom_point() +
  geom_smooth(method = "lm", se=FALSE) +
  facet_wrap(~tag)



growth_rates <- dendroband_measurements_2020 %>% 
  filter(intraannual == 1) %>% 
  select(tag, stemtag, sp, date, measure) %>% 
  group_by(tag, stemtag) %>% 
  mutate(
    days_elapsed = as.numeric(date - lag(date)),
    diff_measure = measure - lag(measure)
  ) %>% 
  filter(!is.na(days_elapsed)) 

ggplot(growth_rates, aes(x=sp, y = growth_per_day)) +
  geom_boxplot() +
  labs(
    x = "species", y = "Growth (mm) per day", 
    title = "2020 growth rates for all dendrobanded trees"
  ) +
  coord_cartesian(ylim = c(-0.15, 0.15))



