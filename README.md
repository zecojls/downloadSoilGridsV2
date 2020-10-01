# Downloading SoilGrids V2 data

This repository contains some R scripts for downloading SoilGrids v2 data. Since the original tutorials provided by SRIC does not work, I made a web scrapping algorithm for downloading directly from their webmapping service.

- script_making_tile_indices.R: Defines a bounding box and tiles size (in this case I was able to make up to 10 degree of Lat and Long), which can be exported as a gpkg layer for indexing. There is an edge buffer of around 0.01 degree.
- script_soilGrids_download.R: Downloads the SoilGrids data for different soil attributes and soil depths using the tile indices defined before.
- script_debugging_with_thumbnails.R: For any reason (perhaps internet connection), some tiles have problems and cannot be visualized. Therefore, this script defines the bugged tiles for redownloading.
- script_overviews_and_virtual_rasters.R: Overviews and mosaicking of tiles can be made from this script.
