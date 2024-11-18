# Load necessary libraries
library(terra)
library(USAboundaries)
library(viridis)
library(RColorBrewer) # For the RdYlBu palette


# Step 1: Select only the values that are in California from raster_rosaseae.tif

# Load the resampled raster
raster_rosaseae_resampled <- rast("./raster_rosaseae_1200x1200.tif")

# Get the spatial boundary of California
California <- vect(us_states(states = "California"))

# Ensure the CRS matches between the raster and California boundary
if (!crs(California) == crs(raster_rosaseae_resampled)) {
  California <- project(California, crs(raster_rosaseae_resampled))
}

# Crop the raster to California's extent (optional but efficient)
raster_cropped <- crop(raster_rosaseae_resampled, California)

# Mask the raster to include only the areas within California
raster_california <- mask(raster_cropped, California)

# Plot the result
plot(raster_california, main = "Raster Rosaceae within California")

# Save the masked raster if needed
writeRaster(raster_california, "./raster_rosaseae_cropped.tif", overwrite = TRUE)

# Step 2: Resample the rasters to make them the same extent and resolution

# Read the two raster files
raster_rosaseae <- rast("./raster_rosaseae_cropped.tif")
aggregated_raster_rosaseae <- rast("./aggregated_raster_rosaseae.tif")

# Ensure both rasters have the same Coordinate Reference System (CRS)
if (!crs(raster_rosaseae) == crs(aggregated_raster_rosaseae)) {
  aggregated_raster_rosaseae <- project(aggregated_raster_rosaseae, crs(raster_rosaseae))
}

# Resample aggregated_raster_rosaseae to match the extent and resolution of raster_rosaseae
aggregated_raster_rosaseae_resampled <- resample(aggregated_raster_rosaseae, raster_rosaseae, method = "bilinear")

# Verify that the extent and resolution now match
print(ext(aggregated_raster_rosaseae_resampled))
print(ext(raster_rosaseae))

print(res(aggregated_raster_rosaseae_resampled))
print(res(raster_rosaseae))

# Save the resampled raster if needed
writeRaster(aggregated_raster_rosaseae_resampled, "./aggregated_raster_rosaseae_resampled.tif", overwrite = TRUE)

# Plot the rasters
plot(raster_rosaseae, main = "Raster Rosaceae")
plot(aggregated_raster_rosaseae_resampled, main = "Aggregated Raster Rosaceae Resampled")

# Step 3: Perform the weighted sum

# Load necessary library
library(terra)

# Load the normalized rasters
raster1 <- rast("./raster_rosaseae_cropped.tif")
raster2 <- rast("./aggregated_raster_rosaseae_resampled.tif")

# Define a normalization function
normalize_raster <- function(r) {
  min_val <- global(r, "min", na.rm = TRUE)[[1]]
  max_val <- global(r, "max", na.rm = TRUE)[[1]]
  (r - min_val) / (max_val - min_val)
}

# Normalize each raster
raster1_norm <- normalize_raster(raster1)
raster2_norm <- normalize_raster(raster2)

# Ensure both normalized rasters have the same CRS
if (!crs(raster1_norm) == crs(raster2_norm)) {
  raster1_norm <- project(raster1_norm, crs(raster2_norm))
}

# Ensure both normalized rasters have the same extent and resolution
if (!all(ext(raster1_norm) == ext(raster2_norm)) || !all(res(raster1_norm) == res(raster2_norm))) {
  raster1_norm <- resample(raster1_norm, raster2_norm, method = "bilinear")
}

# Handle NA values:
# Replace NA with 0 in a raster where the other raster has a value
# Only keep NA where both rasters have NA

# Create masks indicating where each raster has NA values
na_mask1 <- is.na(raster1_norm)
na_mask2 <- is.na(raster2_norm)

# Create a mask where both rasters have NA
both_na_mask <- na_mask1 & na_mask2

# Replace NA with 0 in raster1 where raster2 has a value
raster1_filled <- raster1_norm
raster1_filled[na_mask1 & !na_mask2] <- 0

# Replace NA with 0 in raster2 where raster1 has a value
raster2_filled <- raster2_norm
raster2_filled[na_mask2 & !na_mask1] <- 0

# Multiply normalized rasters by weights
raster1_weighted <- raster1_filled * 0.2
raster2_weighted <- raster2_filled * 0.8

# Sum the weighted rasters
weighted_sum <- raster1_weighted + raster2_weighted

# Set the cells to NA where both rasters had NA
weighted_sum[both_na_mask] <- NA

# Plot the result
plot(weighted_sum, main = "Weighted Sum of Rasters with NA Handling")

# Save the result
writeRaster(weighted_sum, "./weighted_sum.tif", overwrite = TRUE)

# Step 4: Plot the normalized rasters and the weighted sum, and save the figure
# Load California boundary at the country level
california_boundary <- vect(us_states(states = "California"))
# 
# palette <- brewer.pal(11, "RdYlBu") # Create a palette with 11 distinct colors
# palette <- colorRampPalette(palette)(100) # Interpolate to 100 colors for smoother gradients
# Define a custom gradient
palette <- colorRampPalette(c("#F2F2F2", "#F25A38", "#8C6746", "#7EADBF","#42708C" ))(100) # Smooth gradient from white to blue to green
# Load California county boundaries
california_counties <- vect(us_counties(state = "California"))

# Define the output file and dimensions
pdf(file = "raster_comparison_with_california_counties.pdf", width = 10, height = 3.3) # Adjust dimensions as needed

# Save current plotting parameters
old_par <- par(no.readonly = TRUE)

# Set up a 1x3 plotting area
par(mfrow = c(1, 3)) # Arrange plots in a single row with three columns

# Plot raster1_norm with California counties
plot(raster1_norm, main = "Rosaceae density based on GBIF data set", col = palette, axes = TRUE, cex.main = 1.5, cex.axis = 1.2, cex.lab = 1.2)
plot(california_counties, add = TRUE, border = "black", lwd = 1)

# Plot raster2_norm with California counties
plot(raster2_norm, main = "Cropped stone-fruits in California based on CroplandCROS", col = palette, axes = TRUE, cex.main = 1.5, cex.axis = 1.2, cex.lab = 1.2)
plot(california_counties, add = TRUE, border = "black", lwd = 1)

# Plot weighted_sum with California counties and weights in the title
plot(weighted_sum, main = "Weighted sum of both densities\n(Weights: 0.2 for GBIF, 0.8 for CroplandCROS)", col = palette, axes = TRUE, cex.main = 1.5, cex.axis = 1.2, cex.lab = 1.2)
plot(california_counties, add = TRUE, border = "black", lwd = 1)

# Reset plotting parameters to original settings
par(old_par)

# Close the graphics device to save the file
dev.off()

cat("The figure with California's county-level boundaries has been saved as 'raster_comparison_with_california_counties.pdf' in the current working directory.\n")
