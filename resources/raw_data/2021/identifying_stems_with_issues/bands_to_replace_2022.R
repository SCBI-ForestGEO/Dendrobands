# Scripts to preparation of new bands for 2022 season
# https://github.com/SCBI-ForestGEO/Dendrobands/issues/89
# https://github.com/SCBI-ForestGEO/Dendrobands/issues/97
#
# Google Sheet summarizing changes:
# https://docs.google.com/spreadsheets/d/1rneieQOCclZ2q-Kbxog-rzNMM6-9d7foGooTv8Xq588/edit#gid=1289938519
#
# 
# Developed by: Albert Y. Kim - albert.ys.kim@gmail.com
# R version 4.0.3 - January 2022
#
# 🔥HOT TIP🔥 Get a bird's eye view of what this code is doing by
# turning on "code folding" by going to RStudio menu -> Edit -> Folding
# -> Collapse all

library(tidyverse)
library(here)
library(janitor)
library(knitr)
library(googlesheets4)
library(lubridate)

# DO THIS FIRST:
# Authenticate for Google Sheets
gs4_auth()


# 1. Identify bands to replace based on 2021 raw-data ------
## Load data -------
all_data <- 
  # Load and combine all 2021 recordings:
  here("resources/raw_data/2021") %>% 
  dir(path = ., pattern = "data_entry", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols("day" = col_integer(), "month" = col_integer()), show_col_types = FALSE) %>% 
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
  "resources/raw_data/2021/identifying_stems_with_issues/remainders_originally_cataloged_by_jess.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
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





# 2. Create Google Sheet summarizing all Spring 2022 work ---------
## Load data on bands to replace from above -----
issue_stems <- 
  "resources/raw_data/2021/identifying_stems_with_issues/dead_marked_replace_any_issues.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
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
all_2021_stems <- "data/scbi.dendroAll_2021.csv" %>% 
  here() %>% 
  read_csv(show_col_types = FALSE) %>% 
  select(tag, stemtag, biannual, intraannual, sp, quadrat, dbh) %>% 
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
krista_priorities <- 
  "resources/planning/dendro_trees_sp_2021_min_max_mean_dbh_with_dominance.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
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


## Write Google Sheet of counts ------
bands_to_keep <- all_2021_stems %>% 
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

bands_to_replace <- all_2021_stems %>% 
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

bands_caliper <- all_2021_stems %>% 
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


# Write to Google Sheets only once: the Google Sheet has several manual
# edits and is now finalized
# master_list %>%
#   write_sheet(ss = "https://docs.google.com/spreadsheets/d/1rneieQOCclZ2q-Kbxog-rzNMM6-9d7foGooTv8Xq588/edit#gid=0", sheet = "master_list")


# 3. Make CSV lists of dead stems, stems to reband, new stems to install dendrobands on ------
## Load data -----
# Master list containing agonizing decisions: https://github.com/SCBI-ForestGEO/Dendrobands/issues/97
master_list <- read_sheet(
  ss = "https://docs.google.com/spreadsheets/d/1rneieQOCclZ2q-Kbxog-rzNMM6-9d7foGooTv8Xq588/edit#gid=0", 
  sheet = "master_list", 
  skip = 1
) %>% 
  clean_names() %>% 
  select(
    sp,
    biweekly_replace = replace_band_re_caliper_issue_6,
    biweekly_install = install_new_7,
    biannual_replace = replace_band_re_caliper_issue_13,
    biannual_install = install_new_14,
    biweekly_shift_to_biannual = shift_biannual_to_biweekly_change_biannual_to_biweekly_change_biweekly_to_biannual_2
  ) %>% 
  filter(sp != "Total")

# Load 2018 census data
census_2018 <- "https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem3.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
  mutate(
    tag_stemtag = str_c(tag, StemTag, sep = "-"),
    dbh = as.numeric(dbh)
  ) %>% 
  filter(DFstatus == "alive")

## Identify stems that are dead and thus bands need to be retrieved ----
dead_stems


## Identify stems that are alive with no RE or caliper issues -----
stems_to_keep <- all_2021_stems %>% 
  filter(action == "keep") %>% 
  pull(tag_stemtag)
length(stems_to_keep)


## Identify bands to replace -----
bands_to_replace <- all_2021_stems %>%
  filter(action %in% c("replace_band", "caliper")) %>%
  filter(
    (sp %in% (master_list %>% filter(!is.na(biweekly_replace)) %>% pull(sp)) & survey == "biweekly") |
      (sp %in% (master_list %>% filter(!is.na(biannual_replace)) %>% pull(sp)) & survey == "biannual")
  )

stems_to_reband <- bands_to_replace %>% 
  pull(tag_stemtag)
length(stems_to_reband)

bands_to_retrieve <- all_2021_stems %>%
  filter(action %in% c("replace_band", "caliper")) %>%
  filter(
    !(sp %in% (master_list %>% filter(!is.na(biweekly_replace)) %>% pull(sp)) & survey == "biweekly") &
      !(sp %in% (master_list %>% filter(!is.na(biannual_replace)) %>% pull(sp)) & survey == "biannual")
  )
stems_to_retrieve <- bands_to_retrieve %>% 
  pull(tag_stemtag)
length(stems_to_retrieve)


