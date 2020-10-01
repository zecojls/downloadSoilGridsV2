
## Setup

options(stringsAsFactors = FALSE)

library(tidyverse)
library(gdalUtils)
library(rgdal)

## Directories

dir.root <- dirname(getwd()); dir.root
dir.proj <- getwd(); dir.proj

dir.raster <- paste0(dir.proj, "/raster")

## Soil data

attributes <- c("wrb.map", "phh2o.map", "soc.map", "nitrogen.map",
                "cec.map", "silt.map", "clay.map", "sand.map", "bdod.map")

layers <- c("0-5cm_mean", "5-15cm_mean", "15-30cm_mean", "30-60cm_mean")

## Listing files

list.raster.path <- list()

for(a in 1:length(attributes)) {
  
  attribute <- gsub(".map", "", attributes[a])
  
  if(attribute == "wrb") {
    
    layer <- "MostProbable"
    
    raster.selection <- list.files(dir.raster, full.names = T,
                                   pattern = paste(attribute, layer, sep = "_"))
    
    list.raster.path[[a]] <- raster.selection
    
  } else {
    
    list.raster.layer <- list()
    
    for(l in 1:length(layers)) {
      
      layer <- layers[l]
      
      layer.selection <- list.files(dir.raster, full.names = T,
                                    pattern = paste(attribute, layer, sep = "_"))
      
      list.raster.layer[[l]] <- layer.selection
      
    }
    
    list.raster.path[[a]] <- list.raster.layer
    
  }
}

list.raster.path

first.list <- list.raster.path[1]
remaining <- list.raster.path[-1]

path.list <- c(first.list, do.call(c, remaining))

path.list

unlist(lapply(path.list, length))


## Thumbnails

raster.layers <- unlist(path.list)
raster.layers <- bugged.tiles
raster.layers

for(i in 1:length(raster.layers)) {
  
  layer <- raster.layers[i]
  layer.prefix <- gsub("X:/GPP/SoilGridsV2/raster/", "", layer)
  layer.prefix <- gsub(".tif", "", layer.prefix)
  gdal_translate(layer, paste0("thumbnails/", layer.prefix, ".png"),
                 outsize = c("1%","1%"),
                 verbose = FALSE)
  
}

## Comparing thumbnails with downloaded tiles

dir.thumbnails <- paste0(dir.proj, "/thumbnails")
dir.raster <- paste0(dir.proj, "/raster")

listed.thumbnails <- list.files(dir.thumbnails)
listed.thumbnails <- gsub(".png", "", listed.thumbnails)
listed.thumbnails

listed.tiles <- list.files(dir.raster)
listed.tiles <- gsub(".tif", "", listed.tiles)
listed.tiles

bugged.tiles <- listed.tiles[!(listed.tiles %in% listed.thumbnails)]
bugged.tiles

file.remove(paste0(dir.proj, "/raster/", bugged.tiles, ".tif"))
