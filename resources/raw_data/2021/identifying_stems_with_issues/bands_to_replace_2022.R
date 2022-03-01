#
# Preparation of new bands for 2022 season
# https://github.com/SCBI-ForestGEO/Dendrobands/issues/89
# https://github.com/SCBI-ForestGEO/Dendrobands/issues/97
#
# Google Sheet summarizing changes:
# https://docs.google.com/spreadsheets/d/1rneieQOCclZ2q-Kbxog-rzNMM6-9d7foGooTv8Xq588/edit#gid=1289938519

library(tidyverse)
library(here)
library(janitor)
library(knitr)
library(googlesheets4)

# Authenticate for Google Sheets
gs4_auth()


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
  read_csv("resources/raw_data/2021/identifying_stems_with_issues/remainders_originally_cataloged_by_jess.csv") %>% 
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
all_2021_stems <- "data/scbi.dendroAll_2021.csv" %>% 
  here() %>% 
  read_csv() %>% 
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


# Write to Google Sheets: uncomment
# master_list %>%
#   write_sheet(ss = "https://docs.google.com/spreadsheets/d/1rneieQOCclZ2q-Kbxog-rzNMM6-9d7foGooTv8Xq588/edit#gid=0", sheet = "master_list")


# Make lists of dead stems, stems to reband, new stems to install dendrobands on ------
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


## Identify stems to install new bands on -----
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
  labs(x = "dbh", title = "Distribution of dbh from census (histogram) + dendrobands (red lines)", subtitle = "For sp we need to sample for biannual")









## Collate stem info -----
# Reload data to include dead stems
all_2021_stems <- "data/scbi.dendroAll_2021.csv" %>% 
  here() %>% 
  read_csv() %>% 
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
  # Healthy stems, but won't replace band for reallocation purposes
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


bind_rows(
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
  arrange(sp, dbh18) %>% 
  write_csv("resources/raw_data/2021/identifying_stems_with_issues/action_item_list_backup_stems.csv")
