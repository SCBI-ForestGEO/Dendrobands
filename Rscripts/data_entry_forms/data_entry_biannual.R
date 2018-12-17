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