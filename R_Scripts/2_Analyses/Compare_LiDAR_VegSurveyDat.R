#### Veg and LiDAR comparison ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 11/24/2023

# Last modified: 12/4/2023


# What I need to go through and look at
## Did each of the playback surveys have 3 surveys at the site?
## Were each surveys within the 3 week period?


#### Setup #################################
packages <- c("data.table","tidyverse","janitor","ggplot2")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


### Code ######

# Read in data
lidar_height <- read.csv("./Data/Spatial_Data/Comparison_LiDAR_Veg/MISO_FergBlaine_AvgHeight2.csv") %>% clean_names() #%>% select(point_id, max_height_m)
# make a new column to convert the height column
lidar_height <- lidar_height %>% mutate(lidar_mean_height_m = round(mean/1000000, digits = 2)) %>% select(point_id,lidar_mean_height_m)
# Read in canopy cover
lidar_cancov <-  read.csv("./Data/Spatial_Data/Comparison_LiDAR_Veg/MISO_FergBlaine_CanopyCover2.csv") %>% clean_names()
# Create a new column for the percent canopy
# remove 105-2 and 105-1 since the CHM is weird here
lidar_cancov <- lidar_cancov %>% mutate(lidar_percent_canopy = round((sum/392)*100, digits = 2)) %>% filter(!point_id %in% c("105-2","105-1")) %>% select(point_id, lidar_percent_canopy)
# Combine them into one LiDAR metric column
lidar_metric <- left_join(lidar_cancov, lidar_height, by = "point_id")
# see which ones are common to both
common_lidar <- lidar_cancov %>% semi_join(lidar_height, by = "point_id")
# see which ones are unique to the height metric
unique_to_height <- lidar_height %>% anti_join(lidar_cancov, by = "point_id")
# Why didnt' zonal statistics work for these????

veg_dat <- read.csv("./Data/Vegetation_Data/Outputs/2023_VegSurveyData_Cleaned12-3.csv") %>% clean_names()



# choose only the columns you want from the veg data
veg <- veg_dat %>% select(point_id, canopy_height, canopy_cover,x,y)

# join into one dataframe
compare_dat <- left_join(lidar_metric, veg, by = "point_id")
# remove MISO-181 which doesn't have a veg survey
compare_dat <- compare_dat %>% filter(!point_id == "MISO-181")
# Diagnostics
# see which ones are common to both
#common_ids <- veg %>% semi_join(lidar_metric, by = "point_id")
# see which ones are unique to veg
#unique_to_veg <- veg %>% anti_join(lidar_metric, by = "point_id")
# See which ones are unique to LiDAR
#unique_to_lidar <- lidar_metric %>% anti_join(veg, by = "point_id")

# Create a new value for the difference between the two
compare_dat <- compare_dat %>% mutate(cover_diff = (canopy_cover-lidar_percent_canopy),
                                      height_diff = (canopy_height-lidar_mean_height_m))
# Changed away from absolute value so I could see if there is directionality in the way things are changing

#### Normalize this data ######
# Create a function to perform min-max normalization
normalize <- function(data, col_name) {
  new_col_name <- paste0(col_name, "_normalized")
  
  if (new_col_name %in% colnames(data)) {
    print(paste("Column", new_col_name, "already exists in the dataframe."))
    return(data)
  } else if (col_name %in% colnames(data)) {
    col_min <- min(data[[col_name]], na.rm = TRUE)
    col_max <- max(data[[col_name]], na.rm = TRUE)
    data[[new_col_name]] <- round((data[[col_name]] - col_min) / (col_max - col_min), digits = 3)
    return(data)
  } else {
    print(paste("Column", col_name, "not found in the dataframe."))
    return(NULL)
  }
}

# Normalize the columns for lidar metrics
compare_dat <- normalize(compare_dat,"lidar_mean_height_m")
compare_dat <- normalize(compare_dat,"lidar_percent_canopy")
# Create a new column that estimates composite index for density
compare_dat <- compare_dat %>% mutate(lidar_density = lidar_mean_height_m_normalized+lidar_percent_canopy_normalized)
# Normalize the columns for veg survey metrics
compare_dat <- normalize(compare_dat,"canopy_height")
compare_dat <- normalize(compare_dat,"canopy_cover")
# Create a new column that estimates composite index for density
compare_dat <- compare_dat %>% mutate(survey_density = canopy_height_normalized+canopy_cover_normalized)





