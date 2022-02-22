library(tidyverse)
library(here)

# Load data -------
all_data <- 
  # Load and combine all 2021 recordings:
  here("resources/raw_data/2021") %>% 
  dir(path = ., pattern = "data_entry", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols("day" = col_integer(), "month" = col_integer())) %>% 
  mutate(
    notes = tolower(notes),
    caliper_limit = !between(measure, 3, 150), 
    dead = str_detect(codes, regex("DC|DS|DN|I|Q")),
    marked_replace = str_detect(codes, regex("RE"))
  ) %>% 
  # Drop rows that aren't of interest
  filter(
    str_sub(tolower(notes), 1, 13) != "originally on" | is.na(notes), 
    str_sub(tolower(notes), 1, 8) != "estimate" | is.na(notes),
    !str_detect(notes, "seems like outlier") | is.na(notes),
    !str_detect(notes, "original measure of") | is.na(notes),
    notes != "ash - alive!" | is.na(notes), 
    # Can ignore the following notes:
    !notes %in% c("jen jordan", "double-checked", "double-checke", "only one band", "left", "right", "band removed", "left old band") | is.na(notes),
    tag != 30339
  ) %>% 
  # Keep these rows: where codes, notes, or caliper limit issues exist
  filter(!is.na(codes) | !is.na(notes) | caliper_limit) %>% 
  # Organize
  select(tag, stemtag, sp, quadrat, survey.ID, measure, codes, notes, field.recorders, caliper_limit, dead, marked_replace) %>% 
  arrange(tag, stemtag, survey.ID)



# All stems with caliper limit, dead, or marked as replace -----
all_data <- all_data %>% 
  # Any issues?
  mutate(any = caliper_limit | dead | marked_replace)

dead_marked_replace_any <- all_data %>% 
  filter(any) %>% 
  select(-any)
write_csv(dead_marked_replace_any, file = "resources/raw_data/2021/identifying_stems_with_issues/dead_marked_replace_any_issues.csv")

# Get unique tag_stemtag count
dead_marked_replace_any %>%
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>%
  select(tag_stemtag) %>%
  n_distinct()



# ID tag issue ----------
all_data <- all_data %>% 
  filter(!any | is.na(any)) %>% 
  select(-c(caliper_limit, dead, marked_replace, any, codes)) %>% 
  mutate(tag_issue = str_detect(notes, "tag"))

tag_issue <- all_data %>% 
  filter(tag_issue)
write_csv(tag_issue, file = "resources/raw_data/2021/identifying_stems_with_issues/tag_issue.csv")

# Get unique tag_stemtag count
tag_issue %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>%
  select(tag_stemtag) %>%
  n_distinct()



# Other maintenance stems: wrong species, coordinates, etc ------
other_maintenance_stems <- all_data %>% 
  filter(tag %in% c(120790, 72248, 40635, 70579, 110798, 80180))
# write_csv(other_maintenance_stems, file = "resources/raw_data/2021/identifying_stems_with_issues/other_maintenance.csv")

all_data <- all_data %>% 
  filter(!tag %in% c(120790, 72248, 40635, 70579, 110798, 80180))



# Remainder stems -----
original_remainders <- 
  read_csv("resources/raw_data/2021/identifying_stems_with_issues/remainders_original_cataloged_by_jess.csv") %>% 
    select(tag, stemtag, survey.ID, action_needed)

all_data <- all_data %>% 
  filter(!tag_issue) %>% 
  select(-tag_issue) %>% 
  left_join(original_remainders, by = c("tag", "stemtag", "survey.ID"))
write_csv(all_data, file = "resources/raw_data/2021/identifying_stems_with_issues/remainders.csv")

# Get unique tag_stemtag combos:
all_data %>% 
  filter(action_needed != "none") %>%
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>%
  select(tag_stemtag) %>%
  distinct()





# Sampling strategy ---------




all_2021_stems <- here("data/scbi.dendroAll_2021.csv") %>% 
  read_csv() %>% 
  select(
    tag, stemtag, biannual, intraannual, sp, quadrat
    #, lx, ly, stemID, treeID, dendroID, dbh
  ) %>% 
  distinct() %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))


tag_stemtags_to_drop <- 
  bind_rows(
    read_csv("resources/raw_data/2021/identifying_stems_with_issues/dead_marked_replace_any_issues.csv") %>% 
      select(tag, stemtag, caliper_limit, dead, marked_replace) %>% 
      mutate(
        reason = case_when(
          caliper_limit == TRUE ~ "caliper",
          marked_replace ~ "replace band",
          dead ~ "replace tree"
        )
      ) %>% 
      select(-c(caliper_limit, marked_replace, dead)),
    read_csv("resources/raw_data/2021/identifying_stems_with_issues/remainders.csv") %>% 
      filter(action_needed != "none") %>% 
      select(tag, stemtag) %>% 
      mutate(reason = "replace tree")
  ) %>% 
  distinct() %>% 
  mutate(
    tag_stemtag = str_c(tag, stemtag, sep = "-")
  ) 
  
  
all_2021_stems <- all_2021_stems %>% 
  left_join(tag_stemtags_to_drop, by = c("tag", "stemtag", "tag_stemtag")) %>% 
  mutate(reason = ifelse(is.na(reason), "keep", reason))

all_2021_stems %>% 
  mutate(survey = ifelse(intraannual == 1, "biweekly", "biannual")) %>% 
  select(-intraannual) %>% 
  group_by(survey, reason) %>% 
  summarize(n = n()) %>% 
  pivot_wider(names_from = "reason", values_from = "n")


