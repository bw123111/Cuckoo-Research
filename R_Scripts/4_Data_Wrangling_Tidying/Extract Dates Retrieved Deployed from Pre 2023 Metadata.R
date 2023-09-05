#### deployment dates#######

# Purpose: to extract the first day deployed and the first day retrieved from the metadata pre 2023


#################### Setup ##########################

# Libraries
library(tidyverse)
library(here)
library(janitor)



################## Code  ################################################
UMBEL_2022 <- read_csv("./Data/Metadata/2022_ARUDeployment_Metadata_UMBEL.csv")

Skone_2022 <- read_csv("./Data/Metadata/2022_ARUDeployment_Metadata_FWPR7.csv")

Hussey_2022 <- read_csv("./Data/Metadata/2022_ARUDeployment_Metadata_FWPR6.csv")

UMBEL_2021 <- read_csv("./Data/Metadata/2021_ARUDeployment_Metadata_UMBEL.csv")

UMBELFWP_2020 <- read_csv("./Data/2020_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL_FWP.csv")

UMBEL_2022 <- UMBEL_2022 %>% clean_names() 
UMBEL_2022 <- UMBEL_2022 %>% rename(point_id=point_ID)
UMBEL_2022 <- UMBEL_2022 %>% select(point_id,date_deployed,date_retrieved) 


Skone_2022 <- Skone_2022 %>% clean_names() %>% select(point_id,date_deployed,date_retrieved)

Hussey_2022 <- Hussey_2022 %>% clean_names() %>% select(point_id,date_deployed,date_retrieved)

UMBEL_2021 <- UMBEL_2021 %>% clean_names() %>% select(point_id,date_deployed,date_retrieved)
# need to reformat dates

UMBELFWP_2020 <- UMBELFWP_2020 %>% rename(date_retrieved=date_retrived)
UMBELFWP_2020 <- UMBELFWP_2020 %>% clean_names() %>% select(point_id,date_deployed,date_retrieved)


# Put all point IDs into one dataframe
all_points <- rbind(UMBEL_2022,Skone_2022,Hussey_2022,UMBELFWP_2020)
min(all_points$date_deployed)
max(all_points$date_deployed)
