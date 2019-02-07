# determine growth over time with dbh

#1 convert intraannual growth to dbh####

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
dirs <- dir("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data", pattern="_201[1-8]*.csv")
years <- c(2011:2018)

all_years <- list()

for (k in seq(along=dirs)){

    file <- dirs[[k]]
    yr <- read.csv(file)
    yr_intra <- yr[yr$intraannual==1, ]
    tent_name <- paste0(years, sep="_", "trees")

      #years[[j]] <- ifelse(dirs[[k]]=="scbi.dendroAll_2010.csv", 
                           #split(yr, yr$stemID),
                           #split(yr_intra, yr_intra$stemID))
      tent <- split(yr_intra, yr_intra$stemID)

  all_years[[k]] <- tent
}
names(all_years) <- tent_name

#NEXT STEPS 
2. rbind trees by stemID throughout all years, so have full chronology from 2010
3. Run a variation of the for-loop below to find growth
4. Make growth graphs of each stemID like I tried before.



test <- intra[intra$tag==30512, ]
test$dbh2 <- NA
stems <- c(unique(intra$stemID))

trees <- split(intra, intra$stemID) #split data into list of dataframes


#for-loop for each stem in a single year's intraannual survey to determine dbh growth

#this loop says the following:
##1. Assigns the first dbh of the growth column as the first dbh.
##2. Says if new.band=0 (no band change), use Condit's function to determine next dbh based on caliper measurement. If new.band=1 (band and measurement change) and the dbh in the original column is unchanged (indicating a new dbh wasn't recorded when the band was changed), then find the avg of the previous rows in the growth column and add to the previous dbh. Otherwise, if new.band=1 and the dbh in the original column was newly recorded, use Condit's function.

for (i in 2:nrow(test)){
  cal <- c(test$measure)
  test$dbh2[1] <- test$dbh[1]
  
  test$dbh2[i] <- ifelse(test$new.band[[i]] ==0, 
                         findDendroDBH(test$dbh2[[i-1]], cal[[i-1]], cal[[i]]),
                         ifelse(test$dbh[[i]] == test$dbh[[i-1]], 
                                mean(diff(test$dbh2[1:i-1])) + test$dbh2[[i-1]],
                                findDendroDBH(test$dbh2[[i-1]], cal[[i-1]], cal[[i]])))
}



###QUESTIONS
2. what happens to NA values in this iteration
4. Because dbh and dendDiam are so close, we approximate them to be the same. Ideally, we have data for dendDiam AND dbh for each band replacement, so it doesnt matter which one we use. But thats not the case.

#1a. troubleshoot ##################
band18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")
intra <- band18[band18$intraannual==1, ]
intra$dbh2 <- NA

x10671 <- intra[intra$tag==10671, ]
cal <- c(x10671$measure)
x10671$dbh2[[1]] <- x10671$dbh[[1]]
#x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.01), x10671$dbh, x10671$dbh2)

x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.02, findDendroDBH(x10671$dbh, cal[[1]], cal[[2]]), x10671$dbh2)

x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.03, findDendroDBH(x10671$dbh2[[2]], cal[[2]], cal[[3]]), x10671$dbh2)

x10671$dbh2 <- ifelse(x10671$survey.ID == 2018.04, findDendroDBH(x10671$dbh2[[3]], cal[[3]], cal[[4]]), x10671$dbh2)


#######################################################################################
#2 find variability of tree growth by species by year #####

#2010 not included because only one measurement
dirs <- dir("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data", pattern="_201[1-8]*.csv")

library(data.table)
date <- c(2011:2018)
filename <- paste(date, "range", sep="_")

all_sp <- list()
all_files <- list()

#this nested for-loop first makes a list of each species' average growth (max-min) in a year. Then, it combines all the years into one list (all_files).
for (j in seq(along=dirs)){
  year <- read.csv(dirs[[j]])
  year$sp <- as.character(year$sp)
  sp <- c(unique(year$sp))
  
  for (i in seq(along=sp)){
    spec <- sp[[i]]
    name <- paste0(spec, "data")
    sprange <- paste(sp[[i]], "range", sep="_")
    
    name <- subset(year, sp %in% spec)
    name <- name[ ,c("tag", "stemtag", "sp", "measure", "codes")]
    
    #get range (max-min) of measurements by tag
    sprange <- aggregate(name[, c("measure")], list(name$tag, name$stemtag, name$sp), FUN = function(i)max(i) - min(i))
    colnames(sprange) <- c("tag", "stemtag", "sp", "growth")
    
    #remove NA and values over 50 (would indicate band replacement)
    sprange <- subset(sprange, !is.na(sprange$growth) & sprange$growth <= 50)
    #take the average of the ranges
    sprange <- if (nrow(sprange)>=2){
      aggregate(sprange[, c("growth")], list(sprange$sp), mean)
    }
    else {
      sprange[ ,c("sp", "growth")]
    }
    colnames(sprange) <- c("sp", paste0("avg_growth",date[j],"_mm"))
    
    all_sp[[spec]] <- sprange
  }
  all_files[[j]] <- all_sp
}
names(all_files) <- date

#now, coerce the list of lists into a usable dataframe
step1 <- lapply(all_files, rbindlist)
library(tidyverse)
step2 <- reduce(step1, merge, by = "sp", all=TRUE)

#round to 2nd decimal
step2[ ,c(2:9)] <- round(step2[ ,c(2:9)], digits=2)

