######################################################
# Purpose: Create a time series of dbh using dendrometer band measurements
# Developed by: Albert Y. Kim - kimay@si.edu 
# R version 4.0.3 - First created March 2021
# 
# This is a refactoring of growth_over_time.R sections 1 & 5 that takes dbh's
# measured at census and successive caliper measurements, and computes the dbh2.
# Furthermore, it works for 2020+ data, and not just 2010's data. Comparisons of
# the output with the original script in growth_over_time.R are made at the end.
# While writing this code was somewhat of an exercise in redundancy, I used it
# as an opportunity to understand the entire process: starting with caliper
# measurement and ending with constructed dbh2.
######################################################
library(tidyverse) 
library(lubridate)
library(here)
library(zoo)



# 1. Load functions -----

# Load Condit's functions for determining dbh based on previous dbh and successive 
# caliper measurements. Ex: findDendroDBH(dbh1 = 100, m1 = 10, m2 = 11)
# See: http://richardcondit.org/data/dendrometer/calculation/Dendrometer.php
here("Rscripts/analysis/convert_caliper_meas_to_dbh.R") %>% 
  source()


# Function that takes dendroband data for one stemID and computes new dbh based 
# on successive caliper measurements. See codebook for details:
# https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/metadata/scbi.dendroALL_%5BYEAR%5D_metadata.csv
create_dbh_timeseries <- function(stem){
  # Loop to create timeseries of dbh measurements manually:
  # 
  # 1. First, assigns the first dbh of the growth column as the first dbh.
  # 2. Second, is conditional:
  # 2i.   If new.band=0 (no band change), we have a measure, and we have a previous dbh2,
  #       then use Condit's function to determine next dbh2 based on caliper measurement. 
  # 2ii.  If new.band=0, we have a measure, and the previous dbh2 is NA,
  #       then use Condit's function by comparing the new measure with the most recent non-NA dbh2.
  # 2iii. If new.band=0 and the previous measure is NA, 
  #       then give dbh2 a value of NA.
  # 2iv.  If new.band=1 (band and measurement change), we have a measure, and there's a new dbh,
  #       then assign that dbh to dbh2.
  # 2v.   If new.band=1, we have a measure, and there's no new dbh (indicating a new dbh wasn't recorded when the band was changed), 
  #       then dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
  # 2vi.  If new.band=1, measure is NA, and the dbh in the original column is unchanged (UNCOMMON),
  #       then dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
  # 2vii. If new.band=1, measure is NA, and dbh is different (UNCOMMON),
  #       then dbh2 is the new dbh plus the mean of the differences of the previous dbh2's. 
  tree.n <- stem %>% 
    # First
    mutate(dbh2 = ifelse(row_number() == 1, dbh, NA)) %>% 
    mutate(
      dbh2 = as.numeric(dbh2),
      measure = as.numeric(measure),
      dbh = as.numeric(dbh),
      # Keep track which of above 7 conditionals took place
      scenario = 0
    )
  
  for(i in 2:nrow(tree.n)){
    # Second. Compute dbh2 conditionally
    tree.n$dbh2[i] <- case_when(
      tree.n$new.band[i] == 0 & tree.n$survey.ID[i] == 2014.01 & !identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ tree.n$dbh[i],
      # Cases 2.i) - 2.vii)
      tree.n$new.band[i] == 0 & !is.na(tree.n$measure[i]) & !is.na(tree.n$dbh2[i-1]) ~ findDendroDBH(tree.n$dbh2[i-1], tree.n$measure[i-1], tree.n$measure[i]),
      tree.n$new.band[i] == 0 & !is.na(tree.n$measure[i]) & is.na(tree.n$dbh2[i-1]) ~ findDendroDBH(tail(na.locf(tree.n$dbh2[1:i-1]), n=1), tail(na.locf(tree.n$measure[1:i-1]), n=1), tree.n$measure[i]),
      tree.n$new.band[i] == 0 & is.na(tree.n$measure[i]) ~ NA_real_,
      tree.n$new.band[i] == 1 & !is.na(tree.n$measure[i]) & !identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ tree.n$dbh[i],
      tree.n$new.band[i] == 1 & !is.na(tree.n$measure[i]) & identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1: i-1]), na.rm=T),
      tree.n$new.band[i] == 1 & is.na(tree.n$measure[i]) & identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=T),
      tree.n$new.band[i] == 1 & is.na(tree.n$measure[i]) & !identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ tree.n$dbh[i] + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=TRUE),
      TRUE ~ tree.n$dbh2[i]
    )
    
    # Second. Keep track of which conditional took place
    tree.n$scenario[i] <- case_when(
      tree.n$new.band[i] == 0 & tree.n$survey.ID[i] == 2014.01 & !identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ 2014,
      tree.n$new.band[i] == 0 & !is.na(tree.n$measure[i]) & !is.na(tree.n$dbh2[i-1]) ~ 1,
      tree.n$new.band[i] == 0 & !is.na(tree.n$measure[i]) & is.na(tree.n$dbh2[i-1]) ~ 2,
      tree.n$new.band[i] == 0 & is.na(tree.n$measure[i]) ~ 3,
      tree.n$new.band[i] == 1 & !is.na(tree.n$measure[i]) & !identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ 4,
      tree.n$new.band[i] == 1 & !is.na(tree.n$measure[i]) & identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ 5,
      tree.n$new.band[i] == 1 & is.na(tree.n$measure[i]) & identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ 6,
      tree.n$new.band[i] == 1 & is.na(tree.n$measure[i]) & !identical(tree.n$dbh[i], tree.n$dbh[i-1]) ~ 7,
      TRUE ~ NA_real_
    )
  }
  
  return(tree.n)
}