#### Initial comparison of agreement #####
# We want to see how well the two different types of data agree with each other 
# This informs the way that the different methods are biased or trending towards
# plot these
ggplot(compare_dat) +
 aes(x = lidar_mean_height_m, y = canopy_height) +
 geom_point(shape = "circle", 
 size = 1.5, color = "green4") +
  labs(title = "Comparison of Canopy Height Estimates", x = "LiDAR Average Canopy Height Estimate (m)", y = "Survey Average Canopy Height Estimate (m)")  +
  scale_x_continuous(limits=c(0,22),breaks = seq(0,20, by = 5))+
  scale_y_continuous(limits=c(0,22),breaks = seq(0,20, by = 5))+
 theme_minimal()
# Save this plot
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/CanopyHeight_SurveyLiDARComparison.jpeg", width=6, height=6)


ggplot(compare_dat) +
  aes(x = lidar_percent_canopy, y = canopy_cover) +
  geom_point(shape = "circle", 
             size = 1.5, color ="green4") +
  labs(title = "Comparison of Canopy Cover Estimates", x = "LiDAR Percent Canopy Cover Estimate", y = "Survey Percent Canopy Cover Estimate") +
  theme_minimal()
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/CanopyCover_SurveyLiDARComparison.jpeg", width=6, height=6)


# Descriptive stats
max(compare_dat$lidar_mean_height_m)
# # lidar_mean_height goes form 0 - 18.19
max(compare_dat$lidar_percent_canopy)
# # lidar canopy goes from .26 - 99.49
max(compare_dat$canopy_height, na.rm = TRUE)
# # canopy height goes from .01 to 21
# min(compare_dat$canopy_cover, na.rm = TRUE)
# # canopy cover goes from 0.01 - 100

#### Analysis ######
# For analysis: 
## Bland-altman analysis - not sure how to interpret this one
## Residual. sum of squares - this estimates how closely a model fits the data
# lower SSD indicates closer agreement 

# Create statistics
compare_dat <- compare_dat %>% mutate(ssd_height = ((lidar_mean_height_m - canopy_height)^2))
compare_dat <- compare_dat %>% mutate(ssd_cover = ((lidar_percent_canopy - canopy_cover)^2))
compare_dat <- compare_dat %>% mutate(bland_alt_diff_height = lidar_mean_height_m - canopy_height, bland_alt_mean_height = (lidar_mean_height_m - canopy_height)/2 )

# Bland-altman plot
plot(compare_dat$bland_alt_mean_height, compare_dat$bland_alt_diff_height, xlab = "Mean of measurements", ylab = "Differences between measurements",
     main = "Bland-Altman Plot")
abline(h = mean(compare_dat$bland_alt_diff), col = "red", lty = 2)  # Add a line for the mean difference

mean_diff <- mean(compare_dat$bland_alt_diff_height, na.rm = TRUE)
sd_diff <- sd(compare_dat$bland_alt_diff_height, na.rm = TRUE)
loa <- c(mean_diff - 1.96 * sd_diff, mean_diff + 1.96 * sd_diff)  # Limits of agreement

#### Initial Plots with Point Values #####
# More so than whether or not the values line up, we are more interested in how the points cluster together, and whether they're clustering the same in different plots 
# plot lidar derived height against lidar derived canopy cover to see how they cluster
ggplot(compare_dat) +
  aes(x = lidar_mean_height_m, y = lidar_percent_canopy, colour = point_id) +
  geom_point(shape = "circle", 
             size = 1.5) +
  theme_minimal() + 
  labs(title = "LiDAR Vegetation Density", x = "Mean Canopy Height (m)", y = "Percent Canopy Cover")


# plot these
ggplot(compare_dat) +
  aes(x = canopy_height, y = canopy_cover, colour = point_id) +
  geom_point(shape = "circle", 
             size = 1.5) +
  theme_minimal() + 
  labs(title = "Survey Vegetation Density", x = "Mean Canopy Height (m)", y = "Percent Canopy Cover")



#### Output Plots #####
# plot lidar derived height against lidar derived canopy cover with the metric for lidar density as the fill
ggplot(compare_dat) +
  aes(x = lidar_mean_height_m, y = lidar_percent_canopy, colour = lidar_density) +
  geom_point(shape = "circle", 
             size = 2) +
  scale_color_gradient(low = "orange", high = "blue" ) + 
  scale_x_continuous(limits=c(0,22),breaks = seq(0,20, by = 5))+
  labs(title = "LiDAR Vegetation Density", x = "Mean Canopy Height (m)", y = "Percent Canopy Cover") +
  theme_minimal() + 
  theme(legend.position = "none")
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/LiDAROnlyDensity.jpeg", width=10, height=6)
  
#Plot survey height against survey canopy cover with the metric for survey density as the fil
ggplot(compare_dat) +
  aes(x = canopy_height, y = canopy_cover, colour = survey_density) +
  geom_point(shape = "circle", 
             size = 2) +
  scale_color_gradient(low = "orange", high = "blue") +
  scale_x_continuous(limits=c(0,22),breaks = seq(0,20, by = 5))+
  labs(title = "Survey Vegetation Density", x = "Mean Canopy Height (m)", y = "Percent Canopy Cover")+
  theme_minimal()
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/SurveyOnlyDensity.jpeg", width=10, height=6)
  
