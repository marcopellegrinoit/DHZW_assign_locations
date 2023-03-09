library(readr)
library(dplyr)
library(this.path)
setwd(this.dir())
source('src/utils_od_proportions.R')

setwd(this.dir())
setwd('data/ODiN_destination_proportions')
df_DHZW_trips <- read.csv('df_trips-DHZW.csv')

df_shopping <- df_DHZW_trips[df_DHZW_trips$disp_activity == 'shopping',]
df_sport <- df_DHZW_trips[df_DHZW_trips$disp_activity == 'sports/hobby',]
df_work <- df_DHZW_trips[df_DHZW_trips$disp_activity == 'to work',]

df_school_daycare <- df_DHZW_trips[df_DHZW_trips$age_school == 'daycare',]
df_school_primary <- df_DHZW_trips[df_DHZW_trips$age_school == 'primary_school',]
df_school_highschool <- df_DHZW_trips[df_DHZW_trips$age_school == 'highschool',]
df_school_university <- df_DHZW_trips[df_DHZW_trips$age_school == 'university',]

setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

# in my simulations there are no universities in DHZW
df_school_university <- df_school_university[!df_school_university$disp_arrival_PC4 %in% DHZW_PC4_codes,]

df_shopping <- calculate_od_proportions(df_shopping, DHZW_PC4_codes)
df_sport <- calculate_od_proportions(df_sport, DHZW_PC4_codes)
df_work <- calculate_od_proportions(df_work, DHZW_PC4_codes)

df_school_daycare <- calculate_od_proportions(df_school_daycare, DHZW_PC4_codes)
df_school_primary <- calculate_od_proportions(df_school_primary, DHZW_PC4_codes)
df_school_highschool <- calculate_od_proportions(df_school_highschool, DHZW_PC4_codes)
df_school_university <- calculate_od_proportions(df_school_university, DHZW_PC4_codes)

# save
setwd(this.dir())
setwd('data/ODiN_destination_proportions')
write.csv(df_shopping, 'ODiN_shopping.csv', row.names = FALSE)
write.csv(df_sport, 'ODiN_sport.csv', row.names = FALSE)
write.csv(df_work, 'ODiN_work.csv', row.names = FALSE)

write.csv(df_school_daycare, 'ODiN_school_daycare.csv', row.names = FALSE)
write.csv(df_school_primary, 'ODiN_school_primary.csv', row.names = FALSE)
write.csv(df_school_highschool, 'ODiN_school_highschool.csv', row.names = FALSE)
write.csv(df_school_university, 'ODiN_school_university.csv', row.names = FALSE)
