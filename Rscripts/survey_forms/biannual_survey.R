######################################################
# Purpose: Dendroband biannual survey: create field form, create data_entry forms, and merge to master
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
######################################################


#1 create field_form biannual
#2 create data_entry form biannual
#3 merge data_entry form biannual with the year's master file

#1 Create field_form biannual
##1a. if new trees added between last fall survey and spring survey, do this ####
data_2019 <- read.csv("data/scbi.dendroAll_2019.csv")

data_2018 <- read.csv("data/scbi.dendroAll_2018.csv")

prevmeasbi <- subset(data_2018,survey.ID=="2018.14") #subset by previous survey.ID to get previous measure. If printing this for the spring survey, use the last survey.ID from last year.

data_bi <- data_2019

data_bi$prevmeas <- prevmeasbi$measure[match(data_bi$stemID, prevmeasbi$stemID)]

data_bi<-data_bi[ ,c("tag", "stemtag", "sp", "dbh", "quadrat", "lx", "ly", "measure", "crown.condition", "crown.illum", "codes", "prevmeas")]

data_bi$prevmeas <- ifelse(!is.na(data_bi$measure), data_bi$measure, data_bi$prevmeas)
check <- data_bi[is.na(data_bi$prevmeas), ]

data_bi$measure = NA
data_bi$crown.condition = NA
data_bi$crown.illum = NA
data_bi$"Fall measure"= NA

library(dplyr)
data_bi<-data_bi %>% rename("Spring measure" = measure, "codes&notes_spr" = codes, "stem" = stemtag, "crown" = crown.condition, "illum" = crown.illum)



cols <- colnames(data_bi[,c(8:10,13)])
data_bi[,cols] <- " "
data_bi$"codes&notes_fall" <- data_bi$`codes&notes_spr`

data_bi<-data_bi[,c("tag", "stem", "sp", "dbh", "quadrat", "lx", "ly", "prevmeas", "Spring measure", "Fall measure", "crown", "illum", "codes&notes_spr", "codes&notes_fall")]


##1b. if no new trees added between fall and spring survey, do this ####
data_2018 <- read.csv("data/scbi.dendroAll_2018.csv")

prevmeasbi <- subset(data_2018,survey.ID=="2018.14" & biannual=="1") #subset by previous survey.ID. If printing this for the spring survey, use the last survey.ID from last year.

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

##1c. continue with code from either 1a. or 1b. ####
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
         ifelse((data_bi$quadrat %in% c(404:405))|
                  (data_bi$quadrat %in% c(504:507))|
                  (data_bi$quadrat %in% c(603:609))|
                  (data_bi$quadrat %in% c(703:712))|
                  (data_bi$tag == 70579)|
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
                         (data_bi$quadrat %in% c(401:403, 406:415))|
                         (data_bi$quadrat %in% c(502,512:515))|
                         (data_bi$quadrat == 714 & data_bi$tag != 70579)|
                         (data_bi$quadrat %in% c(610,611,614,615,
                                                 701,702,713,715
                                                ,801,1001,1013,1014,1215,
                                                1313,1314,1315,1413,1415)), 3,
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
                                       (data_bi$quadrat %in% c(1416:1418,1420:1424)), 5,
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

need.area <- data_bi[data_bi$area == "", ] 

matrix <- function(data_bi, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_bi)-1)), # title
        names(data_bi), # column names
        unname(sapply(data_bi, as.character))) # data
  
}

temp <- matrix(data_bi, table_title=('Biannual Survey       Spr.Date:                       Spr.SurveyID:                  Spr.Recorder:                   |FallDate:                       FallSurveyID:                 FallRecorder:'))

library(xlsx)
write.xlsx(temp, "field_form_biannual_2019.xlsx", row.names=FALSE, col.names=FALSE) #we write the file to .xlsx to more easily change print settings and cell dimensions

#before printing, please consult README in the field_forms folder.

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_bi)), # blank spacer row"
#as the second line of the rbind function

#####################################################################################
#2 create data_entry form biannual #####
# Create data_biannual forms from master
## Change file name to reflect year of creation

##2a. spring survey data entry ####
data_biannual <- data_bi

library(data.table)
setnames(data_biannual, old=c("stem", "Spring measure", "codes&notes_spr", "crown", "illum"), new=c("stemtag", "measure", "codes", "crown.condition", "crown.illum"))

data_biannual <- data_biannual[!colnames(data_biannual) %in% c("Fall measure", "codes&notes_fall", "dbh", "lx", "ly")]

newcols <- c("survey.ID", "year", "month", "day", "notes", "field.recorders", "data.enter", "new.band")
data_biannual[,newcols] <- ""

data_biannual <- data_biannual[, c("tag", "stemtag", "sp", "quadrat", "survey.ID", "year", "month", "day", "measure", "new.band", "crown.condition", "crown.illum", "codes", "notes", "field.recorders", "data.enter", "area")]

