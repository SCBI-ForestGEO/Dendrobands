# This code builds survey forms for biannual survey, and then merges the data to the master

#1 create field_form biannual
#2 create data_entry form biannual
#3 merge data_entry form biannual with the year's master file

#1 Create field_form biannual ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/protocols_field-resources/field_forms")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

prevmeasbi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by previous survey.ID. If printing this for the spring survey, use the last survey.ID from last year.

data_bi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by 2018.01 (one entry per stem)

data_bi<-data_bi[ ,c("tag", "stemtag", "sp", "dbh", "quadrat", "lx", "ly", "measure", "crown.condition", "crown.illum", "codes", "location")]

data_bi$measure = NA
data_bi$codes = NA
data_bi$crown.condition = NA
data_bi$crown.illum = NA
data_bi$"Fall measure"= NA

library(dplyr)
data_bi<-data_bi %>% rename("Spring measure" = measure, "codes&notes" = codes, "stem" = stemtag, "crown" = crown.condition, "illum" = crown.illum)

data_bi$prevmeas = prevmeasbi$measure

data_bi[is.na(data_bi)&!is.na(data_bi$prevmeas)] <- " "

data_bi<-data_bi[,c("tag", "stem", "sp", "dbh", "quadrat", "lx", "ly", "prevmeas", "Spring measure", "Fall measure", "crown", "illum", "codes&notes", "location")]
  #c(1:7,14,8,13,9:12)] <- ordering by numbers

data_bi$location<-gsub("South", "S", data_bi$location)
data_bi$location<-gsub("North", "N", data_bi$location)

#assign values per tag by survey area (based on biannual map in https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/maps)
data_bi$area <- ""
data_bi$area <- 
  ifelse((data_bi$quadrat %in% c(1301:1303))|
           (data_bi$quadrat %in% c(1401:1404))|
           (data_bi$quadrat %in% c(1501:1515))|
           (data_bi$quadrat %in% c(1601:1615))|
           (data_bi$quadrat %in% c(1701:1715))|
           (data_bi$quadrat %in% c(1801:1815))|
           (data_bi$quadrat %in% c(1901:1915))|
           (data_bi$quadrat %in% c(2001:2015)), 1,
         ifelse((data_bi$quadrat %in% c(504:507))|
                  (data_bi$quadrat %in% c(608))|
                  (data_bi$quadrat %in% c(703:712))|
                  (data_bi$quadrat %in% c(803:813))|
                  (data_bi$quadrat %in% c(901:913))|
                  (data_bi$quadrat %in% c(1003:1012))|
                  (data_bi$quadrat %in% c(1101:1112))|
                  (data_bi$quadrat %in% c(1201:1212))|
                  (data_bi$quadrat %in% c(1304:1311))|
                  (data_bi$quadrat %in% c(1405:1411)), 2,
                ifelse((data_bi$quadrat %in% c(101:115))|
                         (data_bi$quadrat %in% c(201:215))|
                         (data_bi$quadrat %in% c(301:315))|
                         (data_bi$quadrat %in% c(401:415))|
                         (data_bi$quadrat %in% c(502,514,515,610,611,614
                                                ,615,701,702,713,714,715
                                                ,801,1001,1014,1313,1314
                                                ,1315,1413)), 3,
                       ifelse((data_bi$quadrat %in% c(116:132))|
                                (data_bi$quadrat %in% c(216:232))|
                                (data_bi$quadrat %in% c(316:332))|
                                (data_bi$quadrat %in% c(416:432))|
                                (data_bi$quadrat %in% c(516:532))|
                                (data_bi$quadrat %in% c(616:624))|
                                (data_bi$quadrat %in% c(716:724))|
                                (data_bi$quadrat %in% c(816:824)), 4,
                              ifelse((data_bi$quadrat %in% c(916:924))|
                                       (data_bi$quadrat %in% c(1016:1024))|
                                       (data_bi$quadrat %in% c(1116:1124))|
                                       (data_bi$quadrat %in% c(1216:1224))|
                                       (data_bi$quadrat %in% c(1316:1324))|
                                       (data_bi$quadrat %in% c(1416,1417,1422)), 5,
                                     ifelse((data_bi$quadrat %in% c(1419))|
                                              (data_bi$quadrat %in% c(1516:1524))|
                                              (data_bi$quadrat %in% c(1616:1624))|
                                              (data_bi$quadrat %in% c(1716:1724))|
                                              (data_bi$quadrat %in% c(1816:1824))|
                                              (data_bi$quadrat %in% c(1916:1924))|
                                              (data_bi$quadrat %in% c(2016:2024)), 6,
                                            ifelse((data_bi$quadrat %in% c(625:632))|
                                                     (data_bi$quadrat %in% c(725:732))|
                                                     (data_bi$quadrat %in% c(825:832))|
                                                     (data_bi$quadrat %in% c(925:932))|
                                                     (data_bi$quadrat %in% c(1025:1029,1031,1032)), 7,
                                                   ifelse((data_bi$quadrat %in% c(1030))|
                                                            (data_bi$quadrat %in% c(1125:1132))|
                                                            (data_bi$quadrat %in% c(1225:1232))|
                                                            (data_bi$quadrat %in% c(1325:1332))|
                                                            (data_bi$quadrat %in% c(1425:1432)), 8,
                                                          ifelse((data_bi$quadrat %in% c(1525:1532))|
                                                                   (data_bi$quadrat %in% c(1625:1632))|
                                                                   (data_bi$quadrat %in% c(1725:1732))|
                                                                   (data_bi$quadrat %in% c(1825:1832))|
                                                                   (data_bi$quadrat %in% c(1925:1932))|
                                                                   (data_bi$quadrat %in% c(2025:2032)), 9, "")))))))))

