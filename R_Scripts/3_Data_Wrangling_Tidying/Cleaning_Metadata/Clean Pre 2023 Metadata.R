#### Clean 2022-2021 ARU Metadata #####

# this is a script to read in the deployment and retrieval data from 2023 and clean the data so it can be used

# Created 1/22/2024

# Last updated 1/22/2024

#### Install and load pacakges #####
packages <- c("tidyverse","janitor", "lubridate", "chron")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)



# Set a data template #############################
# 2023 data: make all the metadata match this
metadata_template <- read.csv('./Data/Metadata/Outputs/2023_ARUDeployment_MetadataFull_Cleaned10-24.csv') %>% clean_names()
str(metadata_template)

# make a function to join the metadata to the playback data
join_data_metadata <- function(data, metadata, join){
  newdat <- left_join(data, metadata, by = join)
  # maybe in the future select/reorder certain columns
}
# Read in ARU inventory  
arus <- read.csv('./Data/ARU_Inventory/Raw_Data/2023_ARUInventory_UMBEL_FWP.csv') %>% clean_names()
arus_UMBEL <- arus %>% filter(aru_owner == "APR") %>% select(aru_id,aru_model)
arus_R5 <- arus %>% filter(aru_owner == "FWPR5") %>% select(aru_id,aru_model)
arus_R6 <- arus %>% filter(aru_owner == "FWPR6") %>% select(aru_id,aru_model)
arus_R7 <- arus %>% filter(aru_owner == "FWPR7") %>% select(aru_id,aru_model)

#### 2021 Data #####
UMBEL_2021_raw <- read.csv('./Data/Metadata/Raw_Data/2021_ARUDeployment_Metadata_UMBEL.csv') %>% clean_names()

# Filter out the ones that weren't deployed
UMBEL_2021 <- UMBEL_2021_raw %>% filter(deployed == 'y')
# Rename lat and long
UMBEL_2021 <- UMBEL_2021 %>% rename(observer_deployment = obs)
str(UMBEL_2021)
# Make data into M/D/YYYY format for date deployed and then convert to Julian 
UMBEL_2021 <- UMBEL_2021 %>% mutate(date_deployed = case_when(
  date_deployed == '25-May' ~ '5/25/2021',
  date_deployed == '10-Jun' ~ '6/10/2021',
  date_deployed == '11-Jun' ~ '6/11/2021',
  date_deployed == '12-Jun' ~ '6/12/2021',
  date_deployed == '18-Jun' ~ '6/18/2021',
  date_deployed == '25-Jun' ~ '6/25/2021'
))
# Convert deployed to a date
UMBEL_2021$date_dep <- as.POSIXct(UMBEL_2021$date_deployed, format = "%m/%d/%Y")
UMBEL_2021$date_deployed <- as.Date(UMBEL_2021$date_dep)
# Make a Julian Date for deployed
UMBEL_2021$date_deploy_julian <- yday(UMBEL_2021$date_deployed)
# Convert retrieved to a date
UMBEL_2021$date_ret <- as.POSIXct(UMBEL_2021$date_retrieved, format = "%m/%d/%Y")
UMBEL_2021$date_retrieved <- as.Date(UMBEL_2021$date_ret)
# Make a Julian Date for deployed
UMBEL_2021$date_retrieve_julian <- yday(UMBEL_2021$date_retrieved)

# Make column for river
UMBEL_2021 <- UMBEL_2021 %>% mutate(river = "Missouri")
# Make a column for ARU model
UMBEL_2021 <- UMBEL_2021 %>% mutate(aru_type = "AudioMoth")
# Make a column for site use
UMBEL_2021 <- UMBEL_2021 %>% mutate(site_use = "Repeat Survey Point")
# combine directions and comments into notes
UMBEL_2021 <- UMBEL_2021 %>% mutate(notes = paste(directions, comments))

# add on AudioMoth version from inventory
# Replace O with nothing in aru_id
UMBEL_2021$aru_id <- str_replace(UMBEL_2021$aru_id, 'O','')
# Left join by aru ID
UMBEL_2021 <- left_join(UMBEL_2021,arus_UMBEL, by = "aru_id")
# Change the formatting for data_recorded
UMBEL_2021 <- UMBEL_2021 %>% mutate(data_recorded = case_when(
  data_recorded == 'Yes' ~ 'Y',
  data_recorded == 'No' ~ 'N'
))

