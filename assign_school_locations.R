library(readr)
library(dplyr)
library(this.path)
library(sf)
library(plyr)
library(data.table)

################################################################################
# Load datasets

# load synthetic population activity schedule
setwd(this.dir())
setwd('data/')
df_activities <- read.csv('df_synthetic_activities.csv')

# load synthetic population
setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50/')
df_synth_pop <- read.csv('synthetic_population_DHZW_2019.csv')

# load school buildings
setwd(this.dir())
setwd('../DHZW_locations/location_folders/schools/data')
df_school_locations <- st_read('schools_DHZW')

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('../DHZW_synthetic-population/data/shapefiles/raw')
df_PC6_geometries <- st_read('CBS-PC6-2019-v2')
df_PC6_geometries <- df_PC6_geometries[df_PC6_geometries$PC6 %in% unique(df_synth_pop$PC6),]
df_PC6_geometries <- st_transform(df_PC6_geometries, "+proj=longlat +datum=WGS84")
df_PC6_geometries <- st_centroid(df_PC6_geometries)
df_PC6_geometries = subset(df_PC6_geometries, select = c('PC6'))

################################################################################
# Assign to each individual its home point
df_coordinates <- data.frame(st_coordinates(df_PC6_geometries$geometry))
colnames(df_coordinates) <- c('longitude', 'latitude')
df_PC6_geometries = cbind(df_PC6_geometries, df_coordinates)
df_PC6_geometries <- data.frame(df_PC6_geometries)

df_synth_pop <- merge(df_synth_pop, df_PC6_geometries, by='PC6')
df_synth_pop <- df_synth_pop %>%
  dplyr::select(agent_ID, age, PC6, longitude, latitude)

################################################################################
# Assign to each individuals its closest school based on the age

# function to retrieve the closest school for one agent
get_closest_school <- function(df){
  df_schools <- df_school_locations[df_school_locations$category == df$category,]
  dt <- data.table((df_schools$longitude-df$longitude)^2+(df_schools$latitude-df$latitude)^2)
  dt <- cbind(dt, df_schools)
  return(dt[which.min(dt$V1)]$lid)}

# daycare
df_synth_pop$category <- NA
df_synth_pop[df_synth_pop$age <= 5,]$category <- 'daycare'
df_synth_pop_daycare <- adply(.data = df_synth_pop[df_synth_pop$age <= 5,], .margins = 1, .fun = get_closest_school)

# primary school
df_synth_pop[df_synth_pop$age >= 6 & df_synth_pop$age <= 11,]$category <- 'primary_school'
df_synth_pop_primary <- adply(.data = df_synth_pop[df_synth_pop$age >= 6 & df_synth_pop$age <= 11,], .margins = 1, .fun = get_closest_school)

# secondary school
df_synth_pop[df_synth_pop$age >= 12 & df_synth_pop$age <= 18,]$category <- 'highschool'
df_synth_pop_highschool <- adply(.data = df_synth_pop[df_synth_pop$age >= 12 & df_synth_pop$age <= 18,], .margins = 1, .fun = get_closest_school)

# university. no buildings in DHZW
df_synth_pop_university <- df_synth_pop[df_synth_pop$age >= 19,]
df_synth_pop_university$V1 <- 'outside_DHZW'

# put agents back together
df_synth_pop <- rbind(df_synth_pop_daycare, df_synth_pop_primary, df_synth_pop_highschool, df_synth_pop_university)
df_synth_pop <- df_synth_pop %>%
  dplyr::rename('school_lid' = V1)

################################################################################
# Assign the individual's school to their activities

# Flag agents that go to school
df_tmp_activities <- df_activities %>%
  select(agent_ID, activity_type) %>%
  filter(activity_type == 'school') %>%
  distinct()
df_synth_pop$goes_to_school = FALSE
df_synth_pop[df_synth_pop$agent_ID %in% df_tmp_activities$agent_ID,]$goes_to_school <- TRUE
df_synth_pop <- df_synth_pop %>%
  filter(goes_to_school == TRUE) %>%
  select(agent_ID, school_lid)

# merge the school from the population datasets to their school activities
df_activities <- left_join(df_activities, df_synth_pop, by = 'agent_ID')
df_activities[df_activities$activity_type == 'school',]$lid <- df_activities[df_activities$activity_type == 'school',]$school_lid
df_activities <- subset(df_activities, select=-c(school_lid))

################################################################################
# save
setwd(this.dir())
setwd('data/')
write.csv(df_activities, 'df_synthetic_activities.csv', row.names = FALSE)