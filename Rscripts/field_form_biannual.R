# Create field_form_biannual from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")

data_2018 <- read.csv("scbi.dendroAll_2018.csv")

prevmeasbi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by previous survey.ID

data_bi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by 2018.01 (one entry per stem)

data_bi<-data_bi[ ,c(1,2,7:12,15,22)]

data_bi$measure = NA
data_bi$codes = NA
data_bi$"Fall Collector:  "= NA

library(dplyr)
data_bi<-data_bi %>% rename("Spring Collector:" = measure, "codes&notes" = codes, "stem" = stemtag)

data_bi$prevmeas = prevmeasbi$measure

data_bi[is.na(data_bi)&!is.na(data_bi$prevmeas)] <- " "

data_bi<-data_bi[,c(1:3,10,4:6,12,7,11,8:9)]

data_bi$location<-gsub("South", "S", data_bi$location)
data_bi$location<-gsub("North", "N", data_bi$location)

#assign values per tag by survey area (based on biannual map in https://github.com/SCBI-ForestGEO/Dendrobands/tree/master/maps)
data_bi$area <- ""
data_bi$area <- 
  ifelse((data_bi$quadrat %in% c(1501:1515))|
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
                                                ,801,1001,1014,1302,1313
                                                ,1314,1315,1401,1402,1403
                                                ,1404,1413)), 3,
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

data_bi <- data_bi[c(1:11,13,12)]

matrix <- function(data_bi, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_bi)-1)), # title
        names(data_bi), # column names
        unname(sapply(data_bi, as.character))) # data
  
}

temp <- matrix(data_bi, table_title=('Biannual Survey            SpringDate:                       SpringSurveyID:                             FallDate:                       FallSurveyID:'))

library(xlsx)
write.xlsx(temp, "field_form_biannual.xlsx", row.names=FALSE, col.names=FALSE) #we write the file to .xlsx to more easily change print settings and cell dimensions

#before printing, please consult README in the field_forms folder.

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_bi)), # blank spacer row"
#as the second line of the rbind function
