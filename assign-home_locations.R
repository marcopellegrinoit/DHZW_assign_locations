library(readr)
library(dplyr)
library(tidyr)
library(this.path)

################################################################################
# Load datasets

# load synthetic population activity schedule
setwd(this.dir())
setwd('../DHZW_assign-activities/data/processed/')
df_activities <- read.csv('df_synthetic_activities.csv')

# load synthetic population
setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50/')
df_synth_pop <- read.csv('synthetic_population_DHZW_2019.csv')

# load home locations
setwd(this.dir())
setwd('../DHZW_locations/data/output')
df_homes <- read.csv('df_households_minimal.csv')
df_homes <- df_homes %>%
  select(hh_ID, lid)

################################################################################
# Merge

df_synth_pop <- df_synth_pop %>%
  select(agent_ID, hh_ID)

df_activities <- merge(df_activities, df_synth_pop, by = 'agent_ID')
df_activities <- merge(df_activities, df_homes, by = 'hh_ID')

df_activities$in_DHZW = NA
df_activities[df_activities$activity_type == 'home',]$in_DHZW = 1
df_activities[!(df_activities$activity_type == 'home'),]$lid = NA

# save 
setwd(this.dir())
setwd('data/output')
write.csv(df_activities, 'df_synthetic_activities.csv', row.names = FALSE)