# 2. Compute dbh2 from dendroband data -----
# Load all data
dendro_all <- here("data") %>%
  dir(pattern = "scbi.dendroAll", full.names = TRUE) %>%
  map_dfr(.f = read_csv, col_types = cols(dbh = col_double(), dendDiam = col_double())) %>% 
  mutate(date = str_c(year, month, day, sep = "-") %>% ymd()) %>%
  # See codebook:
  # https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/metadata/scbi.dendroALL_%5BYEAR%5D_metadata.csv
  select(
    # Don't need data collection person names
    -c(field.recorders, data.enter),
    # Will get geolocation from census
    -c(quadrat, lx, ly),
    # No crown or liana info for now
    -starts_with("crown"), -lianas,
    # Band information
    -c(type, dir, dendHt),
    # Don't need biannual, only intraannual
    -biannual,
    # Etc
    -c(treeID, measureID)
  ) %>%
  arrange(tag, stemtag, date)

# Apply create_timeseries_new() to each intraannual stemID 
all_stems_intra_v2 <- dendro_all %>% 
  filter(intraannual == 1) %>% 
  group_split(stemID) %>% 
  map_df(create_dbh_timeseries) %>% 
  arrange(stemID, date)

# Apply create_timeseries_new() to each biannual stemID   
all_stems_bi_v2 <- dendro_all %>% 
  filter(intraannual == 0) %>% 
  group_split(stemID) %>% 
  map_df(create_dbh_timeseries) %>% 
  arrange(stemID, date)

# Investigate which conditional held
all_stems_intra_v2 %>% 
  count(scenario) %>% 
  arrange(desc(n)) %>% 
  mutate(
    prop = n/sum(n),
    cum_prop = cumsum(prop)
  )

all_stems_bi_v2 %>% 
  count(scenario) %>% 
  arrange(desc(n)) %>% 
  mutate(prop = n/sum(n)) %>% 
  mutate(
    prop = n/sum(n),
    cum_prop = cumsum(prop)
  )

# Optional: Output .csv
if(FALSE){
  bind_rows(
    all_stems_intra_v2,
    all_stems_bi_v2
  ) %>% 
    # select(-scenario) %>% 
    arrange(stemID, date) %>% 
    write_csv(file = here("data/all_stems.csv"))
  system("mv ./data/all_stems.csv ../../bayesian_data_fusion/data/all_stems.csv")
}



# 3. Compute results using original code in growth_over_time.R -----
## 3.a) format dendroband data ----
files <- dir("data", pattern="scbi.dendroAll*")
dates <- c(2010:2020)

#1a. this loop breaks up each year's dendroband trees into separate dataframes by stemID 
### Grouping by intraannual ----

make_growth_list <- function(dirs, years){
  all_years_intra <- list()
  for (k in seq(along=dirs)){
    file <- dirs[[k]]
    yr <- read.csv(paste0("data/", file), stringsAsFactors = FALSE)
    yr_intra <- yr[yr$intraannual==1, ]
    yr_intra$dbh <- as.numeric(yr_intra$dbh)
    
    all_years_intra[[k]] <- split(yr_intra, yr_intra$stemID)
    
  }
  tent_name <- paste0("trees", sep="_", years)
  names(all_years_intra) <- tent_name
  
  #the below loop takes all the unique stemIDs from each year and rbinds them.
  all_stems_intra <- list()
  
  for(stemID in sort(unique(unlist(sapply(all_years_intra, names))))) {
    all_stems_intra[[paste0("stemID_", stemID)]] <- do.call(rbind, lapply(years, function(year) all_years_intra[[paste0("trees", sep="_", year)]][[stemID]]))
  }
  
  intra_years <- list2env(all_years_intra)
  all_years_intra <<- as.list(intra_years)
  
  intra_stems <- list2env(all_stems_intra)
  all_stems_intra <<- as.list(intra_stems)
}

