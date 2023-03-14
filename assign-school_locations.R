library(readr)
library(dplyr)
library(this.path)
library(sf)
#library(plyr)
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
setwd('../DHZW_locations/data/output')
df_school_locations <- read.csv('school_DHZW.csv')

# Load PC6 centroids of DHZW
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/csv')
df_PC6_DHZW <- read.csv('centroids_PC6_DHZW.csv')

################################################################################
# mark if the agent has at least one school activity
df_tmp_activities <- df_activities %>%
  select(agent_ID, activity_type) %>%
  filter(activity_type == 'school') %>%
  distinct()
df_synth_pop <- df_synth_pop[df_synth_pop$agent_ID %in% df_tmp_activities$agent_ID,]

################################################################################
# for the agents that go to school, calculate from ODiN to what PC4 they go to school. Based on their age group

df_synth_pop$age_school <- NA
df_synth_pop[df_synth_pop$age <= 5,]$age_school <- 'daycare'
df_synth_pop[df_synth_pop$age >= 6 & df_synth_pop$age <= 11,]$age_school <- 'primary_school'
df_synth_pop[df_synth_pop$age >= 12 & df_synth_pop$age <= 18,]$age_school <- 'highschool'
df_synth_pop[df_synth_pop$age >= 19,]$age_school <- 'university'

setwd(this.dir())
setwd('data/ODiN_destination_proportions')
df_school_prop_daycare <- read.csv('ODiN_school_daycare.csv', check.names=FALSE, sep = ',', header = TRUE)
df_school_prop_primary <- read.csv('ODiN_school_primary.csv', check.names=FALSE, sep = ',', header = TRUE)
df_school_prop_highschool <- read.csv('ODiN_school_highschool.csv', check.names=FALSE, sep = ',', header = TRUE)
df_school_prop_university <- read.csv('ODiN_school_university.csv', check.names=FALSE, sep = ',', header = TRUE)
df_synth_pop$PC4 = gsub('.{2}$', '', df_synth_pop$PC6)

