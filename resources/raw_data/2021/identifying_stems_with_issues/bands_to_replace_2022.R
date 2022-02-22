library(tidyverse)
library(here)
library(janitor)

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
# write_csv(all_data, file = "resources/raw_data/2021/identifying_stems_with_issues/remainders.csv")

# Get unique tag_stemtag combos:
all_data %>% 
  filter(action_needed != "none") %>%
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>%
  select(tag_stemtag) %>%
  distinct()





# Sampling strategy ---------
# Load information on new bands needed
tag_stemtags_to_drop <- 
  read_csv("resources/raw_data/2021/identifying_stems_with_issues/dead_marked_replace_any_issues.csv") %>% 
  select(tag, stemtag, codes, caliper_limit, dead, marked_replace) %>% 
  mutate(
    tag_stemtag = str_c(tag, stemtag, sep = "-"),
    action = case_when(
      str_detect(codes, regex("DC|DS|DN")) ~ "replace_stem",
      marked_replace ~ "replace_band",
      caliper_limit == TRUE ~ "caliper",
      TRUE ~ codes
    )
  ) %>% 
  select(tag, stemtag, tag_stemtag, action) %>% 
  distinct()

# Load 2021 stem info  
all_2021_stems <- here("data/scbi.dendroAll_2021.csv") %>% 
  read_csv() %>% 
  select(
    tag, stemtag, biannual, intraannual, sp, quadrat
    #, lx, ly, stemID, treeID, dendroID, dbh
  ) %>% 
  distinct() %>% 
  mutate(
    tag_stemtag = str_c(tag, stemtag, sep = "-"),
    survey = ifelse(intraannual == 1, "biweekly", "biannual"),
  ) %>% 
  # Add action items
  left_join(tag_stemtags_to_drop, by = c("tag", "stemtag", "tag_stemtag")) %>% 
  mutate(
    action = ifelse(is.na(action), "keep", action),
    action = ifelse(action == "caliper", "replace_band", action),
    # TODO: Ensure these are correct
    action = ifelse(action %in% c("I", "Q"), "replace_stem", action)
  )

# Load Krista priorities from
# https://github.com/SCBI-ForestGEO/Dendrobands/issues/97#issuecomment-1045085760
krista_priorities <- read_csv("resources/planning/dendro_trees_sp_2021_min_max_mean_dbh_with_dominance.csv") %>% 
  clean_names() %>% 
  filter(sp != "Sum") %>% 
  mutate(
    priority_grouping = str_sub(priority_grouping, 1, 1) %>% as.numeric(),
    priority_grouping = ifelse(is.na(priority_grouping), 4, priority_grouping),
    # Put ash as bottom priority
    priority_grouping = ifelse(sp == "fram", 5, priority_grouping),
    priority_order = 1:n() %>% as.numeric(),
    priority_order = case_when(
      sp == "caca" ~ 19,
      sp == "cofl" ~ 20,
      sp == "fram" ~ 21,
      TRUE ~ priority_order
    )
  ) %>% 
  arrange(priority_order) %>% 
  select(sp, priority_grouping, priority_order)

  


# All stems in 2021:
# 403 vs 146 = 549 total
# 400 vs 150 = 550 is a nice target
all_2021_stems %>% 
  group_by(survey) %>% 
  summarize(n = n())

# Figure out how many new stems we need:
# biannual = 333 + 23 = 356 i.e. ideally install 44 more.
# biweekly = 128 + 13 = 141 i.e. ideally install 9 more
# total = ideally install 53 more
all_2021_stems %>% 
  group_by(survey, action) %>% 
  summarize(n = n())


status <- all_2021_stems %>% 
  filter(action != "replace_stem") %>% 
  left_join(krista_priorities, by = "sp") %>% 
  group_by(survey, sp, priority_order, priority_grouping) %>% 
  summarize(n = n()) %>% 
  pivot_wider(names_from = "survey", values_from = "n", values_fill = 0) %>% 
  arrange(priority_order)


status %>% 
  ungroup() %>% 
  # filter(priority_grouping %in% c(1)) %>% 
  summarize(biannual = sum(biannual), biweekly = sum(biweekly))


status %>% 
  mutate(
    new_biannual = biannual - 12,
    new_biannual = ifelse(new_biannual >= 0, 0, -new_biannual),
    new_biweekly = biweekly - 5,
    new_biweekly = ifelse(new_biweekly >= 0, 0, -new_biweekly),
  )

status %>% 
  ungroup() %>% 
  filter(priority_grouping %in% c(1)) %>% 
  summarize(new_biannual = sum(new_biannual), new_biweekly = sum(new_biweekly))




