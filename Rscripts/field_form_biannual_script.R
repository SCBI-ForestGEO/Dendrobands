# Create field_form_biannual from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")

data_2018 <- read.csv("data_2018.csv")

prevmeasbi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by previous survey.ID

data_bi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by 2018.01 (one entry per stem)

data_bi<-data_bi[ ,c(1,2,7:12,15,22)]

data_bi$measure = NA
data_bi$codes = NA
data_bi$"Nov. Collector:  "= NA

library(dplyr)
data_bi<-data_bi %>% rename("March Collector:" = measure, "codes&notes" = codes)

data_bi$prevmeas = prevmeasbi$measure

data_bi[is.na(data_bi)&!is.na(data_bi$prevmeas)] <- " "

data_bi<-data_bi[,c(1:3,10,4:6,12,7,11,8:9)]

data_bi$location<-gsub("South", "S", data_bi$location)
data_bi$location<-gsub("North", "N", data_bi$location)

matrix <- function(data_bi, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_bi)-1)), # title
        names(data_bi), # column names
        unname(sapply(data_bi, as.character))) # data
  
}

temp <- matrix(data_bi, table_title=('Biannual Survey            MarchDate:                       MarchSurveyID:                             Nov.Date:                       Nov.SurveyID:'))

library(xlsx)
write.xlsx(temp, "field_form_biannual.xlsx") #we write the file to .xlsx to more easily change print settings and cell dimensions

#after writing new file to excel, need to 
  #1 delete the first row and first column
  #2 add all borders, merge and center title across top
  #3 adjust cell dimensions as needed
  #4 change print margins to "narrow"
  #4 make sure print area is defined as wanted ("Page Layout")



#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_bi)), # blank spacer row"
#as the second line of the rbind function

##below are other attempts to make titles
write.table(temp, 'field_form_biannual.csv', row.names=F, col.names=F, sep=',')

transform(temp, tag=as.numeric(tag), stemtag=as.numeric(stemtag), dbh=as.numeric(dbh), quadrat=as.numeric(quadrat), lx=as.numeric(lx), ly=as.numeric(ly), prevmeas=as.numeric(prevmeas))