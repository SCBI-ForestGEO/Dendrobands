######################################################
# Purpose: give count of each species by survey, plus the min, max, and avg dbh per species
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created February 2019
#
# Modified by: Albert Y. Kim - albert.ys.kim@gmail.com
# R version 4.0.3 - Changed script to run on all years in January 2022
######################################################
# Load libraries. These packages need to be included in DESCRIPTION
# file for CI to work
library(dplyr)
library(stringr)
library(lubridate)
library(here)
library(data.table)
library(purrr)

# Get current year
current_year <- Sys.Date() %>% 
  year()

# If fall biannual survey has been conducted for current year, create
# summary CSV for current year, otherwise don't
fall_biannual_survey <- str_c("resources/raw_data/", current_year, "/data_entry_biannual_fall", current_year, ".csv") %>% 
  here()
if(file.exists(fall_biannual_survey)){
  max_year <- current_year
} else {
  max_year <- current_year -1 
}


for(year in c(2010:2021)){
  year_data <-
    str_c("data/scbi.dendroAll_", year, ".csv") %>% 
    read.csv()
  year_spring_survey_ID <- year_data$survey.ID %>% 
    min() %>% 
    as.character()
  year_fall_survey_ID <- year_data$survey.ID %>% 
    max() %>% 
    as.character()
  output_csv_file <- "results/dendro_trees_dbhcount/" %>% 
    here() %>% 
    str_c("dendro_trees_sp_", year, "_min_max_mean_dbh.csv")
  
  
  # subset by the last survey from the year
  data_surveys <- subset(year_data, year_data$survey.ID == year_fall_survey_ID) 
  # & year_data$status=='alive') #get rid of '0' values for minimum
  
  data_trees <- year_data[!duplicated(year_data["sp"]), ]
  data_trees <- data_trees[c("sp")] # list that shows all sp alive and dead
  
  # make data.frames with the dbhmax,min,mean by sp
  data_surveys$dbh <- as.numeric(data_surveys$dbh)
  dbhmax <- aggregate(data_surveys$dbh, by = list(data_surveys$sp), max)
  dbhmin <- aggregate(data_surveys$dbh, by = list(data_surveys$sp), min)
  dbhavg <- aggregate(data_surveys$dbh, by = list(data_surveys$sp), mean)
  
  names(dbhmax) <- c("sp", "dbhmax.mm")
  names(dbhmin) <- c("sp", "dbhmin.mm")
  names(dbhavg) <- c("sp", "dbhavg.mm")
  
  is.num <- sapply(dbhavg, is.numeric)
  dbhavg[is.num] <- lapply(dbhavg[is.num], round, 1)
  
  # create data.frame with count of sp per survey
  
  
  data_01 <- subset(year_data, year_data$survey.ID == year_spring_survey_ID) # get all sp
  
  countbi <- addmargins(table(data_01$sp, data_01$biannual), 1)
  countbi <- as.data.frame.matrix(countbi)
  setDT(countbi, keep.rownames = TRUE)[]
  colnames(countbi) <- c("sp", "biannual.n")
  
  countintra <- addmargins(table(data_01$sp, data_01$intraannual == 1), 1)
  countintra <- as.data.frame.matrix(countintra)
  setDT(countintra, keep.rownames = TRUE)[]
  colnames(countintra) <- c("sp", "wrong", "intraannual.n")
  countintra$wrong <- NULL
  
  # merge the data.frames together
  # have to make two separate dataframes, then merge them together to make sure the "Sum" row is kept
  data_count <- merge(countbi, countintra, by = "sp")
  data_num <- list(data_trees, dbhmin, dbhmax, dbhavg) %>% 
    reduce(left_join, by = "sp")
  
  data_merged <- merge(data_count, data_num, by = "sp", all.x = TRUE)
  
  data_merged <- data_merged[order(data_merged$sp), ]
  
  ## reorder to make "Sum" row be last. These numbers may change
  ## depending on if a tree has been fully removed from the survey
  data_merged <- data_merged[c(2:20, 22, 23, 21, 1), ]
  
  write.csv(data_merged, output_csv_file, row.names = FALSE)
}
