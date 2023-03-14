library(readr)
library(dplyr)
library(this.path)
library(sf)
setwd(this.dir())
source('src/utils_assignment.R')

################################################################################
# Load datasets

# Load PC4 proportion destinations
setwd(this.dir())
setwd('data/ODiN_destination_proportions')
df_sport_prop <- read.table('ODiN_sport.csv', check.names=FALSE, sep = ',', header = TRUE)

# load synthetic population activity schedule
setwd(this.dir())
setwd('data/')
df_activities <- read.csv('df_synthetic_activities.csv')

# load synthetic population
setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50/')
df_synth_pop <- read.csv('synthetic_population_DHZW_2019.csv')
df_synth_pop$hh_PC4 = gsub('.{2}$', '', df_synth_pop$PC6)
df_synth_pop <- df_synth_pop %>%
  select(agent_ID, hh_PC4)
df_activities <- merge(df_activities, df_synth_pop, by = 'agent_ID')

# load sport locations
setwd(this.dir())
setwd('../DHZW_locations/data/output')
df_sport_locations <- read.csv('sport_DHZW.csv')

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/shapefiles')
df_PC4_geometries <- st_read('centroids_PC4_DHZW_shp')

setwd(this.path::this.dir())
setwd('../DHZW_shapefiles/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

################################################################################
# Call function that assigns locations based on the PC4 proportions

df_activities <- assign_locations_PC4_proportions(df_activities, 'sport', df_sport_prop, df_synth_pop, df_sport_locations, df_PC4_geometries, DHZW_PC4_codes)

# check
nrow(df_activities[df_activities$activity_type=='sport' & is.na(df_activities$lid),])
nrow(df_activities[df_activities$activity_type=='home' & is.na(df_activities$lid),])
nrow(df_activities[df_activities$activity_type=='work' & is.na(df_activities$lid),])
nrow(df_activities[df_activities$activity_type=='school' & is.na(df_activities$lid),])

################################################################################
# save
setwd(this.dir())
setwd('data/')
write.csv(df_activities, 'df_synthetic_activities.csv', row.names = FALSE)