
## Setup

options(stringsAsFactors = FALSE)

options(pillar.sigfig=3)

getwd()

library(curl)
library(XML)
library(tidyverse)

## Directories

dir.root <- dirname(getwd()); dir.root
dir.proj <- getwd(); dir.proj

list.files(dir.root)
list.files(dir.proj)

dir.export <- paste0(dir.proj, "/raster")

min.long <- -74
min.lat <- -34
max.long <- -24
max.lat <- 6

seq.long <- seq(min.long, min.lat, by = 10)
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

# Download links

# WRB
#"https://maps.isric.org/mapserv?map=/map/wrb.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=MostProbable&FORMAT=image/tiff&SUBSET=long(-54.2280,-52.2280)&SUBSET=lat(-22.0906,-20.0906)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# pH
#'https://maps.isric.org/mapserv?map=/map/phh2o.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=phh2o_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-51.8169,-49.8169)&SUBSET=lat(-20.9119,-18.9119)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326'
# SOC
#"https://maps.isric.org/mapserv?map=/map/soc.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=soc_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-52.0848,-50.0848)&SUBSET=lat(-17.2684,-15.2684)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# N
#"https://maps.isric.org/mapserv?map=/map/nitrogen.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=nitrogen_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-49.0307,-47.0307)&SUBSET=lat(-20.4832,-18.4832)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# CTC
#"https://maps.isric.org/mapserv?map=/map/cec.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=cec_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-49.2986,-47.2986)&SUBSET=lat(-23.7516,-21.7516)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# Silt
#"https://maps.isric.org/mapserv?map=/map/silt.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=silt_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-51.1739,-49.1739)&SUBSET=lat(-20.1082,-18.1082)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# Clay
#"https://maps.isric.org/mapserv?map=/map/clay.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=clay_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-52.8950,-50.8950)&SUBSET=lat(-19.4116,-17.4116)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# Sand
#"https://maps.isric.org/mapserv?map=/map/sand.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=sand_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-48.3342,-46.3342)&SUBSET=lat(-19.1437,-17.1437)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326"
# BD
#'https://maps.isric.org/mapserv?map=/map/bdod.map&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=bdod_0-5cm_mean&FORMAT=image/tiff&SUBSET=long(-50.9661,-48.9661)&SUBSET=lat(-18.0721,-16.0721)&SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326&OUTPUTCRS=http://www.opengis.net/def/crs/EPSG/0/4326'

# Automatic download

bbox.coordinates

attributes <- c("wrb.map", "phh2o.map", "soc.map", "nitrogen.map",
               "cec.map", "silt.map", "clay.map", "sand.map", "bdod.map")

layers <- c("0-5cm_mean", "5-15cm_mean", "15-30cm_mean", "30-60cm_mean")

for(a in 1:length(attributes)) {
  
  attribute <- attributes[a]
  
  attribute.prefix <- gsub(".map", "", attribute)
  
  if(attribute == "wrb.map") {
    
    layer <- "MostProbable"
    
    for(t in 1:nrow(bbox.coordinates)) {
      
      min.long = bbox.coordinates[t,"min.long"]
      max.long = bbox.coordinates[t,"max.long"]
      min.lat = bbox.coordinates[t,"min.lat"]
      max.lat = bbox.coordinates[t,"max.lat"]
      left.coord <- bbox.coordinates[t,"left.coord"]
      top.coord <- bbox.coordinates[t,"top.coord"]
      
      wcs <- paste0("https://maps.isric.org/mapserv?map=/map/", attribute, "&",
                    "SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=", layer, "&",
                    "FORMAT=image/tiff&",
                    "SUBSET=long(", min.long, ",", max.long, ")&",
                    "SUBSET=lat(", min.lat, ",", max.lat, ")&",
                    "SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326")
      
      destination.file <- paste0(dir.export, "/SoilGrids_",
                                 paste(attribute.prefix, layer,
                                       left.coord, top.coord, sep = "_"),
                                 ".tif")
      
      if(file.exists(destination.file)) {
        
        next
        
      } else {
        
        cat("Downloading: ", destination.file, "\n")
        download.file(wcs, destfile = destination.file, mode = 'wb')
        
      }
      
    }
    
  } else {
    
    for(l in 1:length(layers)) {
      
      layer <- layers[l]
      
      for(t in 1:nrow(bbox.coordinates)) {
        
        min.long = bbox.coordinates[t, "min.long"]
        max.long = bbox.coordinates[t, "max.long"]
        min.lat = bbox.coordinates[t, "min.lat"]
        max.lat = bbox.coordinates[t, "max.lat"]
        left.coord <- bbox.coordinates[t, "left.coord"]
        top.coord <- bbox.coordinates[t, "top.coord"]
        
        wcs <- paste0("https://maps.isric.org/mapserv?map=/map/", attribute, "&",
                      "SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=", attribute.prefix, "_", layer, "&",
                      "FORMAT=image/tiff&",
                      "SUBSET=long(", min.long, ",", max.long, ")&",
                      "SUBSET=lat(", min.lat, ",", max.lat, ")&",
                      "SUBSETTINGCRS=http://www.opengis.net/def/crs/EPSG/0/4326")
        
        destination.file <- paste0(dir.export, "/SoilGrids_",
                                   paste(attribute.prefix, layer,
                                         left.coord, top.coord, sep = "_"),
                                   ".tif")
        
        if(file.exists(destination.file)) {
          
          next
          
        } else {
          
          cat("Downloading: ", destination.file, "\n")
          download.file(wcs, destfile = destination.file, mode = 'wb')
          
        }
      }
    }
  }
}