write.csv(data_biannual, "resources/data_entry_forms/data_entry_biannual_spr2019.csv", row.names=FALSE)

##2b. fall survey data entry ####
data_2018 <- read.csv("data/scbi.dendroAll_2018.csv")

data_biannual<-data_2018[which(data_2018$survey.ID=='2018.01'), ] #subset by 2018.01 (one entry per stem)

data_biannual<-data_biannual[ ,c("tag", "stemtag", "sp", "quadrat", "survey.ID", "year", "month", "day", "measure", "new.band", "crown.condition", "crown.illum", "codes", "notes", "field.recorders", "data.enter"), ]

#instead of the below code, can also do:
data_biannual[is.na(data_biannual)] <- ""

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
data_bi$area <- 
  ifelse((data_bi$quadrat %in% c(1301:1303))|
           (data_bi$quadrat %in% c(1401:1404))|
           (data_bi$quadrat %in% c(1501:1515))|
           (data_bi$quadrat %in% c(1601:1615))|
           (data_bi$quadrat %in% c(1701:1715))|
           (data_bi$quadrat %in% c(1801:1815))|
           (data_bi$quadrat %in% c(1901:1915))|
           (data_bi$quadrat %in% c(2001:2015)), 1,
         ifelse((data_bi$quadrat %in% c(404:405))|
                  (data_bi$quadrat %in% c(504:507))|
                  (data_bi$quadrat %in% c(603:609))|
                  (data_bi$quadrat %in% c(703:712))|
                  (data_bi$tag == 70579)|
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
                         (data_bi$quadrat %in% c(401:403, 406:415))|
                         (data_bi$quadrat %in% c(502,512:515))|
                         (data_bi$quadrat == 714 & data_bi$tag != 70579)|
                         (data_bi$quadrat %in% c(610,611,614,615,
                                                 701,702,713,715
                                                 ,801,1001,1013,1014,1215,
                                                 1313,1314,1315,1413,1415)), 3,
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
                                       (data_bi$quadrat %in% c(1416:1418,1420:1424)), 5,
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

need.area <- data_bi[data_bi$area == "", ]

##this part only necessary if getting rid of specific NAs
#data_biannual<-sapply(data_biannual, as.character)
#data_biannual[is.na(data_biannual)] <- " "

write.csv(data_biannual, "resources/data_entry_forms/data_entry_biannual_2018.csv", row.names=FALSE)

#this form can be used for entering biannual data before it is merged.

#####################################################################################
#3 Merge data_entry form biannual with the year's master file ####

data_2019 <- read.csv("data/scbi.dendroAll_2019.csv")

data_biannual <- read.csv("resources/data_entry_forms/2019/data_entry_biannual_spr2019.csv")

names2019 <- c(colnames(data_2019))
namesbi <- c(colnames(data_biannual))

## find the names that are in data_2019 but not in data_biannual
missing <- setdiff(names2019, namesbi)

## if need be, do the opposite
# missing <- setdiff(namesbi, names2019)

## add these missed names to data_biannual in order to combine to the master
data_biannual[missing] <- NA
data_biannual$area <- NULL #this column is only relevant for field

test <- rbind(data_2019, data_biannual)

test <- test[order(test$tag, test$stemtag, test$survey.ID, na.last=FALSE), ] #order by tag, then stemtag, then survey.ID (IMPORTANT for multistem plants)

## this section (lines 314-324) was specifically generated for adding in spring biannual survey to a new dataframe for that year, just fyi ####
library(zoo)
library(dplyr)
cols <- c(7,8,11,12,19,20,22,24,25,27)
# cols <- c("test$biannual", "intraannual", "lx", "ly", "stemID", "treeID", "dbh", "new.band", "dendroID", "type", "dendHt") #these are the columns that the numbers are referring to

for (i in seq(along=cols)){
  col_no <- cols[[i]]
  test[,col_no] <- ifelse(is.na(test[,col_no]) & test$tag == lag(test$tag), na.locf(test[,col_no]), test[,col_no])
}

## continue like normal ####
#this is done to get rid of any placeholders. Essentially, the full 2019 form was created to make the 2019 spring biannual field form. However, there were also new trees added to the survey with a survey.ID of 2019.00, so now we can get rid of these extra placeholders now that we've shifted the data above using na.locf.
test <- test[!(is.na(test$survey.ID)), ]

## these values are not always constant
test$new.band <- ifelse(is.na(test$new.band), 0, test$new.band)
deadcodes <- c("DS", "DC", "DN", "DT")
test$status <- ifelse(grepl("D", test$codes), "dead", "alive")

test$codes <- as.character(test$codes)
test$codes <- ifelse(is.na(test$codes), "", test$codes)
test$notes <- as.character(test$notes)
test$notes <- ifelse(is.na(test$notes), "", test$notes)

write.csv(test, "data/scbi.dendroAll_2019.csv", row.names=FALSE)