data_bi <- data_bi[c(1:13,15,14)]

matrix <- function(data_bi, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_bi)-1)), # title
        names(data_bi), # column names
        unname(sapply(data_bi, as.character))) # data
  
}

temp <- matrix(data_bi, table_title=('Biannual Survey       Spr.Date:                       Spr.SurveyID:                  Spr.Recorder:                   |FallDate:                       FallSurveyID:                 FallRecorder:'))

library(xlsx)
write.xlsx(temp, "field_form_biannual.xlsx", row.names=FALSE, col.names=FALSE) #we write the file to .xlsx to more easily change print settings and cell dimensions

#before printing, please consult README in the field_forms folder.

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_bi)), # blank spacer row"
#as the second line of the rbind function

#####################################################################################
#2 create data_entry form biannual #####
# Create data_biannual forms from master
## Change file name to reflect year of creation

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

data_biannual<-data_2018[which(data_2018$survey.ID=='2018.01'), ] #subset by 2018.01 (one entry per stem)

data_biannual<-data_biannual[ ,c("tag", "stemtag", "sp", "quadrat", "survey.ID", "year", "month", "day", "measure", "crown.condition", "crown.illum", "codes", "notes", "field.recorders", "data.enter", "location")]

data_biannual$survey.ID = ""
data_biannual$year = ""
data_biannual$month = ""
data_biannual$day = ""
data_biannual$measure = ""
data_biannual$crown.condition = ""
data_biannual$crown.illum = ""
data_biannual$codes = ""
data_biannual$notes = ""
data_biannual$field.recorders = ""
data_biannual$data.enter = ""


