# Merge data_entry_form with master for intraannual survey

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2014")

file_list <- list.files("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2014", pattern="data_entry_intraannual")

# for intraannual
for (i in seq(along=file_list)){
  filename = file_list[[i]]

data_2014 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2014/scbi.dendroAll_2014.csv")

data_intra <- read.csv(filename)

names2014 <- c(colnames(data_2014))
namesintra <- c(colnames(data_intra))

## find the names that are in data_2018 but not in data_biannual
missing <- setdiff(names2014, namesintra)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2018)

## add these missed names to data_biannual in order to combine to the master
data_intra[missing] <- NA
data_intra$area <- NULL #this column is only relevant for field
data_intra$location <- NULL #only for when merging data pre-2018

test <- rbind(data_2014, data_intra)

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
deadcodes <- c("D", "DS", "DC", "DN", "DT")

test$status <- as.character(test$status)
test$status <- ifelse((is.na(test$status))&(test$codes %in% deadcodes), "dead", 
                      ifelse((is.na(test$status)), na.locf(test$status), test$status))

test$codes <- as.character(test$codes)
test$codes <- ifelse(is.na(test$codes), "", test$codes)
test$notes <- as.character(test$notes)
test$notes <- ifelse(is.na(test$notes), "", test$notes)

write.csv(test, "scbi.dendroAll_2014.csv", row.names=FALSE)
}

# for biannual
#####
# for last biannual survey
data_2014 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2014/scbi.dendroAll_2014.csv")

data_biannual <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2014/data_entry_biannual_2014-14.csv")

names2014 <- c(colnames(data_2014))
namesbi <- c(colnames(data_biannual))

## find the names that are in data_2017 but not in data_biannual
missing <- setdiff(names2014, namesbi)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2017)

## add these missed names to data_biannual in order to combine to the master
data_biannual[missing] <- NA
data_biannual$area <- NULL #this column is only relevant for field
data_biannual$location <- NULL

test <- rbind(data_2014, data_biannual)

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
deadcodes <- c("D", "DS", "DC", "DN", "DT")

test$status <- as.character(test$status)
test$status <- ifelse((is.na(test$status))&(test$codes %in% deadcodes), "dead", 
                      ifelse((is.na(test$status)), na.locf(test$status), test$status))

test$codes <- as.character(test$codes)
test$codes <- ifelse(is.na(test$codes), "", test$codes)
test$notes <- as.character(test$notes)
test$notes <- ifelse(is.na(test$notes), "", test$notes)

write.csv(test, "scbi.dendroAll_2014.csv", row.names=FALSE)



## for fixing intraannual qualifier (do after last biannual merge)
test$intraannual <- ifelse(!(test$survey.ID %in% c("2014.01","2014.14")), "1", "0")

"1" -> dendro14[which(dendro14$intraannual == "1")-1, "intraannual"]
"1" -> dendro14[which(dendro14$intraannual == "1")+1, "intraannual"]

## double check in spreadsheet for multistems (sometimes missed with this code)

#

#for changing date format

## for changing date format
#####
## Krista asked if the dates could be in a Y-m-d format, but I've noticed that R works best for analysis when it's in a simplified format. If we do want to change how the dates are written, then it is here:

##rewrite the date to be standard format (ONLY if current written dates are in same format) & (ONLY after last biannual survey for year)
test$exactdate <- format(as.Date(test$exactdate,format="%m/%d/%Y"), "%Y-%m-%d") 


## matching dbh and stemID/treeID
dendro14 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2014/scbi.dendroAll_2014.csv")

dendro_trees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv")

dendro14$treeID <- dendro_trees$treeID[match(dendro14$tag, dendro_trees$tag)]

dendro14$stemID <- dendro_trees$stemID[match(dendro14$tag, dendro_trees$tag)]

write.csv(dendro14, "scbi.dendroAll_2014.csv", row.names=FALSE)