# Remove stems that will not be rebanded
all_2021_live_stems <- all_2021_stems %>% 
  filter(tag_stemtag %in% c(stems_to_keep, stems_to_reband)) 


## Identify stems to install new bands on (first round) -----
set.seed(76)


### biweekly stems ----
bands_to_install_biweekly <- master_list %>% 
  select(sp, biweekly_install) %>% 
  filter(!is.na(biweekly_install))

biweekly_population <- census_2018 %>%
  select(sp, tag_stemtag, dbh) %>% 
  # Only relevant sp:
  filter(sp %in% bands_to_install_biweekly$sp) %>% 
  # Drop stems that are too small:
  filter((sp == "tiam" & dbh > 100) | (sp == "ceca" & dbh > 50)) %>% 
  sample_frac(1)

biweekly_population_quantiles <- biweekly_population %>% 
  # Quartiles
  group_by(sp) %>% 
  summarise(enframe(quantile(dbh, c(0, 0.25, 0.5, 0.75, 1)), "quantile", "dbh")) %>% 
  mutate(dbh_lag = lead(dbh)) %>% 
  filter(quantile != "100%")

biweekly_population_quantiles <- biweekly_population_quantiles %>% 
  ungroup() %>% 
  mutate(
    number = c(
      # ceca
      1, 1, 1, 0, 
      # tiam
      1, 1, 0, 1
    ),
    number_backup = c(
      # ceca
      0, 1, 1, 0, 
      # tiam
      0, 1, 0, 1
    )
  ) 

biweekly_sample <- NULL
biweekly_sample_backup <- NULL
for(i in 1:nrow(biweekly_population_quantiles)){
  if(biweekly_population_quantiles$number[i] != 0){
    biweekly_sample <- biweekly_population %>% 
      filter(
        sp == biweekly_population_quantiles$sp[i], 
        between(dbh, biweekly_population_quantiles$dbh[i], biweekly_population_quantiles$dbh_lag[i])
      ) %>% 
      sample_n(biweekly_population_quantiles$number[i]) %>% 
      pull(tag_stemtag) %>% 
      c(biweekly_sample)
  }
  
  if(biweekly_population_quantiles$number_backup[i] != 0){
    biweekly_sample_backup <- biweekly_population %>% 
      filter(!tag_stemtag %in% biweekly_sample) %>% 
      filter(
        sp == biweekly_population_quantiles$sp[i], 
        between(dbh, biweekly_population_quantiles$dbh[i], biweekly_population_quantiles$dbh_lag[i])
      ) %>% 
      sample_n(biweekly_population_quantiles$number_backup[i]) %>% 
      pull(tag_stemtag) %>% 
      c(biweekly_sample_backup)
  }  
}

biweekly_population %>%
  ggplot(aes(x = as.numeric(dbh))) +
  geom_histogram(bins = 15, boundary = 0) +
  geom_vline(
    data = all_2021_live_stems %>% filter(sp %in% biweekly_population$sp),
    aes(xintercept = dbh), col ="red"
  ) +
  geom_vline(
    data = biweekly_population_quantiles,
    aes(xintercept = dbh), col = "black", linetype = "dashed"
  ) +
  geom_vline(
    data = biweekly_population %>% filter(tag_stemtag %in% biweekly_sample),
    aes(xintercept = dbh), col = "blue"
  ) +
  facet_wrap(~sp, scales = "free") +
  labs(x = "dbh", title = "Distribution of dbh from census (histogram) + dendrobands (red lines)", subtitle = "For sp we need to sample for biannual")




### biannual stems ----
bands_to_install_biannual <- master_list %>% 
  select(sp, biannual_install) %>% 
  filter(!is.na(biannual_install))

biannual_population <- census_2018 %>%
  select(sp, tag_stemtag, dbh) %>% 
  # Only relevant sp:
  filter(sp %in% bands_to_install_biannual$sp) %>% 
  # Drop stems that are too small:
  filter(dbh > 100) %>% 
  sample_frac(1)

biannual_population_quantiles <- biannual_population %>% 
  # Quartiles
  group_by(sp) %>% 
  summarise(enframe(quantile(dbh, c(0, 0.25, 0.5, 0.75, 1)), "quantile", "dbh")) %>% 
  mutate(dbh_lag = lead(dbh)) %>% 
  filter(quantile != "100%")

sp <- biannual_population_quantiles$sp %>% unique()
biannual_sampling_numbers <- tibble(
  sp = rep(sp, each = 4),
  quantile = rep(biannual_population_quantiles$quantile %>% unique(), times = sp %>% n_distinct()),
  number = c(
    # arcu
    0, 1, 0, 0, 
    # caco
    2, 2, 0, 0, 
    # caovl
    1, 2, 2, 0, 
    # cato
    1, 1, 0, 0, 
    # ceca
    1, 2, 1, 0, 
    # juni
    1, 0, 0, 0, 
    # pist
    1, 0, 1, 0, 
    # ploc
    0, 1, 0, 0, 
    # tiam
    1, 2, 0, 1, 
    # ulru
    1, 2, 2, 0
  ),
  number_backup = c(
    # arcu
    0, 1, 0, 0, 
    # caco
    1, 1, 0, 0, 
    # caovl
    0, 1, 1, 0, 
    # cato
    1, 1, 0, 0, 
    # ceca
    0, 1, 1, 0, 
    # juni
    1, 0, 0, 0, 
    # pist
    1, 0, 1, 0, 
    # ploc
    0, 1, 0, 0, 
    # tiam
    0, 1, 0, 0, 
    # ulru
    0, 1, 1, 0
  )
)

