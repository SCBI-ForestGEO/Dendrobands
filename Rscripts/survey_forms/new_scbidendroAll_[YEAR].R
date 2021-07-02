######################################################
# Purpose: Create new year's master file (data/scbi.dendroAll_[YEAR].csv)
#
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
#
# Modified by: Albert Y. Kim - albert.ys.kim@gmail.com
# R version 4.0.3 - Modified July 2021
######################################################
library(dplyr)
library(stringr)

current_year <- substr(Sys.Date(), 1, 4)
previous_year <- current_year %>% 
  as.numeric() %>% 
  `-`(1) %>% 
  as.character()

# Get previous year's data
previous_year_data <- 
  str_c("data/scbi.dendroAll_", previous_year, ".csv") %>% 
  read.csv()

# subset by the most recent survey and live trees
current_year_data <- subset(previous_year_data, survey.ID == max(survey.ID) & status=="alive")

cols <- c("survey.ID", "year", "month", "day", "measure", "codes", "notes", "status", "field.recorders", "data.enter", "new.band")

current_year_data[,cols] <- ""
current_year_data$crown.condition <- NA
current_year_data$crown.illum <- NA

str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
  write.csv(x = current_year_data, file = ., row.names=FALSE)


