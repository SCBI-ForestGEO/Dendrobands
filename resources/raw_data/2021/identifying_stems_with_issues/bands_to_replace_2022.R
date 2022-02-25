library(tidyverse)
library(here)
library(janitor)
library(knitr)
library(googlesheets4)

# Identify bands to replace ------
## Load data -------
all_data <- 
  # Load and combine all 2021 recordings:
  here("resources/raw_data/2021") %>% 
  dir(path = ., pattern = "data_entry", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols("day" = col_integer(), "month" = col_integer())) %>% 
  mutate(
    tag_stemtag = str_c(tag, stemtag, sep = "-"),
    notes = tolower(notes),
    caliper_limit = !between(measure, 3, 130), 
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
  # If caliper is true, remove RE label to disambiguate
  # mutate(marked_replace = ifelse(caliper_limit == TRUE, FALSE, marked_replace)) %>% 
  # mutate(caliper_limit = ifelse(dead, FALSE, caliper_limit)) %>% 
  # Organize
  select(tag, stemtag, sp, quadrat, survey.ID, measure, codes, notes, field.recorders, caliper_limit, dead, marked_replace) %>% 
  arrange(tag, stemtag, survey.ID)

## All stems with caliper limit, dead, or marked as replace -----
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



## ID tag issue ----------
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



## Other maintenance stems: wrong species, coordinates, etc ------
other_maintenance_stems <- all_data %>% 
  filter(tag %in% c(120790, 72248, 40635, 70579, 110798, 80180))
# write_csv(other_maintenance_stems, file = "resources/raw_data/2021/identifying_stems_with_issues/other_maintenance.csv")

all_data <- all_data %>% 
  filter(!tag %in% c(120790, 72248, 40635, 70579, 110798, 80180))



## Remainder stems -----
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
## Load data -----
issue_stems <- 
  read_csv("resources/raw_data/2021/identifying_stems_with_issues/dead_marked_replace_any_issues.csv") %>% 
  select(tag, stemtag, codes, caliper_limit, dead, marked_replace) %>% 
  replace_na(list(caliper_limit = FALSE, dead = FALSE, marked_replace = FALSE)) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))

# ID all stems that were marked dead at any point:
dead_tag_stemtag <- issue_stems %>% 
  filter(dead == TRUE) %>% 
  pull(tag_stemtag) %>% 
  unique()

# Dead stems
dead_stems <- issue_stems %>% 
  filter(tag_stemtag %in% dead_tag_stemtag) %>% 
  select(tag, stemtag, tag_stemtag) %>% 
  ungroup() %>% 
  distinct()

# Rest of stems
stems_to_act_on <- issue_stems %>% 
  # only live stems
  filter(!tag_stemtag %in% dead_tag_stemtag) %>% 
  mutate(
    action = case_when(
      # The following two tags had both caliper and RE; set to caliper
      tag_stemtag %in% c("160910-1", "192532-1") ~ "caliper",
      # Caliper is prioritized above marked_replace:
      caliper_limit == TRUE ~ "caliper",
      marked_replace ~ "replace_band",
      TRUE ~ codes
    )
  ) %>% 
  select(tag, stemtag, tag_stemtag, action) %>% 
  ungroup() %>% 
  distinct()


## Load 2021 stem info  
all_2021_live_stems <- "data/scbi.dendroAll_2021.csv" %>% 
  here() %>% 
  read_csv() %>% 
  select(tag, stemtag, biannual, intraannual, sp, quadrat) %>% 
  distinct() %>% 
  mutate(
    tag_stemtag = str_c(tag, stemtag, sep = "-"),
    survey = ifelse(intraannual == 1, "biweekly", "biannual"),
  ) %>% 
  # Only live stems
  filter(!tag_stemtag %in% dead_tag_stemtag) %>% 
  # Add action items
  left_join(stems_to_act_on, by = c("tag", "stemtag", "tag_stemtag")) %>% 
  mutate(
    action = ifelse(is.na(action), "keep", action),
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
    # Put ash as bottom priority:
    priority_grouping = ifelse(sp == "fram", 5, priority_grouping),
    # Set priority order:
    priority_order = 1:n() %>% as.numeric(),
    priority_order = case_when(
      sp == "caca" ~ 19,
      sp == "cofl" ~ 20,
      sp == "fram" ~ 21,
      TRUE ~ priority_order
    )
  ) %>% 
  arrange(priority_order) %>% 
  select(sp, priority_grouping, priority_order) %>% 
  rename(group = priority_grouping)


## Write CSV's of counts ------
bands_to_keep <- all_2021_live_stems %>% 
  filter(action == "keep") %>% 
  left_join(krista_priorities, by = "sp") %>% 
  group_by(survey, sp, priority_order, group) %>% 
  summarize(n = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = "survey", values_from = "n", values_fill = 0) %>% 
  arrange(priority_order) %>% 
  select(-priority_order) %>% 
  mutate(group = factor(group)) %>% 
  rename(
    biannual_keep = biannual,
    biweekly_keep = biweekly
  )

