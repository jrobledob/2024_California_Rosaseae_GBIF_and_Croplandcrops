library(terra)
library(viridis)
vir.pal <- viridis(n = 100, option = "viridis")

hostOccGBIF <- read.csv("./Rosaceae.csv", header = TRUE, sep = "\t")

# Cleaning dataset (same as before)
hostOccGBIF <- hostOccGBIF[hostOccGBIF$countryCode != "", ]
hostOccGBIF <- hostOccGBIF[hostOccGBIF$countryCode != "ZZ", ]
hostOccGBIF <- hostOccGBIF[hostOccGBIF$occurrenceStatus == "PRESENT", ]
hostOccGBIF <- hostOccGBIF[hostOccGBIF$year >= 1944, ]
hostOccGBIF$Lon <- as.numeric(hostOccGBIF$decimalLongitude)
hostOccGBIF$Lat <- as.numeric(hostOccGBIF$decimalLatitude)
hostOccGBIF <- hostOccGBIF[hostOccGBIF$decimalLatitude != hostOccGBIF$decimalLongitude, ]
hostOccGBIF <- hostOccGBIF[hostOccGBIF$decimalLatitude != 0 & hostOccGBIF$decimalLongitude != 0, ]
hostOccGBIF <- hostOccGBIF[, colnames(hostOccGBIF) %in% c("species", "Lon", "Lat")]
hostOccGBIF <- hostOccGBIF[!is.na(hostOccGBIF$Lon), ]
hostOccGBIF <- hostOccGBIF[!is.na(hostOccGBIF$Lat), ]
hostOccGBIF <- hostOccGBIF[hostOccGBIF$species != "", ]

# Generating a spatRaster with 1200 x 1200 cells
e <- ext(-180, 180, -60, 90) # left, right, bottom, top
r <- rast(nrows = 1200, ncols = 1200, ext = e, crs = "+proj=longlat") # empty raster with specified dimensions

vectorHost <- vect(hostOccGBIF, 
                   crs = "+proj=longlat", geom = c("Lon", "Lat"))
vectorHost <- crop(vectorHost, e)
rasterHost <- rasterize(vectorHost, r, fun = "length")
plot(rasterHost)

# Optional: Convert into host density maps (adjust 'f' as needed)
f <- 1 # Set factor to 1 since raster already has desired dimensions
rasterHost <- focal(rasterHost, w = 3, fun = mean, na.policy = "all", na.rm = TRUE) # optional smoothing
# Since we already have the desired resolution, no need to aggregate
# r2 <- aggregate(rasterHost, fact = f, fun = sum, na.rm = TRUE) / (2 * f^2)
# Instead, use rasterHost directly
plot(rasterHost, col = vir.pal)

# Save the raster with the desired resolution
writeRaster(rasterHost, "./raster_rosaseae_1200x1200.tif", overwrite = TRUE)
