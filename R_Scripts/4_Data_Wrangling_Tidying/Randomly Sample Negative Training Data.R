#### Randomly Sample Negative Training Data ###################

## Purpose: to randomly sample acoustic files to use as negative training data
# Need 73 30 min files 

# Created 9/25/2023

# Last modified: 9/25/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


##################### Code #############################

# Habitat Data 
# Read in deployment metadata from 2023  
# Separate out only files that start with MISO
# Randomly draw sites from each habitat type 
## 7 habitat types 
## 3 sites? (draw a couple extra in case the audio isn't complete)
# draw from each month (June, July, August)
# from each month, draw one diurnal and one nocturnal file
# 7 habitats x 1 site each x 3 months x 2 time periods each month (total of 42 habitat files)
# sample one extra shrub scrub and one extra evergreen forest (54 habitat files)

# Metadata
metadat <- read.csv("./Data/Metadata/Outputs/2023_ARUDeployment_Metadata_Cleaned9-12.csv")

# How many categories of landcover are there
unique(metadat$landcover_strata)  # 7






# Need 31 other training files 
# Need songmeter and audiomoth 
# region 7 data - get three sites from the far E sites (18 files taking two files each month)
# get one site from the far east sites (CUL, ROB, or SNO) (6 files)


# Total files: 78
