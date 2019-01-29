# This code builds survey forms for intraannual survey, and then merges the data to the master

#1 create field_form intraannual
#2 create data_entry form intraannual
#3 merge data_entry form intraannual with the year's master file

#1 Create field_form intraannual ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/protocols_field-resources/field_forms")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

prevmeasin <- subset(data_2018,survey.ID=="2018.01" & intraannual=="1") #subset by previous survey.ID. Change "2018.01" to be the most recent survey.ID when printing a new field form (to have updated previous measurement)

data_intra <- subset(data_2018,survey.ID=="2018.01" & intraannual=="1") #subset by 2018.01 (one entry per stem)

data_intra<-data_intra[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "measure", "codes", "location", "dbh")]

data_intra$measure = NA
data_intra$codes = NA
data_intra$"Date2: SvID: Name:" = NA
data_intra$"Date3: SvID: Name:" = NA
data_intra$"Date4: SvID: Name:" = NA
data_intra$"Date5: SvID: Name:" = NA

library(dplyr)
data_intra<-data_intra %>% rename("Date1:  SvID:   Name:" = measure, "codes&notes" = codes, "stem" = stemtag)

data_intra$prevmeas = prevmeasin$measure

data_intra[is.na(data_intra)&!is.na(data_intra$prevmeas)] <- " "

data_intra<-data_intra[,c(1:3,10,4:6,15,7,11:14,8:9)]

data_intra$location<-gsub("South", "S", data_intra$location)
data_intra$location<-gsub("North", "N", data_intra$location)

matrix <- function(data_intra, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_intra)-1)), # title
        names(data_intra), # column names
        unname(sapply(data_intra, as.character))) # data
  
}

temp <- matrix(data_intra, table_title=('Intraannual Survey'))


library(xlsx)
write.xlsx(temp, "field_form_intraannual.xlsx", row.names=FALSE, col.names=FALSE)

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_intra)), # blank spacer row"
#as the second line of the rbind function

#after writing new file to excel, need to 
  #1 delete the first row and first column
  #2 add all borders, merge and center title across top
  #3 adjust cell dimensions as needed
  #4 change print margins to "narrow"
  #4 make sure print area is defined as wanted ("Page Layout")

####################################################################################
#2 Create data_entry forms intraannual ####
# Create data_intra forms from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/protocols_field-resources/data_entry_forms")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

data_intra<-data_2018[which(data_2018$survey.ID=='2018.01' & data_2018$intraannual=='1'), ] #subset by 2018.01 (one entry per stem)

data_intra<-data_intra[ ,c("tag", "stemtag", "survey.ID", "year", "month", "day", "sp", "quadrat", "measure", "codes", "notes", "location", "field.recorders", "data.enter")]

data_intra$survey.ID = NA
data_intra$year = NA
data_intra$month = NA
data_intra$day = NA
data_intra$measure = NA
data_intra$codes = NA
data_intra$notes = NA
data_intra$field.recorders = NA
data_intra$data.enter = NA

data_intra<-data_intra[,c(1,2,7,8,3:6,9:11,13:14,12)]

data_intra<-sapply(data_intra, as.character)
data_intra[is.na(data_intra)] <- " "

write.csv(data_intra, "data_entry_intraannual.csv", row.names=FALSE)

####################################################################################
#3 Merge data_entry form intraannual with the year's master file ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")

data_2017 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2017.csv")

data_intra <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2017/data_entry_intraannual_2017-11.csv")

names2017 <- c(colnames(data_2017))
namesintra <- c(colnames(data_intra))

## find the names that are in data_2018 but not in data_biannual
missing <- setdiff(names2017, namesintra)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2018)

## add these missed names to data_biannual in order to combine to the master
data_intra[missing] <- NA
data_intra$area <- NULL #this column is only relevant for field
data_intra$location <- NULL #only for when merging data pre-2018

test <- rbind(data_2017, data_intra)

test <- test[order(test[,"tag"], test[,"survey.ID"]),] #order by tag and survey.ID

## these values are constant from the previous survey.ID
library(zoo)
test$biannual <- na.locf(test$biannual)
test$intraannual <- na.locf(test$intraannual)
test$lx <- na.locf(test$lx)
test$ly <- na.locf(test$ly)
test$stemID <- na.locf(test$stemID)
test$treeID <- na.locf(test$treeID)
test$dbh <- na.locf(test$dbh)

## these should be constant from previous survey, but obviously are updated whenever a new dendroband is installed
test$dendroID <- na.locf(test$dendroID)
test$type <- na.locf(test$type)
test$dendHt <- na.locf(test$dendHt)

## these values are not always constant
test$new.band <- ifelse(is.na(test$new.band), 0, test$new.band)
deadcodes <- c("DS", "DC", "DN", "DT")
test$status <- ifelse((is.na(test$status))&(test$codes %in% deadcodes), "dead", "alive")

#to troubleshoot. Added this bc noticed discrepancy above
test$status <- ifelse(test$codes %in% deadcodes, "dead", test$status)
test$codes <- as.character(test$codes)
test$codes <- ifelse(is.na(test$codes), "", test$codes)
test$notes <- as.character(test$notes)
test$notes <- ifelse(is.na(test$notes), "", test$notes)

write.csv(test, "scbi.dendroAll_2017.csv", row.names=FALSE)