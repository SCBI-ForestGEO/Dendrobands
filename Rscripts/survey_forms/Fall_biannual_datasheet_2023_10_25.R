

# Setup to create Fall Biannual Survey datasheet -------------------

# Open 'create_master_csv_2021_and_after.R

# Run lines 18-39, 45-46, 53-64 if spring and intrannual files exist 

# Run the 'stem locations' section

# Run line 117 to add the current year's data to the environment


# Fall Biannual datasheet ----------------------------------------------

## Keep last intrannual measurement and spring biannual measurement for comparison


table(current_year_data$survey.ID)

# subset the previous intraannual measurement for reference

prev_measure <- 
  current_year_data %>% 
  filter(survey.ID == 2024.02,
         month == 9,
         biannual == 1) %>% 
  select(c(
    "quadrat",
    "tag",
    "stemtag",
    "survey.ID",
    "measure",
    "codes",
    "notes",
    "status"))

colnames(prev_measure)[5] <- "measure_intra"
colnames(prev_measure)[6] <- "codes_intra"
colnames(prev_measure)[7] <- "notes_intra"
colnames(prev_measure)[8] <- "status_intra"

# Subset all data to the spring biannual measurement 

data_biannual <- 
  current_year_data %>%
  filter(survey.ID == 2024.01,
         biannual == 1) %>% 
  .[!duplicated(.[1:2]), ] %>% 
  left_join(prev_measure,
            by = c("tag", "stemtag", "quadrat", "survey.ID"))


                
# Check for dead trees

table(data_biannual$status)

dead <- 
  data_biannual %>% 
  filter(status == "dead")

# Remove dead trees

data_living <- 
  data_biannual %>% 
  filter(status == "alive")

# Add area and location

fall_biannual <- 
  data_living %>% 
  left_join(stem_locations,
            by = c("tag", "stemtag", "quadrat"))



# Rename columns
fall_biannual <-
  fall_biannual %>% rename("spring_measure" = measure)

# Reorder and keep only necessary columns

fall_biannual <- 
  fall_biannual %>% 
  select(c("tag",
           "stemtag",
           "sp",
           "dbh",
           "quadrat",
           "lx",
           "ly",
           "area",
           "location",
           "spring_measure",
           "measure",
           "measure.verified",
           "codes",
           "new.band",
           "notes",
           "field.recorders",
           "data.enter",
           "survey.ID":"day")) %>% 
  arrange(.,
          area,
          tag,
          stemtag)

# Add blank columns

fall_biannual$measure = ""
fall_biannual$codes = ""
fall_biannual$measure.verified = ""
fall_biannual$notes = ""
fall_biannual$field.recorders = ""
fall_biannual$data.enter = ""
fall_biannual$survey.ID = 2024.12
fall_biannual$year = 2024
fall_biannual$month = 11
fall_biannual$day = ""
fall_biannual$new.band = ""



write_csv(fall_biannual, "C:/Users/shuej/OneDrive - Smithsonian Institution/Documents/GitHub/Dendrobands/resources/raw_data/2024/data_entry_biannual_fall2024_BLANK.csv")

# Bands to replace --------------------------------------------------------

# check for code RE

RE <- 
  current_year_data %>% 
  filter(codes == "RE") 

RE <- RE[!duplicated(RE[1:2]), ]



table(RE$notes)

# all bands to replace should be on living trees 

table(RE$status)

# check notes in case a tree needs a new band but 'RE' was not recorded
table(current_year_data$notes)

# Check for large gaps - again, in case 'RE' wasn't recorded
current_year_data$measure <- as.numeric(as.character(current_year_data$measure))

large_gaps <- 
  current_year_data %>% 
  filter(measure > 120) %>% 
  .[!duplicated(.[1:2]), ] %>% 
  filter(codes != "RE")
  

bands_to_build <- rbind(RE, large_gaps)

bands_to_build <-  bands_to_build %>%  
  left_join(stem_locations,
            by = c("tag", "stemtag", "quadrat")) %>% 
  select(c("tag",
           "stemtag",
           "dbh",
           "quadrat",
           "area",
           "lx",
           "ly",
           "year",
           "month",
           "day"))

bands_to_build <- bands_to_build[!duplicated(bands_to_build[1:2]), ]

write_csv(bands_to_build,"C:/Users/shuej/Smithsonian Dropbox/Jessica Shue/Field_Form_Data_Entry/SCBI/dendro/2024/repairs_fall_2024.csv")
