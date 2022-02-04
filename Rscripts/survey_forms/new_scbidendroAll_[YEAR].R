######################################################
# DEPRECATED: This script is superseded by 
# Rscripts/survey_forms/create_master_csv_2021_and_after.R
# as of January 2022 by Albert Y. Kim - albert.ys.kim@gmail.com
# 
# Purpose: Create new year's master file
# (data/scbi.dendroAll_[YEAR].csv)
#
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
#
# Modified by: Albert Y. Kim - albert.ys.kim@gmail.com
# R version 4.0.3 - Modified July 2021
######################################################
library(dplyr)
library(stringr)

new_year <- "2021"
previous_year <- new_year %>% 
  as.numeric() %>% 
  `-`(1) %>% 
  as.character()

# Get previous year's data
previous_year_data <- 
  str_c("data/scbi.dendroAll_", previous_year, ".csv") %>% 
  read.csv()

# subset by the most recent survey and live trees
new_year_data <- subset(previous_year_data, survey.ID == max(survey.ID) & status=="alive")

cols <- c("survey.ID", "year", "month", "day", "measure", "codes", "notes", "status", "field.recorders", "data.enter", "new.band")

new_year_data[,cols] <- ""
new_year_data$crown.condition <- NA
new_year_data$crown.illum <- NA

str_c("data/scbi.dendroAll_", new_year, ".csv") %>% 
  write.csv(x = new_year_data, file = ., row.names=FALSE)


