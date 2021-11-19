# Downloading SoilGrids v2 raster data

This repository contains R scripts for downloading SoilGrids v2 data. Since the original tutorials provided by ISRIC did not work for me, I made a web scrapping algorithm for downloading the data directly from their webmapping service.

- `script_making_tile_indices.R`: defines a bounding box and tiles size (in this case I was able to make up to 10 degree of Lat and Long extent), which can be exported as a gpkg layer for personal indexing. There is an edge buffer of around 0.01 degree for each tile.
- `script_soilGrids_download.R`: downloads the SoilGrids data for different soil attributes and soil depths using the custom parameters.
- `script_debugging_with_thumbnails.R`: for some reason (perhaps internet connection), some tiles are broken and cannot be visualized. Therefore, this script identifies the problematic tiles for redownloading.
- `script_overviews_and_virtual_rasters.R`: overviews and mosaicking of tiles can be made from this script.
