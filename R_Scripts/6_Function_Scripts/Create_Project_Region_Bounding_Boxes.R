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