# Reorder columns
# These are slightly different than the 2023 data becuase it contains different information
UMBEL_2021_final <- UMBEL_2021 %>% select(point_id,
                                  lat, 
                                  long,
                                  river,
                                  observer_deployment,
                                  date_deployed,
                                  date_deploy_julian,
                                  date_retrieved,
                                  date_retrieve_julian,
                                  site_use,
                                  #landcover_strata,
                                  #moved_over30m,
                                  #why_moved,
                                  #point_landcover_description,
                                  aru_id,
                                  aru_type,
                                  aru_model,
                                  sd_id,                                  
                                  data_recorded,
                                  #aru_replaced,
                                  notes
)


# Write the new, cleaned data to ouputs
write.csv(UMBEL_2021_final,"./Data/Metadata/Outputs/2021_ARUDeployment_Retrieval_Metadata_UMBEL_Cleaned1-22.csv", row.names = FALSE)




#### 2022 Data #####
#### 2022 UMBEL ####
# Read in raw data
UMBEL_2022 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_UMBEL.csv") %>% clean_names()
# Work out coordinates
# the data with all of the correct coordinates is 
umbel22_locs <- read.csv('./Data/Cuckoo_Presence_Absence_ARU/Model_1.0/2022_ARUDetections_Combined_Cleaned10-9.csv', fileEncoding = 'latin1')
UMBEL_2022 <- join_data_metadata(UMBEL_2022,umbel22_locs,'point_id')

# Rename columns to match 
UMBEL_2022 <- UMBEL_2022 %>% rename(observer_deployment = observer_deployed, notes = retrieval_notes, data_recorded = data_recorded_on_s_dcard_y_n)

# Convert deployed to a date
UMBEL_2022$date_dep <- as.POSIXct(UMBEL_2022$date_deployed, format = "%m/%d/%Y")
UMBEL_2022$date_deployed <- as.Date(UMBEL_2022$date_dep)
# Make a Julian Date for deployed
UMBEL_2022$date_deploy_julian <- yday(UMBEL_2022$date_deployed)
# Do the same for retrieval
UMBEL_2022$date_ret <- as.POSIXct(UMBEL_2022$date_retrieved, format = "%m/%d/%Y")
UMBEL_2022$date_retrieved <- as.Date(UMBEL_2022$date_ret)
# Make a Julian Date for deployed
UMBEL_2022$date_retrieve_julian <- yday(UMBEL_2022$date_retrieved)

# Make column for river
UMBEL_2022 <- UMBEL_2022 %>% mutate(river = "Missouri")
# Make a column for ARU model
UMBEL_2022 <- UMBEL_2022 %>% mutate(aru_type = "AudioMoth")
# Make a column for site use
UMBEL_2022 <- UMBEL_2022 %>% mutate(site_use = "Repeat Survey Point")
# add on AudioMoth version from inventory
# Left join by aru ID
UMBEL_2022 <- left_join(UMBEL_2022,arus_UMBEL, by = "aru_id")
# change the formatting for data_recorded
UMBEL_2022 <- UMBEL_2022 %>% mutate(data_recorded = case_when(
  data_recorded == 'y' ~ 'Y',
  data_recorded == 'n' ~ 'N'
))
 
UMBEL_2022_habitat <- UMBEL_2022 %>% select(point_id,
                                            x_overstory_size_1_small_2_med_3_large_mature, 
                                            overstory_0_no_trees_1_few_trees_2_gallery_forest, 
                                            understory_riparian_shrub_and_saplings_1_few_2_moderate_3_swimmingly_dense, 
                                            habitat_description)
# Write the new, cleaned data to ouputs
write.csv(UMBEL_2022_habitat,"./Data/Vegetation_Data/Outputs/2022_HabitatDescriptions_UMBEL_Cleaned1-22.csv", row.names = FALSE)

# Reorder columns
# These are slightly different than the 2023 data becuase it contains different information
UMBEL_2022_final <- UMBEL_2022 %>% select(point_id,
                                          lat, 
                                          long,
                                          river,
                                          observer_deployment,
                                          date_deployed,
                                          date_deploy_julian,
                                          date_retrieved,
                                          date_retrieve_julian,
                                          site_use,
                                          #landcover_strata,
                                          #moved_over30m,
                                          #why_moved,
                                          #point_landcover_description,
                                          aru_id,
                                          aru_type,
                                          aru_model,
                                          sd_id,                                  
                                          data_recorded,
                                          #aru_replaced,
                                          notes
)
# Write the new, cleaned data to ouputs
write.csv(UMBEL_2022_final,"./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_UMBEL_Cleaned1-22.csv", row.names = FALSE)