biannual_population_quantiles <- biannual_population_quantiles %>% 
  ungroup() %>% 
  left_join(biannual_sampling_numbers, by = c("sp", "quantile"))

biannual_sample <- NULL
biannual_sample_backup <- NULL
for(i in 1:nrow(biannual_population_quantiles)){
  if(biannual_population_quantiles$number[i] != 0){
    biannual_sample <- biannual_population %>% 
      filter(
        sp == biannual_population_quantiles$sp[i], 
        between(dbh, biannual_population_quantiles$dbh[i], biannual_population_quantiles$dbh_lag[i])
      ) %>% 
      sample_n(biannual_population_quantiles$number[i]) %>% 
      pull(tag_stemtag) %>% 
      c(biannual_sample)
  }
  
  if(biannual_population_quantiles$number_backup[i] != 0){
    biannual_sample_backup <- biannual_population %>% 
      filter(!tag_stemtag %in% biannual_sample) %>% 
      filter(
        sp == biannual_population_quantiles$sp[i], 
        between(dbh, biannual_population_quantiles$dbh[i], biannual_population_quantiles$dbh_lag[i])
      ) %>% 
      sample_n(biannual_population_quantiles$number_backup[i]) %>% 
      pull(tag_stemtag) %>% 
      c(biannual_sample_backup)
  }  
}

biannual_population %>%
  ggplot(aes(x = as.numeric(dbh))) +
  geom_histogram(bins = 15, boundary = 0) +
  geom_vline(
    data = all_2021_live_stems %>% filter(sp %in% biannual_population$sp),
    aes(xintercept = dbh), col ="red"
  ) +
  geom_vline(
    data = biannual_population_quantiles,
    aes(xintercept = dbh), col = "black", linetype = "dashed"
  ) +
  geom_vline(
    data = biannual_population %>% filter(tag_stemtag %in% biannual_sample),
    aes(xintercept = dbh), col = "blue"
  ) +
  facet_wrap(~sp, scales = "free") +
  labs(x = "dbh", 
       title = "Distribution of dbh from census (histogram) + dendrobands (red lines)", 
       subtitle = "For sp we need to sample for biannual")









## Collate stem info -----
# Reload data to include dead stems
all_2021_stems <- "data/scbi.dendroAll_2021.csv" %>% 
  here() %>% 
  read_csv(show_col_types = FALSE) %>% 
  select(tag, stemtag, sp, quadrat, dbh) %>% 
  distinct() %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) 

census_2018 <- "https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem3.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
  mutate(
    tag_stemtag = str_c(tag, StemTag, sep = "-"),
    dbh18 = as.numeric(dbh)
    ) %>% 
  select(tag, stemtag = StemTag, sp, quadrat, tag_stemtag, dbh18)


bind_rows(
  # Dead stems
  all_2021_stems %>% 
    filter(tag_stemtag %in% dead_stems$tag_stemtag) %>% 
    left_join(census_2018, by = c("tag", "stemtag", "sp", "quadrat", "tag_stemtag")) %>% 
    mutate(action = "retrieve band: stem dead") %>% 
    select(-tag_stemtag),
  # Healthy stems, but won't replace band for re-allocation purposes
  all_2021_stems %>% 
    filter(tag_stemtag %in% stems_to_retrieve) %>% 
    left_join(census_2018, by = c("tag", "stemtag", "sp", "quadrat", "tag_stemtag")) %>% 
    mutate(action = "retrieve band: band issue, stem dropped from database") %>% 
    select(-tag_stemtag),
  # Stems to reband:
  all_2021_stems %>% 
    filter(tag_stemtag %in% stems_to_reband) %>% 
    left_join(census_2018, by = c("tag", "stemtag", "sp", "quadrat", "tag_stemtag")) %>% 
    mutate(action = "reband stem") %>% 
    select(-tag_stemtag),
  # Biweekly bands to install:
  census_2018 %>% 
    filter(tag_stemtag %in% c(biweekly_sample)) %>% 
    mutate(
      dbh = NA, 
      action = "install band on new stem: biweekly"
    ) %>% 
    select(tag, stemtag, sp, quadrat, dbh, dbh18, action),
  # Biannual bands to install:
  census_2018 %>% 
    filter(tag_stemtag %in% c(biannual_sample)) %>% 
    mutate(
      dbh = NA, 
      action = "install band on new stem: biannual"
    ) %>% 
    select(tag, stemtag, sp, quadrat, dbh, dbh18, action)
) %>% 
  arrange(action, quadrat, tag, stemtag) %>% 
  write_csv("resources/raw_data/2021/identifying_stems_with_issues/action_item_list.csv")


