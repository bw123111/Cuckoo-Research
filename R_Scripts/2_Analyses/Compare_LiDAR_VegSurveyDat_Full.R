#### Veg and LiDAR Comparison Full ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 1/15/2024 from copying over the preliminary script

# Last modified: 1/15/2024


# What I need to go through and look at
## Did each of the playback surveys have 3 surveys at the site?
## Were each surveys within the 3 week period?


#### Setup #################################
packages <- c("tidyverse","janitor","ggplot2")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


### Code ######

# Read in LiDAR data
# Sum of pixels in each plot
lidar_countpixels <- read.csv("./Data/Spatial_Data/Comparison_LiDAR_Veg/Raw_Data_fromArcPro/LiDARComp_All_SumPixelsTable.csv") %>% clean_names() %>% select(point_id,sum)
# 147 observations
# Average height per plot
lidar_height <- read.csv("./Data/Spatial_Data/Comparison_LiDAR_Veg/Raw_Data_fromArcPro/LiDARComp_All_MeanCanopyHeight.csv") %>% clean_names() #%>% select(point_id, max_height_m)
# make a new column to convert the height column
lidar_height <- lidar_height %>% mutate(lidar_mean_height_m = round(mean/1000000, digits = 2)) %>% select(point_id,lidar_mean_height_m)

# Read in canopy cover
lidar_cancov <-  read.csv("./Data/Spatial_Data/Comparison_LiDAR_Veg/Raw_Data_fromArcPro/LiDARComp_All_CanopyCoverSum.csv") %>% clean_names() %>% select(point_id, count)
# This only has 129 observations?
# Figure out which ones aren't included 
unique_to_height <- lidar_height %>% anti_join(lidar_cancov, by = "point_id")
# These are all plots with a canopy cover/height of 0
# Join the cancov to height
lidar_metric <- left_join(lidar_countpixels,lidar_height, by = "point_id")
lidar_metric <- left_join(lidar_metric, lidar_cancov, by = "point_id")
# change the values of count that are NA to 0
lidar_metric <- lidar_metric %>%
  mutate(count = ifelse(is.na(count) == TRUE, 0, count))

# Remove 105-2 and 105-1 since the LiDAR data doesn't look right
lidar_cancov <- lidar_cancov %>% filter(!point_id %in% c("105-2","105-1"))
lidar_height <- lidar_height %>% filter(!point_id %in% c("105-2","105-1"))
lidar_countpixels <- lidar_countpixels %>% filter(!point_id %in% c("105-2","105-1"))

# Create a new column for the percent canopy
lidar_metric <- lidar_metric %>% mutate(lidar_percent_canopy = round((count/sum) * 100,digits = 2))


# Read in the vegetation data
veg_dat <- read.csv("./Data/Vegetation_Data/Outputs/2023_VegSurveyData_Cleaned1-15.csv") %>% clean_names()

# choose only the columns you want from the veg data
veg <- veg_dat %>% select(point_id, canopy_height, canopy_cover,x,y)

# join into one dataframe
compare_dat <- left_join(lidar_metric, veg, by = "point_id")
# remove MISO-181 which doesn't have a veg survey
compare_dat <- compare_dat %>% filter(!point_id == "MISO-181")
# AME-2 NA for canopy height ???????????????????????????????????????????????

###### Add on Data #####
# Find a way to add in the data source and where the LiDAR data comes from
# Add in a 3DEP column to note whether it was collected with 3DEP
# Add in a year collected column
# Add in an in-season collected column (June - September)
# make a bounding box for each area
# Create a conditional mutate to add in the values for each column
xmax_YELLRich <- 104.4353266
xmin_YELLRich <- 104.0427493
ymax_YELLRich <- 47.8204085
ymin_YELLRich <- 47.3547923

xmax_MISORich <- 105.1930221
xmin_MISORich <- 104.0435244
ymax_MISORich <- 48.1781884
ymin_MISORich <- 47.9808051


