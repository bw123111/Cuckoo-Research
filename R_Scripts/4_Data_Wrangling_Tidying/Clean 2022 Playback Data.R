####### Clean 2022 Playback Data ########


# A script to read in playback data from 2020, 2021, and 2022 and export a clean file for use in analysis and visualization
# First formatting them for use in ARCGIS - summarizing cuckoo detection for each site 
# Next formatting them for us in modeling (later)

# STATUS need to run the UMBEL part of the code again with the completed monitoring_points data

# Created 10/6/2023

# Last updated 10/6/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor","lubridate")
source("./R_Scripts/6_Function_Scripts/Install_Load_Packages.R")
load_packages(packages)


#### Functions ######

# Create a new column for BBCU detections and YBCU detections
create_binary_cuckoo <- function(dataframe){
  updated_dataframe <- dataframe %>%
    mutate(
      bbcu = ifelse(species == "BBCU", 1,
                    ifelse(species %in% c("NOBI", "YBCU"), 0, NA))) %>%
    mutate(
      ybcu = ifelse(species == "YBCU", 1,
                    ifelse(species %in% c("NOBI", "BBCU"), 0, NA)))
  # make bbcu and ybcu a factor????
  return(updated_dataframe)
}


# Clean interval column
# Change 1-5 in interval column to M1 etc
# Logic behind this is to make it the same data type as PB1 etc
clean_intervals <- function(dataframe){
  updated_dataframe <- dataframe %>% mutate(interval = case_when(
    interval == "1" ~ "M1",
    interval == "2" ~ "M2",
    interval == "3" ~ "M3",
    interval == "4" ~ "M4",
    interval == "5" ~ "M5",
    interval == "M1" ~ "M1",
    interval == "M2" ~ "M2",
    interval == "M3" ~ "M3",
    interval == "M4" ~ "M4",
    interval == "M5" ~ "M5",
    interval == "PB1" ~ "PB1",
    interval == "PB2" ~ "PB2",
    interval == "PB3" ~ "PB3",
    interval == "PB4" ~ "PB4",
    interval == "PB5" ~ "PB5"))
  return(updated_dataframe)
}

# clean the ARU ID in the region 6 data
clean_aru_r622 <- function(r6_22_data){
  r6_data_new <- r6_22_data %>% mutate(aru_id = case_when(
    aru_point == "05169_1" ~ "SMM05169",
    aru_point == "05169_2" ~ "SMM05222",
    aru_point == "05169_3" ~ "SMM05075",
    aru_point == "FWP_R6_001_C4" ~ "FWPR6001",
    aru_point == "FWP_R6_002_C5" ~ "FWPR6002",
    aru_point == "FWP_R6_003_C6" ~ "FWPR6003",
    aru_point == "FWP_R6_004_C7" ~ "FWPR6004",
    aru_point == "FWP_R6_005_C8" ~ "FWPR6005",
    aru_point == "FWP_R6_006_C9" ~ "FWPR6006")) 
  r6_data_new <- r6_data_new %>% select(-aru_point)
  return(r6_data_new)
}

# Clean ARUs r5 or R7 2022
clean_arus <- function(dataframe){
  dataframe$aru_id <- str_replace(dataframe$aru_id,"AMU", "AM")
  dataframe$aru_id <- str_replace(dataframe$aru_id," ", "")
  return(dataframe)
}

# convert the date column into a date format
make_date_format <- function(dataframe){
  dataframe$date <- as.Date(dataframe$date, format = "%m/%d/%Y")
  # may need to edit this if different dataframes have different formats
  return(dataframe)
}

# rename the long and lat columns in the metadata and select only the columns needed for cleaning playback data
rename_cols_and_select <- function(metadata){
  if("latitude" %in% colnames(metadata)){
    metadata <- metadata %>% rename(lat = latitude)
  }
  if("longitude" %in% colnames(metadata)){
    metadata <- metadata %>% rename(long = longitude)
  }
  metadata_foruse <- metadata %>% select(point_id, aru_id, lat, long)
  return(metadata_foruse)
}

