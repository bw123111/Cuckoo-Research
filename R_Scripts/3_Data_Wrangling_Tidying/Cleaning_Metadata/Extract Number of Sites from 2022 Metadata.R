##################### Header ############################

# Purpose: reading in and assessing metadata from 2022 field season 

# I want to kow how many sites we have total

# Status: 

#################### Setup ##########################

# Libraries
library(tidyverse)
library(here)
library(janitor)



################## Code  ################################################
UMBEL_2022 <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_UMBEL.csv")

Skone_2022 <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR7.csv")

Hussey_2022 <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR6.csv")

UMBEL_2021 <- read_csv("./Data/Metadata/Raw_Data/2021_ARUDeployment_Metadata_UMBEL.csv")

UMBELFWP_2020 <- read_csv("./Data/ARU_Deployments_Playbacks_in_One_Sheet/2020_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL_FWP.csv")

# pull out the point-id for all of them
# Clean up the names so you can use the same code
UMBEL_2022 <- UMBEL_2022 %>% rename(point_id=point_ID)
UMBEL_2022 <- UMBEL_2022 %>% clean_names() %>% select(point_id) 


Skone_2022 <- Skone_2022 %>% clean_names() %>% select(point_id)

Hussey_2022 <- Hussey_2022 %>% clean_names() %>% select(point_id)

UMBEL_2021 <- UMBEL_2021 %>% clean_names() %>% select(point_id)

UMBELFWP_2020 <- UMBELFWP_2020 %>% clean_names() %>% select(point_id)


# Put all point IDs into one dataframe
all_points <- rbind(UMBEL_2022,Skone_2022,Hussey_2022,UMBEL_2021,UMBELFWP_2020)

# Separate it into two columns
all_points <- all_points %>% separate(col=point_id,into=c("site","point"),sep="-")
# Pull out the unique ones
sites <- unique(all_points$site)

length(sites)

# see how many in 2020
current_points <- rbind(UMBEL_2022,Skone_2022,Hussey_2022)
current_points <- na.omit(current_points)

current_points <- current_points %>% separate(col=point_id,into=c("site","point"),sep="-")
# Pull out the unique ones
current_sites <- unique(current_points$site)

length(current_sites)