bands_to_replace <- all_2021_live_stems %>% 
  filter(action == "replace_band") %>% 
  left_join(krista_priorities, by = "sp") %>% 
  group_by(survey, sp, priority_order, group) %>% 
  summarize(n = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = "survey", values_from = "n", values_fill = 0) %>% 
  arrange(priority_order) %>% 
  select(-priority_order) %>% 
  mutate(group = factor(group)) %>% 
  rename(
    biannual_RE = biannual,
    biweekly_RE = biweekly
  )

bands_caliper <- all_2021_live_stems %>% 
  filter(action == "caliper") %>% 
  left_join(krista_priorities, by = "sp") %>% 
  group_by(survey, sp, priority_order, group) %>% 
  summarize(n = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = "survey", values_from = "n", values_fill = 0) %>% 
  arrange(priority_order) %>% 
  select(-priority_order) %>% 
  mutate(group = factor(group)) %>% 
  rename(
    biannual_caliper = biannual,
    biweekly_caliper = biweekly
  )

master_list <- bands_to_keep %>% 
  left_join(bands_to_replace, by = c("sp", "group")) %>% 
  left_join(bands_caliper, by = c("sp", "group")) %>% 
  replace_na(list(biannual_RE = 0, biweekly_RE = 0, biannual_caliper = 0, biweekly_caliper = 0)) %>% 
  mutate(
    biweekly_replace_band = 0,
    biweekly_install_new = 0,
    biweekly_total = 0,
    biannual_replace_band = 0,
    biannual_install_new = 0,
    biannual_total = 0,
    biannual_biweekly_total = 0
  ) %>% 
  select(sp, group, starts_with("biweekly"), starts_with("biannual")) %>% 
  adorn_totals()


# Write to Google Sheets: uncomment
# master_list %>%
#   write_sheet(ss = "https://docs.google.com/spreadsheets/d/1rneieQOCclZ2q-Kbxog-rzNMM6-9d7foGooTv8Xq588/edit#gid=0", sheet = "master_list")










## Rest --------

# All stems in 2021:
# 403 vs 146 = 549 total
# 400 vs 150 = 550 is a nice target
all_2021_summary <- all_2021_live_stems %>% 
  group_by(survey) %>% 
  summarize(n = n()) %>% 
  pivot_wider(names_from = "survey", values_from = "n") %>% 
  mutate(survey = "2021 total") %>% 
  select(survey, everything())

# Figure out how many new stems we need:
# biannual = 333 + 23 = 356 i.e. ideally install 44 more.
# biweekly = 128 + 13 = 141 i.e. ideally install 9 more
# total = ideally install 53 more
action_2021_summary <- all_2021_live_stems %>% 
  group_by(survey, action) %>%
  summarize(n = n()) %>% 
  ungroup() %>% 
  pivot_wider(names_from = "survey", values_from = "n") %>% 
  rename(survey = action)

target_2022_summary <- tibble(
  survey = "2022 target", biannual = 350, biweekly = 150
)

table <- bind_rows(
  action_2021_summary,
  all_2021_summary
) %>% 
  mutate(total = biannual_only + biweekly)

table %>% kable()





census <- "https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem3.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
  mutate(tag_stemtag = str_c(tag, StemTag, sep = "-"))


census %>% 
  filter(tag_stemtag %in% all_2021_live_stems$tag_stemtag) %>% 
  left_join(all_2021_live_stems %>% select(tag_stemtag, survey, action), by = "tag_stemtag") %>% 
  filter(action == "keep") %>% 
  ggplot(aes(x = gx, y = gy, col = sp)) +
  geom_point() +
  coord_fixed() +
  facet_wrap(~survey)
#facet_grid(action ~ survey)





status <- all_2021_live_stems %>% 
  filter(action != "replace_stem") %>% 
  left_join(krista_priorities, by = "sp") %>% 
  group_by(survey, sp, priority_order, priority_grouping) %>% 
  summarize(n = n()) %>% 
  pivot_wider(names_from = "survey", values_from = "n", values_fill = 0) %>% 
  arrange(priority_order)

status <- status %>% 
  rename(
    bian = biannual_only, 
    biwk = biweekly,
    group = priority_grouping
  ) %>% 
  ungroup() %>% 
  select(-priority_order) %>% 
  mutate(
    new_bian = bian - 12,
    new_bian = ifelse(new_bian >= 0, 0, -new_bian),
    total_new_bian = cumsum(new_bian),
    new_biwk = 0,
    new_biwk = case_when(
      sp %in% c("quve", "qupr", "cato") ~ 2,
      sp %in% c("juni", "caco", "caovl") ~ 1,
      TRUE ~ new_biwk
    ),
    total_new_biwk = cumsum(new_biwk),
  ) %>% 
  select(sp, group, bian, new_bian, total_new_bian, biwk, new_biwk, total_new_biwk)
write_csv(status, "resources/planning/current_distribution.csv")

status %>% kable()
