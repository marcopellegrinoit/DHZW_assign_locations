library('haven')
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
setwd(this.path::this.dir())
source('src/utils_data_preparation.R')

################################################################################
# This script put together the various years of ODiN into a big collection

# Load ODiNs and OViNs
setwd(this.path::this.dir())
setwd('../DHZW_assign-activities/data/OViN and OViN')

OViN2010 <- read_sav("OViN2010.sav")
OViN2011 <- read_sav("OViN2011.sav")
OViN2012 <- read_sav("OViN2012.sav")
OViN2013 <- read_sav("OViN2013.sav")
OViN2014 <- read_sav("OViN2014.sav")
OViN2015 <- read_sav("OViN2015.sav")
OViN2016 <- read_sav("OViN2016.sav")
OViN2017 <- read_sav("OViN2017.sav")
ODiN2018 <- read_sav("ODiN2018.sav")
ODiN2019 <- read_sav("ODiN2019.sav")

OViN2010 <- filter_attributes_OViN(OViN2010)
OViN2011 <- filter_attributes_OViN(OViN2011)
OViN2012 <- filter_attributes_OViN(OViN2012)
OViN2013 <- filter_attributes_OViN(OViN2013)
OViN2014 <- filter_attributes_OViN(OViN2014)
OViN2015 <- filter_attributes_OViN(OViN2015)
OViN2016 <- filter_attributes_OViN(OViN2016)
OViN2017 <- filter_attributes_OViN(OViN2017)
ODiN2018 <- filter_attributes_ODiN(ODiN2018)
ODiN2019 <- filter_attributes_ODiN(ODiN2019)

################################################################################
# ODiN

df_ODiN <- rbind(ODiN2018,
                 ODiN2019)

################################################################################
# OViN

df_OViN <- rbind(OViN2010,
                 OViN2011,
                 OViN2012,
                 OViN2013,
                 OViN2014,
                 OViN2015,
                 OViN2016,
                 OViN2017)


# Since the residential PC4 is not given, for the individuals that at have least one displacement I retrieve it from the first displacement.
df_OViN <- extract_residential_PC4_from_first_displacement(df_OViN)

df_OViN <- subset(df_OViN, select=-c(municipality_urbanization))

################################################################################

df <- rbind(df_OViN,
            df_ODiN)

# Filter individuals that live in DHZW. Since I am analysing the PC4, I only care about individuals with at least a displacement
df <- df[!is.na(df$disp_counter),]

