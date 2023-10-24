####### Clean Negative Data from Google Sheets ########


# A script to read in the datasheets from google sheets

# Created 10/1/2023

# Last updated 10/1/2023

#### Setup ###############
packages <- c("stringr","tidyverse","janitor")
load_packages(packages)

#### Code ############

# read in habitat negative files
hab_neg <- read.csv("./Data/Training_Data/Raw_Data/Cuckoo_Training_Packet_Files_Negative_Data_Habitat_10-1.csv") %>% clean_names()

# read in confusion species files
conf_neg <- read.csv("./Data/Training_Data/Raw_Data/Cuckoo_Training_Packet_Negative_Data_ConfusionSpp_10-1.csv") %>% clean_names()



#### Negative data files metadata #######

# Datasheet for all negative files: point_id, filename, month, period, source, aru_model

# create a new column for filename in hab_neg
hab_neg <- hab_neg %>% unite(filename, c(point_id, file_name), sep = "_", remove = FALSE)
hab_neg <- hab_neg %>% 
  rename(source = location) %>%
  select(point_id,
         filename,
         month,
         period,
         source,
         aru_model)

# filter out the confusion species data that contains info about the files themselves
conf_files <- conf_neg %>% filter(is.na(selection_id)==TRUE)
# create a new column for filename
conf_files <- conf_files %>% unite(filename, c(point_id, file_name), sep = "_", remove = FALSE)
conf_files <- conf_files %>% 
  rename(source = location) %>%
  select(point_id,
         filename,
         month,
         period,
         source,
         aru_model)


# Combine the datasets
neg_files <- rbind(conf_files,hab_neg)

# Write this data to the outputs
write.csv(neg_files, "./Data/Training_Data/Outputs/BBCU_Negative_Training_Files.csv", row.names = FALSE)

###### Confusion species selection tables metadata #######

# Filter out only confusion species selection tables
conf_tables <- conf_neg %>% filter(!is.na(selection_id)==TRUE)

# Select necessary columns
conf_tables <- conf_tables %>% select(file_name, length_clip_s,species)

# write this data to the outputs
write.csv(conf_tables, "./Data/Training_Data/Outputs/ConfSpp_Negative_Training_Data_Tables.csv", row.names = FALSE)

###### Math up the negative data ###########

# how many seconds needed from habitat data = total bbcu positive seconds - confusion species seconds

# See how many seconds of confusion species data you have
conf_spp_seconds <-  sum(conf_tables$length_clip_s)

# calculate the number of seconds of positive training data we have
secs_new <- total_highq *5
secs_orig <- 195 * 5
secs_APR <- 890 * 5
secs_penn <- 375 * 5
# Sum these up to get total seconds of positive training data 
pos_seconds <- secs_new + secs_orig + secs_APR + secs_penn

# calculate the number of habitat seconds needed total
num_hab_seconds <- pos_seconds - conf_spp_seconds
# calculate how many seconds from each habitat file
num_hab_seconds/nrow(hab_neg) # 107 seconds from each file sourced from habitat or location