action_item_list_backup_stems <- bind_rows(
  # Biweekly bands to install:
  census_2018 %>% 
    filter(tag_stemtag %in% c(biweekly_sample_backup)) %>% 
    mutate(
      dbh = NA, 
      action = "install band on new stem: biweekly"
    ) %>% 
    select(tag, stemtag, sp, quadrat, dbh, dbh18, action),
  # Biannual bands to install:
  census_2018 %>% 
    filter(tag_stemtag %in% c(biannual_sample_backup)) %>% 
    mutate(
      dbh = NA, 
      action = "install band on new stem: biannual"
    ) %>% 
    select(tag, stemtag, sp, quadrat, dbh, dbh18, action)
) %>% 
  arrange(sp, dbh18)

# action_item_list_backup_stems %>% 
#   write_csv("resources/raw_data/2021/identifying_stems_with_issues/action_item_list_backup_stems.csv")











## Identify stems to install new bands on (second round) -----
set.seed(76)

# Stems originally marked for new band installation that were found to be
# dead by Jess on 2022/3/2
sampled_stems_found_dead <- census_2018 %>% 
  filter(tag_stemtag %in% c("92140-1", "92520-1", "122017-1", "20572-1", "190755-1")) %>% 
  mutate(
    biweekly = tag_stemtag %in% biweekly_sample,
    biannual = tag_stemtag %in% biannual_sample
  )

# Show these 4 stems were in sampling pool:
census_2018 %>% 
  filter(tag_stemtag %in% sampled_stems_found_dead$tag_stemtag)

# Load mortality census info
all_dead_stems_mort <- 
  "https://raw.githubusercontent.com/SCBI-ForestGEO/SCBImortality/main/data/allmort.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
  filter(current_year_status %in% c("D", "DC", "DN", "DS")) %>% 
  mutate(tag_stemtag = str_c(tag, StemTag, sep = "-"))

# Remove dead stems from sampling pool
census_2018 <- census_2018 %>% 
  filter(!tag_stemtag %in% all_dead_stems_mort$tag_stemtag)

# Show these 4 stems are no longer in sampling pool:
census_2018 %>% 
  filter(tag_stemtag %in% sampled_stems_found_dead$tag_stemtag)

sampled_stems_found_dead


bind_rows(
  census_2018 %>%
    filter(sp == "ulru", between(dbh18, 94, 114)) %>% 
    sample_n(5) %>% 
    mutate(replacement_for = 20572),
  census_2018 %>%
    filter(sp == "cato", between(dbh18, 50, 70)) %>% 
    sample_n(5) %>% 
    mutate(replacement_for = 92140),
  census_2018 %>%
    filter(sp == "ceca", between(dbh18, 48, 68)) %>% 
    sample_n(5) %>% 
    mutate(replacement_for = 92520),
  census_2018 %>%
    filter(sp == "ceca", between(dbh18, 109, 129)) %>% 
    sample_n(5) %>% 
    mutate(replacement_for = 122017),
  census_2018 %>%
    filter(sp == "ulru", between(dbh18, 128, 148)) %>% 
    sample_n(5) %>% 
    mutate(replacement_for = 190755)
) %>% 
  select(replacement_for, everything()) %>% 
  group_by(replacement_for) %>% 
  arrange(quadrat, .by_group = TRUE) %>% 
  write_csv("resources/raw_data/2021/identifying_stems_with_issues/action_item_list_backup_stems_2.csv")






# 4. Make blank spring 2022 field form based on Fall 2021 form ----
## Load data -----
# Load temporary blank spring 2022 field form
spring2022_field_form <- here("resources/raw_data/2021/identifying_stems_with_issues/data_entry_biannual_spr2022_BLANK.csv") %>% 
  read_csv(show_col_types = FALSE)

# Load action item list
action_item_list <- here("resources/raw_data/2021/identifying_stems_with_issues/action_item_list.csv") %>% 
  read_csv(show_col_types = FALSE) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))


# Load Jess Shue's fixes
data_entry_fix_2022 <- 
  bind_rows(
    here("resources/raw_data/2022/data_entry_fix_2022.csv") %>% read_csv(show_col_types = FALSE),
    here("resources/raw_data/2022/data_entry_fix_2022-01.csv") %>% read_csv(show_col_types = FALSE),
  ) %>% 
  mutate(
    location = ifelse(location == "S", "South", "North"),
    area = NA
  ) %>% 
  # Note the order of these variables was decided here:
  # https://github.com/SCBI-ForestGEO/Dendrobands/issues/90
  select(
    # Variables identifying stem:
    tag, stemtag, sp, dbh = dbh18, 
    # Location variables:
    quadrat, lx, ly, area, location,
    # Temp
    action
  ) %>% 
  mutate(
    # Measured variables:
    previous_measure = NA, measure = "", measure_verified = "", crown.condition = "", crown.illum = "", new.band = "", codes = "", notes = "", 
    # Variables with values that won't vary within one survey:
    survey.ID = NA, year = NA, month = NA, day = NA, field.recorders = "", data.enter = ""
  ) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))


## Identify stems that have changed between Fall 2021 and Spring 2022 ----
dead_stems <- action_item_list %>% 
  filter(action == "retrieve band: stem dead") %>% 
  pull(tag_stemtag)
dropped_stems <- action_item_list %>% 
  filter(action == "retrieve band: band issue, stem dropped from database") %>% 
  pull(tag_stemtag)
