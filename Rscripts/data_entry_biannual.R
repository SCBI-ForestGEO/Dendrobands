# Create data_biannual forms from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")

data_2018 <- read.csv("data_2018.csv")

data_biannual<-data_2018[which(data_2018$survey.ID=='2018.01'), ] #subset by 2018.01 (one entry per stem)

data_biannual<-data_biannual[ ,c(1:4,7,8,11:13,15:17)]

data_biannual$survey.ID = NA
data_biannual$exactdate = NA
data_biannual$measure = NA
data_biannual$codes = NA
data_biannual$notes = NA
data_biannual$field.recorders = NA
data_biannual$data.enter = NA

data_biannual<-data_biannual[,c(1,2,5,6,3,4,7:9,11,12,10)]

data_biannual<-sapply(data_biannual, as.character)
data_biannual[is.na(data_biannual)] <- " "

write.csv(data_biannual, "data_entry_biannual.csv", row.names=FALSE)

#this form can be used for entering biannual data before it is merged.