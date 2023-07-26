# Load required packages
library(ggplot2)
library(dplyr)
library(tidyr)
library(this.path)
library(readr)

setwd(this.dir())
# read dataset
df <- read_csv("../data/processed/ODiN_work.csv")

# convert the dataframe for ggplot
df_long <- df %>%
  pivot_longer(cols=-c("hh_PC4"), names_to = "destination_PC4", values_to = "proportion")

# make proportions out of 100
df_long$proportion <- df_long$proportion * 100

# make labels as  factors so then later in the plot I can set how often I want a label on the x axis
df_long$destination_PC4 <- factor(df_long$destination_PC4, levels = unique(df_long$destination_PC4)[seq(1, length(unique(df_long$destination_PC4)), 1)])

# Create the heatmap using ggplot2
heatmap_plot <- ggplot(df_long, aes(x = destination_PC4, y = as.character(hh_PC4), fill = proportion)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue") +  # Adjust the color scheme as needed
  labs(x = "Destination Work Postcodes", y = "Resident Postcodes") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_x_discrete(breaks = unique(df_long$destination_PC4)[seq(1, length(unique(df_long$destination_PC4)), 5)])+ # only a label on the x axis every 5
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 15),  # Adjust the font size
        axis.text.y = element_text(size = 15),  # Adjust the font size
        axis.title = element_text(size = 20),  # Adjust the font size for axis titles
        legend.text = element_text(size = 12),  # Adjust the font size for legend text
        legend.title = element_text(size = 17)) +  # Adjust the font size for legend title
  guides(fill = guide_colorbar(title = "Proportion (%) per \n origin postcode"))  # Modify the legend title

print(heatmap_plot)