new_band <- data_entry_fix_2022 %>% 
  filter(action == "reband stem") %>% 
  pull(tag_stemtag)
new_stems <- data_entry_fix_2022 %>% 
  filter(str_sub(action, 1, nchar("install band on new stem")) == "install band on new stem") %>% 
  select(-c(action, tag_stemtag)) %>% 
  mutate(new.band = 1)


# Sanity check:
data_fix_new_stems <- new_stems %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>% 
  select(tag_stemtag) 
action_item_list_new_stems <- action_item_list %>% 
  filter(str_sub(action, 1, nchar("install band on new stem")) == "install band on new stem") %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>% select(tag_stemtag) 
anti_join(action_item_list_new_stems, data_fix_new_stems)


## Write new blank Spring 2022 form ----
spring2022_field_form_new <- spring2022_field_form %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>% 
  filter(!tag_stemtag %in% dead_stems) %>% 
  filter(!tag_stemtag %in% dropped_stems) %>% 
  mutate(new.band = ifelse(tag_stemtag %in% new_band, 1, 0)) %>% 
  bind_rows(new_stems) %>% 
  mutate(
    # Measured variables:
    measure = "", measure_verified = "", crown.condition = "", crown.illum = "",  codes = "", notes = "", 
    # Variables with values that won't vary within one survey:
    survey.ID = 2022.01, year = 2022, month = 3, day = "", field.recorders = "", data.enter = ""
  ) %>% 
  select(-tag_stemtag) %>% 
  mutate(codes = ifelse(tag == 190694, "BA", codes)) %>% 
  mutate(
    # Assign areas based on quadrats
    area = case_when(
      quadrat %in% c(1301:1303, 1401:1404, 1501:1515, 1601:1615, 1701:1715, 1801:1815, 1901:1915, 2001:2015) ~ 1,
      quadrat %in% c(404:405, 504:507, 603:609, 703:712, 803:813, 901:913, 915, 1003:1012, 1101:1112, 1113, 1201:1212, 1304:1311, 1405:1411) ~ 2,
      quadrat %in% c(101:115, 201:215, 301:315, 401:403, 406:415, 502, 512:515, 610,611,614,615,701,702,713,715,801,1001,1013,1014,1215,1313,1314,1315,1413,1415) ~ 3,
      quadrat %in% c(116:132, 216:232, 316:332, 416:432, 516:532, 616:624, 716:724, 816:824) ~ 4,
      quadrat %in% c(916:924, 1016:1024, 1116:1124, 1216:1224, 1316:1324, 1416:1418,1420:1424) ~ 5,
      quadrat %in% c(1419, 1516:1524, 1616:1624, 1716:1724, 1816:1824, 1916:1924, 2016:2024) ~ 6,
      quadrat %in% c(625:632, 725:732, 825:832, 925:932, 1025:1029,1031,1032) ~ 7,
      quadrat %in% c(1030, 1125:1132, 1225:1232, 1325:1332, 1425:1432) ~ 8,
      quadrat %in% c(1525:1532, 1625:1632, 1725:1732, 1825:1832, 1925:1932, 2025:2032) ~ 9
    ),
    # Special cases
    area = ifelse(tag == 70579, 2, area),
    area = ifelse(quadrat == 714 & tag != 70579, 3, area)
  ) %>% 
  arrange(area, quadrat, tag, stemtag) %>% 
  select(
    tag, stemtag, sp, dbh, quadrat, lx, ly, area, 
    location, previous_measure, new.band, measure, measure_verified, 
    crown.condition, crown.illum, codes, notes, 
    survey.ID, year, month, day, field.recorders, data.enter
  )

# write_csv(spring2022_field_form_new, file = "resources/raw_data/2021/identifying_stems_with_issues/data_entry_biannual_spr2022_BLANK_version_2.csv")




# 5. Update dendroID.csv ----
## Get all fixes that occured in Spring ----
data_entry_fix_2022 <- 
  bind_rows(
    here("resources/raw_data/2022/data_entry_fix_2022.csv") %>% read_csv(show_col_types = FALSE),
    here("resources/raw_data/2022/data_entry_fix_2022-01.csv") %>% read_csv(show_col_types = FALSE),
  ) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) 

## Sanity check: Reconcile all data_entry_fix actions with Google Sheet ----
data_entry_fix_2022 %>% 
  count(action)
# install band on new stem: biannual matches N24 in Google Sheet = 30. YES
# install band on new stem: biweekly matches G24 in Google Sheet = 6. YES
# retrieve band: band issue, stem dropped from database should match sum of yellow cells in Google Sheet. NOT DONE YET.
# reband stem: should match F24 + M24 = 12 + 4 = 16, but there are 19. NO these 19-16=3 are it:
unidentified_reband_stems <- anti_join(
  data_entry_fix_2022 %>% filter(action == "reband stem") %>% select(tag_stemtag),
  action_item_list %>% filter(action == "reband stem") %>% select(tag_stemtag),
  by = "tag_stemtag"
) %>% 
  pull(tag_stemtag)

# Ask Jess about these:
data_entry_fix_2022 %>% 
  filter(tag_stemtag %in% unidentified_reband_stems) %>% 
  select(tag, sp, action, new.band, codes, intraannual, notes)

