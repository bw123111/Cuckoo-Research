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
# Lower left hand corner 104.4353266°W 47.3547923°N 
# Upper right hand corner 104.0427493°W 47.8204085°N 
# 3DEP, not flown during summer
# bbox_YELLRich
xmax_YELLRich <- 104.4353266
xmin_YELLRich <- 104.0427493
ymax_YELLRich <- 47.8204085
ymin_YELLRich <- 47.3547923

# Missouri Richland
# Bottom right hand corner: 104.0435244°W 47.9808051°N # Top left hand corner: 105.1930221°W 48.1781884°N
xmax_MISORich <- 105.1930221
xmin_MISORich <- 104.0435244
ymax_MISORich <- 48.1781884
ymin_MISORich <- 47.9808051




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