# Make a list of bounding boxes
YellRICH_box = list(x_min = 104.0427493, 
                    x_max = 104.4353266, 
                    y_min = 47.3547923, 
                    y_max = 47.8204085, 
                    year = 2020, 
                    season = "not_summer")
MisoRICH_box = c(x_min = 104.0435244, 
                 x_max = 105.1930221, 
                 y_min = 47.9808051, 
                 y_max = 48.1781884, 
                 year = 2025, 
                 season = "summer")
# Add more bounding boxes as needed
bounding_boxes <- list(YellRICH_box,MisoRICH_box)

test <- compare_dat
test[,"region"] <- NA
test <- compare_dat %>% mutate(
   region = case_when(
   x >= bounding_boxes[["YellRICH_box"]]["x_min"] & 
     x <= bounding_boxes[["YellRICH_box"]]["x_max"] & 
      y >= bounding_boxes[["YellRICH_box"]]["y_min"] & 
      y <= bounding_boxes[["YellRICH_box"]]["y_max"] ~ "YellRICH_box",
    x = bounding_boxes[["MisoRICH_box"]]["x_min"] & 
      x <= bounding_boxes[["MisoRICH_box"]]["x_max"] &
      y >= bounding_boxes[["MisoRICH_box"]]["y_min"] & 
      y <= bounding_boxes[["MisoRICH_box"]]["y_max"] ~ "MisoRICH_box",
    .default = "UNK"))
###### START HERE ##############################################
# Error in `mutate()`:
#   ℹ In argument: `region = case_when(...)`.
# Caused by error:
#   ! `region` must be size 149 or 1, not 0.


# Split these case_whens up
    year_collected = case_when(
      region == "YellRICH_box" ~ bounding_boxes[["YellRICH_box"]]["year"],
      region == "MisoRICH_box" ~ bounding_boxes[["MisoRICH_box"]]["year"],
      .default = "UNK"),
    season_collected = case_when(
      region == "YellRICH_box" ~ bounding_boxes[["YellRICH_box"]]["season"],
      region == "MisoRICH_box" ~ bounding_boxes[["MisoRICH_box"]]["season"],
      .default = "UNK")
  )

# Example usage:
test <- assign_year_season2(compare_dat, x_col = "x", y_col = "y")


apply(X = compare_dat,MARGIN = 1, FUN = assign_year_season)


# Pull out only the columns you need 
compare_dat %>% select(lidar_mean_height_m,lidar_percent_canopy,canopy_height,canopy_cover,x,y)


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


