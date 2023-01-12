library(readr)
library(dplyr)
library(this.path)
library(sf)

assign_locations_PC4_proportions <- function (df_activities, activity_type, df_prop, df_synth_pop, df_locations, df_PC4_geometries) {
  
  # Assign PC4 locations based on proportions of where people go in ODiN
  
  df_activities$PC4_activity <- NA
  for (PC4 in unique(df_synth_pop$PC4)) {
    print(PC4)
    
    # get activities of people that live in such PC4
    PC4_agent_IDs <- df_synth_pop[df_synth_pop$PC4 == PC4, ]$agent_ID
    #  df_activities_PC4 <- df_activities[df_activities$agent_ID %in% PC4_agent_IDs,]
    
    df_prop_PC4 <-
      df_prop[df_prop$hh_PC4 == PC4, ]
    
    df_activities[df_activities$agent_ID %in% PC4_agent_IDs &
                    df_activities$activity_type == activity_type, ] <-
      df_activities[df_activities$agent_ID %in% PC4_agent_IDs &
                      df_activities$activity_type == activity_type, ] %>%
      mutate(PC4_activity = sample(
        colnames(df_prop_PC4[,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
        size = n(),
        prob = as.numeric(df_prop_PC4[1,-which(names(df_prop_PC4) %in% c('hh_PC4'))]),
        replace = TRUE
      ))
  }
  
  ################################################################################
  # For each PC4 pick a random location in it. If there are no locations in such area, look into the closest PC4
  
  for (PC4 in unique(df_activities[df_activities$activity_type == activity_type, ]$PC4_activity)) {
    print(PC4)
    if (PC4 == 'outside DHZW') {
      df_activities[df_activities$activity_type == activity_type &
                      df_activities$PC4_activity == 'outside DHZW', ]$lid <-
        'outside DHZW'
    } else {
      # get locations in such area
      df_locations_PC4 <-
        df_locations[df_locations$PC4 == PC4, ]
      
      # if there are no locations in such area, calculate the closest PC4 and look there
      original_PC4 <-
        PC4 # save the original PC4 in which the location would be. We needed it later to assign to such rows the random location
      list_PC4_tried <- c() # list of PC4 tried
      PC4_point <-
        df_PC4_geometries[df_PC4_geometries$PC4 == original_PC4, ]  # centroid of the original PC4
      while (nrow(df_locations_PC4) == 0) {
        #if there are no locations in the searched PC4, look into the next closest one
        list_PC4_tried <-
          append(list_PC4_tried, PC4) # add the just searched PC4
        print(paste(PC4, nrow(df_locations_PC4)), sep = ' ')
        df_PC4_geometries$distance <-
          as.numeric(st_distance(df_PC4_geometries, PC4_point)) # calculate the distance to all the PC4
        df_PC4_geometries[df_PC4_geometries$PC4 %in% list_PC4_tried, ]$distance <-
          NA # eliminate the subject PC4 and the tried ones
        PC4 <-
          df_PC4_geometries[which.min(df_PC4_geometries$distance), ]$PC4  # extract the next closest PC4
        df_locations_PC4 <-
          df_locations[df_locations$PC4 == PC4, ]  # retrieve locations in the new PC4
      }
      
      print(paste(PC4, nrow(df_locations_PC4)), sep = ' ')
      
      # distribute random locations of the PC4
      df_activities[df_activities$activity_type == activity_type &
                      df_activities$PC4_activity == original_PC4, ]$lid <-
        sample(
          df_locations_PC4$lid,
          replace = TRUE,
          size = nrow(df_activities[df_activities$activity_type == activity_type &
                                      df_activities$PC4_activity == original_PC4, ])
        )
      
    }
  }
  
  df_activities = subset(df_activities, select = -c(PC4, PC4_activity))
  
  return(df_activities)
}