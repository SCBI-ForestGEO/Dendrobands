library(readr)
library(dplyr)
intra02<- read_csv("Dendrobands/resources/data_entry_forms/2020/data_entry_intraannual_2020-02.csv")
intra03 <- read_csv("Dendrobands/resources/data_entry_forms/2020/data_entry_intraannual_2020-03.csv")
intra04 <- read_csv("Dendrobands/resources/data_entry_forms/2020/data_entry_intraannual_2020-04.csv")

intra02$date <- paste(intra02$month, intra02$day, intra02$year, sep = "/")
intra03$date <- paste(intra03$month, intra03$day, intra03$year, sep = "/")
intra04$date <- paste(intra04$month, intra04$day, intra04$year, sep = "/")

survey02 <- intra02[,c(1,2,15)]
survey03 <- intra03[,c(1,2,15)]
survey04 <- intra04[,c(1,2,15)]

colnames(survey02) <- c("Tag","stemID" , unique(intra02$date))
colnames(survey03) <- c("Tag", "stemID" , unique(intra03$date))
colnames(survey04) <- c("Tag","stemID" , unique(intra04$date))

phenology2020 <- cbind(survey02,survey03[,3],survey04[,3])

#Combine 2014 DF w/ 2020 DF#

phenology2014 <- read_csv("SCBI-ForestGEO-Data/leaf phenology/data/SCBI_spring_phenology_2014.csv")

same_tags <- phenology2020 %>%
  filter(Tag %in% phenology2014$Tag)

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