df_synth_pop$PC4_school <- NA
for (PC4 in unique(df_synth_pop$PC4)) {
  # get agents that live there that  go to school
  df_agents_in_PC4 <- df_synth_pop[df_synth_pop$PC4 == PC4,]
  df_agents_in_PC4_IDs <- df_agents_in_PC4$agent_ID
  
  # for the unique school groups in that PC4
  for (age_school in unique(df_agents_in_PC4$age_school)) {
    if (age_school=='daycare') {
      # get ODiN proportions  
      df_prop_PC4 <- df_school_prop_daycare[df_school_prop_daycare$hh_PC4 == PC4, ]
      
      # apply following ODiN proportions
      df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='daycare',] <-
        df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='daycare', ] %>%
        mutate(PC4_school = sample( 
          colnames(df_prop_PC4[,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          size = n(),
          prob = as.numeric(df_prop_PC4[1,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          replace = TRUE
        ))
    } else if (age_school=='primary_school') {
      df_prop_PC4 <- df_school_prop_primary[df_school_prop_primary$hh_PC4 == PC4, ]
      
      # apply following ODiN proportions
      df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='primary_school',] <-
        df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='primary_school', ] %>%
        mutate(PC4_school = sample( 
          colnames(df_prop_PC4[,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          size = n(),
          prob = as.numeric(df_prop_PC4[1,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          replace = TRUE
        ))
    } else if (age_school=='highschool') {
      df_prop_PC4 <- df_school_prop_highschool[df_school_prop_highschool$hh_PC4 == PC4, ]
      
      # apply following ODiN proportions
      df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='highschool',] <-
        df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='highschool', ] %>%
        mutate(PC4_school = sample( 
          colnames(df_prop_PC4[,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          size = n(),
          prob = as.numeric(df_prop_PC4[1,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          replace = TRUE
        ))
    } else {
      df_prop_PC4 <- df_school_prop_university[df_school_prop_university$hh_PC4 == PC4, ]
      
      # apply following ODiN proportions
      df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='university',] <-
        df_synth_pop[df_synth_pop$agent_ID %in% df_agents_in_PC4_IDs & df_synth_pop$age_school=='university', ] %>%
        mutate(PC4_school = sample( 
          colnames(df_prop_PC4[,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          size = n(),
          prob = as.numeric(df_prop_PC4[1,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
          replace = TRUE
        ))
    }
  }
}

# Mark if the school is in DHZW. If so, in the next step we look for the closest real schools
setwd(this.path::this.dir())
setwd('../DHZW_shapefiles/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_synth_pop$school_in_DHZW <- 0
df_synth_pop[df_synth_pop$PC4_school %in% DHZW_PC4_codes,]$school_in_DHZW <- 1

################################################################################
# Assign to each individual its home point

df_synth_pop <- merge(df_synth_pop, df_PC6_DHZW, by='PC6')
df_synth_pop <- df_synth_pop %>%
  dplyr::select(agent_ID, age_school, PC4_school, school_in_DHZW, coordinate_y, coordinate_x)

################################################################################
# Assign to each individuals its closest school based on the age

# function to retrieve the closest school for one agent
get_closest_school <- function(df){
  df_schools <- df_school_locations[df_school_locations$category == df$age_school,]
  dt <- data.table((df_schools$coordinate_y-df$coordinate_y)^2+(df_schools$coordinate_x-df$coordinate_x)^2)
  dt <- cbind(dt, df_schools)
  return(dt[which.min(dt$V1)]$lid)
}

# daycare
df_synth_pop_daycare <- df_synth_pop[df_synth_pop$age_school=='daycare' & df_synth_pop$school_in_DHZW == 1,]
df_synth_pop_daycare <- plyr::adply(.data = df_synth_pop_daycare, .margins = 1, .fun = get_closest_school)
df_synth_pop_daycare <- df_synth_pop_daycare %>%
  dplyr::rename('school_lid' = V1) %>%
  dplyr::select(agent_ID, school_lid)

# primary school
df_synth_pop_primary <- df_synth_pop[df_synth_pop$age_school=='primary_school' & df_synth_pop$school_in_DHZW == 1,]
df_synth_pop_primary <- plyr::adply(.data = df_synth_pop_primary, .margins = 1, .fun = get_closest_school)
df_synth_pop_primary <- df_synth_pop_primary %>%
  dplyr::rename('school_lid' = V1) %>%
  dplyr::select(agent_ID, school_lid)

# highschool
df_synth_pop_highschool <- df_synth_pop[df_synth_pop$age_school=='highschool' & df_synth_pop$school_in_DHZW == 1,]
df_synth_pop_highschool <- plyr::adply(.data = df_synth_pop_highschool, .margins = 1, .fun = get_closest_school)
df_synth_pop_highschool <- df_synth_pop_highschool %>%
  dplyr::rename('school_lid' = V1) %>%
  dplyr::select(agent_ID, school_lid)

df_synth_pop_real_schools <- rbind(df_synth_pop_daycare, df_synth_pop_primary, df_synth_pop_highschool)
df_synth_pop_real_schools$school_in_DHZW <- 1

################################################################################
# External locations
df_synth_pop_ext_schools <- df_synth_pop[df_synth_pop$school_in_DHZW==0,]
df_synth_pop_ext_schools <- df_synth_pop_ext_schools %>%
  dplyr::select(agent_ID, PC4_school) %>%
  rename(school_lid = PC4_school)
df_synth_pop_ext_schools$school_in_DHZW <- 0

################################################################################
df_synth_pop_to_school <- rbind(df_synth_pop_real_schools, df_synth_pop_ext_schools)

# merge the school from the population datasets to their school activities
df_activities <- left_join(df_activities, df_synth_pop_to_school, by = 'agent_ID')
df_activities[df_activities$activity_type == 'school',]$lid <- df_activities[df_activities$activity_type == 'school',]$school_lid
df_activities[df_activities$activity_type == 'school',]$in_DHZW <- df_activities[df_activities$activity_type == 'school',]$school_in_DHZW

df_activities <- subset(df_activities, select=-c(school_lid, school_in_DHZW))

################################################################################
nrow(df_activities[df_activities$activity_type=='school' & is.na(df_activities$lid),])

# save
setwd(this.dir())
setwd('data/')
write.csv(df_activities, 'df_synthetic_activities.csv', row.names = FALSE)