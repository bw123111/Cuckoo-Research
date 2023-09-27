#### Randomly Sample Negative Training Data Sites ###################

## Purpose: to randomly sample acoustic files to use as negative training data
# Need 73 30 min files 

# Created 9/25/2023

# Last modified: 9/25/2023


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


##################### Code #############################

# Sample Habitat Points ####### 
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
metadat <- metadat %>% separate(point_id, into = c("site","point"), sep = "-")
miso_hab <- metadat %>% filter(site == "MISO")


# randomly sample from each habitat type 
# How many categories of landcover are there
unique(metadat$landcover_strata)  # 7
# Can do this all in one step
# rand_select <- miso_hab %>% group_by(landcover_strata) %>% sample_n(1)

# separate out by landcover strata then rbind them all together 
## Select three from the sites we're just pulling one from to have backups
# Mixed forest
## m_for <- miso_hab %>% filter(landcover_strata == "Mixed Forest") %>% sample_n(3)
metadat %>% filter(landcover_strata == "Mixed Forest")
## Only mixed forest is along Yellowstone and Musselshell

# Woody Wetlands
wood_wet <- miso_hab %>% filter(landcover_strata == "Woody Wetlands") %>% sample_n(3)

# Emergent Herbaceous Wetlands
herb_wet <- miso_hab %>% filter(landcover_strata == "Emergent Herbaceous Wetlands") %>% sample_n(3)

# Deciduous Forest
d_for <- miso_hab %>% filter(landcover_strata == "Deciduous Forest") %>% sample_n(3)


## Select six from shrub scrub, grassland/herbaceous evergreen forest to have backups
# Evergreen forest
e_for <- miso_hab %>% filter(landcover_strata == "Evergreen Forest") %>% sample_n(6)
# Sampled 6 out of 9 total

# Shrub/Scrub
shrub <- miso_hab %>% filter(landcover_strata == "Shrub/Scrub") %>% sample_n(6)
# sampled 6 out of 12 total

# Grassland/Herbaceous
grass <- miso_hab %>% filter(landcover_strata == "Grassland/Herbaceous") %>% sample_n(6)
# sampled 6 out of 8 total 

# Bind these together to get the dataframe to pull your training data from
sampled_dat <- rbind(wood_wet, herb_wet, d_for, e_for, shrub, grass)

# write this to a .csv
write.csv(sampled_dat, "./Data/Wrangling_CNN_Training_Data/Outputs/Habitat_Points_For_Negative_Data.csv")











# Need 31 other training files 
# Need songmeter and audiomoth 
# region 7 data - get three sites from the far E sites (18 files taking two files each month)
# get one site from the far east sites (CUL, ROB, or SNO) (6 files)

# 4 sites
# MUS along the musselshell?
# One of the south west sites : JDO/KIF/WJH
sw_sites <- list("JDO-1","JDO-2","JDO-3","KIF-1","KIF-2","KIF-3","WJH-1","WJH-2","WJH-3")
selection_sw <- sample(sw_sites, size = 3)
#test <- sample(sw_sites, size = 3) this is working correctly
# One of the north east sites : SNO
ne_sites <- list("SNO-1","SNO-2","SNO-3")
selection_ne <- sample(ne_sites, size = 3)
# One of the south east sites : STI/HOL/ELI/XSS/XFI/SID
se_sites <- list("STI-1","STI-2","STI-3","HOL-1","HOL-2","HOL-3","ELI-1","ELI-2","ELI-3","XSS-1","XSS-2","XSS-3","XFI-1","XFI-2","XFI-3","SID-1","SID-2","SID-3")
selection_se <- sample(se_sites, size = 3)
# One of the north west sites : 82/203/83/84
nw_sites <- list("82-1","82-3","82-4","203-1","203-2","203-2","83-1","83-2","83-3","84-1","84-2","84-3")
selection_nw <- sample(nw_sites, size = 3)


# Total files: 78
