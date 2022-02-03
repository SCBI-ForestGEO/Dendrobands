## Cameron Dow, MAy 6, 2020
## Preliminary script to analyze phenology data from dendrobanded trees

library(readr)
library(dplyr)

#read data files directly from Github (ignore errors for now)

intra02<- read_csv("https://raw.githubusercontent.com/SCBI-ForestGEO/Dendrobands/master/resources/raw_data/2020/data_entry_intraannual_2020-02.csv?token=AGNAWNF6UOUA444C26GHK4C6XRIHM")

intra03 <- read_csv("https://raw.githubusercontent.com/SCBI-ForestGEO/Dendrobands/master/resources/raw_data/2020/data_entry_intraannual_2020-03.csv?token=AGNAWNAEFWIKIO3XYTQTOVK6XRMWU")

intra04 <- read_csv("https://raw.githubusercontent.com/SCBI-ForestGEO/Dendrobands/master/resources/raw_data/2020/data_entry_intraannual_2020-04.csv?token=AGNAWNFSVMFQNGISPL7DZB26XRM72")

# add an column to obtain full dates
intra02$date <- paste(intra02$month, intra02$day, intra02$year, sep = "/")
intra03$date <- paste(intra03$month, intra03$day, intra03$year, sep = "/")
intra04$date <- paste(intra04$month, intra04$day, intra04$year, sep = "/")

#subset to get only pheno data
survey02 <- intra02[,c(1,2,15)]
survey03 <- intra03[,c(1,2,15)]
survey04 <- intra04[,c(1,2,15)]

#rename columns (don't use "stemID" as that has another meaning)
colnames(survey02) <- c("Tag","stem" , unique(intra02$date))
colnames(survey03) <- c("Tag", "stem" , unique(intra03$date))
colnames(survey04) <- c("Tag","stem" , unique(intra04$date))

#now combine all surveys to get a singular phenology dataset 

phenology2020 <- cbind(survey02,survey03[,3],survey04[,3])

#Combine with data from 2014#

phenology2014 <- read_csv("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/leaf%20phenology/data/SCBI_spring_phenology_2014.csv")

#subset to obtain a dataframe with unique tags
same_tags <- phenology2020 %>%
  filter(Tag %in% phenology2014$Tag)

#now merge both years in a single data frame
Pheno_compare <- merge(phenology2014,phenology2020, all=FALSE)

#library(reshape2)
#pheno_melt <- melt(Pheno_compare, id.vars = c("Tag", "stemID", "species", "DBH 2013(mm)"))

#Pheno_compare[,12] <- as.numeric(Pheno_compare[,12])
#Pheno_compare[4,12] <- 1
#Pheno_compare[is.na(Pheno_compare)] <- 3

#pheno_sums <- colSums(Pheno_compare[,5:24])
#pheno_dates <- colnames(Pheno_compare[,5:24])

#phenodf <- data.frame(pheno_dates, pheno_sums)
#phenodf[10,2] <- phenodf[10,2]-21