#### 2022 Region 5 ####
R5_2022 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR5.csv") %>% clean_names()
# Rename columns
R5_2022 <- R5_2022 %>% rename(lat = latitude, long = longitude, observer_deployment = observer, notes = navigation_notes)
# Convert deployed to a date
R5_2022$date_dep <- as.POSIXct(R5_2022$date_deployed, format = "%m/%d/%Y")
R5_2022$date_deployed <- as.Date(R5_2022$date_dep)
# Make a Julian Date for deployed
R5_2022$date_deploy_julian <- yday(R5_2022$date_deployed)
# Do the same for retrieval
R5_2022$date_ret <- as.POSIXct(R5_2022$date_retrieved, format = "%m/%d/%Y")
R5_2022$date_retrieved <- as.Date(R5_2022$date_ret)
# Make a Julian Date for deployed
R5_2022$date_retrieve_julian <- yday(R5_2022$date_retrieved)
# Make column for river
R5_2022 <- R5_2022 %>% separate(point_id, into = c("site_id", "point"), sep = "-" , remove = FALSE)
R5_2022 <- R5_2022 %>% mutate(river = case_when(
  site_id == 'JDO' ~ "Yellowstone",
  site_id == 'WJH' ~ "Yellowstone",
  site_id == 'KIF' ~ "Yellowstone",
  site_id == 'MUS' ~ "Musselshell",))
# Make a column for ARU model
R5_2022 <- R5_2022 %>% mutate(aru_type = "SongMeter")
# Make a column for site use
R5_2022 <- R5_2022 %>% mutate(site_use = "Repeat Survey Point")
# add on AudioMoth version from inventory
# Left join by aru ID
R5_2022 <- left_join(R5_2022,arus_R5, by = "aru_id")


# Reorder columns
# These are slightly different than the 2023 data becuase it contains different information
R5_2022_final <- R5_2022 %>% select(point_id,
                                          lat, 
                                          long,
                                          river,
                                          observer_deployment,
                                          date_deployed,
                                          date_deploy_julian,
                                          date_retrieved,
                                          date_retrieve_julian,
                                          site_use,
                                          #landcover_strata,
                                          #moved_over30m,
                                          #why_moved,
                                          #point_landcover_description,
                                          aru_id,
                                          aru_type,
                                          aru_model,
                                          sd_id,                                  
                                          data_recorded,
                                          #aru_replaced,
                                          notes
)
# Write the new, cleaned data to ouputs
write.csv(R5_2022_final,"./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_FWPR5_Cleaned1-22.csv", row.names = FALSE)


#### 2022 R6 #####
R6_2022 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR6.csv") %>% clean_names()
R6_2022 <- R6_2022 %>% mutate(observer_deployment = 'NH')
R6_2022 <- R6_2022 %>% rename(notes = directions_to_aru, habitat_description = habitat_type_tree_and_shrub_species_cover_age_class_weeds_etc)
# Convert deployed to a date
R6_2022$date_dep <- as.POSIXct(R6_2022$date_deployed, format = "%m/%d/%Y")
R6_2022$date_deployed <- as.Date(R6_2022$date_dep)
# Make a Julian Date for deployed
R6_2022$date_deploy_julian <- yday(R6_2022$date_deployed)
# Do the same for retrieval
R6_2022$date_ret <- as.POSIXct(R6_2022$date_retrieved, format = "%m/%d/%Y")
R6_2022$date_retrieved <- as.Date(R6_2022$date_ret)
# Make a Julian Date for deployed
R6_2022$date_retrieve_julian <- yday(R6_2022$date_retrieved)

# Make column for river
R6_2022 <- R6_2022 %>% mutate(river = "Missouri")
# Make a column for site use
R6_2022 <- R6_2022 %>% mutate(site_use = "Repeat Survey Point", data_recorded = "Y")
# add on AudioMoth version from inventory
# Left join by aru ID
R6_2022 <- left_join(R6_2022,arus_R6, by = "aru_id")
# change the formatting for data_recorded
R6_2022 <- R6_2022 %>% mutate(aru_model = ifelse(is.na(aru_model),'AM1.2.0',aru_model))
R6_2022 <- R6_2022 %>% mutate(aru_type = case_when(
  aru_model == 'AM1.2.0' ~ 'AudioMoth',
  aru_model == 'SMM' ~ 'SongMeter'
))
# Make a column for ARU model
R6_2022_habitat <- R6_2022 %>% select(point_id, habitat_description)

# Write the new, cleaned data to ouputs
write.csv(R6_2022_habitat,"./Data/Vegetation_Data/Outputs/2022_HabitatDescriptions_FWPR6_Cleaned1-22.csv", row.names = FALSE)


