######################################################
# Purpose: Create new year's master file (scbi.dendroAll_[YEAR].csv)
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
######################################################


data_2018 <- read.csv("data/scbi.dendroAll_2018.csv")

#subset by the most recent survey and live trees
data_2019 <- subset(data_2018,survey.ID=="2018.14" & status=="alive")

cols <- c("survey.ID", "year", "month", "day", "measure", "codes", "notes", "status", "field.recorders", "data.enter", "new.band")

data_2019[,cols] <- ""
data_2019$crown.condition <- NA
data_2019$crown.illum <- NA

write.csv(data_2019, "data/scbi.dendroAll_2019.csv", row.names=FALSE)


