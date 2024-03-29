library(readr)
library(dplyr)
library(this.path)
library(sf)

################################################################################
# Load datasets

# Load PC4 proportion destinations
setwd(this.dir())
setwd('data/processed')
df_work_prop <- read.table('ODiN_work.csv', check.names=FALSE, sep = ',', header = TRUE)

# load synthetic population activity schedule
setwd(this.dir())
setwd('data/')
df_activities <- read.csv('df_synthetic_activities.csv')

# load synthetic population
setwd(this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households/4_car_2022-12-26_15-50/')
df_synth_pop <- read.csv('synthetic_population_DHZW_2019.csv')
df_synth_pop$PC4 = gsub('.{2}$', '', df_synth_pop$PC6)
df_synth_pop <- df_synth_pop %>%
  select(agent_ID, PC4)

df_activities <- merge(df_activities, df_synth_pop, by = 'agent_ID')

# load work locations
setwd(this.dir())
setwd('../DHZW_locations/data/output')
df_work_locations <- read.csv('work_DHZW.csv')

# Load PC4 vectorial coordinates and compute their centroids
setwd(this.dir())
setwd('../DHZW_shapefiles/data/processed/shapefiles')
df_PC4 <- st_read('centroids_PC4_DHZW_shp')

################################################################################
# add a flag to the synthetic agents that have at least one work activity

df_tmp_activities <- df_activities %>%
  select(agent_ID, activity_type) %>%
  filter(activity_type == 'work') %>%
  distinct()
df_synth_pop$is_working = FALSE
df_synth_pop[df_synth_pop$agent_ID %in% df_tmp_activities$agent_ID,]$is_working <- TRUE

################################################################################
# add the PC4 of the working location based on ODiN proportions

df_synth_pop$PC4_work <- NA
for (PC4 in unique(df_synth_pop$PC4)) {
  print(PC4)
  
  # get activities of people that live in such PC4
  PC4_agent_IDs <- df_synth_pop[df_synth_pop$PC4 == PC4, ]$agent_ID

  df_prop_PC4 <- df_work_prop[df_work_prop$hh_PC4 == PC4, ]
  
  df_synth_pop[df_synth_pop$agent_ID %in% PC4_agent_IDs &
                 df_synth_pop$is_working == TRUE, ] <-
    df_synth_pop[df_synth_pop$agent_ID %in% PC4_agent_IDs &
                   df_synth_pop$is_working == TRUE, ] %>%
    mutate(PC4_work = sample(
      colnames(df_prop_PC4[,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
      size = n(),
      prob = as.numeric(df_prop_PC4[1,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
      replace = TRUE
    ))
}

# Mark if the work is in DHZW. If so, in the next step we look for the closest real schools
setwd(this.path::this.dir())
setwd('../DHZW_shapefiles/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1
df_synth_pop$work_in_DHZW <- NA
df_synth_pop[df_synth_pop$is_working==TRUE,]$work_in_DHZW <- 0
df_synth_pop[df_synth_pop$is_working==TRUE & df_synth_pop$PC4_work %in% DHZW_PC4_codes,]$work_in_DHZW <- 1

################################################################################
# add the work location inside each PC4

df_synth_pop$work_lid <- NA
for (PC4 in unique(df_synth_pop[df_synth_pop$is_working == TRUE, ]$PC4_work)) {
  print(PC4)
  if ((PC4 %in% DHZW_PC4_codes)) {
    # get locations in such area
    df_locations_PC4 <-
      df_work_locations[df_work_locations$PC4 == PC4, ]
    
    # if there are no locations in such area, calculate the closest PC4 and look there
    original_PC4 <-
      PC4 # save the original PC4 in which the location would be. We needed it later to assign to such rows the random location
    list_PC4_tried <- c() # list of PC4 tried
    PC4_point <-
      df_PC4[df_PC4$PC4 == original_PC4, ]  # centroid of the original PC4
    while (nrow(df_locations_PC4) == 0) {
      #if there are no locations in the searched PC4, look into the next closest one
      list_PC4_tried <-
        append(list_PC4_tried, PC4) # add the just searched PC4
      print(paste(PC4, nrow(df_locations_PC4)), sep = ' ')
      df_PC4$distance <-
        as.numeric(st_distance(df_PC4, PC4_point)) # calculate the distance to all the PC4
      df_PC4[df_PC4$PC4 %in% list_PC4_tried, ]$distance <-
        NA # eliminate the subject PC4 and the tried ones
      PC4 <-
        df_PC4[which.min(df_PC4$distance), ]$PC4  # extract the next closest PC4
      df_locations_PC4 <-
        df_work_locations[df_work_locations$PC4 == PC4, ]  # retrieve locations in the new PC4
    }
    
    print(paste(PC4, nrow(df_locations_PC4)), sep = ' ')
    
    # distribute random locations of the PC4
    df_synth_pop[df_synth_pop$is_working == TRUE &
                   df_synth_pop$PC4_work == original_PC4, ]$work_lid <-
      sample(
        df_locations_PC4$lid,
        replace = TRUE,
        size = nrow(df_synth_pop[df_synth_pop$is_working == TRUE &
                                   df_synth_pop$PC4_work == original_PC4, ])
      )
    
  }
}

df_synth_pop <- df_synth_pop %>%
  filter(is_working == TRUE) %>%
  select(agent_ID, work_lid, PC4_work, work_in_DHZW)
df_synth_pop[df_synth_pop$work_in_DHZW==0,]$work_lid <- df_synth_pop[df_synth_pop$work_in_DHZW==0,]$PC4_work
df_synth_pop = subset(df_synth_pop, select = -c(PC4_work))

################################################################################
# assign the work location from the population dataframe to the activity dataframe

df_activities <- left_join(df_activities, df_synth_pop, by = 'agent_ID')
df_activities[df_activities$activity_type == 'work',]$lid <- df_activities[df_activities$activity_type == 'work',]$work_lid
df_activities[df_activities$activity_type == 'work',]$in_DHZW <- df_activities[df_activities$activity_type == 'work',]$work_in_DHZW

df_activities <- subset(df_activities, select=-c(work_lid, work_in_DHZW, PC4))

################################################################################
# check
nrow(df_activities[df_activities$activity_type=='work' & is.na(df_activities$lid),])

# save
setwd(this.dir())
setwd('data/output')
write.csv(df_activities, 'df_synthetic_activities.csv', row.names = FALSE)