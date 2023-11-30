#### Clean 2023 Playback Data ###################

## Purpose: to read in the raw data files from the playback data, clean them, and output the cleaned data into a new folder

# Created 8/23/2023

# Last modified: 11/21/2023


# What I need to go through and look at
## Did each of the playback surveys have 3 surveys at the site?
## Were each surveys within the 3 week period?


#### Setup #################################
packages <- c("data.table","tidyverse","janitor")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


##################### 2023 Data #############################

# Missing Data: 
# Metadata for LMA#1 and LMA#2
# Brandi's data
# UMBEL data from their crews
# coordinates for playback sites BSB, CLA, LMA

#### METADATA #####
# Read in metadata files
fwp_ak <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWPR6.csv")
fwp_dj <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWP_DANIEL.csv")
fwp_mo <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_FWPR5.csv")
# Waiting on response from Megan about cleaning this
fwp_bs <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_BRS.csv")
umbel_ak <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyMetadata_UMBEL.csv")
# Need to manually clean MMR data and add it to this datasheet

# get all total surveys
pb_all <- rbind(fwp_ak,fwp_dj,umbel_ak,fwp_bs,fwp_mo)
# remove certain lines - already manually cleaned
#pb_all <- pb_all %>% filter(!survey_id %in% c("84#2b","84#3b","203-1_2","^change this to 203_2"))
# Remove observer AES and MIV (didn't transcribe this data)
pb_all <- pb_all %>% filter(!observer %in% c("MIV","AES"))
# separate by site
temp <- pb_all %>% separate(col = survey_id, into = c("site","ID"), sep = "#")
all_sites <- unique(temp$site) # total of 33 sites, 95 surveys

# pull in 2023_playbackpoints-FWP and UMBEL and filter out only the sites with their site in the list of points used in 2023
points_fwp <- read.csv("./Data/Monitoring_Points/2023_PlaybackPoints_FWP.csv") %>% rename(long = x, lat = y) %>% select(point_id, lat,long)
points_umbel <- read.csv("./Data/Monitoring_Points/2023_Playback_Survey_Points_UMBEL.csv") %>% rename(lat = latitude,long = longitude) %>% select(point_id,lat,long) 
# remove the sites that aren't formatted correctly and weren't used
#points_umbel <- points_umbel[-c(60:65),]
points_umbel <- points_umbel %>% filter(!point_id %in% c("SIP-1_old",
                                         "SIP-2_old",
                                         "Playback Site 2",
                                         "Playback Site 3",
                                         "Playback Site 5",
                                         "Playback Site 6",
                                         "Playback Site 7",
                                         "Playback Site 8") )
points_umbel$point_id <- str_replace(points_umbel$point_id,"_new", "")
# Bind fwp and umbel points together
points_all <- rbind(points_fwp,points_umbel)

# filter out the points that are in the 2023 playback data
## OLD
#points_all <- points_all %>% separate(point_id, into = c("site","id"), sep = "-")
#pb23_wcoordd <- left_join(all_sites,points_all, by = "point_id")

# Separate points all into site and point
points_all <- points_all %>% separate(point_id, into = c("site","id"), sep = "-", remove = FALSE)
# Filter out the point that aren't in the temp ID
pb23_wcoord <- points_all %>% filter(site %in% temp$site)

# write the playback points to a .csv
#write.csv(points_avg, "./Data/Playback_Results/2023/Outputs/2023_PlaybackSiteLocations_All_10-25.csv", row.names = FALSE)
write.csv(pb23_wcoord, "./Data/Playback_Results/2023/Outputs/2023_PlaybackSiteLocations_All_11-28.csv", row.names = FALSE)


# average the sites
points_avg <- pb23_wcoord %>% separate(col = point_id, into = c("site","id"), sep = "-") %>% group_by(site) %>% summarize(lat_avg = mean(lat), long_avg = mean(long))
# export this for use in ArcGIS
write.csv(points_avg, "./Data/Playback_Results/2023/Outputs/2023_PlaybackSiteLocationsAvg_All_11-28.csv", row.names = FALSE)

#pb_locs <- points_avg %>% filter(site %in% all_sites) # none missing - this looks good
# Total surveys
# 95 surveys for all the sites
# 3 points at each site except WBB that had 2
94 * 3 # 282
1 * 2 # 2
# Total number of surveys 
282 + 2 # 284


#### PLAYBACK DATA ####
# Manually cleaned up to remove spaced 11/21

# Pull out only NOBI, BBCU or YBCU from my data (UMBEL and FWPR6)
ak_umbel <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackPtCtSurveyData_UMBEL.csv") %>% clean_names()
ak_r6 <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackPtCtSurveyData_FWPR6.csv") %>% clean_names()
daniel <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackSurveyData_FWP_DANIEL.csv")
all_23 <- rbind(ak_umbel,ak_r6,daniel)
all_cuckoo <- all_23 %>% filter(species %in% c("BBCU","YBCU","NOBI")) # use this in conjunction with the other data

all_cuckoo <- all_cuckoo %>% mutate(bbcu_detection = ifelse(species == "BBCU", 1, 0), ybcu_detection = ifelse(species == "YBCU", 1, 0))
cuckoo_summed <- all_cuckoo %>% group_by(survey_id) %>% summarize(detection_hist_bbcu = max(bbcu_detection),detection_hist_ybcu = max(ybcu_detection)) %>% arrange()


# From Daniel's playback data: figure out a way to apply the start time across 1-5 as well as PB1-PB5

# For all data:
## remove the colon from the times

### MISC #####
# # Pull out the number of surveys from Region 6
# fwp <- rbind(fwp_ak,fwp_dj)
# # separate the first column
# temp <- fwp %>% separate(col = survey_id, into = c("site","ID"), sep = "#")
# r6_surveys <- temp %>% filter(site %in% c("ROB","SNO","CUL","CLA"))
# r7_surveys <- temp %>% filter(!(site %in% c("ROB","SNO","CUL","CLA")))
# Old: 29 sites, 3 surveys at each site = 87 playback surveys
