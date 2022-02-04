library(dplyr)
library(stringr)
library(lubridate)
library(zoo)
library(here)
library(readr)

# Setup ----
# Set years
current_year <-  Sys.Date() %>% year()

# TODO: Remove this later
current_year <- 2021
previous_year <- current_year - 1


# Establish filenames of spring biannual, all intraannual, and fall biannual survey raw data
current_year_spring_biannual_filename <- str_c("resources/raw_data/2021/data_entry_biannual_spr", current_year, ".csv") %>% 
  here()
current_year_intraannual_filename_list <- str_c("resources/raw_data/", current_year) %>% 
  here() %>% 
  dir(path = ., pattern = "data_entry_intraannual", full.names = TRUE)
current_year_fall_biannual_filename <- str_c("resources/raw_data/2021/data_entry_biannual_fall", current_year, ".csv") %>% 
  here()

# Establish filenames of previous year and current year finalized data
previous_year_data_filename <- str_c("data/scbi.dendroAll_", previous_year, ".csv") %>% 
  here()
current_year_data_filename <- str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
  here()


# Create blank current year working/running data master csv ----
# Copied and modified from Rscripts/survey_forms/new_scbidendroAll_[YEAR].R
new_year_data <- 
  # Load previous year's data
  read_csv(previous_year_data_filename, show_col_types = FALSE) %>% 
  # Subset by the most recent survey and live trees
  filter(survey.ID == max(survey.ID) & status == "alive")

# Clear values
cols <- c("survey.ID", "year", "month", "day", "measure", "codes", "notes", "status", "field.recorders", "data.enter", "new.band")
new_year_data[, cols] <- ""
new_year_data$crown.condition <- NA
new_year_data$crown.illum <- NA

# Write to CSV
str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
  write.csv(x = new_year_data, file = ., row.names=FALSE)







# Merge data_entry form spring biannual with the year's master file ----
# Copied from Rscripts/survey_forms/biannual_survey.R
if(file.exists(current_year_spring_biannual_filename)){
  # DO THIS: Set biannual survey ID. Should be "spr" or "fall"
  season <- "spr"
  
  current_year_data <- str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
    read.csv()
  
  data_biannual <- 
    str_c("resources/raw_data/2021/data_entry_biannual_", season, "2021.csv") %>% 
    read.csv()
  
  names_current_year <- c(colnames(current_year_data))
  namesbi <- c(colnames(data_biannual))
  
  ## find the names that are in current_year_data but not in data_biannual
  missing <- setdiff(names_current_year, namesbi)
  
  ## if need be, do the opposite
  # missing <- setdiff(namesbi, names_current_year)
  
  ## add these missed names to data_biannual in order to combine to the master
  data_biannual[missing] <- NA
  data_biannual$area <- NULL #this column is only relevant for field
  
  test <- rbind(current_year_data, data_biannual)
  
  test <- test[order(test$tag, test$stemtag, test$survey.ID, na.last=FALSE), ] #order by tag, then stemtag, then survey.ID (IMPORTANT for multistem plants)
  
  ## this section (next ten lines) was specifically generated for adding in spring biannual survey to a new dataframe for that year, just fyi
  cols <- c(7,8,11,12,19,20,22,24,25,27)
  # cols <- c("biannual", "intraannual", "lx", "ly", "stemID", "treeID", "dbh", "new.band", "dendroID", "type", "dendHt") #these are the columns that the numbers are referring to
  
  for (i in seq(along=cols)){
    col_no <- cols[[i]]
    test[,col_no] <- ifelse(is.na(test[,col_no]) & test$tag == lag(test$tag), na.locf(test[,col_no]), test[,col_no])
  }
  
  # continue like normal
  # this is done to get rid of any placeholders. Essentially, the full
  # current_year form was created to make the current_year spring biannual field form.
  # However, there were also new trees added to the survey with a
  # survey.ID of .00, so now we can get rid of these extra
  # placeholders now that we've shifted the data above using na.locf.
  test <- test[!(is.na(test$survey.ID)), ]
  
  ## these values are not always constant
  test$new.band <- ifelse(is.na(test$new.band), 0, test$new.band)
  deadcodes <- c("DS", "DC", "DN", "DT")
  test$status <- ifelse(grepl("D", test$codes), "dead", "alive")
  
  test$codes <- as.character(test$codes)
  test$codes <- ifelse(is.na(test$codes), "", test$codes)
  test$notes <- as.character(test$notes)
  test$notes <- ifelse(is.na(test$notes), "", test$notes)
  
  str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
    write.csv(x = test, file = ., row.names=FALSE)
  
  
}





