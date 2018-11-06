# Create data_biannual forms from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/protocols_field-resources/data_entry_forms")

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2018/scbi.dendroAll_2018.csv")

data_biannual<-data_2018[which(data_2018$survey.ID=='2018.01'), ] #subset by 2018.01 (one entry per stem)

data_biannual<-data_biannual[ ,c("tag", "stemtag", "sp", "quadrat", "survey.ID", "exactdate", "measure", "crown.condition", "illum", "codes", "notes", "field.recorders", "data.enter", "location")]

data_biannual$survey.ID = NA
data_biannual$exactdate = NA
data_biannual$measure = NA
data_biannual$crown.condition = NA
data_biannual$illum = NA
data_biannual$codes = NA
data_biannual$notes = NA
data_biannual$field.recorders = NA
data_biannual$data.enter = NA

data_biannual<-sapply(data_biannual, as.character)
data_biannual[is.na(data_biannual)] <- " "

write.csv(data_biannual, "data_entry_biannual.csv", row.names=FALSE)

#this form can be used for entering biannual data before it is merged.