filter_attributes_ODiN <- function(df) {
  df <- df %>%
    sjlabelled::remove_all_labels() %>%
    tibble()    # without this, results will be cast as a list
  
  df <- df %>%
    select(OPID,
           Leeftijd,
           WoPC,
           Weekdag,
           Doel,
           VerplID,
           VertLoc,
           VertPC,
           AankPC,
           VerplNr,
           KHvm,
           #KRvm,
           #RVertStat,
           OPRijbewijsAu,
           HHAuto,
           AfstV
    ) %>%
    rename(
      agent_ID = OPID,
      age = Leeftijd,
      hh_PC4 = WoPC,
      day_of_week = Weekdag,
      disp_activity = Doel,
      disp_ID = VerplID,
      disp_start_home = VertLoc,
      disp_modal_choice = KHvm,
      #section_modal_choice = KRvm,
      #section_train_station_ID = RVertStat,
      disp_counter = VerplNr,
      disp_start_PC4 = VertPC,
      disp_arrival_PC4 = AankPC,
      car_license = OPRijbewijsAu,
      n_cars_hh = HHAuto,
      distance = AfstV
    )
  
  return(df)
}

filter_attributes_OViN <- function(df) {
  df <- df %>%
    sjlabelled::remove_all_labels() %>%
    tibble()    # without this, results will be cast as a list
  
  df <- df %>%
    select(OPID,
           Leeftijd,
           Sted,
           Weekdag,
           Doel,
           VerplID,
           Vertrekp,
           VertPC,
           AankPC,
           VerplNr,
           KHvm,
           #KRvm,
           #RVertStat,
           Rijbewijs,
           HHAuto,
           AfstV
    ) %>%
    rename(
      agent_ID = OPID,
      age = Leeftijd,
      municipality_urbanization = Sted,
      day_of_week = Weekdag,
      disp_activity = Doel,
      disp_ID = VerplID,
      disp_start_home = Vertrekp,
      disp_modal_choice = KHvm,
      #section_modal_choice = KRvm,
      #section_train_station_ID = RVertStat,
      disp_counter = VerplNr,
      disp_start_PC4 = VertPC,
      disp_arrival_PC4 = AankPC,
      car_license = Rijbewijs,
      n_cars_hh = HHAuto,
      distance = AfstV
    )
  
  return(df)
}

extract_residential_PC4_from_first_displacement <- function(df) {
  df$hh_PC4=NA
  
  # Consider individuals with at least a displacement. Find the starting point of the first move, and set it as home
  df <- df[!is.na(df$disp_counter),]
  df[df$disp_counter==1,]$hh_PC4 = as.character(df[df$disp_counter==1,]$disp_start_PC4)
  
  # apply residential PC4 to all the rows of the individual
  df <- df %>%
    group_by(agent_ID) %>% 
    mutate(hh_PC4 = zoo::na.locf(hh_PC4, na.rm=FALSE))
  
  return(df)
}

filter_start_day_from_home <- function (df) {
  agents_home_IDs <- unique(df[((df$disp_start_home==1 & df$disp_counter==1)),]$agent_ID)
  
  df[df$agent_ID %in% agents_home_IDs,]
  
  # Remove useless column
  df <- subset(df, select=-c(disp_start_home,disp_counter))
  return(df)
}