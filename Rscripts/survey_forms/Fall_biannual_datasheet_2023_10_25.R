

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
  filter(survey.ID == 2023.08,
         biannual == 1)

# Subset all data to the spring biannual measurement 

data_biannual <- 
  current_year_data %>%
  filter(survey.ID == 2023.01,
         biannual == 1)

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
           "spring_measure"))

# Add blank columns

fall_biannual$measure = ""
fall_biannual$codes = ""
fall_biannual$measure.verified = ""
fall_biannual$notes = ""
fall_biannual$field.recorders = ""
fall_biannual$data.enter = ""
fall_biannual$survey.ID = ""
fall_biannual$year = 2023
fall_biannual$month = 11
fall_biannual$day = ""
fall_biannual$new.band = ""



# Bands to replace --------------------------------------------------------

# check for code RE

RE <- 
  current_year_data %>% 
  filter(codes == "RE")

table(RE$notes)

# all bands to replace should be on living trees 

table(RE$status)

# check notes
table(current_year_data$notes)

# 