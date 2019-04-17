######################################################
# Purpose: Create csv showing ANPP ratio in dendroband survey by species distribution, then make graphs to help determine which trees to add to replace dead ones in surveys.
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created October 2018
######################################################
library(RCurl)

data_2018 <- read.csv("data/scbi.dendroAll_2018.csv")
dendro <- read.csv("results/dendro_trees_dbhcount2018.csv")
ANPP <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/summary_data/ANPP_total_and_by_species.csv"))

data_dbh<-data_2018[which(data_2018$survey.ID=='2018.14'), ]

#calculate ratio of # dendrobands to ANPP for each species ####
library(data.table)
ANPPmerge <- data.frame(ANPP$species, ANPP$ANPP_Mg.C.ha1.y1_10cm)
setnames(ANPPmerge, old="ANPP.species", new="sp")
ANPPmerge <- merge(ANPPmerge,dendro, by="sp")

ANPPmerge$ANPP.ratio <- ANPPmerge$biannual.n/ANPPmerge$ANPP.ANPP_Mg.C.ha1.y1_10cm

## round to 5 decimal places and 2 decimal places
ANPPmerge$ANPP.ANPP_Mg.C.ha1.y1_10cm <- sprintf(ANPPmerge$ANPP.ANPP_Mg.C.ha1.y1_10cm, fmt='%#.5f')

ANPPmerge$ANPP.ratio <- sprintf(ANPPmerge$ANPP.ratio, fmt='%#.2f')

write.csv(ANPPmerge, "results/dendro_trees_ANPP.csv", row.names=FALSE)

#################################################################################
#make graphs of dbh and ANPP
library(ggplot2)

##when running this whole script at once, plots won't show up in "plots" window because they're being directly written to the pdf. For troubleshooting, ignore this pdf code.
pdf(file="results/Dendroband_sp_dbh_ANPP.pdf", width=12)

## basic distribution of dbh size classes
hist(data_dbh$dbh, 
     main="Histogram of Dendroband DBH 2018", 
     xlab="DBH (mm)", 
     border="blue", 
     col="grey",
     las=1,
     breaks=15)

## plot number of dbh size occurrences with species fill-in
ggplot(data = data_dbh) +
  aes(x = dbh, fill = sp) +
  geom_histogram(bins = 16) +
  labs(title = "Dendroband dbh and species by frequency 2018") +
  theme_minimal()

## plot number of trees by species
ggplot(data=dendro) +
  aes(x=sp,weight=biannual.n)+
  geom_bar(fill="blue")+
  scale_x_discrete(limits=dendro$sp)+
  labs(title = "Dendroband sp numbers")+
  theme_minimal()

## plot ANPP contribution (>10cm) by dendroband sp numbers
ggplot(data = ANPPmerge) +
  aes(x = sp, fill = ANPP.ANPP_Mg.C.ha1.y1_10cm, weight = biannual.n) +
  geom_bar() +
  scale_fill_gradientn(colours=c("black", "orange", "green", "blue", "purple", "yellow", "red", "#990000"), 
                      values=c(0,0.31,1.3), guide="colourbar",
                      name="ANPP in MgC/ha/yr Stems>10cm", 
                      limits=c(0,1.3), breaks=c(0,0.05,0.1,0.15,0.2,0.25,0.31,1.3),
                      labels=c(0,0.05,0.1,0.15,0.2,0.25,0.31,1.3)) +
  guides(fill=guide_colourbar(barheight=15, direction="vertical", title.position="top")) +
  labs(title = "Dendroband sp numbers by ANPP >10cm 2018") +
  theme_minimal()
dev.off()
