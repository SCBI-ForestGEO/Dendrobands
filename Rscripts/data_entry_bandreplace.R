# Create data_entry_bandreplace forms from master

setwd()

data_2018 <- read.csv("scbi.dendroAll_2018.csv")

data_install<-data_2018[which(data_2018$survey.ID=='2018.01'), ] 
#when running the code, add: &data_2018$codes=='RD'
#when trouble-shooting code, remove: &data_2018$codes=='RD'
#subset by RD codes and one entry per stem

data_install<-data_install[ ,c(1:2,7:13,21,24,25,27)]

data_install$measure = NA
data_install$codes = NA
data_install$notes = NA
data_install$dendDiam = NA
data_install$dendHt = NA
data_install$type = NA
data_install$dendroID = NA

data_install$install.date = NA
data_install$surveyor = NA
data_install$dbhnew = NA

data_install<-data_install[,c(1:6,14,16,11,12,10,13,7:9,15)]

data_install<-sapply(data_install, as.character)
data_install[is.na(data_install)] <- " "

write.csv(data_install, "data_entry_bandreplace.csv", row.names=FALSE)
