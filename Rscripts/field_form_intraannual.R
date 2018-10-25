# Create field_form_intrannual from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")
#set it here so you don't overwrite any files

data_2018 <- read.csv("scbi.dendroAll_2018.csv")

prevmeasin <- subset(data_2018,survey.ID=="2018.01" & intraannual=="1") #subset by previous survey.ID

data_intra <- subset(data_2018,survey.ID=="2018.01" & intraannual=="1") #subset by 2018.01 (one entry per stem)

data_intra<-data_intra[ ,c(1,2,7:12,15,22)]

data_intra$measure = NA
data_intra$codes = NA
data_intra$"Date2: SvID: Name:" = NA
data_intra$"Date3: SvID: Name:" = NA
data_intra$"Date4: SvID: Name:" = NA
data_intra$"Date5: SvID: Name:" = NA

library(dplyr)
data_intra<-data_intra %>% rename("Date1:  SvID:   Name:" = measure, "codes&notes" = codes, "stem" = stemtag)

data_intra$prevmeas = prevmeasin$measure

data_intra[is.na(data_intra)&!is.na(data_intra$prevmeas)] <- " "

data_intra<-data_intra[,c(1:3,10,4:6,15,7,11:14,8:9)]

data_intra$location<-gsub("South", "S", data_intra$location)
data_intra$location<-gsub("North", "N", data_intra$location)

matrix <- function(data_intra, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_intra)-1)), # title
        names(data_intra), # column names
        unname(sapply(data_intra, as.character))) # data
  
}

temp <- matrix(data_intra, table_title=('Intraannual Survey'))


library(xlsx)
write.xlsx(temp, "field_form_intraannual.xlsx", row.names=FALSE, col.names=FALSE)

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_intra)), # blank spacer row"
#as the second line of the rbind function

#after writing new file to excel, need to 
  #1 delete the first row and first column
  #2 add all borders, merge and center title across top
  #3 adjust cell dimensions as needed
  #4 change print margins to "narrow"
  #4 make sure print area is defined as wanted ("Page Layout")

##below are other attempts to make titles

write.table(temp, 'field_form_intraannual.csv', row.names=F, col.names=F, sep=',')

transform(temp, tag=as.numeric(tag), stemtag=as.numeric(stemtag), dbh=as.numeric(dbh), quadrat=as.numeric(quadrat), lx=as.numeric(lx), ly=as.numeric(ly), prevmeas=as.numeric(prevmeas))