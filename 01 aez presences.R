
# Load libraries
require(pacman)
pacman::p_load(raster, rgdal, rgeos, tidyverse)

# Load data
fles <- list.files('../data/input/tbl', full.names = T)
fles
tble <- map(fles, read_csv)
ntrp <- st_read('../data/input/shp/neotropico.shp')

# Join tables
tble <- bind_rows(tble)
tble <- tble[,1:3]
tble <- drop_na(tble)

# Table to shapefile
shpf <- st_as_sf(tble, coords = c('X', 'Y'), crs = st_crs(4326))
intr <- st_intersection(shpf, ntrp)
intr <- intr %>% dplyr::select(specie, ENGLISH)
st_write(intr, '../data/input/shp/points_country.shp')

# Frequency
freq <- table(tble$specie)
freq <- data.frame(count = freq)
names(freq) <- c('sp', 'n')

# Order
freq <- freq %>% arrange(desc(n))
write.csv(freq, '../tbl/points/frequency_v1.csv', row.names = FALSE)
write.csv(tble, '../tbl/points/01_presences_all.csv')

freq %>% filter(n < 30)

