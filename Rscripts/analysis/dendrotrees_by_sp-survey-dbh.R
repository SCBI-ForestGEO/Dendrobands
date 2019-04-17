######################################################
# Purpose: give count of each species by survey, plus the min, max, and avg dbh per species
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created February 2019
######################################################

data_2017 <- read.csv("data/scbi.dendroAll_2017.csv")

#subset by the last survey from the year
data_surveys<- subset(data_2017,data_2017$survey.ID=='2017.12') #& data_2017$status=='alive') #get rid of '0' values for minimum

data_trees <- data_2017[!duplicated(data_2017["sp"]),]
data_trees <- data_trees[c("sp")] #list that shows all sp alive and dead

#make data.frames with the dbhmax,min,mean by sp
data_surveys$dbh <- as.numeric(data_surveys$dbh)
dbhmax <- aggregate(data_surveys$dbh, by=list(data_surveys$sp), max)
dbhmin <- aggregate(data_surveys$dbh, by=list(data_surveys$sp), min)
dbhavg <- aggregate(data_surveys$dbh, by=list(data_surveys$sp), mean)

names(dbhmax) <- c("sp", "dbhmax.mm")
names(dbhmin) <- c("sp", "dbhmin.mm")
names(dbhavg) <- c("sp", "dbhavg.mm")

is.num <- sapply(dbhavg,is.numeric)
dbhavg[is.num] <- lapply(dbhavg[is.num], round, 1)

#create data.frame with count of sp per survey
library(data.table) 

data_01<-subset(data_2017,data_2017$survey.ID=='2017.01') #get all sp

countbi<- addmargins(table(data_01$sp, data_01$biannual),1)  
countbi<- as.data.frame.matrix(countbi)
  setDT(countbi, keep.rownames=TRUE)[]
  colnames(countbi) <- c("sp", "biannual.n")
  
countintra<- addmargins(table(data_01$sp, data_01$intraannual==1), 1)
countintra<- as.data.frame.matrix(countintra)
  setDT(countintra, keep.rownames=TRUE)[]
  colnames(countintra) <- c("sp", "wrong", "intraannual.n")
  countintra$wrong <- NULL

#merge the data.frames together  
library(tidyverse) 

#have to make two separate dataframes, then merge them together to make sure the "Sum" row is kept
data_count <- merge(countbi, countintra, by="sp")
data_num <- list(data_trees,dbhmin,dbhmax,dbhavg) %>% reduce(left_join, by="sp")

data_merged <- merge(data_count, data_num, by="sp", all.x=TRUE)

data_merged <- data_merged[order(data_merged$sp),]

##reorder to make "Sum" row be last. These numbers may change depending on if a tree has been fully removed from the survey
data_merged <- data_merged[c(1:20,22,23,21),]

write.csv(data_merged, "results/dendro_trees_dbhcount/dendro_trees_sp_2017_min_max_mean_dbh.csv", row.names=FALSE)