# make a function to join the metadata to the playback data
join_playback_metadata <- function(playback, metadata){
  newdat <- left_join(playback, metadata, by = "aru_id")
  # maybe in the future select/reorder certain columns
}


# make a function to join the metadata to the playback data
join_playback_metadata_bypoint <- function(playback, metadata){
  newdat <- left_join(playback, metadata, by = "point_id")
  # maybe in the future select/reorder certain columns
}

# Create a survey ID column that is just the site, a #, then 1 (since in 2022 only one survey was conducted) 
separate_site_make_survey_id <- function(dataframe){
  dataframe <- dataframe %>% 
    separate(point_id, into = c("site_id", "point"), sep = "-" , remove = FALSE) %>%
    mutate(survey_id = paste(site_id,"#1"))
  dataframe$survey_id <- str_replace(dataframe$survey_id," ", "")
  return(dataframe)
}

# Make a function to create a new column that wasn't entered into the dataset and fill it with "no_data" values
make_unentered_columns <- function(dataframe,column_name){
  dataframe <- dataframe %>% mutate(!!column_name := "no_data")
  return(dataframe)
}


# select the columns in the correct order
reorder_final_cols <- function(dataframe){
  final_dataframe <- dataframe %>% select(obs,
                                          date,
                                          time,
                                          survey_id, 
                                          site_id, 
                                          point_id,
                                          lat,
                                          long,
                                          time, 
                                          interval, 
                                          species, 
                                          bbcu, 
                                          ybcu, 
                                          distance, 
                                          bearing, 
                                          how, 
                                          visual, 
                                          call, 
                                          sex, 
                                          cluster, 
                                          notes)
}
#### Code ############

# Region 7 #################


# Need to create a new script for removing the U and space from the Region 7 playback data and joining it to the right name from the metadata, then writing it to outputs 

## NEED TO FIGURE OUT A WAY TO REFORMAT TIME ?????????????????????????????

# Read in playback data
r7PB_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_R7_PlaybackSurveyData.csv") %>% clean_names() %>% rename(aru_id = point)
# Change the first row with "NOBI " to remove the space afterwards
r7PB_22[1,8] <- "NOBI"
# changing data entry error based off of the ARU inventory from 2023 - SMM04965 exists, SMM04956 doesn't
r7PB_22[31:40,4] <- "SMM04965"

# create a column for the cuckoo detections
r7PB_22 <- create_binary_cuckoo(r7PB_22)
# Clean the interval column
r7PB_22 <- clean_intervals(r7PB_22)
# Clean the ARU_ID column
r7PB_22 <- clean_arus(r7PB_22)
# Make the date column a date
r7PB_22 <- make_date_format(r7PB_22)

# Read in metadata
r7_metadat <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_MetadataSpacesRemoved_FWPR7.csv") %>% clean_names()
# rename columns and select only the necessary
r7_metadat <- rename_cols_and_select(r7_metadat)

# join the playback and the metadata
r7_22 <- join_playback_metadata(r7PB_22,r7_metadat)

# separate out the site and make a survey_id column
r7_22 <- separate_site_make_survey_id(r7_22)

# Now check which columns are missing and add them in or rename
r7_22 <- r7_22 %>% rename(bearing = cuckoo_bearing)
r7_22 <- r7_22 %>% rename(cluster = cluster_sz) # not sure what cluster code is
r7_22 <- r7_22 %>% rename(notes = bird_notes) 
r7_22 <- make_unentered_columns(r7_22,"call")

#choose the final columns to include in playback data
r7_22_final <- reorder_final_cols(r7_22)

