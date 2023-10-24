#### Clean 2023 ARU Survey123 Deployment Retrieval Data #####

# this is a script to read in the deployment and retrieval data from 2023 and clean the data so it can be used

# Created 9/5/2023

# Last updated 10/24/2023

#### Install and load pacakges #####
packages <- c("tidyverse","janitor", "lubridate", "chron")
source("./R_Scripts/Function_Scripts/Install_Load_Packages.R")
load_packages(packages)



# Clean Deployment data #############################
# read in the data from the Raw Data folder
deploy <- read.csv("./Data/Metadata/Raw_Data/2023_ARUDeployment_Metadata_9-5.csv") %>% clean_names()

# Remove the first six columns that have metadata from Survey123 that we don't need
deploy <- deploy %>% select(-(1:6))

# Clean Initials 
## Change DJ or DEJ to DAJ

# point_id
## Make sure they are all capital case
deploy$point_id <- toupper(deploy$point_id)
deploy$aru_id <- toupper(deploy$aru_id)
deploy$sd_id <- toupper(deploy$sd_card_id)

# change any "_" in the data to "-"
deploy <- deploy %>% mutate(point_id = str_replace(point_id, "_", "-"))
deploy <- deploy %>% mutate(aru_id = str_replace(aru_id, "_", ""))
# remove spaces
deploy <- deploy %>% mutate(aru_id = str_replace(aru_id, " ", ""))
deploy <- deploy %>% mutate(sd_id = str_replace(sd_id, " ", ""))

# fix the spelling of the point_id
## first separate point ID
deploy_sep <- deploy %>% separate(point_id, into = c("site","point"), sep = "-")
## Pull out the unique values of site
sites <- unique(deploy_sep$site)
# Remove the space in the SD card IDs
deploy_sep <- deploy_sep %>% mutate(sd_card_id = str_replace(sd_card_id, " ", ""))
# Remove the space in the ARU ID
deploy_sep <- deploy_sep %>% mutate(aru_id = str_replace(aru_id, " ", ""))
## Replace any unusual values from sites
deploy_sep <- deploy_sep %>% mutate(site = str_replace(site, "MISS", "MISO"))
deploy_sep <- deploy_sep %>% mutate(site = str_replace(site, "MISI", "MISO"))
# Check that MISS is gone
unique(deploy_sep$site)
## Looks good

# Fix the observer column with case_when


# Manually look through the point column to make sure that habitat sites have three numbers
## Need to change MISO 069
## Change row 68, column 6
deploy_sep[68,6] <- "069"
# Change the row with UM022 that should be UM028
deploy_sep[125,17] <- "UM028"
# Change data entry error CU006 to correct ID CO006
deploy_sep[149,17] <- "CO006"
# Change data entry error APR-127 to APR127
deploy_sep[78,17] <- "APR127"
# Change data entry error APR08 to APR008
deploy_sep[57,17] <- "APR008"
# Change data entry error SOO76 to S0076
deploy_sep[146,17] <- "S0076"
# Change data entry error UM007 to UM001
deploy_sep[62,17] <- "UM001"
# Change data entry error UM062 to UM016
deploy_sep[126,17] <- "UM016"
# Change lack of data entry to UM025
deploy_sep[106,17] <- "UM025"
# Change lack of data entry to UM008
deploy_sep[105,17] <- "UM008"
# Change lack of data entry to APR064
deploy_sep[104,17] <- "APR064"


# Turn the date and time column into a datetime column
deploy_sep$datetime <- as.POSIXct(deploy_sep$date_and_time, format = "%m/%d/%Y %I:%M:%S %p")
# Subtract 6 hours from the "datetime" column to convert back to MST
deploy_sep$datetime <- deploy_sep$datetime - as.difftime(6, units = "hours")
# Separate date 
deploy_sep$date <- as.Date(deploy_sep$datetime)
deploy_sep$date_julian <- yday(deploy_sep$date)



# Unite the columns for site and point
deploy <- deploy_sep %>% 
  unite(col = point_id, c("site","point"), sep="-") %>% rename(date_deployed = date, observer_deployment = observer)