data_biannual$area <- ""
data_biannual$area <- 
  ifelse((data_biannual$quadrat %in% c(1301:1303))|
           (data_biannual$quadrat %in% c(1401:1404))|
           (data_biannual$quadrat %in% c(1501:1515))|
           (data_biannual$quadrat %in% c(1601:1615))|
           (data_biannual$quadrat %in% c(1701:1715))|
           (data_biannual$quadrat %in% c(1801:1815))|
           (data_biannual$quadrat %in% c(1901:1915))|
           (data_biannual$quadrat %in% c(2001:2015)), 1,
         ifelse((data_biannual$quadrat %in% c(504:507))|
                  (data_biannual$quadrat %in% c(608))|
                  (data_biannual$quadrat %in% c(703:712))|
                  (data_biannual$tag %in% 70579)|
                  (data_biannual$quadrat %in% c(803:813))|
                  (data_biannual$quadrat %in% c(901:913))|
                  (data_biannual$quadrat %in% c(1003:1012))|
                  (data_biannual$quadrat %in% c(1101:1112))|
                  (data_biannual$quadrat %in% c(1201:1212))|
                  (data_biannual$quadrat %in% c(1304:1311))|
                  (data_biannual$quadrat %in% c(1405:1411)), 2,
                ifelse((data_biannual$quadrat %in% c(101:115))|
                         (data_biannual$quadrat %in% c(201:215))|
                         (data_biannual$quadrat %in% c(301:315))|
                         (data_biannual$quadrat %in% c(401:415))|
                         (data_biannual$quadrat %in% 714 & data_biannual$tag %in% c(70492:70495,70581))|
                         (data_biannual$quadrat %in% c(502,514,515,610,611,614
                                                       ,615,701,702,713,715
                                                       ,801,1001,1014,1313,1314
                                                       ,1315,1413)), 3,
                       ifelse((data_biannual$quadrat %in% c(116:132))|
                                (data_biannual$quadrat %in% c(216:232))|
                                (data_biannual$quadrat %in% c(316:332))|
                                (data_biannual$quadrat %in% c(416:432))|
                                (data_biannual$quadrat %in% c(516:532))|
                                (data_biannual$quadrat %in% c(616:624))|
                                (data_biannual$quadrat %in% c(716:724))|
                                (data_biannual$quadrat %in% c(816:824)), 4,
                              ifelse((data_biannual$quadrat %in% c(916:924))|
                                       (data_biannual$quadrat %in% c(1016:1024))|
                                       (data_biannual$quadrat %in% c(1116:1124))|
                                       (data_biannual$quadrat %in% c(1216:1224))|
                                       (data_biannual$quadrat %in% c(1316:1324))|
                                       (data_biannual$quadrat %in% c(1416,1417,1422)), 5,
                                     ifelse((data_biannual$quadrat %in% c(1419))|
                                              (data_biannual$quadrat %in% c(1516:1524))|
                                              (data_biannual$quadrat %in% c(1616:1624))|
                                              (data_biannual$quadrat %in% c(1716:1724))|
                                              (data_biannual$quadrat %in% c(1816:1824))|
                                              (data_biannual$quadrat %in% c(1916:1924))|
                                              (data_biannual$quadrat %in% c(2016:2024)), 6,
                                            ifelse((data_biannual$quadrat %in% c(625:632))|
                                                     (data_biannual$quadrat %in% c(725:732))|
                                                     (data_biannual$quadrat %in% c(825:832))|
                                                     (data_biannual$quadrat %in% c(925:932))|
                                                     (data_biannual$quadrat %in% c(1025:1029,1031,1032)), 7,
                                                   ifelse((data_biannual$quadrat %in% c(1030))|
                                                            (data_biannual$quadrat %in% c(1125:1132))|
                                                            (data_biannual$quadrat %in% c(1225:1232))|
                                                            (data_biannual$quadrat %in% c(1325:1332))|
                                                            (data_biannual$quadrat %in% c(1425:1432)), 8,
                                                          ifelse((data_biannual$quadrat %in% c(1525:1532))|
                                                                   (data_biannual$quadrat %in% c(1625:1632))|
                                                                   (data_biannual$quadrat %in% c(1725:1732))|
                                                                   (data_biannual$quadrat %in% c(1825:1832))|
                                                                   (data_biannual$quadrat %in% c(1925:1932))|
                                                                   (data_biannual$quadrat %in% c(2025:2032)), 9, "")))))))))

##this part only necessary if getting rid of specific NAs
#data_biannual<-sapply(data_biannual, as.character)
#data_biannual[is.na(data_biannual)] <- " "

write.csv(data_biannual, "data_entry_biannual_2018.csv", row.names=FALSE)

#this form can be used for entering biannual data before it is merged.

#####################################################################################
#3 Merge data_entry form biannual with the year's master file ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/")

data_2017 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2017.csv")

data_biannual <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2017/data_entry_biannual_2017.csv")

names2017 <- c(colnames(data_2017))
namesbi <- c(colnames(data_biannual))

## find the names that are in data_2017 but not in data_biannual
missing <- setdiff(names2017, namesbi)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2017)

## add these missed names to data_biannual in order to combine to the master
data_biannual[missing] <- NA
data_biannual$area <- NULL #this column is only relevant for field

test <- rbind(data_2017, data_biannual)

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
#test$dendroID <- na.locf(test$dendroID.spring)
test$type <- na.locf(test$type)
test$dendHt <- na.locf(test$dendHt)

## these values are not always constant
test$new.band <- ifelse(is.na(test$new.band), 0, test$new.band)
deadcodes <- c("DS", "DC", "DN", "DT")
test$status <- ifelse((is.na(test$status))&(test$codes %in% deadcodes), "dead", "alive")

test$status <- ifelse(test$codes %in% deadcodes, "dead", test$status)
test$codes <- as.character(test$codes)
test$codes <- ifelse(is.na(test$codes), "", test$codes)
test$notes <- as.character(test$notes)
test$notes <- ifelse(is.na(test$notes), "", test$notes)

##rewrite the date to be standard format (ONLY if current written dates are in same format) & (ONLY after last biannual survey for year)
test$exactdate <- format(as.Date(test$exactdate,format="%m/%d/%Y"), "%Y-%m-%d")

write.csv(test, "scbi.dendroAll_2017.csv", row.names=FALSE)
