#### Split ARU Metadata by Region #####

# this is a script to split up the data into each region 

# Created 9/11/2023

# Last updated 9/11/2023

#### Install and load pacakges #################################
packages <- c("tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


##### Code #########################################

# Read in cleaned data
all_metadata <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_Metadata_Cleaned9-7.csv")

# Split out Upper Missouri River
# 108.0743650°W 47.6626152°N - easternmost extent of the UMBEL deployments
# 108.7668825°W 47.4279918°N - southernmost edge of the UMBEL deployments

upper_miso <- all_metadata %>% filter(x < -108.0743650 & y > 47.4279918)

# Split out Lower Missouri River 
# Coordinates for southern and westernmost boundary 47.963980, -106.414798

lower_miso <- all_metadata %>% filter(x > -106.414798 & y > 47.963980)


# Split out Yellowstone
# Coordinates for Nothernmost and westernmost boundary 47.751310, -107.7825650

yell <- all_metadata %>% filter(x > -107.7825650 & y < 47.751310)


# 107.7825650°W 46.7159112°N 
# Split out Region 5/Musselshell

mush <- all_metadata %>% filter(x < -107.7825650 & y < 46.7159112)
