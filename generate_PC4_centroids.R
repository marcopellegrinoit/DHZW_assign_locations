library(this.path)
library(sf)
library(dplyr)

# Load PC5 Netherlands
setwd(this.dir())
setwd('data')
df_PC4 <- st_read('CBS-PC4-2019-v2')

# Transform into WGS84
df_PC4 <- st_transform(df_PC4, "+proj=longlat +datum=WGS84")

# compute the centroid
df_centroid_PC4 <- st_centroid(df_PC4)
df_coordinates <- data.frame(st_coordinates(df_centroid_PC4))
colnames(df_coordinates) <- c('PC4_longitude', 'PC4_latitude')
df_PC4 = cbind(df_PC4, df_coordinates)
df_PC4 <- data.frame(df_PC4)
df_PC4 = subset(df_PC4, select = -c(geometry))

df_PC4 <- df_PC4 %>%
  select(PC4, PC4_longitude, PC4_latitude)

setwd(this.dir())
setwd('data')
write.csv(df_PC4, 'NL_PC4_centroids.csv', row.names = FALSE)