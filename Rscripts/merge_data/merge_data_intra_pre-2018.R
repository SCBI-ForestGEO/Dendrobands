# Merge data_entry_form with master for intraannual survey

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2016")

file_list <- list.files("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2016", pattern="data_entry_intraannual")

# for intraannual
for (i in seq(along=file_list)){
  filename = file_list[[i]]

data_2016 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2016/scbi.dendroAll_2016.csv")

data_intra <- read.csv(filename)

names2016 <- c(colnames(data_2016))
namesintra <- c(colnames(data_intra))

## find the names that are in data_2018 but not in data_biannual
missing <- setdiff(names2016, namesintra)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2018)

## add these missed names to data_biannual in order to combine to the master
data_intra[missing] <- NA
data_intra$area <- NULL #this column is only relevant for field
data_intra$location <- NULL #only for when merging data pre-2018

test <- rbind(data_2016, data_intra)

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

write.csv(test, "scbi.dendroAll_2016.csv", row.names=FALSE)
}


#for the final biannual survey #####
data_2016 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2016/scbi.dendroAll_2016.csv")

data_biannual <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2016/data_entry_biannual_2016-15.csv")

names2016 <- c(colnames(data_2016))
namesbi <- c(colnames(data_biannual))

## find the names that are in data_2017 but not in data_biannual
missing <- setdiff(names2016, namesbi)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2017)

## add these missed names to data_biannual in order to combine to the master
data_biannual[missing] <- NA
data_biannual$area <- NULL #this column is only relevant for field
data_biannual$location <- NULL

test <- rbind(data_2016, data_biannual)

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


## for fixing intraannual qualifier (do after last biannual merge)
test$intraannual <- ifelse(!(test$survey.ID %in% c("2016.01","2016.15")), "1", "0")

"1" -> test[which(test$intraannual == "1")-1, "intraannual"]
"1" -> test[which(test$intraannual == "1")+1, "intraannual"]

write.csv(test, "scbi.dendroAll_2016.csv", row.names=FALSE)
## double check in spreadsheet for multistems (sometimes missed with this code)

#

#for changing date format

## for changing date format
#split dates to columns #####
## to split dates into separate columns of year, month, and day from current date column

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2018")

dendro18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2018/scbi.dendroAll_2018.csv")

#convert dates to vector
datetxt <- dendro18[ ,"exactdate"]

datetxt <- as.Date(datetxt, "%m/%d/%Y")

dates <- data.frame(date = datetxt,
                 year = as.numeric(format(datetxt, format = "%Y")),
                 month = as.numeric(format(datetxt, format = "%m")),
                 day = as.numeric(format(datetxt, format = "%d")))

dendro18$exactdate <- as.Date(dendro18$exactdate, "%m/%d/%Y")
dendro18$year <- dates$year[match(dendro18$exactdate, dates$date)]
dendro18$month <- dates$month[match(dendro18$exactdate, dates$date)]
dendro18$day <- dates$day[match(dendro18$exactdate, dates$date)]

dendro18 <- dendro18[, c(1:3,31:33,5:30)]

write.csv(dendro18, "scbi.dendroAll_2018.csv", row.names=FALSE)

#matching dbh and stemID/treeID ##### 
dendro16 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2016.csv")

dendro_trees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv")

dendro16$treeID <- dendro_trees$treeID[match(dendro16$tag, dendro_trees$tag)]

dendro16$stemID <- dendro_trees$stemID[match(dendro16$tag, dendro_trees$tag)]

write.csv(dendro16, "scbi.dendroAll_2016.csv", row.names=FALSE)

