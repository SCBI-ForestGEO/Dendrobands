# determining which trees need new dendrobands

#read in most recent raw data
library(tidyverse)

recent_data <- read_csv("C:/Users/kennedyia/OneDrive - Smithsonian Institution/Documents/GitHub/Dendrobands/resources/raw_data/2026/data_entry_intraannual_2026-12.csv")
unique(recent_data$codes)

bands_to_replace <- recent_data %>%
  filter(str_detect(codes, "RE"))
bands_to_replace <- bands_to_replace%>%
  dplyr::select(-data.enter, -field.recorders, -survey.ID, -month, -day)
