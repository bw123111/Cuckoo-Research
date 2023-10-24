#### Clean 2023 Vegetation Survey Data ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 10/24/2023

# Last modified: 10/24/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


##################### 2023 Data #############################

# load in data
veg <- read.csv("./Data/Vegetation_Data/Raw_Data/2023_Vegetation_Survey_Data.csv") %>% clean_names()
# split it into habitat data (MISO,YELL, OR MUSH OR do GREPL to match any four letters - any three numbers) vs playback data (anything else) -- jk just split this on does the site have an ARU

# get the numbers for each of them- see if they match up

# compare them to playback_all from Clean 2023 Playback Data