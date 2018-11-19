# Create field_form_bandreplace forms from master

setwd()

data_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/2018/scbi.dendroAll_2018.csv")

trends <- data_2018[,c("tag", "stemtag", "survey.ID", "sp", "measure")]
trends <- trends[which(trends$survey.ID==c('2018.01', '2018.14')), ] 

##determine which trees will need to have dendroband replaced based on measurements. The max a caliper can measure is 153.71 mm.
library(data.table)
growth <- data.table(trends)
growth<-growth[,list(band.growth=diff(measure)),list(tag,sp)]

##range of measurement values over the growing season
range <- c(sort(growth$band.growth, decreasing=TRUE))
range <- range[range >=0]
range
mean(range)
sd(range)

##in 2018's example, mean=11.88 and sd=8.94, so I'm assigning values in measure >= 133 to have a code of RD.
data_install<-data_2018[which(data_2018$survey.ID=='2018.14'), ]
data_install$codes <- as.character(data_install$codes)
data_install$codes <- ifelse(data_install$measure >= 133 & !grepl("RD", data_install$codes), paste(data_install$codes, "RD", sep = ";"), data_install$codes)
data_install$codes <- gsub("^;", "", data_install$codes) 

##subset by RD codes (having subset by 2018.14 already above)
data_install<-data_install[grepl("RD",data_install[["codes"]]), ]

##rest of code is for making the field_form
data_install<-data_install[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "measure", "codes", "location", "dendDiam", "dendroID", "type", "dendHt")]

data_install$measure = NA
data_install$codes = NA
data_install$dendDiam = NA
data_install$dendHt = NA
data_install$type = NA
data_install$dendroID = NA

data_install$install.date = NA
data_install$dbhnew = NA

library(dplyr)
setnames(data_install, old=c("codes", "stemtag"), new=c("codes&notes", "stem"))

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
