# setup -------------------------------------------------------------------
# created by Jess Shue
library(lubridate)
library(readr)
library(tidyverse)

# custom function

`%not in%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

# open zipped csv files ---------------------------------------------------


intra_data <- list(
  
  # trees
  trees = read_csv(
    unz("NZCBI_dendrometers_2026.zip", 
        "dendrometer_trees_2026_0.csv"), 
    col_names = TRUE),
  
  # measurements
  measurements = read_csv(
    unz("NZCBI_dendrometers_2026.zip",
        "dendrometer_measurements_2026_1.csv"), 
    col_names = TRUE))


colnames(intra_data$trees)
colnames(intra_data$measurements)

# Select necessary fields from each csv and rename ----------------------------

trees <- intra_data$trees %>% 
  select(c(tag,
           StemTag,
           sp,
           dbh,
           quadrat,
           lx,
           ly,
           area,
           location,
           previous_measure))

#create unique ids
trees$treeID <- paste(trees$tag, trees$StemTag, sep = ".")



# measurements

measurements <- intra_data$measurements %>% 
  select(c(tag,
           StemTag,
           measure,
           measureVerified,
           newBand,
           codes,
           COD_BA:COD_RT,
           notes,
           measureDate)) %>% 
  rename(.,
         measure_verified = "measureVerified",
         new.band = "newBand",
         stemtag = "StemTag")

measurements$measureDate <- as.Date(measurements$measureDate, format = "%m/%d/%Y %H:%M:%S")

measurements$treeID <- paste(measurements$tag, measurements$stemtag, sep = ".")



# area and location for each tree

area_loc <- trees %>% 
  distinct(treeID,
           .keep_all = TRUE) %>% 
  select(treeID,
         area,
         location)

# remove tag and stemtag from measurements - will merge by treeID 

measurements <- measurements[ , -c(1:2)]

# Combine tree data and measurements --------------------------------------

spring_2026 <- merge(trees, measurements, by = "treeID")

# create current survey ---------------------------------------------------

# If measurements split into two days, keep only those measured -----------
#update this date to right before the most recent measurement began
survey <- spring_2026 %>% 
  filter(measureDate > as.Date("2026-9-24"))

# survey <- spring_2026 %>% 
  # filter(between(measureDate, as.Date("2026-07-17"), as.Date("2026-08-01")))

# check for duplicates

# Check for duplicates ----------------------------------------------------


dups <- survey[duplicated(survey$treeID), ]

dup_meas <- survey %>% 
  filter(tag %in% dups$tag)


# Remove all records with duplicate measurements from the survey

survey <- survey %>% 
  filter(treeID %not in% dup_meas$treeID)

# remove extra measurements from dup_meas and merge back to survey
#adjust this depending which of the duplicates you want to remove
keep_meas <- dup_meas[-2, ]

survey <- rbind(survey, keep_meas)

rm(dups, dup_meas)
# Check for missing trees from CURRENT data table -------------------------

current <- read_csv("C:/Users/kennedyia/OneDrive - Smithsonian Institution/Documents/GitHub/Dendrobands/data/scbi.dendroAll_BLANK.csv")

current$treeID <- paste(current$tag, current$stemtag, sep = ".")

# select intraannual trees only

current <- current %>% 
  filter(intraannual == 1)

# Missing from intraannual measurements: 202201, 30233, 122006, 142708, 110061 - BT band removed, 90660 - replaced 7/7

missing <- current %>%
  filter(treeID %not in% survey$treeID)

# Missing from All BLANK: 
#checking against current all blank file, making sure current data file has all the trees init that we are surveying
missing2 <- survey %>%
  filter(treeID %not in% current$treeID)

# two trees to keep in data but aren't being measured (need to replace band or dead)

trees_to_add <- c(110061, 22601, 90752, 131364, 142708, 172499, 182471, 192484)


missing <- spring_2026 %>% 
  filter(tag %in% trees_to_add,
         measureDate>as.Date("2026-08-29"))

#missing <- missing[2, ]

missing$measureDate <- "2026-09-25"
missing$previous_measure <- 0
missing$measure <- 0
missing$measure_verified <- 0

trees_to_add2 <- 110061
missing2 <- spring_2026 %>% 
  filter(tag %in% trees_to_add2,
         measureDate>as.Date("2026-04-30"))

missing <- within(missing, notes[tag == 142708] <- "tree down")
missing2 <- within(missing2, notes[tag == 110061] <- "Big Tree; band removed")
missing <- within(missing, COD_dead[tag == 142708] <- "dead")
missing <- within(missing, COD_DC[tag == 142708] <- "DC")

# a few trees were added but not to the dendroAll_BLANK file

# Trees to add to dendroAll_BLANK -----------------------------------------


# 101223 - added to intraannual
# 102303 - added to intraannual
# 162446 - added to intraannual
# 172499 - listed as a tree to replace
# 202283 - added to intraannual



add_trees <- bian_data$trees %>% 
  filter(tag %in% missing$tag) %>%
  select(c(tag,
           stemtag,
           sp,
           dbh,
           quadrat,
           lx,
           ly,
           area,
           location,
           previous_measure))

AddColumns <-  c('measure.verified',
                 'new.band')

add_trees[ , AddColumns] <-  "NA"

add_trees$measure <- "NA"

add_trees$codes <- "RE"

add_trees$notes <- ""

add_trees$field.recorders <- "Jessica Shue"

add_trees$data.enter <- "Jessica Shue"

add_trees$survey.ID <- "2026.10"

add_trees$year <- 2026

add_trees$month <- 08

add_trees$day <- 19












# Trees to keep in the survey  --------------------------------------------
#in case you miss measuring these trees you can add them back in here
#add <- c("62114.1", "202201.1", "72124.1","90752.1")

keepers <- spring_2026 %>% 
  filter(treeID %in% add,
         measureDate > "2026-07-01")

keepers <- keepers[c(1, 4, 5, 9), ]

keepers$measureDate <- "2026-08-17"

keepers$previous_measure <- 0

keepers$measure <- 0

keepers$measure_verified <- 0

keepers$COD_RE <- "RE"

# keepers <- within(keepers, previous_measure[tag == 142708] <- 10.45)
# keepers <- within(keepers, previous_measure[tag == 122006] <- 48.31)
# keepers <- within(keepers, previous_measure[tag == 30233] <- 134.12)
# keepers <- within(keepers, notes[tag == 142708] <- "replace tree")
# keepers <- within(keepers, COD_RE[tag == 122006] <- "RE")
# keepers <- within(keepers, COD_RE[tag == 30233] <- "RE")




# Add columns for GitHub --------------------------------------------------
# keepers,
# merge missed trees due to needing band replaced

survey <- rbind(survey, missing)
survey <- rbind(survey, missing2)
#will need to add back 11061 back in too

#  add year, month, day
survey <- survey %>%
  mutate(year = year(measureDate),
         month = month(measureDate),
         day = day(measureDate))

# accidentally measured 24 biannual trees - remove
# survey <- survey %>% 
#   filter(tag %not in% missing2$tag)

# area and location

# survey <- merge(survey, area_loc, by = "treeID")
#this gets updated each time
survey$survey.ID <- "2026.12"

survey$field.recorders <- ""


#change based on which area each person did
survey["field.recorders"][survey["area"] == 1] <- "Jessica Shue"
survey["field.recorders"][survey["area"] == 2] <- "Jessica Shue"
survey["field.recorders"][survey["area"] == 3] <- "Iris Kennedy"
survey["field.recorders"][survey["area"] == 4] <- "Iris Kennedy"
survey["field.recorders"][survey["area"] == 5] <- "Iris Kennedy"
survey["field.recorders"][survey["area"] == 6] <- "Jessica Shue"
survey["field.recorders"][survey["area"] == 7] <- "Iris Kennedy"
survey["field.recorders"][survey["area"] == 8] <- "Iris Kennedy"
survey["field.recorders"][survey["area"] == 9] <- "Iris Kennedy"


survey$data.enter <- "Iris Kennedy"



# Combine codes -----------------------------------------------------------

#renaming AGOL formatting for github
survey <- survey %>% 
  mutate(across(.cols = -measureDate, 
                ~ gsub('-', 
                       NA, 
                       ., 
                       fixed = TRUE)))

#combining into one column
survey <- survey %>% 
  unite("codes",
        COD_BA,
        COD_DC:COD_RT,
        na.rm = TRUE,
        sep = ", ",
        remove = TRUE)



# data for export ---------------------------------------------------------

for_GitHub <- survey %>% 
  select(tag:codes,
         notes,
         field.recorders,
         data.enter,
         survey.ID,
         year,
         month,
         day)

# add missing trees

# remove extra tree measurements
# for_GitHub <- for_GitHub %>% 
#   filter(tag != 100612)

# for_GitHub <- rbind(for_GitHub, add_trees)


# replace 0 with "" in measure column (AGOL requires a number)
for_GitHub <- within(for_GitHub, measure[measure == 0] <- "NA")
for_GitHub <- within(for_GitHub, previous_measure[is.na(previous_measure)] <- "NA")

# 
# for_GitHub <- within(for_GitHub, notes[tag == 50562] <- "likely measurement typo")
# for_GitHub <- within(for_GitHub, measure_verified[tag == 72116] <- 77.82)

#update the nmame of the csv to the correct number of measurement count
write_csv(for_GitHub, "C:/Users/kennedyia/OneDrive - Smithsonian Institution/Documents/GitHub/Dendrobands/resources/raw_data/2026/data_entry_intraannual_2026-12.csv", na = "")

#quick check, sort from high to low and look for really negative or positive numbers (technically gituhub acitons should tell you)
for_GitHub$measure <- as.numeric(as.character(for_GitHub$measure))

for_GitHub$previous_measure <- as.numeric(as.character(for_GitHub$previous_measure))

for_GitHub$diff <- for_GitHub$measure - for_GitHub$previous_measure

