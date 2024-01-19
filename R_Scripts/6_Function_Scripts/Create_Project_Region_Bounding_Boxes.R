######### Establish Bounding Boxes for Regions #################

# This is a script for creating boundaries for each of the regions on the MT Cuckoo Project

# Created: 12/21/2023
# Last updated: 12/21/2023


######## Install and Load Packages #########
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


####### Establish Boundaries ######

# Project bounding box 
# Bounding box coordinates from MRLC download 2/15:
ymin_proj <- 44.94910
ymax_proj <- 49.03619
xmin_proj <- -112.35849
xmax_proj <- -103.97674


# UMBEL/Upper MISO
# 108.0743650°W 47.6626152°N - easternmost extent of the UMBEL deployments
# 108.7668825°W 47.4279918°N - southernmost edge of the UMBEL deployments

# only values that are less than -108.0743650
# only values that are greater than 47.4279918
xmin_upperMISO <- -108.0743650
ymin_upperMISO <- 47.4279918

# Yellowstone Richland
# Lower left hand corner -104.4353266°W 47.3547923°N 
# Upper right hand corner -104.0427493°W 47.8204085°N 
# 3DEP, not flown during summer
# bbox_YELLRich
xmin_YELLRich <- -104.4353266
xmax_YELLRich <- -104.0427493
ymax_YELLRich <- 47.8204085
ymin_YELLRich <- 47.3547923

# Missouri Richland
# Bottom right hand corner: -104.0435244°W 47.9808051°N # Top left hand corner: -105.1930221°W 48.1781884°N
xmin_MISORich <- -105.1930221
xmax_MISORich <- -104.0435244
ymax_MISORich <- 48.1781884
ymin_MISORich <- 47.9808051

# Missouri Valley
# Lower left coordinates: -106.4741166°W 47.9971349°N # Top right coordinates: -106.1843971°W 48.0806277°N 
xmin_MISOValley <- -106.4741166
xmax_MISOValley <- -106.1843971
ymin_MISOValley <- 47.9971349
ymax_MISOValley <- 48.0806277

# Missouri Fergus/Blaine Counties
# Lower left coordinates: -109.7891580°W 47.5657318°N # Top right coordinates: -108.2747290°W 47.8317349°N 
xmin_MISOFergBlaine <- -109.7891580
xmax_MISOFergBlaine <- -108.2747290
ymin_MISOFergBlaine <- 47.5657318
ymax_MISOFergBlaine <- 47.8317349


# Yellowstone Treasure, Rosebud, Custer, Dawson
# Lower left coordinates: -107.4708394°W 46.1472362°N # Top right coordinates: -104.3824226°W 47.3548756°N 
xmin_YELLTrasRoseCustDaws <- -107.4708394
xmax_YELLTrasRoseCustDaws <- -104.3824226
ymin_YELLTrasRoseCustDaws <- 46.1472362
ymax_YELLTrasRoseCustDaws <- 47.3548756

# Yellowstone Yellowstone
# Lower left coordinates: -108.7819310°W 45.6249239°N # Top right coordinates: -107.4667606°W 46.1721385°N 
xmin_YELLYellowstone <- -108.7819310
xmax_YELLYellowstone <- -107.4667606
ymin_YELLYellowstone <- 45.6249239
ymax_YELLYellowstone <- 46.1721385

# Missouri Choteau
# Lower left coordinates: -110.5511274°W 47.8640621°N # Top right coordinates: -110.4149778°W 47.9380156°N 
xmin_MISOChoteau <- -110.5511274
xmax_MISOChoteau <- -110.4149778
ymin_MISOChoteau <- 47.8640621
ymax_MISOChoteau <- 47.9380156

# Musselshell Wheatland
# Lower left coordinates: -110.2777646°W 46.3604738°N # Top right coordinates: -109.3957428°W 46.6263620°N 
xmin_MUSHWheatland <- -110.2777646
xmax_MUSHWheatland <- -109.3957428
ymin_MUSHWheatland <- 46.3604738
ymax_MUSHWheatland <- 46.6263620


# Pulled from Compare_LiDAR_VegSurveyDat_Full:
# Make a list of lists with the bounding boxes and the metadata from the lidar
YELLRich  <- list(x_max = -104.0427493, 
                  x_min = -104.4353266,
                  y_max = 47.8204085, 
                  y_min = 47.3547923, 
                  year = "2020", 
                  season = "not_summer",
                  protocol = "3DEP",
                  river = "YELL",
                  county = "Richland",
                  region = "YELLRich")
MISORich <- list(x_max = -104.0435244, 
                 x_min = -105.1930221, 
                 y_min = 47.9808051, 
                 y_max = 48.1781884, 
                 year = "2020", 
                 season = "not_summer",
                 protocol = "3DEP",
                 river = "MISO",
                 county = "Richland",
                 region = "MISORich")
MISOValley <- list(x_max = -106.1843971,
                   x_min = -106.4741166,
                   y_max = 48.0806277,
                   y_min = 47.9971349,
                   year = "2018",
                   season = "not_summer",
                   protocol = "not_3DEP",
                   river = "MISO",
                   county = "Valley",
                   region = "MISOValley")
MISOFergBlaine <- list(x_max = -108.2747290,
                       x_min = -109.7891580,
                       y_max = 47.8317349,
                       y_min = 47.5657318,
                       year =  "2020_2021",
                       season = "summer",
                       protocol = "3DEP",
                       river = "MISO",
                       county = "Fergus_Blaine",
                       region = "MISOFergBlaine")
YELLTreasRoseCustDaws <- list(x_max = -104.3824226,
                              x_min = -107.4708394,
                              y_max = 47.3548756,
                              y_min = 46.1472362,
                              year = "2019",
                              season = "summer",
                              protocol = "not_3DEP",
                              river = "YELL",
                              county = "Treasure_Rose_Custer_Dawson",
                              region = "YELL_TreasRoseCustDawson")
# Add more bounding boxes as needed
bounding_boxes <- list(YELLRich,MISORich,MISOValley,MISOFergBlaine,YELLTreasRoseCustDaws)


# TESTING CODE # CREATING A FUNCTION TO TEST BOUNDING BOXES
# Create a function 
create_cols <- function(xmax,xmin,ymax,ymin,year,season) {
  # Check if the coordinates provided fall within xmax, xmin, and ymax, ymin provided
  #
}
# Write a function that checks if the coordinates in the x and y columns of a dataframe fall within the 

assign_year_season <- function(x, y) {
  # Define your bounding boxes
  # Example: Bounding boxes for different regions
  bounding_boxes <- list(
    box1 = c(x_min = 10, x_max = 20, y_min = 30, y_max = 40),
    box2 = c(x_min = 20, x_max = 30, y_min = 40, y_max = 50),
    # Add more bounding boxes as needed
  )
  
  # Initialize variables
  region <- NA
  
  # Check which bounding box the point falls into
  for (box_name in names(bounding_boxes)) {
    box <- bounding_boxes[[box_name]]
    if (x >= box["x_min"] && x <= box["x_max"] && y >= box["y_min"] && y <= box["y_max"]) {
      # Assign year and season based on the bounding box
      region <- as.character(box_name)
      break
    }
  }
  
  return(c(region))
}

# Example usage:
your_data <- mutate(your_data, c("year_collected", "season_collected") := pmap(list(x, y), assign_year_seas