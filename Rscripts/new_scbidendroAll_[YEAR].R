# Create new scbi.dendroAll_[YEAR].csv

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2018/scbi.dendroAll_2018.csv")

#subset by the most recent survey and live trees
data_2019 <- subset(data_2018,survey.ID=="2018.14" & status=="alive")

cols <- c("survey.ID", "exactdate", "measure", "codes", "notes", "status", "field.recorders", "data.enter", "new.band")

data_2019[,cols] <- ""

write.csv(data_2019, "scbi.dendroAll_2019.csv", row.names=FALSE)

## as of Nov 2018, unsure if we want to keep the crown and illum cols populated when making a new table for a new year, considering those values will only be updated in the next fall