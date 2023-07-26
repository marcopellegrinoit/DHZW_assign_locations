library(readr)
library(dplyr)
library(this.path)
library(sf)

assign_locations_PC4_proportions <- function (df_activities, activity_type, df_prop, df_synth_pop, df_locations, df_PC4_geometries, DHZW_PC4_codes) {
  df_activities$PC4_activity <- NA
  for (hh_PC4 in unique(df_synth_pop$hh_PC4)) {
    print(hh_PC4)
    
    # get activities of people that live in such PC4
    PC4_agent_IDs <- df_synth_pop[df_synth_pop$hh_PC4 == hh_PC4, ]$agent_ID
    #  df_activities_PC4 <- df_activities[df_activities$agent_ID %in% PC4_agent_IDs,]
    
    df_prop_PC4 <-
      df_prop[df_prop$hh_PC4 == hh_PC4, ]
    
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
  # 
  # ################################################################################
  # # For each PC4 pick a random location in it. If there are no locations in such area, look into the closest PC4

  for (PC4 in unique(df_activities[df_activities$activity_type == activity_type, ]$PC4_activity)) {
    if (PC4 %in% DHZW_PC4_codes) {
      print(PC4)
      # get locations in such area
      df_locations_PC4 <-
        df_locations[df_locations$PC4 == PC4, ]

      # if there are no locations in such area, calculate the closest PC4 and look there
      original_PC4 <-
        PC4 # save the original PC4 in which the location would be. We needed it later to assign to such rows the random location
      list_PC4_tried <- c() # list of PC4 tried
      PC4_point <-
        df_PC4_geometries[df_PC4_geometries$PC4 == original_PC4, ]  # centroid of the original PC4

      df_PC4_geometries_tmp <- df_PC4_geometries
      while (nrow(df_locations_PC4) == 0) {
        print(PC4)
        #if there are no locations in the searched PC4, look into the next closest one
        list_PC4_tried <-
          append(list_PC4_tried, PC4) # add the just searched PC4
        
        df_PC4_geometries_tmp$distance <-
          as.numeric(st_distance(df_PC4_geometries_tmp, PC4_point)) # calculate the distance to all the PC4
        
        print(df_PC4_geometries_tmp$distance)

        df_PC4_geometries_tmp <- df_PC4_geometries_tmp[df_PC4_geometries_tmp$PC4 != PC4,] # eliminate the subject PC4 and the tried ones
        PC4 <- df_PC4_geometries_tmp[which.min(df_PC4_geometries_tmp$distance), ]$PC4  # extract the next closest PC4
        df_locations_PC4 <- df_locations[df_locations$PC4 == PC4, ]  # retrieve locations in the new PC4
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
      df_activities[df_activities$activity_type == activity_type &
                      df_activities$PC4_activity == original_PC4, ]$in_DHZW <- 1
    } else {
      df_activities[df_activities$activity_type == activity_type &
                      df_activities$PC4_activity == PC4, ]$lid <- PC4
      df_activities[df_activities$activity_type == activity_type &
                      df_activities$PC4_activity == PC4, ]$in_DHZW <- 0
      }
  }

  df_activities = subset(df_activities, select = -c(hh_PC4, PC4_activity))
  
  return(df_activities)
}