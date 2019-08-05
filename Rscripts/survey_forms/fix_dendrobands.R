######################################################
# Purpose: Determine trees that need bands replaced or fixed, create field forms, data_entry forms, and merge to master
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
######################################################
library(data.table) #1b, 2a, 2b
library(xlsx) #2a

dendro19 <- read.csv("data/scbi.dendroAll_2019.csv") 

#be aware of the dbh differences
##2011-2013 data: dbh is from 2008
##2014-2018 data: dbh is from 2013
##2019-     data: dbh is from 2018

#Quick: number of bands that need to be fixed
length(c(grep("RE", dendro19$codes)))

#1 Create field and data_entry forms for trees that need fixing
##Either do 1a or 1b, then move to step 2.

#1a If don't have much time, focus on fixing the bands that need to be fixed ####
##these bands were marked as "RE" already from the field survey.
data_fix <- dendro19[which(dendro19$survey.ID ==2019.09), ]
data_fix <- data_fix[grep("RE", data_fix$codes), ]
 #in case any fixes have been done since the fall survey

##1b if have more time, determine # of dendrobands whose window is too large. These will ultimately need to be changed at some point if not done now. ####

#first, see the average growth trends using 2018 data (or any recent full dataset)
trends <- dendro18[,c("tag", "stemtag", "survey.ID", "sp", "measure")]
trends <- trends[which(trends$survey.ID==c('2018.01', '2018.14')), ] 

##determine which trees will need to have dendroband replaced based on measurements. The max a caliper can measure is 153.71 mm.
##if don't have much time, then focus first on those bands that really need fixing 
growth <- data.table(trends)
growth<-growth[,list(band.growth=diff(measure)),list(tag,sp)]

##range of measurement values over the growing season
range <- c(sort(growth$band.growth, decreasing=TRUE))
range <- range[range >=0]
range
mean(range)
sd(range)

##in 2018's example, mean=11.88 and sd=8.94, so I'm assigning values in measure >= 140 to have a code of RE (probably you don't need to ever go below 130 for this)
data_install<-dendro19[which(dendro19$survey.ID=='2019.09'), ]
data_install$codes <- as.character(data_install$codes)
data_install$codes <- ifelse(data_install$measure >= 130 & !grepl("RE", data_install$codes), paste(data_install$codes, "RE", sep = ";"), data_install$codes)
data_install$codes <- gsub("^;", "", data_install$codes)

# get all RE codes (including those labeled directly from the survey)
data_fix <- data_install[grep("RE", data_install$codes), ]

######################################################################################
#2 Create forms
##pay attention to whether or not you're doing data_fix from 1a or data_fix_all from 1b!!!!!!

#2a. Create the field form ####
dendro_trees <- read.csv("data/dendro_trees.csv")

data_fix$location <- dendro_trees$location[match(data_fix$stemID, dendro_trees$stemID)]

data_field<-data_fix[ ,c("tag", "stemtag", "sp", "quadrat", "lx", "ly", "dbh", "measure", "codes", "location", "dendDiam", "dendroID", "type", "dendHt")]

data_field$measure = NA
data_field$dendDiam = NA
data_field$dendHt = NA
data_field$type = NA
data_field$dendroID = NA
data_field$codes <- gsub("[[:punct:]]*RE[[:punct:]]*", "", data_field$codes)

data_field$field.date = NA
data_field$dbhnew.cm = NA

setnames(data_field, old=c("codes", "stemtag", "dendDiam", "dendHt", "measure"), new=c("codes&notes", "stem", "dendDiam.cm", "dendHt.m", "measure.mm"))

data_field[is.na(data_field)] <- " "

data_field<-data_field[,c(1:7,15,16,12,13,11,14,8:10)]

data_field$location<-gsub("South", "S", data_field$location)
data_field$location<-gsub("North", "N", data_field$location)

##2ai. Get accurate DBH ####
##Since DBH increases every year, we need something more accurate than a 1-in-5 year survey measurement for DBH. Thus, here we source functions from the growth_over_time script to see the DBH for specific trees based on stemID.

#source functions to use
SourceFunctions<-function(file) {
  MyEnv<-new.env()
  source(file=file,local=MyEnv)
  list2env(Filter(f=is.function,x=as.list(MyEnv)),
           envir=parent.env(environment()))
}
SourceFunctions("Rscripts/analysis/growth_over_time.R")

dirs <- dir("data", pattern="_201[0-9]*.csv")
years <- c(2010:2019)

#this function makes a list of each stemID growth from 2010-2019
make_growth_list(dirs, years)

#this function calculates DBH for specific stemID
##specifically, it will yield 2 graphs, from which you can get the accurate DBH
calculate_dbh(1609) #here, 1609 is sample stemID

data_field$DBH <- c()

##2aii. Create the excel sheet ####
matrix <- function(data_field, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_field)-1)), # title
        names(data_field), # column names
        unname(sapply(data_field, as.character))) # data
  
}

temp <- matrix(data_field, table_title=('Dendroband Replacement                       Date:                       SurveyID:                         Surveyors:'))

write.xlsx(temp, "resources/field_forms/2019/field_form_fix_2019-091.xlsx", row.names = FALSE, col.names=FALSE)

#2b. Create data_entry form ####
data_entry<-data_fix[ ,c(1:2,9:12,3:6,22:25,21,27,13:18,7:8,19:20,26,28:31)]
  
cols <- c("survey.ID", "year", "month", "day", "dbh", "measure", "codes", "notes", "field.recorders", "data.enter", "dendDiam", "dendroID", "type", "dendHt")

data_entry[, cols] <- ""
data_entry$new.band <- 1
data_entry$dir <- NA
data_entry$crown.condition <- NA
data_entry$crown.illum <- NA
data_entry$location <- NULL #we don't need this column for data entry

data_entry <- setnames(data_entry, old=c("dbh", "dendDiam", "dendHt", "measure"), new=c("dbh.mm", "dendDiam.mm", "dendHt.m", "measure.mm"))

fix_bands <- read.csv("resources/data_entry_forms/2019/data_entry_fix_2019.csv")
fix_bands <- rbind(fix_bands, data_entry)

write.csv(fix_bands, "resources/data_entry_forms/2019/data_entry_fix_2019.csv", row.names=FALSE)

#######################################################################################
#3. Merge data with year form.  MAKE SURE DBH AND DENDDIAM ARE IN MM ####
data_2019 <- read.csv("data/scbi.dendroAll_2019.csv")

fix_bands <- read.csv("resources/data_entry_forms/2019/data_entry_fix_2019.csv", colClasses = c("codes" = "character"))
#install$codes <- ifelse(is.na(install$codes), "", "F")
#install$notes <- ifelse(is.na(install$notes), "", install$notes)

#subset by the surveyID you need
install <- fix_bands[fix_bands$survey.ID == 2019.091, ]

setnames(install, old=c("dbh.mm", "dendDiam.mm", "dendHt.m", "measure.mm"), new=c("dbh", "dendDiam", "dendHt", "measure"), skip_absent=TRUE)

data_2019 <- rbind(data_2019, install)
data_2019 <- data_2019[order(data_2019$tag, data_2019$stemtag), ]

write.csv(data_2019, "data/scbi.dendroAll_2019.csv", row.names=FALSE)

#######################################################################################
#4. Merge data with dendroID.csv ####

##there is no code here. Merging with dendroID.csv happens only after the full year's data is complete to avoid duplication. The code for this is in "dendroID_chronology.R"

##if this is deemed unnecessary then merging each time with dendroID shouldn't be difficult, and the script can just be added here.