make_growth_list(files, dates)

##an explanation of the for-loop
#sort(unique(unlist(sapply(all_years, names)))) -> an explainer:
#sapply says find all the names within all_years
#unlist says take all those names (all those stemIDS) and dump them all together
#unique gets rid of the duplicates, and sort sorts them

### Grouping by biannual ----
all_years_bi <- list()

dirs <- files
years <- dates

for (k in seq(along=dirs)){
  file <- dirs[[k]]
  yr <- read.csv(paste0("data/", file), stringsAsFactors = FALSE)
  yr_bi <- yr[yr$intraannual == 0, ]
  yr_bi$dbh <- as.numeric(yr_bi$dbh)
  
  all_years_bi[[k]] <- split(yr_bi, yr_bi$stemID)
}
tent_name <- paste0("trees", sep="_", years)
names(all_years_bi) <- tent_name

#the below loop takes all the unique stemIDs from each year and rbinds them.
all_stems_bi <- list()

for(stemID in sort(unique(unlist(sapply(all_years_bi, names))))) {
  all_stems_bi[[paste0("stemID_", stemID)]] <-  do.call(rbind, lapply(years, function(year) all_years_bi[[paste0("trees", sep="_", year)]][[stemID]]))
}



## 3.b) Loop to create timeseries of dbh measurements manually ----

##before we knew Sean was working on a package (RDendrom), Valentine and I tried to create the same functionality manually (#5 and #6 in this script). Since we do have RDendrom, this manual work is deprecated, but I've decided to leave it here in case it's needed later.
## *** to run this section, you need to run section #1 above first. ****

#description of loop 
##1. First, assigns the first dbh of the growth column as the first dbh.
##2. Second, is conditional:
##2i.If new.band=0 (no band change), we have a measure, and we have a previous dbh2, use Condit's function to determine next dbh2 based on caliper measurement. 
##2ii. If new.band=0, we have a measure, and the previous dbh2 is NA, use Condit's function by comparing the new measure with the most recent non-NA dbh2.
##2iii. If new.band=0 and the previous measure is NA, give dbh2 a value of NA.
##2iv. If new.band=1 (band and measurement change), we have a measure, and there's a new dbh, assign that dbh to dbh2.
##2v. If new.band=1, we have a measure, and there's no new dbh (indicating a new dbh wasn't recorded when the band was changed), dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
##2vi. UNCOMMON If new.band=1 , measure is NA, and the dbh in the original column is unchanged , dbh2 is the sum of the differences of the previous dbh2's added to the most recent dbh2.
##2vii. UNCOMMON If new.band=1, measure is NA, and dbh is different, dbh2 is the new dbh plus the mean of the differences of the previous dbh2's. 

### Intraannual data ----
for(stems in names(all_stems_intra)) {
  tree.n <- all_stems_intra[[stems]]
  tree.n$dbh2 <- NA
  tree.n$dbh2[1] <- tree.n$dbh[1]
  
  tree.n$dbh2 <- as.numeric(tree.n$dbh2)
  tree.n$measure <- as.numeric(tree.n$measure)
  tree.n$dbh <- as.numeric(tree.n$dbh)
  
  q <- mean(unlist(tapply(tree.n$measure, tree.n$dendroID, diff)), na.rm=TRUE)
  
  for(i in 2:(nrow(tree.n))){
    tree.n$dbh2[[i]] <- 
      
      ifelse(tree.n$new.band[[i]] == 0 & tree.n$survey.ID[[i]] == 2014.01 & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
             tree.n$dbh[[i]],
             
             ifelse(tree.n$new.band[[i]] == 0 & !is.na(tree.n$measure[[i]]) & !is.na(tree.n$dbh2[[i-1]]),
                    findDendroDBH(tree.n$dbh2[[i-1]], tree.n$measure[[i-1]], tree.n$measure[[i]]),
                    
                    ifelse(tree.n$new.band[[i]] == 0 & !is.na(tree.n$measure[[i]]) & is.na(tree.n$dbh2[[i-1]]), 
                           findDendroDBH(tail(na.locf(tree.n$dbh2[1:i-1]), n=1), tail(na.locf(tree.n$measure[1:i-1]), n=1), tree.n$measure[[i]]),
                           
                           ifelse(tree.n$new.band[[i]] == 0 & is.na(tree.n$measure[[i]]), NA,
                                  
                                  ifelse(tree.n$new.band[[i]]==1 & !is.na(tree.n$measure[[i]]) & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                         tree.n$dbh[[i]],
                                         
                                         ifelse(tree.n$new.band[[i]] == 1 & !is.na(tree.n$measure[[i]]) & identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                                max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1: i-1]), na.rm = T),
                                                
                                                ifelse(tree.n$new.band[[i]] == 1 & is.na(tree.n$measure[[i]]) & identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                                       max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=T),
                                                       
                                                       ifelse(tree.n$new.band[[i]] == 1 & is.na(tree.n$measure[[i]]) & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                                              tree.n$dbh[i] + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=TRUE),
                                                              tree.n$dbh2))))))))
  }
  all_stems_intra[[stems]] <- tree.n
}