# Create a new column for secondary ARU deployments (or just split out the data?) - add a new column for ARU_replaced and fill it with Y if the value for Point ID is not unique in the dataset
#list_dups <- deploy[duplicated(deploy$point_id) == TRUE,]
deploy <- deploy %>% mutate(aru_replaced = ifelse(duplicated(point_id) == FALSE, "N", "Y")) #need to workshop this code a bit
#duplicated(deploy$point_id)
# This isn't flagging the original ones as ones that were replaced 

# rename some of the original columns to make them more concise 
deploy <- deploy %>% rename(moved_over30m = was_the_point_moved_30_m_from_the_original_coordinates, why_moved = why_was_the_point_moved,audiomoth_version = which_audio_moth_version)

# Reorder columns
deploy_final <- deploy %>% select(point_id,
                                x, 
                                y,
                                river,
                                observer_deployment,
                                date_deployed,
                                date_julian,
                                site_use,
                                landcover_strata,
                                moved_over30m,
                                why_moved,
                                point_landcover_description,
                                aru_id,
                                aru_model,
                                audiomoth_version,
                                sd_id,
                                aru_replaced,
                                notes
                                )


# Write the new, cleaned data to ouputs
write.csv(deploy_final,"./Data/Metadata/Outputs/2023_ARUDeployment_MetadataFull_Cleaned10-24.csv", row.names = FALSE)


# Grab just the necessary columns for passing onto FWP
deploy_reduced <- deploy %>% select(point_id, 
                                    x, 
                                    y, 
                                    aru_id, 
                                    sd_card_id, 
                                    site_use, 
                                    river, 
                                    date_deployed)
# Write the new, cleaned data to ouputs
write.csv(deploy_reduced,"./Data/Metadata/Outputs/2023_ARUDeployment_MetadataTrimmed_Cleaned10-5.csv", row.names = FALSE)


# Clean retrieval data ###############

# Read in data from Raw Data folder
retrieve <- read.csv("./Data/Metadata/Raw_Data/2023_ARURetrieval_Metadata_10-23.csv") %>% clean_names()

# Remove the first six columns that have metadata from Survey123 that we don't need
retrieve <- retrieve %>% select(-(1:6))

# make sure all point ID are upper case
retrieve$point_id <- toupper(retrieve$point_id)
# change a couple of the points to the correct format
retrieve[146,4] <- "YELL-150"
retrieve[147,4] <- "YELL-211"
# replace misspelling
retrieve <- retrieve %>% mutate(point_id = str_replace(point_id, "YEL-", "YELL-"))
# separate point ID into site and point for cleaning
retrieve_sep <- retrieve %>% separate(point_id, into = c("site","point"), sep = "-")
# Replace any misspellings
retrieve_sep <- retrieve_sep %>% mutate(site = str_replace(site, "MISI", "MISO"))

# Remove the space in the SD card IDs
retrieve_sep <- retrieve_sep %>% mutate(sd_card_id = str_replace(sd_card_id, " ", ""))
# Remove the space in the ARU ID
retrieve_sep <- retrieve_sep %>% mutate(aru_id = str_replace(aru_id, " ", ""))
# Edit one point to be the correct format
retrieve_sep[42,5] <- "069"
# Edit the monitor at CUL-3
retrieve_sep[24,6] <- "006"
# Edit the ID that should be ROB-2 but was input as ROB-1
retrieve_sep[26,5] <- "2"
# Change the row with UM022 that should be UM028
retrieve_sep[77,7] <- "UM028"
# Add that monitor 1424 had SD card UM026
retrieve_sep[76,7] <- "UM026"
# Add in 
retrieve_sep[82,7] <- "APR033"
# Change data entry error UM007 to UM001
retrieve_sep[13,7] <- "UM001"

# need to convert time to MST from UTC
## Change the date if the time zone bumps it back (goes over midnight)
# Turn the date and time column into a datetime column
retrieve_sep$datetime <- as.POSIXct(retrieve_sep$date_and_time, format = "%m/%d/%Y %H:%M")
# Subtract 6 hours from the "datetime" column to convert back to MST
retrieve_sep$datetime <- retrieve_sep$datetime - as.difftime(6, units = "hours")
# Separate date 
retrieve_sep$date <- as.Date(retrieve_sep$datetime)
retrieve_sep$date_julian <- yday(retrieve_sep$date)


