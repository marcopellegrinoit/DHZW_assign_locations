library(ggplot2)
library(dplyr)
library(this.path)
library(readr)
library(openxlsx)
library(tidyr)

################################################################################
# distance analysis per mode
df_distance_mode <- read.csv('../data/processed/analysis/ODiN/distance_mode.csv')
df_distance_mode_sim <- read_csv("../../DHZW-simulation_Sim-2APL/src/main/resources/distance_analysis/mode_distance.csv")
df_distance_mode_sim$average_distance <- df_distance_mode_sim$total_distance / df_distance_mode_sim$n_trips

# Create ggplot bar plot
# ggplot(df_distance_mode, aes(x = disp_modal_choice, y = avg_distance)) +
#   geom_bar(stat = "identity", position = "dodge") +
#   labs(title = "Average distance per mode choice", x = "Mode choice", y = "Average distance (km)")

df_distance_mode_comparison <- merge(df_distance_mode, df_distance_mode_sim, by.x = 'disp_modal_choice', by.y = 'mode_choice')
df_distance_mode_comparison <- df_distance_mode_comparison %>%
  select(disp_modal_choice, avg_distance, average_distance) %>%
  rename(ODiN = avg_distance,
         simulation = average_distance) %>%
  pivot_longer(cols = c('ODiN', 'simulation'), names_to = 'data', values_to = 'average_distance')

ggplot(df_distance_mode_comparison, aes(x = disp_modal_choice, y = average_distance, fill = data)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparison of average distance per mode choice", x = "Mode choice", y = "Average distance (km)")

################################################################################
# distance analysis per activity

df_distance_activity <- read.csv('../data/processed/analysis/ODiN/distance_activity.csv')
df_distance_activity_sim <- read_csv("../..//DHZW-simulation_Sim-2APL/src/main/resources/distance_analysis/activity_distance.csv")
df_distance_activity_sim$average_distance <- df_distance_activity_sim$total_distance / df_distance_activity_sim$n_trips

# Create ggplot bar plot
# ggplot(df_distance_activity, aes(x = disp_activity, y = avg_distance)) +
#   geom_bar(stat = "identity", position = "dodge") +
#   labs(title = "Average distance per destination activity", x = "Destination activity", y = "Average distance (km)")

df_distance_activity_comparison <- merge(df_distance_activity, df_distance_activity_sim, by.x = 'disp_activity', by.y = 'activity_type') 
df_distance_activity_comparison <- df_distance_activity_comparison %>%
  select(disp_activity, avg_distance, average_distance) %>%
  rename(ODiN = avg_distance,
         simulation = average_distance) %>%
  pivot_longer(cols = c('ODiN', 'simulation'), names_to = 'data', values_to = 'average_distance')

ggplot(df_distance_activity_comparison, aes(x = disp_activity, y = average_distance, fill = data)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparison of average distance per destination activity", x = "Destination activity", y = "Average distance (km)")

################################################################################
################################################################################
# Overall modal choice analysis

df_mode <- read.csv('../data/processed/analysis/ODiN/mode_choice_overall.csv')
df_mode_sim <- read_csv("../..//DHZW-simulation_Sim-2APL/src/main/resources/distance_analysis/mode_total.csv")
df_mode_sim$proportion_sim <- df_mode_sim$frequency / sum(df_mode_sim$frequency)

# # Create ggplot bar plot
# ggplot(df_mode, aes(x = mode_choice, y = proportion)) +
#   geom_bar(stat = "identity", position = "dodge") +
#   labs(title = "Mode choice proportion", x = "Mode choice", y = "Proportion (%)")

df_mode_comparison <- merge(df_mode, df_mode_sim, by='mode_choice')
df_mode_comparison <- df_mode_comparison %>%
  select(mode_choice, proportion, proportion_sim) %>%
  rename(ODiN = proportion,
         simulation = proportion_sim) %>%
  pivot_longer(cols = c('ODiN', 'simulation'), names_to = 'data', values_to = 'proportion')

ggplot(df_mode_comparison, aes(x = mode_choice, y = proportion, fill = data)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparison of mode choice", x = "Mode choice", y = "proportion")

################################################################################
################################################################################
# Overall average distance weighted by number of trips (it does not matter what dataset activity or mode it is used)

df_distance_mode_sim$weighted_distance <- df_distance_mode_sim$average_distance * df_distance_mode_sim$n_trips
df_distance_mode$weighted_distance <- df_distance_mode$avg_distance * df_distance_mode$n

sum(df_distance_mode_sim$weighted_distance) / sum(df_distance_mode_sim$n_trips)
sum(df_distance_mode$weighted_distance) / sum(df_distance_mode$n)

################################################################################
################################################################################
# Mode x day

df_mode_day <- read.csv('mode_day.csv')

# todo

################################################################################
# Activity type x mode

df_mode_activity <- read.csv('../data/processed/analysis/ODiN/mode_activity.csv')

# Create ggplot bar plot
ggplot(df_mode_activity, aes(x = mode_choice, y = proportion_within_activity_type, fill = activity_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Proportions of mode choice for each activity type",
       x = "Mode choice",
       y = "Proportion within activity type")

################################################################################
# Car license

df_car_license <- read.csv('../data/processed/analysis/ODiN/mode_carlicense.csv')

# Create ggplot bar plot
ggplot(df_car_license, aes(x = mode_choice, y = proportion, fill = car_license)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Proportions of mode choice related to car license ownership",
       x = "Mode choice",
       y = "Proportion within each mode choice",
       fill = "Car license")

################################################################################
# Car ownership

df_car_ownership <- read.csv('../data/processed/analysis/ODiN/mode_carownership.csv')

# Create ggplot bar plot
ggplot(df_car_ownership, aes(x = mode_choice, y = proportion, fill = car_ownership)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Proportions of mode choice related to car ownership",
       x = "Mode choice",
       y = "Proportion within each mode choice",
       fill = "Car ownership")