#find range of years
step2$mingrowth_mm <- apply(step2[, 2:9], 1, min, na.rm=TRUE)
step2$maxgrowth_mm <- apply(step2[, 2:9], 1, max, na.rm=TRUE)
step2$avg_growth_range_mm <- step2[, "maxgrowth_mm"] - step2[, "mingrowth_mm"]

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/results")
write.csv(step2, "growth_variability_by_sp.csv", row.names=FALSE)
#########################################################################################
#3. growth variability graphs ####
library(ggplot2)
library(RColorBrewer)

setwd("E:/Github_SCBI/Dendrobands/results")
pdf("mean_growth_by_species.pdf", width=12)

#this graph shows the average range of growth per species. The lower numbers means the avg max and avg min are closer together. Almost all species are under 10mm, which means on average each species grows less than 1cm per growing season (1 cm according to dendroband measurements).
ggplot(data = step2) +
  aes(x = sp, weight = avg_growth_range_mm) +
  geom_bar(fill = "#0c4c8a") +
  labs(title="Avg (Dendroband) Growth Range by Species", x="Species", y="Growth (mm)")
  theme_minimal()

#the following graph breaks the first one apart and plots the max by the min. It reveals a good fit relationship between the two, suggesting that most species follow a similar average pattern.
pallette = brewer.pal(9, "Set1")
pallette = colorRampPalette(pallette)(23)

ggplot(data = step2) + 
  geom_point(aes(x = mingrowth_mm, y = maxgrowth_mm, color=sp)) +
  scale_colour_manual(values = pallette) +
  labs(title="Avg (Dendroband) Growth by Species", x="Minimum growth (mm)", y="Maximum growth (mm)") +
  theme_grey()

dev.off()

######################################################################################
#4 troubleshooting for-loop ##############################################
dendro_2018 <- read.csv("E:/Github_SCBI/Dendrobands/data/scbi.dendroAll_2018.csv")

dendro_2018$sp <- as.character(dendro_2018$sp)
sp <- c(unique(dendro_2018$sp))

all_sp <- list()
all_sp <- data.frame(sp = character(), 
                     avg_range = integer())

for (i in seq(along=sp)){
  spec <- sp[[i]]
  name <- paste0(spec, "data")
  sprange <- paste(sp[[i]], "range", sep="_")
  
  name <- subset(dendro_2018, sp %in% spec)
  name <- name[ ,c("tag", "stemtag", "sp", "measure", "codes")]
  
  #get range (max-min) of measurements by tag
  sprange <- aggregate(name[, c("measure")], list(name$tag, name$stemtag, name$sp), FUN = function(i)max(i) - min(i))
  colnames(sprange) <- c("tag", "stemtag", "sp", "measure_range")
  
  #remove NA and values over 50 (would indicate band replacement)
  sprange <- subset(sprange, !is.na(sprange$measure_range) & sprange$measure_range <= 50)
  #take the average of the ranges
  sprange <- if (nrow(sprange)>=2){
    aggregate(sprange[, c("measure_range")], list(sprange$sp), mean)
  }
  else {
    sprange[ ,c("sp", "measure_range")]
  }
  colnames(sprange) <- c("sp", "avg_range")
  
  all_sp[[i]] <- sprange
}

library(data.table)
file <- rbindlist(all_sp)
colnames(file) <- c("sp", "avg_range")
file$avg_range <- round(file$avg_range, digits=2)
######################################################################################
#5 Graph the dbh growth per stem in a given year #####
## based off McMahon code: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4314258/

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data")
band18 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/scbi.dendroAll_2018.csv")

library(chron)
band18$date <- paste0(band18$month, sep="/", band18$day, sep="/", band18$year)
band18$doy <- julian(band18$month, band18$day, band18$year, origin=c(01,01,2018))

intra <- subset(band18, band18$intraannual == 1)

tagsintra <- c(unique(intra$tag))
surveys <- c(unique(intra$survey.ID))

intra$date <- as.Date(intra$date, format="%m/%d/%Y")
intra$date <- factor(intra$date, ordered=TRUE)

intraannual <- split(intra, f=c(intra$tag))

library(ggplot2)

##5a. for-loop graphs ####
#this code makes graphs for every dendroband individual, with sub-graphs for those trees with multiple stems. The next bit is to do this same graph but be able to show the dendroband measurements but in dbh changes.
pdf(file = "Dendroband_caliper_growth_2018.pdf")
for (i in names(intraannual)){
  
  dendro <- intraannual[[i]]
  
  q <- ggplot(data = dendro) +
    aes(x = doy, y = measure, group=1) +
    geom_line(color = "#0c4c8a") +
    labs(title = paste0("Dendroband Growth 2018 ",sep="_", i),
         x = "Date 2018",
         y = "Caliper measurements") +
    theme_minimal() +
    facet_wrap(c("tag", "stemtag"), labeller="label_both")
  print(q)
}
dev.off()

###
test <- subset(intra, intra$tag == 10671)
plot(test$doy, test$measure, xlab = "Day of the year", ylab = "DBH (cm)", pch = 18, 
     col = "red", main = "Cumulative annual growth")
###

test <- subset(intra, intra$tag == 10671)
p <- ggplot(test) +
  aes(x = doy, y = measure) +
  geom_line(color = "#0c4c8a") +
  labs(title = paste0("Dendroband Growth 2018 ", "_10671"),
       x = "Date 2018",
       y = "Caliper measurements") +
  theme_minimal()
print(p)
dev.off()