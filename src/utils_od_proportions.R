library(tidyr)
library(purrr)

calculate_od_proportions <- function(df_trips, DHZW_PC4_codes) {
  df_od <- data.frame(matrix(ncol = (length(unique(df_trips$disp_arrival_PC4))+1), nrow = length(DHZW_PC4_codes)))
  colnames(df_od) <- c('hh_PC4', unique(df_trips$disp_arrival_PC4))
  df_od[is.na(df_od)] <- 0
  df_od$hh_PC4 <- DHZW_PC4_codes
  
  for (hh_PC4 in df_od$hh_PC4) {
    for (PC4 in colnames(df_od)) {
      if (PC4 != 'hh_PC4') {
        df_od[df_od$hh_PC4 == hh_PC4, PC4] <- nrow(df_trips[df_trips$hh_PC4 == hh_PC4 & df_trips$disp_arrival_PC4 == PC4,])
      }
    }
  }
  
  normalised <- df_od[, -which(names(df_od) %in% c('hh_PC4'))] %>% 
    as.data.frame %>%
    mutate(newSum = select_if(., is.numeric) %>% 
             reduce(`+`)) %>% 
    mutate_if(is.numeric, list(~ ./newSum)) %>% 
    select(-newSum)
  
  df <- cbind(normalised, df_od$hh_PC4)
  df <- df %>%
    rename('hh_PC4' = `df_od$hh_PC4`)
}