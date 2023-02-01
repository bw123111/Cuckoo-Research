##########################Splitting up Metadata Files into Metadata and Playback Files ###################


###############Header########################

# Created 10/7/2022
## Purpose: to take in files that have deployment metadata and playback data and pull out playback data


# Libraries used
library(tidyverse)
library(dplyr)
library(janitor)
library(naniar)


##################### 2020 Data #############################
# Read in the data
data_2020 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2020_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL_FWP.csv")

#file.choose()

# Rename the column for the point ID
#data_2020 <- data_2020 %>% rename(point_id=`2020point_ID`)

# Clean up the names so they're easier to work with
data_2020 <- clean_names(data_2020)


# Select just the information relevant to the playbacks
playbacks_2020 <- data_2020 %>% select(point_id,lat,long, date_deployed,playback_cuckoo_detected)

# Clean up the rest of the data
## Correct the mispelled column name
#playbacks_2021 <- playbacks_2021 %>% rename(playback_detection=playbcack_cuckoo_detection)

## Make na into actual NAs
#playbacks_2021 <- playbacks_2021 %>% replace_with_na(replace= list(playback_detection="na"))

write_csv(playbacks_2020,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2020_BBCUPlayback_Results_UMBEL.csv")


################## 2021 Data #################################

# Read in the data for 2021
data_2021 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2021_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL.csv")

#file.choose()

# Clean up the names so they're easier to work with
data_2021 <- clean_names(data_2021)
# Chop off all the NAs at the end
data_2021 <- data_2021 %>% filter(is.na(Site)==FALSE)
# Select just the information relevant to the playbacks
playbacks_2021 <- data_2021 %>% select(point_id,lat,long, date_deployed,playbcack_cuckoo_detection)

# Clean up the rest of the data
## Correct the mispelled column name
playbacks_2021 <- playbacks_2021 %>% rename(playback_detection=playbcack_cuckoo_detection)

## Make na into actual NAs
playbacks_2021 <- playbacks_2021 %>% replace_with_na(replace= list(playback_detection="na"))

write_csv(playbacks_2021,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2021_BBCUPlayback_Results_UMBEL.csv")


# Write it to a .csv file