# Resolution: Based on meeting with Jess Shue on 2022/3/31
# -92140 is only a tag issue (marked in resources/raw_data/2021/identifying_stems_with_issues/tag_issue.csv)
# -30233 and 190115 should be marked as BA in the spring survey sheet


## Sanity check: Reconcile "reband stem" data_entry_fix actions with Google Sheet ----
# These counts should match purple columns F & M in Google Sheet:
data_entry_fix_2022 %>% 
  filter(action == "reband stem") %>% 
  count(intraannual, sp) %>% 
  pivot_wider(names_from = intraannual, values_from = n) %>% 
  arrange(factor(sp, levels = master_list$sp)) %>% 
  select(sp, `1`, `0`)

# We have:
# +1 fagr biweekly
# +1 litu biannual
# +1 cato biannual
# which are unidentified_reband_stems above

## Sanity check: Drill down on new.band and "reband stem" ----
data_entry_fix_2022 %>% 
  filter(action == "reband stem") %>% 
  count(new.band)

# On top of unidentified_reband_stems (action item one), we have the following
# three reband stem with new.band = 0
# Ask Jess about these:
data_entry_fix_2022 %>% 
  filter(action == "reband stem") %>% 
  filter(new.band == 0) %>% 
  select(tag_stemtag, sp, action, new.band, codes, intraannual, notes) %>% 
  filter(!tag_stemtag %in% unidentified_reband_stems)

# Resolution: Based on meeting with Jess Shue on 2022/3/31
# -40465 needs new tag (added to resources/raw_data/2021/identifying_stems_with_issues/tag_issue.csv)
# -All stems with codes = F need to be cataloged as inside deer exclosure
# -100771 and 190413 should be marked as BA in the spring survey sheet


## Sanity check: Reconcile "new band" data_entry_fix actions with Google Sheet ----
# These counts should match purple columns G & N in Google Sheet.
data_entry_fix_2022 %>% 
  filter(action %in% c("install band on new stem: biannual", "install band on new stem: biweekly")) %>% 
  count(intraannual, sp) %>% 
  pivot_wider(names_from = intraannual, values_from = n) %>% 
  arrange(factor(sp, levels = master_list$sp)) %>% 
  select(sp, `1`, `0`)

# We have
# + 1 biannual cato
# - 1 biannual ulru
data_entry_fix_2022 %>% 
  filter(action %in% c("install band on new stem: biannual", "install band on new stem: biweekly")) %>% 
  filter(sp %in% c("cato", "ulru"))
action_item_list %>% 
  filter(action == "install band on new stem: biannual") %>% 
  filter(sp %in% c("cato", "ulru"))

# Conclusion: Was there a mix up?
# Resolution: Based on meeting with Jess Shue on 2022/3/31
# This mix-up was very likely and understandable. Leave them as is.


## Write updated dendroID.csv -----
dendroID <- here("data/dendroID.csv") %>%
  read_csv(show_col_types = FALSE)

dendroID_bands_to_add <- data_entry_fix_2022 %>% 
  # This includes bands installed on new stems and bands replaced on 
  # existing stems
  filter(new.band == 1) %>% 
  mutate(
    dendDiam = dendDiam.mm, 
    dbh = dbh18, 
    dir = NA, 
    dendHt = dendHt.m, 
    crown.condition = NA, 
    crown.illum = NA, 
    lianas = NA, 
    measureID = NA
  ) 

dendroID <- dendroID_bands_to_add %>%
  select(
    tag, stemtag, survey.ID, biannual, intraannual, sp,
    quadrat, stemID, treeID,
    dendDiam, dbh, new.band,
    dendroID, type, dir,
    dendHt, crown.condition, crown.illum, lianas, measureID
  ) %>%
  bind_rows(dendroID) %>% 
  arrange(tag, stemtag)

# write_csv(dendroID, file = "data/dendroID.csv", quote = "all")



# 6. Update master CSV ----
## New stems and replaced bands ----
new_bands <- data_entry_fix_2022 %>% 
  filter(action %in% c("install band on new stem: biannual", "install band on new stem: biweekly")) %>% 
  mutate(
    survey.ID = NA, year = NA, month = NA, day = NA,
    measure = NA, codes = NA, notes = NA, status = NA,
    field.recorders = NA, data.enter = NA,
    dendDiam = NA, dendDiam = dendDiam.mm, 
    dbh = dbh18, 
    new.band = NA, dir = NA, 
    dendHt = dendHt.m, 
    crown.condition = NA, crown.illum = NA, lianas = NA, measureID = NA
  ) %>% 
  select(
    tag, stemtag, survey.ID, year, month, day, biannual, 
    intraannual, sp, quadrat, lx, ly, measure, codes, 
    notes, status, field.recorders, data.enter, stemID, 
    treeID, dendDiam, dbh, new.band, dendroID, type, 
    dir, dendHt, crown.condition, crown.illum, lianas, 
    measureID
  ) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))

