library(dplyr)
library(this.path)
library(readr)
library(openxlsx)

setwd(this.dir())
setwd('../data/processed')

df <- read_csv("displacements_DHZW.csv")
df$day_of_week <- as.numeric(df$day_of_week)
df <- df[order(df$disp_ID),]

setwd(this.dir())
setwd('data/processed/analysis/ODiN')

################################################################################
# distance analysis per mode

df_distance <- df %>%
  select(disp_modal_choice, distance) %>%
  group_by(disp_modal_choice) %>%
  summarize(tot_distance = sum(distance))

df_total <- as.data.frame(table(df$disp_modal_choice))
colnames(df_total) <- c('disp_modal_choice', 'n')

df_distance_avg <- merge(df_distance, df_total, by='disp_modal_choice')
df_distance_avg$avg_distance <- df_distance_avg$tot_distance / df_distance_avg$n

write.csv(df_distance_avg, 'distance_mode.csv', row.names = FALSE)
write.xlsx(df_distance_avg, file = "distance_mode.xlsx", rowNames = FALSE)

################################################################################
# distance analysis per activity

df_distance <- df %>%
  select(disp_activity, distance) %>%
  group_by(disp_activity) %>%
  summarize(tot_distance = sum(distance))

df_total <- as.data.frame(table(df$disp_activity))
colnames(df_total) <- c('disp_activity', 'n')

df_distance_avg <- merge(df_distance, df_total, by='disp_activity')
df_distance_avg$avg_distance <- df_distance_avg$tot_distance / df_distance_avg$n

write.csv(df_distance_avg, 'distance_activity.csv', row.names = FALSE)
write.xlsx(df_distance_avg, file = "distance_activity.xlsx", rowNames = FALSE)

################################################################################
################################################################################
# Overall modal choice analysis

overall_prop_table <- with(df, table(disp_modal_choice)) %>%
  prop.table() %>%
  round(2)

df_prop_overall <- as.data.frame(overall_prop_table)
colnames(df_prop_overall) <- c('mode_choice', 'proportion')

write.csv(df_prop_overall, 'mode_choice_overall.csv', row.names = FALSE)
write.xlsx(df_prop_overall, file = "mode_choice_overall.xlsx", rowNames = FALSE)


################################################################################
# Mode x day

prop_table <- round(prop.table(table(df$disp_modal_choice, df$day_of_week), margin = 2), 2)

# Convert frequency table to data frame and sort day_of_week by numerical order
df_prop <- as.data.frame(prop_table)
colnames(df_prop) <- c('mode_choice', 'day_integer', 'proportion_within_day')
df_prop$day_integer <- factor(df_prop$day_integer, ordered = TRUE)

df_prop$day_string = ''
df_prop[df_prop$day_integer=='1',]$day_string <- 'Monday'
df_prop[df_prop$day_integer=='2',]$day_string <- 'Tuesday'
df_prop[df_prop$day_integer=='3',]$day_string <- 'Wednesday'
df_prop[df_prop$day_integer=='4',]$day_string <- 'Thursday'
df_prop[df_prop$day_integer=='5',]$day_string <- 'Friday'
df_prop[df_prop$day_integer=='6',]$day_string <- 'Saturday'
df_prop[df_prop$day_integer=='7',]$day_string <- 'Sunday'

write.csv(df_prop, 'mode_day.csv', row.names = FALSE)
write.xlsx(df_prop, file = "mode_day.xlsx", rowNames = FALSE)

################################################################################
# Activity type x mode

prop_table <- round(prop.table(table(df$disp_modal_choice, df$disp_activity), margin = 2), 2)

# Convert frequency table to data frame and sort day_of_week by numerical order
df_prop <- as.data.frame(prop_table)
colnames(df_prop) <- c('mode_choice', 'activity_type', 'proportion_within_activity_type')

write.csv(df_prop, 'mode_activity.csv', row.names = FALSE)
write.xlsx(df_prop, file = "mode_activity.xlsx", rowNames = FALSE)

################################################################################
# Car license
prop_table <- round(prop.table(table(df$disp_modal_choice, df$car_license), margin = 1), 2)

df_prop <- as.data.frame(prop_table)
colnames(df_prop) <- c('mode_choice', 'car_license', 'proportion')

write.csv(df_prop, 'mode_carlicense.csv', row.names = FALSE)
write.xlsx(df_prop, file = "mode_carlicense.xlsx", rowNames = FALSE)

################################################################################
# Car ownership
prop_table <- round(prop.table(table(df$disp_modal_choice, df$car_hh_ownership), margin = 1), 2)
df_prop <- as.data.frame(prop_table)
colnames(df_prop) <- c('mode_choice', 'car_ownership', 'proportion')

write.csv(df_prop, 'mode_carownership.csv', row.names = FALSE)
write.xlsx(df_prop, file = "mode_carownership.xlsx", rowNames = FALSE)