# WRITE REGION 7 DATA
write.csv(r7_22_final,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_FWPR7_Cleaned10-6.csv", row.names = FALSE)




# Region 5 is fine, will need to get this data and clean it later but for now it's good
r5_22 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR5.csv") %>% 
  clean_names()
test <- clean_arus(r5_22)
# works well






# clean ARU ID R6 2022
r6PB_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_BBCUPlaybackSessionResults_FWPR6.csv") %>% clean_names() 

# create a column for the cuckoo detections
r6PB_22 <- create_binary_cuckoo(r6PB_22)
# Clean the interval column
r6PB_22 <- clean_intervals(r6PB_22)
# Clean the ARU_ID column
r6PB_22 <- clean_aru_r622(r6PB_22)
# Make the date column a date
r6PB_22 <- make_date_format(r6PB_22)

# Read in metadata
r6_metadat <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR6.csv") %>% clean_names()
# rename columns and select only the necessary
r6_metadat <- rename_cols_and_select(r6_metadat)

# join the playback and the metadata
r6_22 <- join_playback_metadata(r6PB_22,r6_metadat)

# separate out the site and make a survey_id column
r6_22 <- separate_site_make_survey_id(r6_22)

# Now check which columns are missing and add them in or rename
r6_22 <- r6_22 %>% rename(obs = observer)
r6_22 <- r6_22 %>% rename(time = start)
r6_22 <- make_unentered_columns(r6_22,"how")

#choose the final columns to include in playback data
r6_22_final <- reorder_final_cols(r6_22)

# WRITE REGION 6 DATA
write.csv(r6_22_final,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_FWPR6_Cleaned10-6.csv", row.names = FALSE)





### UMBEL Playback Data ############
umbel_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022MMR_CuckooPlaybackData_UMBEL.csv") %>% clean_names()
# fix the point_id
umbel_22$point_id <- str_replace(umbel_22$point_id,"_", "-")

# create a column for the cuckoo detections
umbelPB_22 <- create_binary_cuckoo(umbel_22)
# Clean the interval column
umbelPB_22 <- clean_intervals(umbelPB_22)
# Make the date column a date
umbelPB_22 <- make_date_format(umbelPB_22)

# Read in metadata
umbel_metadat <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_UMBEL.csv") %>% clean_names() %>% rename(lat_2022 = lat_if_new_or_from_2021, long_2022 = long_if_new_or_from_2021)
# read in monitoring points
umbel_points <- read.csv("./Data/Monitoring_Points/UMBEL_LetterNamedPoints2022.csv") %>% clean_names() %>% select(gps_id,lat,long) %>% rename(point_id = gps_id) 

# Fill in missing lat and long values in 'umbel_metadat' with the values from umbel_points
umbel_metadat <- umbel_metadat %>%
  mutate(
    lat = ifelse(is.na(lat_2022), umbel_points$lat[match(point_id, umbel_points$point_id)], lat_2022),
    long = ifelse(is.na(long_2022), umbel_points$long[match(point_id, umbel_points$point_id)], long_2022)
  )
# NEED TO FILL IN MISSING VALUES *******************************************

# need to left join this with monitoring points 
# rename columns and select only the necessary
umbel_metadat <- rename_cols_and_select(umbel_metadat)

# join the playback and the metadata
umbel_22 <- join_playback_metadata_bypoint(umbelPB_22,umbel_metadat)

# separate out the site and make a survey_id column
umbel_22 <- separate_site_make_survey_id(umbel_22)

# Now check which columns are missing and add them in or rename
# Now check which columns are missing and add them in or rename
umbel_22 <- umbel_22 %>% rename(bearing = cuckoo_bearing)
umbel_22 <- umbel_22 %>% rename(cluster = cluster_sz) # not sure what cluster code is
umbel_22 <- umbel_22 %>% rename(notes = bird_notes)
umbel_22 <- make_unentered_columns(umbel_22,"call")

#choose the final columns to include in playback data
umbel_22_final <- reorder_final_cols(umbel_22)

# WRITE REGION 6 DATA
write.csv(umbel_22_final,"./Data/Playback_Results/2022/Outputs/2022_PlaybackSurveys_UMBEL_Cleaned10-6.csv", row.names = FALSE)



# CODE GRAVEYARD #########
# r7PB_22 <- r7PB_22 %>% 
#   mutate(bbcu = ifelse(species == "BBCU",1,0)) %>% 
#   mutate(ybcu = ifelse(species == "YBCU",1,0)) 

# Original
# r7PB_22 <- r7PB_22 %>%
#   mutate(
#     bbcu = ifelse(species == "BBCU", 1,
#                   ifelse(species %in% c("NOBI", "YBCU"), 0, "no_data"))
#   ) %>%
#   mutate(
#     ybcu = ifelse(species == "YBCU", 1,
#                   ifelse(species %in% c("NOBI", "BBCU"), 0, "no_data"))
#   )

# # Read in playback and metadata, clean names, rename, and select the one that you want
# r5_22 <- read.csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR5.csv") %>% 
#   clean_names() %>% 
#   rename(lat = latitude, long = longitude, bbcu_detected = playback_cuckoo_detection)
# 
# r7PB_22 <- read.csv("./Data/Playback_Results/2022/Raw_Data/2022_R7_PlaybackSurveyData.csv") %>% clean_names() %>% rename(aru_id = point)
# 
# # Turn the cuckoo_detected column into YBCU detected and BBCU detected

# r7_metadat %>% rename(
#   lat = case_when(
#     latitude == "lat" ~ "latitude",
#     TRUE ~ "latitude"
#   ),
#   long = case_when(
#     longitude == "long" ~ "longitude",
#     TRUE ~ "longitude"
#   )
# ) %>%
#   select(point_id, aru_id, lat, long)
#metadata %>% rename(long = longitude, lat = latitude) %>% select(point_id, aru_id, lat, long)
# 
# remove_non_alphanumeric <- function(dataframe, column) {
#   dataframe[[column]] <- gsub("[^[:alnum:]]", "", dataframe[[column]])
#   return(dataframe)
# }
# # Apply remove_non_alphanumeric to all columns in the dataframe
# for (col_name in colnames(r7_metadat)) {
#   r7_metadat <- remove_non_alphanumeric(r7_metadat, col_name)
# }
# 
# remove_spaces_long_lat <- function(dataframe) {
#   dataframe$lat <- str_replace(dataframe$lat, "\\S" , "")
#   dataframe$long <- str_replace(dataframe$long, "\\S", "")
#   return(dataframe)
# }
# 
# test <- remove_spaces_long_lat(r7_metadat)
# 
# # Create a function to remove spaces from a column
# remove_spaces <- function(dataframe,column) {
#   dataframe$column <- str_replace(dataframe$column, " ", "")
# }
# 
# remove_spaces <- function(dataframe, column) {
#   dataframe[[column]] <- str_replace(dataframe[[column]], " ", "")
#   return(dataframe)
# }
# 
# for(col_name in colnames(r7_metadat)){
#   r7_metadat <- remove_spaces(r7_metadat, col_name)
# }
# 
# for(i in ncol(r7_metadat)){
#   # apply remove_spaces across every column
# }
# 
# apply(r7_metadat, 2, remove_spaces, )
# 
# # Create a function to apply remove_spaces to all columns in a dataframe
# remove_spaces_from_all_columns <- function(dataframe) {
#   result <- dataframe %>%
#     mutate_all(.funs = list(remove_spaces))
#   return(result)
# }
# 
# # Example usage:
# # Replace "your_data" with the name of your dataframe
# test <- remove_spaces_from_all_columns(r7_metadat)
# 
# 
# # create a function to read in the metadata and remove spaces from columns
# dataframe$col <- str_replace(dataframe$col," ", "")
# r7_metadat <- r7_metadat %>%
#   mutate_all(~trimws(.))

# test <- r7PB_22 %>% separate(point_id, into = c("site_id", "point"), sep = "-" , remove = FALSE) %>% mutate(survey_id = paste(site_id,"#1"))


# # Remove the spaces in the ARU ID column
# r7_22_sum$aru_id <- str_replace(r7_22_sum$aru_id,"U ", "")
# 
# 
# # need to link this with the metadata to link ARU ID to point ID
# 
# # %>%
# #   group_by(aru_id) %>% 
# #   summarize(bbcu_detected = sum(bbcu))
# 
# 
# # add on lat and long
# # Read in metadata
# r7MD_22 <- read_csv("./Data/Metadata/Raw_Data/2022_ARUDeployment_Metadata_FWPR7.csv") %>% clean_names() %>% rename(long = longitude, lat = latitude)