# Unite the columns
retrieve <- retrieve_sep %>% 
  unite(col = point_id, c("site","point"), sep="-") %>% rename(date_retrieved = date, 
                                                               observer_retrieve = observer_initials, 
                                                               container_condition = what_is_the_condition_of_the_aru_container, 
                                                               container_notes = other_what_is_the_condition_of_the_aru_container,
                                                               container_description = breifly_describe_aru_container_condition,
                                                               aru_condition = what_is_the_condition_of_the_aru_itself,
                                                               aru_notes = other_what_is_the_condition_of_the_aru_itself,
                                                               led_status = what_is_the_status_of_the_aru) %>% 
  unite(col = led_notes, c("other_what_is_the_status_of_the_aru","le_ds_status_if_abnormal"), sep = "") %>%
  unite(col = container_notes, c("container_description","container_notes"), sep = "")

# Reorder columns
retrieve_final <- retrieve %>% select(point_id,
                                        x, 
                                        y,
                                        river,
                                        observer_retrieve,
                                        date_retrieved,
                                        date_julian,
                                        aru_id, 
                                        sd_card_id, 
                                        aru_orientation, 
                                        aru_height,
                                        container_condition,
                                        container_notes,
                                        aru_condition,
                                        aru_notes,
                                        led_status,
                                        led_notes)

# Write the new, cleaned data to ouputs
write.csv(retrieve_final,"./Data/Metadata/Outputs/2023_ARURetrieval_MetadataFull_Cleaned10-24.csv", row.names = FALSE)


# Grab just the necessary columns for passing onto FWP
retrieve_reduced <- retrieve %>% select(point_id, 
                                        x, 
                                        y, 
                                        aru_id, 
                                        sd_card_id, 
                                        aru_orientation, 
                                        aru_height, 
                                        date_retrieved,
                                        container_notes,
                                        aru_condition,
                                        aru_notes,
                                        led_status,
                                        led_notes)
# Write the new, cleaned data to ouputs
write.csv(retrieve_reduced,"./Data/Metadata/Outputs/2023_ARURetrieval_MetadataTrimmed_Cleaned10-5.csv", row.names = FALSE)




#### CODE GRAVEYARD #####
# # pull out time
# deploy_sep$time <- sub(".{0,8}(.{8})", "\\1", deploy_sep$datetime)
# deploy_sep$time <- substr(deploy_sep$datetime, nchar(deploy_sep$datetime)-7,nchar(deploy_sep$datetime))
# deploy_sep$time_new <- strptime(deploy_sep$time, format = "%H:%M:%S")
# 
# #deploy_sep$time <- times(format(deploy_sep$datetime, format = "%H:%M:%S"))
# #str_extract(deploy_sep$datetime, [-1,-8])
# str_extract(test3,"([[:digit:]]{8})_([[:digit:]]{6}).WAV")
# # need to convert time to MST from UTC
# # Could also just remove the time column?
# deploy_sep_test <- deploy_sep %>% separate(date_and_time, into = c("date","time","period"), sep = " ", extra = "merge")
# deploy_sep_test$date <- as.Date(deploy_sep_test$date)
# deploy_sep_test$time_new <- strptime(deploy_sep_test$time, format = "%H:%M:%S")



# Convert "time" to POSIXct (date-time)
# deploy_sep$time <- as.POSIXct(deploy_sep$time, format = "%I:%M:%S %p")
# deploy_sep$time_new <- deploy_sep$time - as.difftime(6, units = "hours")


# # Convert "date" to Date
# deploy_sep$date <- as.Date(deploy_sep$date, format = "%m/%d/%Y")

#### Combine Deployment and Retrieval Metadata ############
# not using this, using "Compare 2023 ARUs deployed and retrieved" script already created
# join by point_id
# keep the date retrieved and date deployed 
# retrieve_tojoin <- retrieve %>% select(point_id,
#                                        x,
#                                        y,
#                                        aru_id,
#                                        sd_card_id,
#                                        date_retrieved,
#                                        aru_condition,
#                                        led_status
# )
# 
# deploy_tojoin <- deploy %>% select(point_id,
#                                    aru_id,
#                                    aru_model,
#                                    observer_deployment,
#                                    sd_card_id,
#                                    date_deployed,
#                                    site_use)
# 
# allmeta <- left_join(deploy_tojoin,retrieve_tojoin, by = "point_id")
# check why one of the YELL points doesn't look like it has retrieval data and why some of the deployment points that shouldn't have a match still do 
# try this with anti-join and semi-join??