
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

## Virtual rasters

path.list

for(i in 1:length(path.list)) {
  
  raster.layers <- path.list[[i]]
  
  raster.prefix <- gsub("X:/GPP/SoilGridsV2/raster/SoilGrids_", "", raster.layers[1])
  raster.prefix <- gsub(".tif", "", raster.prefix)
  raster.prefix <- str_sub(raster.prefix, start = 1, end = nchar(raster.prefix)-7)
  
  gdalbuildvrt(raster.layers,
               output.vrt = paste(dir.proj, paste0(paste("mosaicos/SoilGrids", raster.prefix, sep = "_"), ".vrt"), sep = "/"),
               separete = FALSE,
               overwrite = TRUE,
               verbose = FALSE)
}

