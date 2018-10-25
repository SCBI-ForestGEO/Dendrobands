# Create field_form_biannual from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/2018")

data_2018 <- read.csv("scbi.dendroAll_2018.csv")

prevmeasbi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by previous survey.ID

data_bi <- subset(data_2018,survey.ID=="2018.01" & biannual=="1") #subset by 2018.01 (one entry per stem)

data_bi<-data_bi[ ,c(1,2,7:12,15,22)]

data_bi$measure = NA
data_bi$codes = NA
data_bi$"Fall Collector:  "= NA

library(dplyr)
data_bi<-data_bi %>% rename("Spring Collector:" = measure, "codes&notes" = codes, "stem" = stemtag)

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

temp <- matrix(data_bi, table_title=('Biannual Survey            SpringDate:                       SpringSurveyID:                             FallDate:                       FallSurveyID:'))

library(xlsx)
write.xlsx(temp, "field_form_biannual.xlsx", row.names=FALSE, col.names=FALSE) #we write the file to .xlsx to more easily change print settings and cell dimensions

#before printing, please consult README in the field_forms folder.

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_bi)), # blank spacer row"
#as the second line of the rbind function
