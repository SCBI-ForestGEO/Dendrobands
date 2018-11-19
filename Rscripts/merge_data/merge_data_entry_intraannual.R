# Merge data_entry_form with master for intraannual survey

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
