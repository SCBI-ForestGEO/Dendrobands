setwd()

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018/scbi.dendroAll_2018.csv")

data_surveys<- subset(data_2018,data_2018$survey.ID=='2018.01' & data_2018$status=='alive') #get rid of '0' values for min

data_trees <- data_2018[!duplicated(data_2018[7]),]
data_trees <- data_trees[c("sp")] #list that shows all sp alive and dead

#make data.frames with the dbhmax,min,mean by sp
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

data_01<-subset(data_2018,data_2018$survey.ID=='2018.01') #get all sp

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
data_merged <- data_merged[c(1:21,23,24,22),]

write.csv(data_merged, "dendro_trees_dbhcount.csv", row.names=FALSE)
