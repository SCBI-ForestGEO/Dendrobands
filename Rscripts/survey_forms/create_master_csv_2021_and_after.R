# Purposes: 
# 1. Take current year's field form csv's in resources/raw_data/YEAR/ and create
# a) master version of data that's cleaned and ready for analysis in data/scbi.dendroAll_YEAR.csv
# b) next survey's blank field form
#
# This script is based on now deprecated scripts: new_scbidendroAll_[YEAR].R,
# biannual_survey.R, intraannual_survey.R
# 
# Developed by: Albert Y. Kim - albert.ys.kim@gmail.com
# R version 4.0.3 - First created in 2021
#
# 🔥HOT TIP🔥 Get a bird's eye view of what this code is doing by
# turning on "code folding" by going to RStudio menu -> Edit -> Folding
# -> Collapse all

# Setup ----
# These packages must be included in DESCRIPTION for continuous integration to work
library(dplyr)
library(stringr)
library(lubridate)
library(zoo)
library(readr)
library(here)

## Establish years and filenames ----
# Get current year
current_year <- Sys.Date() %>% 
  year()

# Establish filenames of this year's spring biannual, all intraannual,
# and fall biannual survey raw data
current_year_spring_biannual_filename <- 
  str_c("resources/raw_data/", current_year, "/data_entry_biannual_spr", current_year, ".csv") %>% 
  here()
current_year_intraannual_filename_list <- 
  str_c("resources/raw_data/", current_year) %>% 
  here() %>% 
  # Ignore _BLANK .csv files
  dir(path = ., pattern = "data_entry_intraannual_[0-9]+-[0-9]+\\.csv", full.names = TRUE)
current_year_fall_biannual_filename <- 
  str_c("resources/raw_data/", current_year, "/data_entry_biannual_fall", current_year, ".csv") %>% 
  here()

# Establish filenames of previous year and current year finalized data
current_year_data_filename <- str_c("data/scbi.dendroAll_", current_year, ".csv") %>%
  here()



## Create current year's blank master data csv ----
# Code taken from Rscripts/survey_forms/new_scbidendroAll_[YEAR].R
# Read-in BLANK form
scbi.dendroAll_BLANK <- read_csv("data/scbi.dendroAll_BLANK.csv", show_col_types = FALSE) 

# Data frame of this year's data
new_year_data <- scbi.dendroAll_BLANK

# Clear values
variables_to_reset <- c(
  "survey.ID", "year", "month", "day", "measure", "codes", "notes", 
  "status", "field.recorders", "data.enter", "new.band", 
  "crown.condition", "crown.illum"
)
new_year_data[, variables_to_reset] <- ""


# Write to CSV for data folder
write.csv(x = new_year_data, file = current_year_data_filename, row.names=FALSE)

## Load location and area of all stems ----
# Code taken from Rscripts/survey_forms/biannual_survey.R on 2022/2/3
stem_locations <- 
  # TODO: dendro_trees.csv needs updating:
  # read_csv("data/dendro_trees.csv", show_col_types = FALSE) %>% 
  # select(tag, stemtag, quadrat, location) %>% 
  # For now do this manually, remove later
  bind_rows(
    scbi.dendroAll_BLANK %>% 
      mutate(location = ifelse(quadrat %% 100 <= 15, "South", "North")) %>% 
      select(tag, stemtag, quadrat, location)
  ) %>% 
  mutate(
    # Assign areas based on quadrats
    area = case_when(
      quadrat %in% c(1301:1303, 1401:1404, 1501:1515, 1601:1615, 1701:1715, 1801:1815, 1901:1915, 2001:2015) ~ 1,
      quadrat %in% c(404:405, 504:507, 603:609, 703:712, 803:813, 901:913, 1003:1012, 1101:1112, 1201:1212, 1304:1311, 1405:1411) ~ 2,
      quadrat %in% c(101:115, 201:215, 301:315, 401:403, 406:415, 502, 512:515, 610,611,614,615,701,702,713,715,801,915,1001,1013,1014,1215,1313,1314,1315,1413,1415) ~ 3,
      quadrat %in% c(116:132, 216:232, 316:332, 416:432, 516:532, 616:624, 716:724, 816:824) ~ 4,
      quadrat %in% c(916:924, 1016:1024, 1116:1124, 1216:1224, 1316:1324, 1416:1418,1420:1424) ~ 5,
      quadrat %in% c(1419, 1516:1524, 1616:1624, 1716:1724, 1816:1824, 1916:1924, 2016:2024) ~ 6,
      quadrat %in% c(625:632, 725:732, 825:832, 925:932, 1025:1029,1031,1032) ~ 7,
      quadrat %in% c(1030, 1125:1132, 1225:1232, 1325:1332, 1425:1432) ~ 8,
      quadrat %in% c(1525:1532, 1625:1632, 1725:1732, 1825:1832, 1925:1932, 2025:2032) ~ 9
    ),
    # Special cases
    area = ifelse(tag == 70579, 2, area),
    area = ifelse(tag == 111305, 3, area), # https://github.com/SCBI-ForestGEO/Dendrobands/issues/109 
    area = ifelse(quadrat == 714 & tag != 70579, 3, area),
    # Convert to character
    area = as.character(area)
  ) %>% 
  distinct()


