# Determine both dendrobands that need to be fixed, and new trees that will replace dead ones.

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/field_forms")

dendro18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv") 

#be aware of the dbh differences
##2011-2013 data: dbh is from 2008
##2014-2018 data: dbh is from 2013
##2019-     data: dbh is from 2018

#Quick: number of bands that need to be fixed
length(c(grep("RD", dendro18$codes)))

#1 Create field and data_entry forms for trees that need fixing
##Either do 1a or 1b, then move to step 2.

#1a If don't have much time, focus on fixing the bands that need to be fixed ####
##these bands were marked as "RD" already from the field survey.
data_fix <- dendro18[grep("RD", dendro18$codes), ]
data_fix <- data_fix[which(data_fix$survey.ID>= 2018.14), ] #in case any fixes have been done since the fall survey

##1b if have more time, determine # of dendrobands whose window is too large. These will ultimately need to be changed at some point if not done now. ####
trends <- dendro18[,c("tag", "stemtag", "survey.ID", "sp", "measure")]
trends <- trends[which(trends$survey.ID==c('2018.01', '2018.14')), ] 

##determine which trees will need to have dendroband replaced based on measurements. The max a caliper can measure is 153.71 mm.
##if don't have much time, then focus first on those bands that really need fixing 
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
data_install<-dendro18[which(dendro18$survey.ID=='2018.14'), ]
data_install$codes <- as.character(data_install$codes)
data_install$codes <- ifelse(data_install$measure >= 133 & !grepl("RD", data_install$codes), paste(data_install$codes, "RD", sep = ";"), data_install$codes)
data_install$codes <- gsub("^;", "", data_install$codes)
data_fix_all <- data_install[grep("RD", data_install$codes), ]

######################################################################################
#2 Create forms
##pay attention to whether or not you're doing data_fix from 1a or data_fix_all from 1b!!!!!!

#2a. Create the field form ####
##dbh column is included here to help know what size dendroband to make. For taking out in the field, don't necessarily have to include this column.
dendro_trees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv")

data_fix$location <- dendro_trees$location[match(data_fix$stemID, dendro_trees$stemID)]

data_field<-data_fix[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "dbh", "measure", "codes", "location", "dendDiam", "dendroID", "type", "dendHt")]

data_field$measure = NA
data_field$codes = NA
data_field$dendDiam = NA
data_field$dendHt = NA
data_field$type = NA
data_field$dendroID = NA

data_field$field.date = NA
data_field$dbhnew = NA

library(data.table)
setnames(data_field, old=c("codes", "stemtag"), new=c("codes&notes", "stem"))

data_field[is.na(data_field)] <- " "

data_field<-data_field[,c(1:7,15,16,12,13,11,14,8:10)]

data_field$location<-gsub("South", "S", data_field$location)
data_field$location<-gsub("North", "N", data_field$location)

matrix <- function(data_field, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_field)-1)), # title
        names(data_field), # column names
        unname(sapply(data_field, as.character))) # data
  
}

temp <- matrix(data_field, table_title=('Dendroband Replacement                       Date:                       Surveyors:'))

library(xlsx)
write.xlsx(temp, "field_form_fix_replace_2018.xlsx", row.names = FALSE, col.names=FALSE)


#2b. Create data_entry form ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms")

data_entry<-data_fix[ ,c(1:2,9:12,3:6,23:26,22,27:28,13:15,18:19,7:8,16:17,20:21,29:32)]
  
cols <- c("survey.ID", "year", "month", "day", "dbh", "measure", "codes", "notes", "field.recorders", "data.enter", "dendDiam", "dendroID", "type", "dendHt")

data_entry[, cols] <- ""
data_entry$new.band <- 1
data_entry$dir <- NA
data_entry$crown.condition <- NA
data_entry$crown.illum <- NA
data_entry$location <- NULL #we don't need this column for data entry

library(data.table)
data_entry <- setnames(old=c("dbh", "dendDiam"), new=c("dbh(mm)", "dendDiam(mm)"))

write.csv(data_entry, "data_entry_fix_replace_2019.csv", row.names=FALSE)

#######################################################################################
#3. Merge data with year form.  MAKE SURE DBH AND DENDDIAM ARE IN MM
#3a. Merging if bands replaced after fall biannual ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")

data_2019 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2019.csv")

install <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2019.csv")

data_2019 <- rbind(data_2019, install)
data_2019 <- data_2019[order(data_2019$tag, data_2019$stemtag), ]

write.csv(data_2019, "scbi.dendroAll_2019.csv", row.names=FALSE)

#3b. Merging if bands replaces before spring biannual ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")

data_2019 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2019.csv")

install_late <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/data_entry_forms/2019/data_entry_fix_replace_2019.csv")

data_2019 <- rbind(data_2019, install_late)
data_2019 <- data_2019[order(data_2019$tag, data_2019$stemtag), ]

write.csv(data_2019, "scbi.dendroAll_2019.csv", row.names=FALSE)

#######################################################################################
#4. Merge data with dendroID.csv ####

##there is no code here. Merging with dendroID.csv happens only after the full year's data is complete to avoid duplication. The code for this is in "dendroID_chronology.R"