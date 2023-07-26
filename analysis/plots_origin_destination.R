library(readr)
library(dplyr)
library(circlize)
library(od)
library(ggplot2)
library(sf)
library("this.path")
library('ggmap')
library('rgeos')
library("scales")

################################################################################
# Graph

setwd(this.path::this.dir())
setwd('../data/processed/')
df_ODiN <- read_csv("displacements_DHZW.csv")

# load DHZW area
setwd(this.path::this.dir())
setwd("../../DHZW_shapefiles/data/codes")
DHZW_PC4_codes <- read.csv("DHZW_PC4_codes.csv", sep = ";" ,header=F)$V1

df_ODiN$departure_PC4 <- as.character(df_ODiN$disp_start_PC4)
df_ODiN$arrival_PC4 <- as.character(df_ODiN$disp_arrival_PC4)

df_ODiN[!(df_ODiN$disp_start_PC4 %in% DHZW_PC4_codes),]$departure_PC4 = 'outside DHZW'
df_ODiN[!(df_ODiN$disp_arrival_PC4 %in% DHZW_PC4_codes),]$arrival_PC4 = 'outside DHZW'

df_ODiN_od <- df_ODiN %>%
  select(departure_PC4, arrival_PC4) %>%
  group_by(departure_PC4, arrival_PC4) %>%
  summarise(freq = n())

od_matrix = od_to_odmatrix(x=df_ODiN_od, name_orig = 'departure_PC4', name_dest = 'arrival_PC4', attrib = 'freq')

setwd(paste0(this.path::this.dir(), "/plots"))
png('origin_destination_graph.png', width = 2000, height = 2000, res = 400)
chordDiagram(od_matrix, link.border = "black")
title("Origin-destination graph", cex = 0.6)
dev.off()

################################################################################
# Map

# Select trips only within DHZW
df_ODiN <- df_ODiN[df_ODiN$departure_PC4!='outside DHZW',]
df_ODiN <- df_ODiN[df_ODiN$arrival_PC4!='outside DHZW',]

# Filter out trips within the same postcode. the arrow would no work for them
df_ODiN <- df_ODiN[df_ODiN$disp_start_PC4!=df_ODiN$disp_arrival_PC4,]

# Calculate frequencies for each origin-destination
df_ODiN_map <- df_ODiN %>%
  select(disp_start_PC4, disp_arrival_PC4) %>%
  group_by(disp_start_PC4, disp_arrival_PC4) %>%
  summarise(freq = n())

# Load geometris of PC4 of DHZW
setwd(this.path::this.dir())
setwd('../../DHZW_shapefiles/data/processed/shapefiles/')
shp_DHZW_PC4 <- st_read('DHZW_PC4_shapefiles')

# Calculate centroids of PC4
shp_DHZW_PC4$centroid <- st_centroid(st_as_sf(shp_DHZW_PC4$geometry))
shp_DHZW_PC4$centroid <- st_transform(shp_DHZW_PC4$centroid, 3857)
centroids <- st_coordinates(shp_DHZW_PC4$centroid)
centroids <- cbind(centroids, shp_DHZW_PC4$PC4)
colnames(centroids) <- c('x', 'y', 'PC4')

# Transform orign-destination PC4 into coordinates
df_ODiN_map <- merge(df_ODiN_map, centroids, by.x=c('disp_start_PC4'), by.y=c('PC4'))
df_ODiN_map <- df_ODiN_map %>%
  rename('start_x' = 'x',
         'start_y' = 'y')
df_ODiN_map <- merge(df_ODiN_map, centroids, by.x=c('disp_arrival_PC4'), by.y=c('PC4'))
df_ODiN_map <- df_ODiN_map %>%
  rename('arrival_x' = 'x',
         'arrival_y' = 'y')

# Function to transform Google map to be plotted in ggplot
ggmap_bbox <- function(map) {
  if (!inherits(map, "ggmap")) stop("map must be a ggmap object")
  # Extract the bounding box (in lat/lon) from the ggmap to a numeric vector, 
  # and set the names to what sf::st_bbox expects:
  map_bbox <- setNames(unlist(attr(map, "bb")), 
                       c("ymin", "xmin", "ymax", "xmax"))
  # Coonvert the bbox to an sf polygon, transform it to 3857, 
  # and convert back to a bbox (convoluted, but it works)
  bbox_3857 <- st_bbox(st_transform(st_as_sfc(st_bbox(map_bbox, crs = 4326)), 3857))
  # Overwrite the bbox of the ggmap object with the transformed coordinates 
  attr(map, "bb")$ll.lat <- bbox_3857["ymin"]
  attr(map, "bb")$ll.lon <- bbox_3857["xmin"]
  attr(map, "bb")$ur.lat <- bbox_3857["ymax"]
  attr(map, "bb")$ur.lon <- bbox_3857["xmax"]
  map
}

# Download Google map
setwd(this.path::this.dir())
setwd("../data")
google_key <- read_file("google_key.txt")
register_google(key = google_key, write = TRUE)

# retrieve backrgound map
map <- get_map(c(4.23, 52.02, 4.32, 52.07), source = "google", zoom=14)
map <- ggmap_bbox(map)

# Transform PC4 in the correct reference system for Google
PC4_3857 <- st_transform(shp_DHZW_PC4, 3857)

# Scale trip frequencies for better read of the plot
df_ODiN_map$freq <- rescale(df_ODiN_map$freq, to = c(0, 1))        

# Plot
ggmap(map) +
  coord_sf(crs = st_crs(3857)) + # force the ggplot2 map to be in 3857
  geom_sf(
    aes(fill = PC4),
    data = PC4_3857,
    inherit.aes = FALSE,
    alpha = 0.3
  ) +
  geom_curve(
    data = df_ODiN_map,
    aes(
      x = start_x,
      y = start_y,
      xend = arrival_x,
      yend = arrival_y,
      size=freq,
      color=disp_start_PC4
    ),
    curvature = -1,
    arrow = arrow(length = unit(0.01, "npc"))
  )

################################################################################
# Heatmaps

# optionally, select the type of activity to plot
df_ODiN_heatmap <- df_ODiN[df_ODiN$disp_destination=='to work',]

df_ODiN_heatmap <- df_ODiN %>%
  select(agent_ID, disp_ID, disp_start_PC4, disp_arrival_PC4, disp_modal_choice) %>%
  distinct()

df_ODiN_heatmap <- df_ODiN_heatmap %>%
  select(disp_start_PC4, disp_arrival_PC4) %>%
  group_by(disp_start_PC4, disp_arrival_PC4) %>%
  summarise(freq = n())

ggplot(df_ODiN_heatmap, aes(disp_start_PC4, disp_arrival_PC4, fill= freq)) + 
  geom_tile()+
  scale_fill_distiller(palette = "Reds", direction = 1)+
  ggtitle("Frequency heatmap of 'to work' ODiN movements of DHZW inhabitants")+
  ylab("Arrival PC4")+
  xlab("Departure PC4")+
  labs(fill = "Frequency")+
  theme(title = element_text(size = 20),
        legend.title=element_text(size=20),
        legend.text=element_text(size=15),
        axis.text = element_text(size=15),
        axis.title = element_text(size=20),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


