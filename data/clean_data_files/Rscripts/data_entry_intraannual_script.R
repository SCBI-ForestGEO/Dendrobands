# Create data_intra forms from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")

data_2018 <- read.csv("data_2018.csv")

data_intra<-data_2018[which(data_2018$survey.ID=='2018.01' & data_2018$intraannual=='1'), ] #subset by 2018.01 (one entry per stem)

data_intra<-data_intra[ ,c(1:4,7,8,11:13,15:17)]

data_intra$survey.ID = NA
data_intra$exactdate = NA
data_intra$measure = NA
data_intra$codes = NA
data_intra$notes = NA
data_intra$field.recorders = NA
data_intra$data.enter = NA

data_intra<-data_intra[,c(1,2,5,6,3,4,7:9,11,12,10)]

data_intra<-sapply(data_intra, as.character)
data_intra[is.na(data_intra)] <- " "

write.csv(data_intra, "data_entry_intraannual.csv")

#this form can be used for entering biannual data before it is merged.