setwd(this.path::this.dir())
setwd('data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1
df <- df[df$hh_PC4 %in% DHZW_PC4_codes,]

# Filter only individuals with at least a displacement that starts the day from home
df <- filter_start_day_from_home(df)

df$disp_activity <- recode(
  df$disp_activity,
  '1' = 'to home',
  '2' = 'to work',
  '3' = 'business visit',
  '4' = 'transport is the job',
  '5' = 'pick up / bring people',
  '6' = 'collection/delivery of goods',
  '7' = 'follow education',
  '8' = 'shopping',
  '9' = 'visit/stay',
  '10' =	'hiking',
  '11' =	'sports/hobby',
  '12' =	'other leisure activities',
  '13' =	'services/personal care',
  '14' =	'other'
)


df$disp_modal_choice <- recode(
  df$disp_modal_choice,
  '1' = 'car driver',
  '2' = 'car passenger',
  '3' = 'train',
  '4' = 'bus_tram_metro',
  '5' = 'bike',
  '6' = 'foot',
  '7' = 'other'
)


################################################################################

df$disp_start_inside <- TRUE
df$disp_arrival_inside <- TRUE
df[!(df$disp_start_PC4 %in% DHZW_PC4_codes),]$disp_start_inside <- FALSE
df[!(df$disp_arrival_PC4 %in% DHZW_PC4_codes),]$disp_arrival_inside <- FALSE

# remove trips completely outside
df <- df[!(df$disp_start_inside == FALSE & df$disp_arrival_inside == FALSE), ]

# remove trips that are not clear
df <- df %>%
  filter(disp_arrival_PC4!='0000' &
           disp_arrival_PC4!='0' &
           !is.na(disp_arrival_PC4))

df <- df %>%
  filter(disp_start_PC4!='0000' &
           disp_start_PC4!='0' &
           !is.na(disp_start_PC4))


df <- df %>%
  filter(disp_modal_choice!='other')%>%
  filter(!is.na(disp_modal_choice))

df$car_license <- recode(
  df$car_license,
  '0' = 'no',
  '1' = 'yes',
  '2' = 'unknown',
  '3' = 'no'
)
df <- df[df$car_license!='unknown' & !is.na(df$car_license),]

df$n_cars_hh <- recode(
  df$n_cars_hh,
  '0' = 'no',
  '1' = 'yes',
  '2' = 'yes',
  '3' = 'yes',
  '4' = 'yes',
  '5' = 'yes',
  '6' = 'yes',
  '7' = 'yes',
  '8' = 'yes',
  '9' = 'yes',
  '10' = 'unknown'
)
df <- df[df$n_cars_hh!='unknown' & !is.na(df$n_cars_hh),]

df <- df %>%
  rename(car_hh_ownership = n_cars_hh)

# Shift Sunday at the end of the week
df$day_of_week <- recode(
  df$day_of_week,
  '1' = '7',
  '2' = '1',
  '3' = '2',
  '4' = '3',
  '5' = '4',
  '6' = '5',
  '7' = '6'
)

df$day_string = ''
df[df$day_of_week=='1',]$day_string <- 'Monday'
df[df$day_of_week=='2',]$day_string <- 'Tuesday'
df[df$day_of_week=='3',]$day_string <- 'Wednesday'
df[df$day_of_week=='4',]$day_string <- 'Thursday'
df[df$day_of_week=='5',]$day_string <- 'Friday'
df[df$day_of_week=='6',]$day_string <- 'Saturday'
df[df$day_of_week=='7',]$day_string <- 'Sunday'


df$distance <- df$distance / 10 # hectometers to kilometers

# no individuals younger than 4 years old
df <- df[df$age >= 4,]

df$disp_activity <- recode(
  df$disp_activity,
  'to home' = 'HOME',
  'to work' = 'WORK',
  'shopping' = 'SHOPPING',
  'follow education' = 'SCHOOL',
  'sports/hobby' = 'SPORT'
)

df$disp_modal_choice <- recode(
  df$disp_modal_choice,
  'car passenger' = 'CAR_PASSENGER',
  'car driver' = 'CAR_DRIVER',
  'bike' = 'BIKE',
  'bus_tram_metro' = 'BUS_TRAM',
  'foot' = 'WALK',
  'train' = 'TRAIN'
)

df <- df %>%
  distinct()

################################################################################
# remove trips that go or come from unwanted activities

# order trips
df <- df[order(df$disp_ID),]
df$day_of_week <- as.numeric(df$day_of_week)

df <- df %>%
  ungroup() %>%
  mutate(previous_activity = lag(disp_activity)) %>%
  mutate(previous_agent = lag(agent_ID))

# remove trips that are going to unwanted activities, or come from unwanted activities for the same agent in the same day
df_filter <- df[df$disp_activity %in% c("SHOPPING", "WORK", "SPORT", "SCHOOL", "HOME") &
                  df$previous_activity %in% c("SHOPPING", "WORK", "SPORT", "SCHOOL", "HOME") &
                  df$previous_agent == df$agent_ID,]

# store trips that are the first of each new day, or new agent that still go to wanted activities. no going back home because it must be going to some activity
df_previous_different <- df[df$disp_activity %in% c("SHOPPING", "WORK", "SPORT", "SCHOOL", "HOME") &
                              (df$previous_agent != df$agent_ID),]

df_total <- rbind(df_filter, df_previous_different)
df_total <- df_total[order(df_total$disp_ID),]

df_total <- df_total %>%
  select(agent_ID, age, hh_PC4, day_of_week, car_license, car_hh_ownership, disp_ID, disp_start_PC4, disp_arrival_PC4, disp_activity, disp_start_inside, disp_arrival_inside, disp_modal_choice, distance) %>%
  distinct()

df_total <- df_total %>%
  drop_na()

# Save dataset
setwd(this.path::this.dir())
setwd("data/processed")
write.csv(df_total, 'displacements_DHZW.csv', row.names = FALSE)