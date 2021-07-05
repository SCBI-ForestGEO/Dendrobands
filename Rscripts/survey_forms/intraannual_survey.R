######################################################
# Purpose: Dendroband intraannual survey: create field forms, create data_entry forms, and merge data_entry form with year master
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018, updated by Erika Gonzalez-Akre, March 2020
######################################################
library(dplyr) #1
library(writexl) #1
library(xlsx) #1 (depends on Java)
library(zoo) #3
library(tidyverse)

#1 create field_form intraannual
#2 create data_entry form intraannual
#3 merge data_entry form intraannual with the year's master file

#1 Create field_form intraannual ####
## when printing new field forms, this code will create a new form with the updated "prevmeas".

data_2020 <- read.csv("data/scbi.dendroAll_2020.csv")

dendro_trees <- read.csv("data/dendro_trees.csv")

#subset by what's in intraannual survey
intra <- data_2020[data_2020$intraannual == "1", ]

#subset by max survey.ID (specific for each stemID - this code already takes into account if a stem has a newer measurement in a 2019.061 scenario (for example, when you measure few trees betwen surveys- compared to 2019.06)
prevmeasin <- NULL
for (i in seq(along=unique(intra$stemID))){
  sub <- data_2020[data_2020$stemID == unique(intra$stemID)[[i]], ]
  #sub <- sub[sub$survey.ID == max(sub$survey.ID), ]
  #previous line not needed when creating first datasheet of the intrannual survey but maybe needed next time.
  
  prevmeasin <- rbind(prevmeasin, sub)
}

prevmeasin<-prevmeasin[-which(is.na(prevmeasin)), ]#use this to remove rows with all NA values

data_intra <- NULL
for (i in seq(along=unique(intra$stemID))){
  sub <- data_2020[data_2020$stemID == unique(intra$stemID)[[i]], ]
  #sub <- sub[sub$survey.ID == max(sub$survey.ID), ]
  #previous line not needed when creating first datasheet of the intrannual survey but maybe needed next time.
  
  data_intra <- rbind(data_intra, sub)
}

data_intra<-data_intra[-which(is.na(data_intra)), ]#use this to remove rows with all NA values

data_intra$location <- dendro_trees$location[match(data_intra$stemID, dendro_trees$stemID)]

data_intra<-data_intra[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "measure", "codes", "location", "dbh")]

data_intra$measure = NA
for (i in 1:nrow(data_intra)){
  data_intra$codes <- ifelse(grepl("F", data_intra$codes), "F", "")
}

data_intra$"Date2: SvID: Name:" = NA
data_intra$"Date3: SvID: Name:" = NA
data_intra$"Date4: SvID: Name:" = NA
#data_intra$"Date5: SvID: Name:" = NA

data_intra <- data_intra %>% rename("Date1:  SvID:   Name:" = measure, "codes&notes" = codes, "stem" = stemtag, "dbh_2018" = dbh)

data_intra$prevmeas = prevmeasin$measure

data_intra[is.na(data_intra)&!is.na(data_intra$prevmeas)] <- " "

data_intra<-data_intra[,c(1:3,10,4:6,14,7,11:13,8:9)]

data_intra$location<-gsub("South", "S", data_intra$location)
data_intra$location<-gsub("North", "N", data_intra$location)

matrix <- function(data_intra, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_intra)-1)), # title
        names(data_intra), # column names
        unname(sapply(data_intra, as.character))) # data
  
}


temp <- matrix(data_intra, table_title=('Intraannual Survey'))
temp <- as.data.frame(temp) #don't use this if using xlsx package

write_xlsx(temp, "resources/field_forms/2020/field_form_intraannual.xlsx", col_names=FALSE)

#to add a blank spacer row between title and columns, add
"rep('', ncol(data_intra)), # blank spacer row"
#as the second line of the rbind function

#after writing new file to excel, you need to do this manually: 
  #1 add all borders, wrap text on survey columns (Date1: SvID: Name:)
  #2 adjust cell dimensions as needed
  #3 change print margins to "narrow" 
  #4 make sure print area is defined as landscape ("Page Layout")
  #5 Filter by location (S or N) and print separately

####################################################################################
#2 Create data_entry forms intraannual ####
# Create data_intra forms from master

data_2020 <- read.csv("data/scbi.dendroAll_2020.csv")
dendro_trees <- read.csv("data/dendro_trees.csv")

intra <- data_2020[data_2020$intraannual == "1", ]

data_intra <- NULL
for (i in seq(along=unique(intra$stemID))){
  sub <- data_2020[data_2020$stemID == unique(intra$stemID)[[i]], ]
  #sub <- sub[sub$survey.ID == max(sub$survey.ID), ]
  
  data_intra <- rbind(data_intra, sub)
}
data_intra<-data_intra[-which(is.na(data_intra)), ]#use this to remove rows with all NA values

data_intra$location <- dendro_trees$location[match(data_intra$stemID, dendro_trees$stemID)]

data_intra<-data_intra[ ,c("tag", "stemtag", "survey.ID", "year", "month", "day", "sp", "quadrat", "measure", "codes", "notes", "location", "field.recorders", "data.enter")]

data_intra$survey.ID = NA
data_intra$year = NA
data_intra$month = NA
data_intra$day = NA
data_intra$measure = NA
for (i in 1:nrow(data_intra)){
  data_intra$codes <- ifelse(grepl("F", data_intra$codes), "F", "")
}
data_intra$notes = NA
data_intra$field.recorders = NA
data_intra$data.enter = NA

data_intra<-data_intra[,c(1,2,7,8,3:6,9:11,13:14,12)]

data_intra[is.na(data_intra)] <- " "

write.csv(data_intra, "resources/data_entry_forms/2020/data_entry_intraannual.csv", row.names=FALSE)
#Now RENAME manually the file to reflect the survey ID, for example 2020-02

####################################################################################
#3 Merge data_entry form intraannual with the year's master file ####

# DO THIS: Set current year
current_year <- "2021"
# DO THIS: Set intrannual survey ID you want to merge into master. Should be: "02", "03", ...
survey_ID <- "02"

current_year_data <- str_c("data/scbi.dendroAll_", current_year, ".csv") %>% 
  read.csv()

#change for the appropriate surveyID file
data_intra <- str_c("resources/data_entry_forms/", current_year, "/data_entry_intraannual_", current_year, "-", survey_ID, ".csv") %>% 
  read.csv(colClasses = c("codes" = "character")) %>% 
  # As of 2020 new variable
  select(-Leaf.code)
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




#################################################################################### 
#4. to troubleshoot. Added this bc noticed discrepancy above ####
# test$codes <- as.character(test$codes)
# test$codes <- ifelse(is.na(test$codes), "", test$codes)
# test$notes <- as.character(test$notes)
# test$notes <- ifelse(is.na(test$notes), "", test$notes)



