# Create field_form_bandreplace forms from master

setwd()

data_2018 <- read.csv("scbi.dendroAll_2018.csv")

data_install<-data_2018[which(data_2018$survey.ID=='2018.01'), ] 
#when trouble-shooting code, remove: &data_2018$codes=='RD'
#subset by RD codes and one entry per stem

data_install<-data_install[ ,c(1:2,7:12,15,21,24,25,27)]

data_install$measure = NA
data_install$codes = NA
data_install$dendDiam = NA
data_install$dendHt = NA
data_install$type = NA
data_install$dendroID = NA

data_install$install.date = NA
data_install$dbhnew = NA

library(dplyr)
data_install<-data_install %>% rename("codes&notes" = codes, "stem" = stemtag)

data_install[is.na(data_install)] <- " "

data_install<-data_install[,c(1:6,14,15,11,12,10,13,7:9)]

data_install$location<-gsub("South", "S", data_install$location)
data_install$location<-gsub("North", "N", data_install$location)

matrix <- function(data_install, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_install)-1)), # title
        names(data_install), # column names
        unname(sapply(data_install, as.character))) # data

  }

temp <- matrix(data_install, table_title=('Dendroband Replacement        Date:                       Surveyors:'))

library(xlsx)
write.xlsx(temp, "field_form_bandreplace.xlsx", row.names = FALSE, col.names=FALSE)