# Merge all individual intraannual surveys ----------------------------------------
# Copied from Rscripts/survey_forms/intraannual.R
if(length(current_year_intraannual_filename_list) > 0){
  # DO THIS: Set current year
  current_year <- "2021"
  
  intraannual_surveys <-  str_c("resources/raw_data/", current_year) %>% 
    here() %>% 
    dir(path = ., pattern = "data_entry_intraannual", full.names = TRUE)
  
  for(i in 1:length(intraannual_surveys)){
    current_year_data <- str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
      read.csv()
    
    #change for the appropriate surveyID file
    data_intra <- intraannual_surveys[i] %>% 
      read.csv(colClasses = c("codes" = "character")) %>% 
      # As of 2020 new variable, remove it:
      select(-matches("Leaf.code")) %>% 
      # As of 2021 new variable, remove it:
      select(-matches("measure_verified")) %>%     
      # Select specific columns
      select(tag, stemtag, sp, quadrat, survey.ID, year, month, 
             day, measure, codes, notes, field.recorders, data.enter, 
             location)
    # data_intra$codes <- ifelse(is.na(data_intra$codes), "", data_intra$codes)
    # data_intra$notes <- ifelse(is.na(data_intra$notes), "", data_intra$notes)
    
    names_current_year <- c(colnames(current_year_data))
    namesintra <- c(colnames(data_intra))
    
    ## find the names that are in data_2018 but not in data_biannual
    missing <- setdiff(names_current_year, namesintra)
    
    ## if need be, do the opposite
    # missing <- setdiff(namesintra, names_current_year)
    
    ## add these missed names to data_intra in order to combine to the master
    data_intra[missing] <- NA
    data_intra$area <- NULL #this column is only relevant for field
    data_intra$location <- NULL #only for when merging data pre-2018
    
    test <- rbind(current_year_data, data_intra)
    
    test <- test[order(test[,"tag"], test[,"stemtag"], test[,"survey.ID"]),] #order by tag and survey.ID
    
    ## these values are constant from the previous survey.ID
    test$biannual <- na.locf(test$biannual)
    test$intraannual <- na.locf(test$intraannual)
    test$lx <- na.locf(test$lx)
    test$ly <- na.locf(test$ly)
    test$stemID <- na.locf(test$stemID)
    test$treeID <- na.locf(test$treeID)
    test$dbh <- na.locf(test$dbh)
    
    
    ## these should be constant from previous survey, but obviously are updated whenever a new dendroband is installed
    test$dendroID <- na.locf(test$dendroID)
    test$dendHt <- na.locf(test$dendHt)
    test$type <- na.locf(test$type)
    
    ## these values are not always constant
    test$new.band <- ifelse(is.na(test$new.band), 0, test$new.band)
    test$status <- as.character(test$status)
    test$status <- ifelse((is.na(test$status))&(grepl("D", test$codes)), "dead", na.locf(test$status))
    
    #DENDROID
    ##1. if any bands were given a note of "band adjusted" in the intraannual survey, give it a new.band = 1 and update the dendroID in the scbi.dendroAll_YEAR.csv manually
    ##1a. disclaimer: if it is a *new* band, give a new id number but if the band adjustment doesn't seem to affect the data, leave the band id the same
    ##2. this will be easier because a, it happens very infrequently and b, it's faster.
    ##3. MAKE SURE to then do Section #4 of fix_dendrobands.R script 
    
    str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
      write.csv(x = test, file = ., row.names=FALSE)
  }
}












# Merge data_entry form fall biannual with the year's master file -----
# Copied from Rscripts/survey_forms/biannual_survey.R
if(file.exists(current_year_fall_biannual_filename)){
  # DO THIS: Set current year
  current_year <- "2021"
  
  # DO THIS: Set biannual survey ID. Should be "spr" or "fall"
  season <- "fall"
  fall_biannual_survey <- str_c("resources/raw_data/", current_year, "/data_entry_biannual_", season, current_year, ".csv") %>% 
    here()
  
  current_year_data <- str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
    read.csv()
  
  data_biannual <- 
    fall_biannual_survey %>% 
    read.csv()
  
  names_current_year <- c(colnames(current_year_data))
  namesbi <- c(colnames(data_biannual))
  
  ## find the names that are in current_year_data but not in data_biannual
  missing <- setdiff(names_current_year, namesbi)
  
  ## if need be, do the opposite
  # missing <- setdiff(namesbi, names_current_year)
  
  ## add these missed names to data_biannual in order to combine to the master
  data_biannual[missing] <- NA
  data_biannual$area <- NULL #this column is only relevant for field
  data_biannual$measure_verified <- NULL #this column is only relevant for verifying measurements in the field
  
  test <- rbind(current_year_data, data_biannual)
  
  test <- test[order(test$tag, test$stemtag, test$survey.ID, na.last=FALSE), ] #order by tag, then stemtag, then survey.ID (IMPORTANT for multistem plants)
  
  ## this section (next ten lines) was specifically generated for adding in spring biannual survey to a new dataframe for that year, just fyi
  cols <- c(7,8,11,12,19,20,22,24,25,27)
  # cols <- c("biannual", "intraannual", "lx", "ly", "stemID", "treeID", "dbh", "new.band", "dendroID", "type", "dendHt") #these are the columns that the numbers are referring to
  
  for (i in seq(along=cols)){
    col_no <- cols[[i]]
    test[,col_no] <- ifelse(is.na(test[,col_no]) & test$tag == lag(test$tag), na.locf(test[,col_no]), test[,col_no])
  }
  
  # continue like normal
  # this is done to get rid of any placeholders. Essentially, the full
  # current_year form was created to make the current_year spring biannual field form.
  # However, there were also new trees added to the survey with a
  # survey.ID of .00, so now we can get rid of these extra
  # placeholders now that we've shifted the data above using na.locf.
  test <- test[!(is.na(test$survey.ID)), ]
  
  ## these values are not always constant
  test$new.band <- ifelse(is.na(test$new.band), 0, test$new.band)
  deadcodes <- c("DS", "DC", "DN", "DT")
  test$status <- ifelse(grepl("D", test$codes), "dead", "alive")
  
  test$codes <- as.character(test$codes)
  test$codes <- ifelse(is.na(test$codes), "", test$codes)
  test$notes <- as.character(test$notes)
  test$notes <- ifelse(is.na(test$notes), "", test$notes)
  
  str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
    write.csv(x = test, file = ., row.names=FALSE)
  
  
  
  
}



