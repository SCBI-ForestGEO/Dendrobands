# Create field_form_intrannual from master

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data_intra/clean_data_intra_files/2018")

data_intra_2018 <- read.csv("data_intra_2018.csv")

prevmeas <- data_intra_2018[which(data_intra_2018$survey.ID=='2018.01' & data_intra_2018$intrannual=='1'), ] #subset by previous survey.ID

data_intra_intra<-data_intra_2018[which(data_intra_2018$survey.ID=='2018.01' & data_intra_2018$intrannual=='1'), ] #subset by 2018.01 (one entry per stem)

data_intra_intra<-data_intra_intra[ ,c(1,2,7:13,15,22)]

data_intra_intra$measure = NA
data_intra_intra$codes = NA
data_intra_intra$notes = NA
data_intra_intra$measure1 = NA
data_intra_intra$measure2 = NA
data_intra_intra$measure3 = NA
data_intra_intra$measure4 = NA

library(dplyr)
data_intra_intra<-data_intra_intra %>% rename("Collector: Measure:" = measure, "Collector: Measure:" = measure1, "Collector: Measure:" = measure2, "Collector: Measure:" = measure3, "Collector: Measure:" = measure4)

data_intra_intra$prevmeas = prevmeas$measure

data_intra_intra[is.na(data_intra_intra)&!is.na(data_intra_intra$prevmeas)] <- " "

data_intra_intra<-data_intra_intra[,c(1:3,11,4:6,16,7,12:15,8:10)]

text_matrix <- function(data_intra_intra, table_title) {
  
  rbind(c(table_title, rep('', ncol(data_intra)-1)), # title
        names(data_intra), # column names
        unname(sapply(data_intra, as.character))) # data
  
}

temp <- text_matrix(data_intra, table_title=('Intraannual Survey         Date:                SurveyID:'))

library(xlsx)
write.xlsx(temp, "test.xlsx")

write.table(temp, 'test.csv', row.names=F, col.names=F, sep=',')

#to add a blank spacer row btwn title and columns, add
"rep('', ncol(data_intra)), # blank spacer row"
#as the second line of the rbind function
