# Creates visualizations of all new measurements that are "anomalous"

library(ggplot2)


anomalies <- read_csv("testthat/reports/warnings/warnings_file.csv") %>% 
  filter(alert_name == "new_measure_too_different_from_previous")

dendroband_measurements <- dendroband_measurements %>% 
  filter(year == 2021, intraannual == 1) %>% 
  select(tag, stemtag, year, month, day, measure) %>% 
  mutate(
    date = ymd(str_c(year, month, day, sep = "-")),
    stemtag = as.factor(stemtag)
  )


anomaly_tags <- anomalies %>% 
  pull(tag) %>% 
  unique()


dendroband_measurements %>% 
  filter(tag %in% anomaly_tags) %>% 
  ggplot(aes(x = date, y = measure, col = stemtag)) +
  geom_point() + 
  geom_line() +
  facet_wrap(~tag, scales = "free_y", ncol = 4) +
  theme_bw() +
  geom_vline(xintercept = ymd("2021-07-21"), col = "black", linetype = "dashed") +
  labs(
    x = "Biweekly survey date",
    y = "Measure recorded",
    title = "All stems with at least one difference in dendroband measures > 10mm"
  )
filename <- file.path(here("testthat"), "reports/measurement_anomalies.png")
ggsave(filename, device = "png", width = 16 / 2, units = "in", dpi = 300)