# merge stem_locations to new_year_data along with fall biannual measurement

spring_biannual_area <- merge(new_year_data, 
                       stem_locations, 
                       by = c("tag", "stemtag", "quadrat"))

fall_measurement <- 
  read_csv(last_year_fall_biannual_filename, show_col_types = FALSE) %>% 
  select(tag,
         stemtag,
         measure) %>% 
  rename(previous_measure = measure)

spring_biannual <- merge(spring_biannual_area, 
                         fall_measurement,
                         by = c("tag", "stemtag"),
                         all.x = TRUE)
  


# Write to CSV for spring biannual
write.csv(x = spring_biannual, file = current_year_spring_biannual_filename, row.names=FALSE)



# 2. Process spring biannual field form ----
# Code taken from Rscripts/survey_forms/biannual_survey.R
if(file.exists(current_year_spring_biannual_filename)){
  ## 2.a) Merge data_entry form spring biannual with the year's master file ----
  current_year_data <- read.csv(current_year_data_filename)
  data_biannual <- read.csv(current_year_spring_biannual_filename)
  
  names_current_year <- c(colnames(current_year_data))
  namesbi <- c(colnames(data_biannual))
  
  # find the names that are in current_year_data but not in data_biannual
  ## add these missed names to data_biannual in order to combine to the master
  missing_vars <- setdiff(names_current_year, namesbi)
  data_biannual[missing_vars] <- NA
  
  # if need be, do the opposite
  # these variables are only relevant for field
  drop_vars <- setdiff(namesbi, names_current_year)
  data_biannual <- data_biannual %>% 
    select(-all_of(drop_vars))
  
  test <- rbind(current_year_data, data_biannual)
  
  # order by tag, then stemtag, then survey.ID (IMPORTANT for multistem plants):
  test <- test[order(test$tag, test$stemtag, test$survey.ID, na.last=FALSE), ] 
  
  ## this section (next ten lines) was specifically generated for adding
  ## in spring biannual survey to a new dataframe for that year, just
  ## fyi
  cols <- c("biannual", "intraannual", "lx", "ly", "stemID", "treeID", "dbh", "new.band", "dendroID", "type", "dendHt")
  for (i in seq(along=cols)){
    col <- cols[[i]]
    test[,col] <- ifelse(is.na(test[,col]) & test$tag == lag(test$tag), na.locf(test[,col]), test[,col])
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
  
  # Write to CSV
  write.csv(x = test, file = current_year_data_filename, row.names=FALSE)
  
  
  
  ## 2.b) Create field form for first biweekly (if it hasn't taken place yet)----
  if(length(current_year_intraannual_filename_list) == 0){
    new_survey_ID <- "02"
    
    blank_form <- scbi.dendroAll_BLANK %>% 
      as_tibble() %>% 
      # IMPORTANT: Keep only intraannual
      filter(intraannual == 1) %>% 
      # Join location data
      left_join(stem_locations, by = c("tag", "stemtag", "quadrat")) %>% 
      # Join previous measure
      left_join(
        test %>% 
          filter(survey.ID == max(survey.ID)) %>% 
          select(tag, stemtag, previous_measure = measure) %>% 
          distinct(),
        by = c("tag", "stemtag")
      ) %>% 
      mutate(measure_verified = "")
    
    blank_form[, variables_to_reset] <- ""
    
    blank_form <- blank_form %>% 
      select(
        # Variables identifying stem:
        tag, stemtag, sp, dbh, 
        # Location variables:
        quadrat, lx, ly, area, location, 
        # Measured variables:
        previous_measure, measure, measure_verified, 
        # crown.condition, crown.illum, 
        new.band, codes, notes, 
        # Variables with values that won't vary within one survey:
        survey.ID, year, month, day, field.recorders, data.enter
      ) %>% 
      mutate(
        year = current_year, 
        survey.ID = str_c(year, ".", new_survey_ID)
      )
    
    str_c(here(), "/resources/raw_data/", current_year, "/data_entry_intraannual_", current_year,"-", new_survey_ID, "-BLANK.csv") %>% 
      write_csv(x = blank_form, file = .)
  }
  
}





# 3. Process all individual intraannual field form ----------------------------------------
# Code taken from Rscripts/survey_forms/intraannual.R

if(length(current_year_intraannual_filename_list) > 0){
  ## 3.a) Merge data_entry forms for all biweekly surveys with the year's master file ----
  for(i in 1:length(current_year_intraannual_filename_list)){
    current_year_data <- read.csv(current_year_data_filename)
    
    # Change for the appropriate surveyID file
    data_intra <- current_year_intraannual_filename_list[i] %>% 
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
    
    # Write to CSV
    write.csv(x = test, file = current_year_data_filename, row.names=FALSE)
  }
  
  ## 3.b) Create field form for next biweekly -----
  # Create survey.ID in double digit form
  new_survey_ID <- length(current_year_intraannual_filename_list) + 2
  new_survey_ID <- str_pad(new_survey_ID, width = 2, side = "left", pad = "0")
  
  blank_form <- scbi.dendroAll_BLANK %>% 
    as_tibble() %>% 
    # IMPORTANT: Keep only intraannual
    filter(intraannual == 1) %>% 
    # Join location data
    left_join(stem_locations, by = c("tag", "stemtag", "quadrat")) %>% 
    # Join previous measure from last survey
    left_join(
      test %>% 
        filter(survey.ID == max(survey.ID)) %>% 
        select(tag, stemtag, previous_measure = measure) %>% 
        distinct(),
      by = c("tag", "stemtag")
    ) %>% 
    mutate(measure_verified = "")
  
  blank_form[, variables_to_reset] <- ""
  
  blank_form <- blank_form %>% 
    select(
      # Variables identifying stem:
      tag, stemtag, sp, dbh, 
      # Location variables:
      quadrat, lx, ly, area, location, 
      # Measured variables:
      previous_measure, measure, measure_verified, 
      # crown.condition, crown.illum, 
      new.band, codes, notes, 
      # Variables with values that won't vary within one survey:
      survey.ID, year, month, day, field.recorders, data.enter
    ) %>% 
    mutate(
      year = current_year, 
      survey.ID = str_c(year, ".", new_survey_ID)
    )
  
  str_c(here(), "/resources/raw_data/", current_year, "/data_entry_intraannual_", current_year,"-", new_survey_ID, "-BLANK.csv") %>% 
    write_csv(x = blank_form, file = .)
  
  
}












# 4. Process fall biannual field form -----
# Code taken from Rscripts/survey_forms/biannual_survey.R
if(file.exists(current_year_fall_biannual_filename)){
  ## 4.a) Merge data_entry form spring biannual with the year's master file ----
  current_year_data <- read.csv(current_year_data_filename)
  data_biannual <- read.csv(current_year_fall_biannual_filename)
  
  names_current_year <- c(colnames(current_year_data))
  namesbi <- c(colnames(data_biannual))
  
  # find the names that are in current_year_data but not in data_biannual
  ## add these missed names to data_biannual in order to combine to the master
  missing_vars <- setdiff(names_current_year, namesbi)
  data_biannual[missing_vars] <- NA
  
  # if need be, do the opposite
  # these variables are only relevant for field
  drop_vars <- setdiff(namesbi, names_current_year)
  data_biannual <- data_biannual %>% 
    select(-all_of(drop_vars))
  
  test <- rbind(current_year_data, data_biannual)
  
  # order by tag, then stemtag, then survey.ID (IMPORTANT for multistem plants):
  test <- test[order(test$tag, test$stemtag, test$survey.ID, na.last=FALSE), ] 
  
  ## this section (next ten lines) was specifically generated for adding
  ## in spring biannual survey to a new dataframe for that year, just
  ## fyi
  cols <- c("biannual", "intraannual", "lx", "ly", "stemID", "treeID", "dbh", "new.band", "dendroID", "type", "dendHt")
  for (i in seq(along=cols)){
    col <- cols[[i]]
    test[,col] <- ifelse(is.na(test[,col]) & test$tag == lag(test$tag), na.locf(test[,col]), test[,col])
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
  
  # Write to CSV
  write.csv(x = test, file = current_year_data_filename, row.names=FALSE)
  
}