replaced_bands <- data_entry_fix_2022 %>% 
  filter(action == "reband stem" & new.band == 1) %>% 
  mutate(
    survey.ID = NA, year = NA, month = NA, day = NA,
    measure = NA, codes = NA, notes = NA, status = NA,
    field.recorders = NA, data.enter = NA,
    dendDiam = NA, dendDiam = dendDiam.mm, 
    dbh = dbh18, 
    new.band = NA, dir = NA, 
    dendHt = dendHt.m, 
    crown.condition = NA, crown.illum = NA, lianas = NA, measureID = NA
    ) %>% 
  select(
    tag, stemtag, survey.ID, year, month, day, biannual, 
    intraannual, sp, quadrat, lx, ly, measure, codes, 
    notes, status, field.recorders, data.enter, stemID, 
    treeID, dendDiam, dbh, new.band, dendroID, type, 
    dir, dendHt, crown.condition, crown.illum, lianas, 
    measureID
  ) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))
  
## Drop dead stems and stems to drop from database, add new stems ----
master_2022_sheet <- here("resources/raw_data/2021/identifying_stems_with_issues/scbi.dendroAll_BLANK.csv") %>% 
  read_csv(show_col_types = FALSE) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-")) %>% 
  # 1. Remove dead stems.
  # Number of remaining rows should be sum of columns C, D, E, J, K, L = 496
  # WE'RE GOOD!
  filter(!tag_stemtag %in% dead_tag_stemtag) %>% 
  # 2. Drop stems removed from database to bring total down to 500.
  # Number of stems to drop should be sum of yellow cells = 32
  # thus number of remaining rows should be 496 - 32 = 464
  # WE'RE GOOD!
  filter(!tag_stemtag %in% stems_to_retrieve) %>% 
  # 3. Add new stems
  # Number of rows added should be sum of columns G, N
  # WE'RE ALMOST GOOD (note above potential mix up between biannual cato and ulru)
  bind_rows(new_bands) %>% 
  # 4. Update rows for rebanded stems
  filter(!tag_stemtag %in% replaced_bands$tag_stemtag) %>% 
  bind_rows(replaced_bands)

## Sanity check: Check for duplicate entries ----
master_2022_sheet %>% 
  count(tag_stemtag) %>% 
  filter(n > 1)



## Make sure autodendrometer tags are biweekly ----
autodendrometer_tags <- 
  "https://raw.githubusercontent.com/SCBI-ForestGEO/AutoDendrometers/main/data/PointDendrometerTrees.csv" %>% 
  read_csv(show_col_types = FALSE) %>% 
  select(tag) %>% 
  arrange(tag)

# Check if all biweekly:
master_2022_sheet %>% 
  filter(tag %in% autodendrometer_tags$tag) %>% 
  select(tag, sp, intraannual) %>% 
  arrange(tag)

# Need to switch 91486 to biweekly:
master_2022_sheet <- master_2022_sheet %>% 
  mutate(intraannual = ifelse(tag == 91486, 1, intraannual))

# Update numbers of biweekly/biannual switches
master_list <- master_list %>% 
  mutate(biweekly_shift_to_biannual = ifelse(sp == "cagl", biweekly_shift_to_biannual + 1, biweekly_shift_to_biannual))

# Check if all biweekly:
master_2022_sheet %>% 
  filter(tag %in% autodendrometer_tags$tag) %>% 
  select(tag, sp, intraannual) %>% 
  arrange(tag)

# Sanity check with Google sheet
master_2022_sheet %>% 
  group_by(intraannual, sp) %>% 
  count() %>% 
  pivot_wider(names_from = "intraannual", values_from = "n", values_fill = 0) %>% 
  arrange(factor(sp, levels = master_list$sp)) %>% 
  select(sp, `1`, `0`)



## Identify stems to shift between biweekly and biannual ----
# Should match positive values in Column O, except autodendrometer 91486 cagl
shift_biweekly_to_biannual_numbers <- master_list %>% 
  filter(biweekly_shift_to_biannual>0) %>% 
  mutate(n = biweekly_shift_to_biannual) %>% 
  select(sp, n)
# Should match positive values in Column H, except autodendrometer 91486 cagl
shift_biannual_to_biweekly_numbers <- master_list %>% 
  filter(biweekly_shift_to_biannual<0) %>% 
  mutate(n = -biweekly_shift_to_biannual) %>% 
  select(sp, n)

# Identify length of time records of all stems
tag_stemtag_record_lengths <- 
  # Load and combine all 2021 recordings:
  here("data") %>% 
  dir(path = ., pattern = "scbi.dendroAll", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols("day" = col_integer(), "month" = col_integer()), show_col_types = FALSE) %>% 
  mutate(
    tag_stemtag = str_c(tag, stemtag, sep = "-"),
    date = ymd(str_c(year, month, day, sep = "-"))
  ) %>% 
  # Only those stems still in 2022 data base:
  filter(tag_stemtag %in% master_2022_sheet$tag_stemtag) %>% 
  group_by(tag, stemtag, intraannual, sp) %>%
  # Compute number of days of records:
  summarize(min_date = min(date, na.rm = TRUE), max_date = max(date, na.rm = TRUE)) %>% 
  mutate(
    ndays = max_date - min_date,
    ndays = as.numeric(ndays)
  ) %>% 
  select(tag, stemtag, intraannual, sp, ndays) %>% 
  group_by(sp) %>% 
  arrange(ndays, .by_group = TRUE) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))

