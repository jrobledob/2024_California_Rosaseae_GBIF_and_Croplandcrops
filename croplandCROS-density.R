#install.packages("remotes")
#remotes::install_github("ropensci/USAboundaries")
# install.packages("USAboundariesData", repos = "https://ropensci.r-universe.dev", type = "source")
library(terra)
library(RColorBrewer)
library(rnaturalearth)
library(USAboundaries)
beauty.pal<-colorRampPalette(rev(brewer.pal(11, "Spectral")), space = "Lab")
California.counties <- vect(us_counties(states = "California"))
lakes <- ne_download(scale = "medium", type = "lakes", category = "physical", returnclass = "sf")

stone_fruts<-rast("./Stone fruits 2023.TIF")

# change all the values in the raster that are 66,67,68,75,210,218,220,223 to 1
stone_fruts[stone_fruts == 66 | stone_fruts == 67 | stone_fruts == 68 | stone_fruts == 75 | stone_fruts == 210 | stone_fruts == 218 | stone_fruts == 220 | stone_fruts == 223] <- 1


# v<-54
# grapes<-grapes/v
# grapes<-project(grapes, "+proj=longlat +datum=WGS84")
plot(stone_fruts, col = "grey50")

ag.factor<-40
ag_raster<-aggregate(stone_fruts, fact = ag.factor,
                     fun = "sum", 
                     na.rm = TRUE) / (ag.factor*ag.factor)

plot(ag_raster, col = beauty.pal(100))
#writeRaster(ag_raster, "./aggregated_raster_rosaseae.tif", overwrite = TRUE)

