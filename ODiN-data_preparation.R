library('haven')
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
setwd(this.path::this.dir())
source('../DHZW_assign-travel-behaviours/src/utils.R')

################################################################################
# This script put together the various years of ODiN into a big collection

# Load ODiNs and OViNs
setwd(this.path::this.dir())
setwd('../DHZW_assign-travel-behaviours/data/OViN and OViN')

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

# For individuals with at least a displacement, filter only the ones that start the  day from one. This is because in the simulation the delibration cycle is at midnight everyday, so the agetns must then start from home everyday.
df <- filter_start_day_from_home(df)

# format the values of the attributes
df <- format_values(df)

################################################################################
# Calculate times

df$disp_start_time <- df$disp_start_hour * 60 + df$disp_start_min
df$disp_arrival_time <-
  df$disp_arrival_hour * 60 + df$disp_arrival_min
df <-
  subset(
    df,
    select = -c(
      year,
      disp_start_hour,
      disp_start_min,
      disp_arrival_hour,
      disp_arrival_min
    )
  )

################################################################################
# Data cleaning

df <- df %>%
  select(agent_ID, hh_PC4, disp_start_PC4, disp_arrival_PC4, disp_activity, day_of_week)

df[!(df$disp_start_PC4 %in% DHZW_PC4_codes),]$disp_start_PC4 <- 'outside_DHZW'
df[!(df$disp_arrival_PC4 %in% DHZW_PC4_codes),]$disp_arrival_PC4 <- 'outside_DHZW'

unique(df$disp_start_PC4)
unique(df$disp_arrival_PC4)
unique(df$hh_PC4)
unique(df$disp_activity)
unique(df$day_of_week)

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/ODiN_destination_proportions"))
write.csv(df, 'df_trips-DHZW.csv', row.names = FALSE)
