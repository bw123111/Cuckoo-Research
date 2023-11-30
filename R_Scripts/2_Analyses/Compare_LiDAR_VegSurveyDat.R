#### Veg and LiDAR comparison ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 11/24/2023

# Last modified: 11/24/2023


# What I need to go through and look at
## Did each of the playback surveys have 3 surveys at the site?
## Were each surveys within the 3 week period?


#### Setup #################################
packages <- c("data.table","tidyverse","janitor","ggplot2")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


### Code ######

# Read in data
lidar_metric <- read.csv("./Data/Spatial_Data/Comparison_LiDAR_Veg/R623_PolygonCHMSampled113VegBuffer.csv") %>% clean_names() %>% select(point_id, max_height_m)
veg_dat <- read.csv("./Data/Vegetation_Data/Raw_Data/2023_Vegetation_Survey_Data.csv") %>% clean_names()

# OLD merge x and y into a coord_id variable
#veg_dat <- veg_dat %>% unite(coord_id, x, y, sep="_", remove =FALSE)
#lidar_metric <- lidar_metric %>% unite(coord_id, x, y, sep="_", remove =FALSE)

# choose only the columns you want from the veg data
veg <- veg_dat %>% select(point_id, canopy_height, canopy_cover, total_shrub_cover_all_species_combined)

# join into one dataframe
compare_dat <- left_join(lidar_metric, veg, by = "point_id")
# Diagnostics
# see which ones are common to both
common_ids <- veg %>% semi_join(lidar_metric, by = "point_id")
# see which ones are unique to veg
unique_to_veg <- veg %>% anti_join(lidar_metric, by = "point_id")
# See which ones are unique to LiDAR
unique_to_lidar <- lidar_metric %>% anti_join(veg, by = "point_id")


# plot these
ggplot(compare_dat) +
 aes(x = max_height_m, y = canopy_height, colour = point_id) +
 geom_point(shape = "circle", 
 size = 1.5) +
 scale_color_hue(direction = 1) +
 theme_minimal()
# make a plot that plots 
ggplot(aes(x = max_height_m))

# For analysis: 
## Bland-altman analysis
## Residual. sum of squares
# lower SSD indicates closer agreement 

# Create statistics
compare_dat <- compare_dat %>% mutate(ssd = ((max_height_m - canopy_height)^2))
compare_dat <- compare_dat %>% mutate(bland_alt_diff = max_height_m - canopy_height, bland_alt_mean = (max_height_m - canopy_height)/2 )

# Bland-altman plot
plot(compare_dat$bland_alt_mean, compare_dat$bland_alt_diff, xlab = "Mean of measurements", ylab = "Differences between measurements",
     main = "Bland-Altman Plot")
abline(h = mean(compare_dat$bland_alt_diff), col = "red", lty = 2)  # Add a line for the mean difference

mean_diff <- mean(compare_dat$bland_alt_diff, na.rm = TRUE)
sd_diff <- sd(compare_dat$bland_alt_diff, na.rm = TRUE)
loa <- c(mean_diff - 1.96 * sd_diff, mean_diff + 1.96 * sd_diff)  # Limits of agreement
# FIND OUT HOW TO INTERPRET THESE ######
