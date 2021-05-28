

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, gtools, stringr, sf, tidyverse, terra)

g <- gc(reset = TRUE)
rm(list = ls())

# Load data ---------------------------------------------------------------
tble <- read_csv('../tbl/points/01_presences_all.csv')
ntrp <- vect('../data/input/shp/neotropico.shp')
fles <- list.files('../data/input/raster/crn/wrl', full.names = T, pattern = '.tif$')
fles <- mixedsort(fles)
stck <- terra::rast(fles)

# Extract by mask ---------------------------------------------------------
stck <- terra::crop(stck, ntrp)
stck <- terra::mask(stck, ntrp)

# Write rasters -----------------------------------------------------------
Map('writeRaster', x = stck, filename = paste0('../data/input/raster/crn/ntr/bio_', 1:19, '.tif'))

# Remove duplicated by cells ----------------------------------------------
mask <- stck[[1]]
mask <- mask * 0 + 1
mask <- raster(mask)

# Function to duplicated by cell ------------------------------------------
dup_cell <- function(spce){
  
  print(spce)
  tble <- tble %>% filter(specie == spce)
  cell <- terra::extract(mask, tble[,c('X', 'Y')], cellnumbers = T) 
  cell <- xyFromCell(mask, cell[,'cells'])
  dupv <- duplicated(cell[,c('x', 'y')])
  occd <- tbl_df(tble[!dupv,])
  return(occd)
  
}

# Species 
spcs <- unique(tble$specie)
dplc <- map(.x = spcs, .f = dup_cell)
dplc <- bind_rows(dplc)
freq <- as.data.frame(table(dplc$specie))
freq <- freq %>% arrange(desc(Freq))

# Write final csv --------------------------------------------------------
write.csv(freq, '../tbl/points/frequency_v2.csv', row.names = FALSE)
write.csv(dplc, '../tbl/points/02_presences_all.csv', row.names = FALSE)