# Shift stems with shortest records from biweekly to biannual
shift_biweekly_to_biannual <- NULL
for(i in 1:nrow(shift_biweekly_to_biannual_numbers)){
  shift_biweekly_to_biannual <- tag_stemtag_record_lengths %>% 
    filter(intraannual == 1, sp %in% shift_biweekly_to_biannual_numbers$sp[i]) %>% 
    arrange(ndays) %>% 
    slice(1:shift_biweekly_to_biannual_numbers$n[i]) %>% 
    select(sp, tag_stemtag) %>% 
    bind_rows(shift_biweekly_to_biannual)
}

# Should match positive values in Column O, except autodendrometer 91486 cagl
shift_biweekly_to_biannual %>% 
  count(sp) %>% 
  arrange(factor(sp, levels = master_list$sp))

# Shift stems with longest records from biannual to biweekly
shift_biannual_to_biweekly <- NULL
for(i in 1:nrow(shift_biannual_to_biweekly_numbers)){
  shift_biannual_to_biweekly <- tag_stemtag_record_lengths %>% 
    filter(intraannual == 0, sp %in% shift_biannual_to_biweekly_numbers$sp[i]) %>% 
    arrange(desc(ndays)) %>% 
    slice(1:shift_biannual_to_biweekly_numbers$n[i]) %>% 
    select(sp, tag_stemtag) %>% 
    bind_rows(shift_biannual_to_biweekly)
}

# Should match positive values in Column H, except autodendrometer 91486 cagl
shift_biannual_to_biweekly %>% 
  count(sp) %>% 
  arrange(factor(sp, levels = master_list$sp))


## Switch stems between biweekly and biannual ----
master_2022_sheet <- master_2022_sheet %>% 
  mutate(
    intraannual = ifelse(tag_stemtag %in% shift_biannual_to_biweekly$tag_stemtag, 1, intraannual),
    intraannual = ifelse(tag_stemtag %in% shift_biweekly_to_biannual$tag_stemtag, 0, intraannual)
  ) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))


## FINAL Sanity check: with Google sheet -----
master_2022_sheet %>% 
  group_by(intraannual, sp) %>% 
  count() %>% 
  pivot_wider(names_from = "intraannual", values_from = "n", values_fill = 0) %>% 
  arrange(factor(sp, levels = master_list$sp)) %>% 
  select(sp, `1`, `0`)

# Should match columns I and P. Differences are all accounted for:
# Biweekly:
# +1 cagl: autodendrometer 91486 cagl later switched to biweekly
# -1 cato: Mix up in sp in https://github.com/SCBI-ForestGEO/Dendrobands/pull/33
# +1 caco: Mix up in sp in https://github.com/SCBI-ForestGEO/Dendrobands/pull/33
# -1 caovl: Mix up in sp in https://github.com/SCBI-ForestGEO/Dendrobands/pull/33
# Net = +0
#
# Biannual:
# +1 cagl: autodendrometer 91486 cagl later switched to biweekly
# +1 cato: Biannual new band on new stem mix-up acknowledged by Jess 
# +1 cato: Mix up in sp in https://github.com/SCBI-ForestGEO/Dendrobands/pull/33
# -1 caco: Mix up in sp in https://github.com/SCBI-ForestGEO/Dendrobands/pull/33
# +1 caovl: Mix up in sp in https://github.com/SCBI-ForestGEO/Dendrobands/pull/33
# -1 ulru: Biannual new band on new stem mix-up acknowledged by Jess
# Net = 0


## Write updated master CSV ----
# Clear columns (code modified from Ian's Rscripts/survey_forms/new_scbidendroAll_[YEAR].R)
variables_to_reset <- c(
  "survey.ID", "year", "month", "day", "measure", "codes", "notes", 
  "status", "field.recorders", "data.enter", "new.band", 
  "crown.condition", "crown.illum"
)
master_2022_sheet[, variables_to_reset] <- ""

master_2022_sheet %>%
  select(-tag_stemtag) %>%
  write_csv(file = "data/scbi.dendroAll_BLANK.csv")


# 7. Retroactively update spring biannual form with results from data_entry_fix forms -----
spring_biannual <- read_csv("resources/raw_data/2022/data_entry_biannual_spr2022.csv")

# Field fixes
data_entry_fix_2022 <- 
  bind_rows(
    here("resources/raw_data/2022/data_entry_fix_2022.csv") %>% read_csv(show_col_types = FALSE),
    here("resources/raw_data/2022/data_entry_fix_2022-01.csv") %>% read_csv(show_col_types = FALSE),
  ) %>% 
  mutate(tag_stemtag = str_c(tag, stemtag, sep = "-"))

## code == BA ----
data_entry_fix_2022 %>% 
  filter(str_detect(codes, "BA")) %>% 
  pull(tag)

## new.band == 1 ----
A <- spring_biannual %>% 
  filter(new.band == 1) %>% 
  select(tag, stemtag)
B <- data_entry_fix_2022 %>% 
  filter(new.band == 1) %>% 
  select(tag, stemtag)

# Here
# 40465: replace tag; band fine
# 121301: TODO Ask jess about spring biannual code: 116.88; old band removed
anti_join(A, B, by = c("tag", "stemtag"))

# Here
# TODO: 6 new stems have to be marked as new.band = 1 in first biweekly
anti_join(B, A, by = c("tag", "stemtag"))

