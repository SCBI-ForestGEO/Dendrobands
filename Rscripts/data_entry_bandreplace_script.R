# Create data_entry_bandreplace forms from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")

data_2018 <- read.csv("data_2018.csv")

data_install<-data_2018[which(data_2018$survey.ID=='2018.01'), ] 
#when trouble-shooting code, remove: &data_2018$codes=='RD'
#subset by RD codes and one entry per stem

data_install<-data_install[ ,c(1:2,7:13,21,26)]

data_install$measure = NA
data_install$codes = NA
data_install$notes = NA
data_install$dendDiam = NA
data_install$dendHt = NA
data_install$installdate = NA
data_install$surveyor = NA
data_install$dbhnew = NA

data_install<-data_install[,c(1:6,12,14,11,10,7:9,13)]

data_install<-sapply(data_install, as.character)
data_install[is.na(data_install)] <- " "

write.csv(data_install, "data_entry_bandreplace.csv", row.names=FALSE)
