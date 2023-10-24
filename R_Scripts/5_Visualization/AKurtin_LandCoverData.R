############### Land Cover Sampling Data ###############

# make a list of required packages
packages <- c("sf","ggmap","terra","raster","tidyverse","rgdal","methods","FedData")

# check if they are installed and if not, install them then read them into the library
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)



# Read in the updated, reprojected raster
lcov <- terra::rast(".\\Data\\Spatial_Data\\NLCD_2019_MTLandcoverProjected.tiff")
# visualize it quickly
plot(lcov)
# The values of the land cover are wrong - developed land should be cultivated crops
levels(lcov)
# Column Red?
cats(lcov)


# Renaming the categories with FedData
# Working with NLCD data: https://smalltownbigdata.github.io/feb2021-landcover/feb2021-landcover.html
# load in the legend 
legend <- pal_nlcd()
# make a vector of all the values we have in our study area and select those from the legend object
vals <- unique(lcov[[1]])
df <- legend[legend$ID %in% vals$Red,]
# There are none of the values in Red that line up with values in legend - R is reading it in as RGB values

# Plot the RGB values https://stackoverflow.com/questions/47393629/r-raster-band-combination-not-showing-rgb
terra::plotRGB(lcov,r=2, g=3, b=4, main = "2019 Land Cover", stretch = "lin")
# ERROR: no valid layer selected
# Select one layer
lcov_subset <- subset(lcov,1)
# try it again
terra::plotRGB(lcov_subset,r=2, g=3, b=4, main = "2019 Land Cover", stretch = "lin")
# SAME ERROR: no valid layer selected ??