#### CODE GRAVEYARD #####
# assign_year_season2 <- function(data, x_col, y_col) {
#   # Define your bounding boxes
#   YellRICH_box <- list(x_min = 104.0427493, 
#                        x_max = 104.4353266, 
#                        y_min = 47.3547923, 
#                        y_max = 47.8204085, 
#                        year = 2020, 
#                        season = "not_summer")
#   
#   MisoRICH_box <- list(x_min = 104.0435244, 
#                        x_max = 105.1930221, 
#                        y_min = 47.9808051, 
#                        y_max = 48.1781884, 
#                        year = 2025, 
#                        season = "summer")
#   
#   # Add more bounding boxes as needed
#   bounding_boxes <- list(YellRICH_box, MisoRICH_box)
#   
#   data <- data %>% mutate(
#     region = case_when(
#       x_col >= bounding_boxes[["YellRICH_box"]][["x_min"]] & 
#         x_col <= bounding_boxes[["YellRICH_box"]][["x_max"]] & 
#         y_col >= bounding_boxes[["YellRICH_box"]][["y_min"]] & 
#         y_col <= bounding_boxes[["YellRICH_box"]][["y_max"]] ~ "YellRICH_box",
#       x_col >= bounding_boxes[["MisoRICH_box"]][["x_min"]] & 
#         x_col <= bounding_boxes[["MisoRICH_box"]][["x_max"]] &
#         y_col >= bounding_boxes[["MisoRICH_box"]][["y_min"]] & 
#         y_col <= bounding_boxes[["MisoRICH_box"]][["y_max"]] ~ "MisoRICH_box",
#       TRUE ~ "UNK"),
#     year_collected = case_when(
#       region == "YellRICH_box" ~ as.character(bounding_boxes[["YellRICH_box"]][["year"]]),
#       region == "MisoRICH_box" ~ as.character(bounding_boxes[["MisoRICH_box"]][["year"]]),
#       TRUE ~ "UNK"),
#     season_collected = case_when(
#       region == "YellRICH_box" ~ as.character(bounding_boxes[["YellRICH_box"]][["season"]]),
#       region == "MisoRICH_box" ~ as.character(bounding_boxes[["MisoRICH_box"]][["season"]]),
#       TRUE ~ "UNK")
#   )
#   
#   return(data)
# }
# 
# # Example usage:
# test <- assign_year_season2(compare_dat, x_col = "x", y_col = "y")
# 
# 
# 
# 
# 
# 
# 
# assign_year_season <- function(data) {
#   # Define your bounding boxes
#   # Example: Bounding boxes for different regions
#   bounding_boxes <- list(
#     YellRICH_box = c(x_min = 104.0427493, x_max = 104.4353266, y_min = 47.3547923, y_max =47.8204085, year = 2020, season = "not_summer"),
#     MisoRICH_box = c(x_min = 104.0435244, x_max = 105.1930221, y_min = 47.9808051, y_max = 48.1781884, year = 2025, season = "summer"),
#     # Add more bounding boxes as needed
#   )
#   
#   # Check which bounding box the point falls into
#   for (box_name in names(bounding_boxes)) {
#     box <- bounding_boxes[[box_name]]
#     if (x >= box["x_min"] && x <= box["x_max"] && y >= box["y_min"] && y <= box["y_max"]) {
#       # Assign year and season based on the bounding box
#       region <- as.character(box_name)
#       year_collected <- box["year"]
#       season_collected <- box["season"]
#       break
#     }
#   }
#   newdat <- data %>% mutate(region = region, year_collected = year_collected, season_collected = season_collected)
#   return(newdat)
# }
# 
# # Example usage:
# test <- assign_year_season(compare_dat)
# 
# # We're doing too much here
# assign_year_season2 <- function(data, x_col, y_col) {
#   # Define your bounding boxes
#   
#   
#   data <- data %>% mutate(
#     region = case_when(
#       x_col >= bounding_boxes[["YellRICH_box"]]["x_min"] & 
#         x_col <= bounding_boxes[["YellRICH_box"]]["x_max"] & 
#         y_col >= bounding_boxes[["YellRICH_box"]]["y_min"] & 
#         y_col <= bounding_boxes[["YellRICH_box"]]["y_max"] ~ "YellRICH_box",
#       x_col = bounding_boxes[["MisoRICH_box"]]["x_min"] & 
#         x_col <= bounding_boxes[["MisoRICH_box"]]["x_max"] &
#         y_col >= bounding_boxes[["MisoRICH_box"]]["y_min"] & 
#         y_col <= bounding_boxes[["MisoRICH_box"]]["y_max"] ~ "MisoRICH_box",
#       .default = "UNK"),
#     year_collected = case_when(
#       region == "YellRICH_box" ~ bounding_boxes[["YellRICH_box"]]["year"],
#       region == "MisoRICH_box" ~ bounding_boxes[["MisoRICH_box"]]["year"],
#       .default = "UNK"),
#     season_collected = case_when(
#       region == "YellRICH_box" ~ bounding_boxes[["YellRICH_box"]]["season"],
#       region == "MisoRICH_box" ~ bounding_boxes[["MisoRICH_box"]]["season"],
#       .default = "UNK")
#   )
#   
#   return(data)
# }
# # Example usage:
# test <- assign_year_season2(compare_dat, x_col = "x", y_col = "y")
