library(readr)
library(dplyr)
library(this.path)
setwd(this.dir())
source('src/utils_od_proportions.R')

setwd(this.dir())
setwd('../DHZW_assign-travel-behaviours/data/processed')
df_DHZW_trips <- read.csv('df_activity_trips_DHZW.csv')

df_DHZW_trips <- df_DHZW_trips %>%
  filter(disp_activity == 'shopping' |
         disp_activity == 'to work' |
         disp_activity == 'sports/hobby')

df_DHZW_trips <- df_DHZW_trips %>%
  select(agent_ID, hh_PC4, disp_arrival_PC4, disp_activity)

setwd(this.dir())
setwd('../DHZW_assign-travel-behaviours/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_DHZW_trips[!(df_DHZW_trips$disp_arrival_PC4 %in% DHZW_PC4_codes),]$disp_arrival_PC4 <- 'outside DHZW'

df_shopping <- df_DHZW_trips[df_DHZW_trips$disp_activity == 'shopping',]
df_sport <- df_DHZW_trips[df_DHZW_trips$disp_activity == 'sports/hobby',]
df_work <- df_DHZW_trips[df_DHZW_trips$disp_activity == 'to work',]

df_shopping <- calculate_od_proportions(df_shopping, DHZW_PC4_codes)
df_sport <- calculate_od_proportions(df_sport, DHZW_PC4_codes)
df_work <- calculate_od_proportions(df_work, DHZW_PC4_codes)

# save
setwd(this.dir())
setwd('data/ODiN_destination_proportions')
write.csv(df_shopping, 'ODiN_shopping.csv', row.names = FALSE)
write.csv(df_sport, 'ODiN_sport.csv', row.names = FALSE)
write.csv(df_work, 'ODiN_work.csv', row.names = FALSE)