# These are slightly different than the 2023 data becuase it contains different information
R6_2022_final <- R6_2022 %>% select(point_id,
                                    lat, 
                                    long,
                                    river,
                                    observer_deployment,
                                    date_deployed,
                                    date_deploy_julian,
                                    date_retrieved,
                                    date_retrieve_julian,
                                    site_use,
                                    #landcover_strata,
                                    #moved_over30m,
                                    #why_moved,
                                    #point_landcover_description,
                                    aru_id,
                                    aru_type,
                                    aru_model,
                                    sd_id,                                  
                                    data_recorded,
                                    #aru_replaced,
                                    notes
)
# Write the new, cleaned data to ouputs
write.csv(R6_2022_final,"./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_FWPR6_Cleaned1-22.csv", row.names = FALSE)




#### 2022 R7 ######
R7_2022 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_MetadataSpacesRemoved_FWPR7.csv") %>% clean_names()
# Rename columns
R7_2022 <- R7_2022 %>% rename(lat = latitude, long = longitude, observer_deployment = observer, notes = comments)
# Convert deployed to a date
R7_2022$date_dep <- as.POSIXct(R7_2022$date_deployed, format = "%m/%d/%Y")
R7_2022$date_deployed <- as.Date(R7_2022$date_dep)
# Make a Julian Date for deployed
R7_2022$date_deploy_julian <- yday(R7_2022$date_deployed)
# Do the same for retrieval
R7_2022$date_ret <- as.POSIXct(R7_2022$date_retrieved, format = "%m/%d/%Y")
R7_2022$date_retrieved <- as.Date(R7_2022$date_ret)
# Make a Julian Date for deployed
R7_2022$date_retrieve_julian <- yday(R7_2022$date_retrieved)
# Make column for river
R7_2022 <- R7_2022 %>% mutate(river = "Yellowstone")
# Make a column for site use
R7_2022 <- R7_2022 %>% mutate(site_use = "Repeat Survey Point", data_recorded = "Y_needs_double_check")
# Edit the aru data
arus_R7$aru_id <- str_replace(arus_R7$aru_id, ' R7 ' ,'')
# Left join by aru ID
R7_2022 <- left_join(R7_2022,arus_R7, by = "aru_id")
R7_2022 <- R7_2022 %>% mutate(aru_type = case_when(
  aru_model == 'AM1.2.0' ~ 'AudioMoth',
  aru_model == 'SMM' ~ 'SongMeter'
))


# No habitat description provided 

# These are slightly different than the 2023 data becuase it contains different information
R7_2022_final <- R7_2022 %>% select(point_id,
                                    lat, 
                                    long,
                                    river,
                                    observer_deployment,
                                    date_deployed,
                                    date_deploy_julian,
                                    date_retrieved,
                                    date_retrieve_julian,
                                    site_use,
                                    #landcover_strata,
                                    #moved_over30m,
                                    #why_moved,
                                    #point_landcover_description,
                                    aru_id,
                                    aru_type,
                                    aru_model,
                                    sd_id,                                  
                                    data_recorded,
                                    #aru_replaced,
                                    notes
)
# Write the new, cleaned data to ouputs
write.csv(R7_2022_final,"./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_FWPR7_Cleaned1-22.csv", row.names = FALSE)


# Read in all of the updated .csvs and combine them into one 
metadataFWP_2022 <- rbind(R5_2022_final,R6_2022_final,R7_2022_final)
write.csv(metadataFWP_2022,"./Data/Metadata/Outputs/2022_ARUDeployment_Retrieval_Metadata_FWPALL_Cleaned1-22.csv", row.names = FALSE)

##### Code Graveyard #####
# make_date_juliandate <- function(data,datecolumn){
#   data$date_dep <- as.POSIXct(data$datecolumn, format = "%m/%d/%Y")
#   print(date$date_dep)
#   data$datecolumn <- as.Date(data$date_dep)
#   # Make a Julian Date for deployed
#   data$date_deploy_julian <- yday(data$date_deployed)
#   return(data)
# }
# clean the ARU ID in the region 6 data
# clean_aru_r622 <- function(r6_22_data){
#   r6_data_new <- r6_22_data %>% mutate(aru_id = case_when(
#     aru_point == "05169_1" ~ "SMM05169",
#     aru_point == "05169_2" ~ "SMM05222",
#     aru_point == "05169_3" ~ "SMM05075",
#     aru_point == "FWP_R6_001_C4" ~ "FWPR6001",
#     aru_point == "FWP_R6_002_C5" ~ "FWPR6002",
#     aru_point == "FWP_R6_003_C6" ~ "FWPR6003",
#     aru_point == "FWP_R6_004_C7" ~ "FWPR6004",
#     aru_point == "FWP_R6_005_C8" ~ "FWPR6005",
#     aru_point == "FWP_R6_006_C9" ~ "FWPR6006")) 
#   r6_data_new <- r6_data_new %>% select(-aru_point)
#   return(r6_data_new)
# }