# This allows a visual comparison, but could we also try taking the differences between the two?
ggplot(compare_dat) +
  aes(x = lidar_density, y = survey_density) +
  geom_point() +
  labs(title = "Comparison of Survey and LiDAR Density Metrics", x = "LiDAR Density Metric", y = "Survey Density Metric") +
  theme_minimal()
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/LiDARvsSurveyDensityMetric.jpeg", width=6, height=6)
  
# Now try mixing and matching these
# Survey data plotted with LiDAR Density colors
ggplot(compare_dat) +
  aes(x = canopy_height, y = canopy_cover, colour = lidar_density) +
  geom_point(shape = "circle", 
             size = 2) +
  scale_color_gradient(low = "orange", high = "blue") +
  labs(title = "Survey Vegetation Density with LiDAR Density Colors", x = "Mean Canopy Height (m)", y = "Percent Canopy Cover")+
  scale_x_continuous(limits=c(0,22),breaks = seq(0,20, by = 5))+
  theme_minimal() + 
  theme(legend.position = "none")
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/SurveyPlot_LiDARDensityColor.jpeg", width=10, height=6)

# LiDAR data plotted with survey density colors
ggplot(compare_dat) +
  aes(x = lidar_mean_height_m, y = lidar_percent_canopy, colour = survey_density) +
  geom_point(shape = "circle", 
             size = 2) +
  scale_color_gradient(low = "orange", high = "blue") + 
  scale_x_continuous(limits=c(0,22),breaks = seq(0,20, by = 5))+
  labs(title = "LiDAR Vegetation Density with Survey Density Colors", x = "Mean Canopy Height (m)", y = "Percent Canopy Cover")+
  theme_minimal()+
  theme(legend.position = "none")
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/LiDARPlot_SurveyDensityColor.jpeg", width=10, height=6)




# Plot these  to see the variation
ggplot(compare_dat) +
  aes(x = x, y = y, color = cover_diff)+
  geom_point() +
  scale_color_gradient(low = "red", high = "blue")+
  labs(title = "Spatial Distribution of Difference Between Canopy Cover Measurements", x = "Longitude", y = "Latitude") +
  theme_minimal()
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/MappingDifferencesinCanopyCoverEstimates.jpeg", width=10, height=6)


ggplot(compare_dat) +
  aes(x = x, y = y, color = height_diff)+
  geom_point() +
  scale_color_gradient(low = "red", high = "blue")+
  #scale_color_gradient(low = "black", high = "red")+
  labs(title = "Spatial Distribution of Difference Between Canopy Height Measurements", x = "Longitude", y = "Latitude") +
  theme_minimal() 
ggsave("./Data/Spatial_Data/Comparison_LiDAR_Veg/Outputs/MappingDifferencesinCanopyHeightEstimates.jpeg", width=10, height=6)

# Most change is in these points: (MISO-022, MISO-065, MISO-188, MISO-196, MISO-017, MISO-191, MISO-177, and MISO-171)




##### CODE GRAVEYARD ######
# # Figure out what to do with divide by zeros 
# # mutate zeros into 0.01 so the number is still small but calculable
# compare_dat$canopy_height <- ifelse(compare_dat$canopy_height == 0, 0.01, compare_dat$canopy_height)
# compare_dat$canopy_cover <- ifelse(compare_dat$canopy_cover == 0, 0.01, compare_dat$canopy_cover)
# # Take the ratio of height and cover for each point and make it into a "density" point
# # Do this for lidar and veg survey and take the different (want difference to be close to zero)
# compare_dat <- compare_dat %>% mutate(lidar_density = lidar_percent_canopy/lidar_mean_height_m,
#                                       veg_density = canopy_cover/canopy_height)

# 
# lidar_density_col <- compare_dat %>% select(lidar_density)
# ggplot(data = lidar_density_col, aes(x=lidar_density, y = 0)) +
#   geom_point(size = 3) 


#plot them with the color corresponding to the density measurement 
# keep the same density measurement accross graphs

# Normalize the metrics using min-max normalization
# compare_dat$lidar_height_normalized <- ((compare_dat$lidar_mean_height_m - min(compare_dat$lidar_mean_height_m))/ (max(compare_dat$lidar_mean_height_m) - min(compare_dat$lidar_mean_height_m)))

# OLD merge x and y into a coord_id variable
#veg_dat <- veg_dat %>% unite(coord_id, x, y, sep="_", remove =FALSE)
#lidar_metric <- lidar_metric %>% unite(coord_id, x, y, sep="_", remove =FALSE)