#correction factor for 2013 census data. was going to complete this, but then Sean McMahon figured out his code.
# for(stems in names(all_stems)) {
#   tree.n <- all_stems[[stems]]
# 
#   tree.nsub <- tree.n[tree.n$survey.ID %in% c(2010:2014.01), ]
#   tree.n$dbh2 <- ifelse(unique(tree.nsub$dbh2[!tail(tree.nsub$dbh2, n=1)]), tree.n$dbh2,
#                         ifelse(tree.n$survey.ID == 2013.16 & tree.n$survey.ID == 2014.01, 
#                                
#                                abs(diff(tail(tree.n$dbh, n=2))) + tree.n$dbh2)....
#   #Dendrobands: if dbh 2010:2013.16 same, then take difference of 2014.01 and 2013.06, and add to entire 2010:2013.16 measurements.
#                         
#   all_stems[[stems]] <- tree.n
# }

### Biannual data ----
for(stems in names(all_stems_bi)) {
  tree.n <- all_stems_bi[[stems]]
  tree.n$dbh2 <- NA
  tree.n$dbh2[1] <- tree.n$dbh[1]
  
  tree.n$dbh2 <- as.numeric(tree.n$dbh2)
  tree.n$measure <- as.numeric(tree.n$measure)
  tree.n$dbh <- as.numeric(tree.n$dbh)
  
  q <- mean(unlist(tapply(tree.n$measure, tree.n$dendroID, diff)), na.rm=TRUE)
  
  for(i in 2:(nrow(tree.n))){
    tree.n$dbh2[[i]] <- 
      
      ifelse(tree.n$new.band[[i]] == 0 & tree.n$survey.ID[[i]] == 2014.01 & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
             tree.n$dbh[[i]],
             
             ifelse(tree.n$new.band[[i]] == 0 & !is.na(tree.n$measure[[i]]) & !is.na(tree.n$dbh2[[i-1]]),
                    findDendroDBH(tree.n$dbh2[[i-1]], tree.n$measure[[i-1]], tree.n$measure[[i]]),
                    
                    ifelse(tree.n$new.band[[i]] == 0 & !is.na(tree.n$measure[[i]]) & is.na(tree.n$dbh2[[i-1]]), 
                           findDendroDBH(tail(na.locf(tree.n$dbh2[1:i-1]), n=1), tail(na.locf(tree.n$measure[1:i-1]), n=1), tree.n$measure[[i]]),
                           
                           ifelse(tree.n$new.band[[i]] == 0 & is.na(tree.n$measure[[i]]), NA,
                                  
                                  ifelse(tree.n$new.band[[i]]==1 & !is.na(tree.n$measure[[i]]) & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                         tree.n$dbh[[i]],
                                         
                                         ifelse(tree.n$new.band[[i]] == 1 & !is.na(tree.n$measure[[i]]) & identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                                max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1: i-1]), na.rm = T),
                                                
                                                ifelse(tree.n$new.band[[i]] == 1 & is.na(tree.n$measure[[i]]) & identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                                       max(tree.n$dbh2[1: i-1], na.rm = T) + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=T),
                                                       
                                                       ifelse(tree.n$new.band[[i]] == 1 & is.na(tree.n$measure[[i]]) & !identical(tree.n$dbh[[i]], tree.n$dbh[[i-1]]),
                                                              tree.n$dbh[i] + mean(diff(tree.n$dbh2[1:(i-1)]), na.rm=TRUE),
                                                              tree.n$dbh2))))))))
  }
  all_stems_bi[[stems]] <- tree.n
}

#correction factor for 2013 census data: see above in intraannual code






# 4. Compare results -----
all_stems_intra <- all_stems_intra %>% 
  bind_rows() %>% 
  as_tibble() %>% 
  mutate(date = str_c(year, month, day, sep = "-") %>% ymd()) %>% 
  arrange(stemID, date)
identical(all_stems_intra_v2$dbh2, all_stems_intra$dbh2)


all_stems_bi <- all_stems_bi %>% 
  bind_rows() %>% 
  as_tibble() %>% 
  mutate(date = str_c(year, month, day, sep = "-") %>% ymd()) %>% 
  arrange(stemID, date)
identical(all_stems_bi_v2$dbh2, all_stems_bi$dbh2)


