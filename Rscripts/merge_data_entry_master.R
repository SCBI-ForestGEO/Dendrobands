# Merge data_entry_form with master

setwd()

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2018/scbi.dendroAll_2018.csv")

data_biannual <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/data_entry_biannual_2018.csv")

names2018 <- c(colnames(data_2018))
namesbi <- c(colnames(data_biannual))

## find the names that are in data_2018 but not in data_biannual
missing <- setdiff(names2018, namesbi)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2018)

## add these missed names to data_biannual in order to combine to the master
data_biannual[missing] <- NA
data_biannual$area <- NULL #this column is only relevant for field

test <- rbind(data_2018, data_biannual)

test <- test[order(test[,1], test[,3]),] #order by tag and survey.ID

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

##rewrite the date to be standard format (if current written dates are in same format)
test$exactdate <- format(as.Date(test$exactdate,format="%m/%d/%Y"), "%Y-%m-%d")

write.csv(test, "scbi.dendroAll_2018.csv", row.names=FALSE)
