library(readr)
library(dplyr)
library(this.path)
setwd(this.dir())
source('src/utils_od_proportions.R')

setwd(this.dir())
setwd('data/processed')
df_old <- read.csv('df_trips-DHZW.csv')

setwd(this.dir())
setwd('../data/processed')
df <- read.csv('displacements_DHZW.csv')

df_shopping <- df[df$disp_activity == 'SHOPPING',]
df_sport <- df[df$disp_activity == 'SPORT',]
df_work <- df[df$disp_activity == 'WORK',]
df_school <- df[df$disp_activity == 'SCHOOL',]

df_school$age_school <- NA
df_school[df_school$age <= 5,]$age_school <- 'daycare'
df_school[df_school$age >= 6 & df_school$age <= 11,]$age_school <- 'primary_school'
df_school[df_school$age >= 12 & df_school$age <= 18,]$age_school <- 'highschool'
df_school[df_school$age >= 19,]$age_school <- 'university'

df_school_daycare <- df_school[df_school$age_school == 'daycare',]
df_school_primary <- df_school[df_school$age_school == 'primary_school',]
df_school_highschool <- df_school[df_school$age_school == 'highschool',]
df_school_university <- df_school[df_school$age_school == 'university',]

setwd(this.path::this.dir())
setwd('../DHZW_shapefiles/data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

# remove trips that go to uni inside DHZW, because there are no uni there
df_school_university <- df_school_university[!df_school_university$disp_arrival_PC4 %in% DHZW_PC4_codes,]

df_shopping <- calculate_od_proportions(df_shopping, DHZW_PC4_codes)
df_sport <- calculate_od_proportions(df_sport, DHZW_PC4_codes)
df_work <- calculate_od_proportions(df_work, DHZW_PC4_codes)

df_school_daycare <- calculate_od_proportions(df_school_daycare, DHZW_PC4_codes)
df_school_daycare[is.na(df_school_daycare)] = 1/(nrow(df_school_daycare)-1) # for home PC4 that have no people going to daycare just normally distribute it
df_school_primary <- calculate_od_proportions(df_school_primary, DHZW_PC4_codes)
df_school_primary[is.na(df_school_primary)] = 1/(ncol(df_school_primary)-1) # for home PC4 that have no people going to daycare just normally distribute it
df_school_highschool <- calculate_od_proportions(df_school_highschool, DHZW_PC4_codes)
df_school_highschool[is.na(df_school_highschool)] = 1/(ncol(df_school_highschool)-1) # for home PC4 that have no people going to daycare just normally distribute it
df_school_university <- calculate_od_proportions(df_school_university, DHZW_PC4_codes)
df_school_university[is.na(df_school_university)] = 1/(ncol(df_school_university)-1) # for home PC4 that have no people going to daycare just normally distribute it

# save
setwd(this.dir())
setwd('data/processed')
write.csv(df_shopping, 'ODiN_shopping.csv', row.names = FALSE)
write.csv(df_sport, 'ODiN_sport.csv', row.names = FALSE)
write.csv(df_work, 'ODiN_work.csv', row.names = FALSE)

write.csv(df_school_daycare, 'ODiN_school_daycare.csv', row.names = FALSE)
write.csv(df_school_primary, 'ODiN_school_primary.csv', row.names = FALSE)
write.csv(df_school_highschool, 'ODiN_school_highschool.csv', row.names = FALSE)
write.csv(df_school_university, 'ODiN_school_university.csv', row.names = FALSE)
