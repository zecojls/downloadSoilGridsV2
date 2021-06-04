
## Setup

options(stringsAsFactors = FALSE)
options(pillar.sigfig=3)

getwd()

library(tidyverse)
library(rgeos)
library(sf)

## Directories

dir.root <- dirname(getwd()); dir.root
dir.proj <- getwd(); dir.proj

list.files(dir.root)
list.files(dir.proj)

dir.export <- paste0(dir.proj, "/raster")

## Building bouding boxes

min.long <- -74
min.lat <- -34
max.long <- -24
max.lat <- 6

seq.long <- seq(min.long, max.long, by = 10)
seq.lat <- seq(min.lat, max.lat, by = 10)

combination.min <- expand.grid(seq.long[-length(seq.long)], seq.lat[-length(seq.lat)])
combination.max <- expand.grid(seq.long[-1], seq.lat[-1])

full.combination <- tibble(min.long = combination.min[,1],
                           max.long = combination.max[,1],
                           min.lat = combination.min[,2],
                           max.lat = combination.max[,2])

full.combination <- full.combination %>%
  mutate(min.long = min.long - 0.01,
         max.long = max.long + 0.01,
         min.lat = min.lat - 0.01,
         max.lat = max.lat + 0.01)

full.combination <- as.data.frame(full.combination)

bbox.coordinates <- full.combination %>%
  mutate(left.coord = paste0(ifelse(min.long < 0, "W", "E"), round(abs(min.long), 0)),
         top.coord = paste0(ifelse(max.lat < 0, "S", "N"), round(abs(max.lat), 0)))

bbox.coordinates

## Making spatial polygons

list.polygons <- list()

for(i in 1:nrow(bbox.coordinates)) {
  
  n <- bbox.coordinates[i,"max.lat"]
  s <- bbox.coordinates[i,"min.lat"]
  w <- bbox.coordinates[i,"min.long"]
  e <- bbox.coordinates[i,"max.long"]
  
  bbox <- rgeos::bbox2SP(n = n, s = s, w = w, e = e,
                         proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
  
  bbox.sf <- st_as_sf(bbox)
  
  list.polygons[[i]] <- bbox.sf
  
}

list.polygons

multipolygon <- do.call(rbind, list.polygons)

export.vector <- st_as_sf(data.frame(bbox.coordinates, geometry = multipolygon))
export.vector

st_write(export.vector, "X:/GPP/SoilGridsV2/vetor/SoilGrids_tiles.gpkg")
