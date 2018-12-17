# Create data_intra forms from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/protocols_field-resources/data_entry_forms")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

data_intra<-data_2018[which(data_2018$survey.ID=='2018.01' & data_2018$intraannual=='1'), ] #subset by 2018.01 (one entry per stem)

data_intra<-data_intra[ ,c("tag", "stemtag", "survey.ID", "year", "month", "day", "sp", "quadrat", "measure", "codes", "notes", "location", "field.recorders", "data.enter")]

data_intra$survey.ID = NA
data_intra$year = NA
data_intra$month = NA
data_intra$day = NA
data_intra$measure = NA
data_intra$codes = NA
data_intra$notes = NA
data_intra$field.recorders = NA
data_intra$data.enter = NA

data_intra<-data_intra[,c(1,2,7,8,3:6,9:11,13:14,12)]

data_intra<-sapply(data_intra, as.character)
data_intra[is.na(data_intra)] <- " "

write.csv(data_intra, "data_entry_intraannual.csv", row.names=FALSE)

#this form can be used for entering biannual data before it is merged.