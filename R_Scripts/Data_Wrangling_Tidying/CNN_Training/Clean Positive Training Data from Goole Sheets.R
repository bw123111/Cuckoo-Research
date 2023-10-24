####### Clean Positive Training Data From Google Sheets ########


# This is a script to read in the training data I currently have and remove unnecessary files so I can make sure it is all backed up

# Created 9/27/2023

# Last updated 10/1/2023

#### Setup ####
library(tidyverse)
library(janitor)


#### Read in Current Datasheets #####

# Read in sheet for UMBEL data and FWP data
umbel <- read.csv("./Data/Training_Data/Raw_Data/Raw_Audio_Processed_UMBEL_10-1.csv") %>% clean_names()
fwp <- read.csv("./Data/Training_Data/Raw_Data/Raw_Audio_Processed_FWPR6_7_10-1.csv") %>% clean_names()


###### Process Data ####
# make these into one datasheet by selecting the same columns and rbinding them 
umbel_tojoin <- umbel %>% select(filename,
                                 bbcu_bird_net,
                                 bbcu_verified,
                                 ybcu_bird_net,
                                 ybcu_verified,
                                 num_bbcu_5_sec_clips,
                                 num_ybcu_5_sec_clips,
                                 good_for_confusion_spp,
                                 num_clips_poor_quality_audio,
                                 num_rattle_clips,
                                 raven_annotation,
                                 cleaned_for_pitt,
                                 notes)
fwp_tojoin <- fwp %>% select(filename,
                             bbcu_bird_net,
                             bbcu_verified,
                             ybcu_bird_net,
                             ybcu_verified,
                             num_bbcu_5_sec_clips,
                             num_ybcu_5_sec_clips,
                             good_for_confusion_spp,
                             num_clips_poor_quality_audio,
                             num_rattle_clips,
                             raven_annotation,
                             cleaned_for_pitt,
                             notes)

alldat <- rbind(umbel_tojoin,fwp_tojoin)

# pull only the files that have bbcu present
fwp_bbcu <- fwp_tojoin %>% filter(bbcu_verified == 1)
umbel_bbcu <- umbel_tojoin %>% filter(bbcu_verified == 1)


# Read in xeno-canto data
xc_dat <- read.csv("./Data/Training_Data/Raw_Data/Cuckoo_Training_Packet_XC_Data_10-1.csv") %>% clean_names()

xc_dat <- xc_dat %>% select(filename,
                 bbcu_bird_net,
                 bbcu_verified,
                 ybcu_bird_net,
                 ybcu_verified,
                 num_bbcu_5_sec_clips,
                 num_ybcu_5_sec_clips,
                 good_for_confusion_spp,
                 num_clips_poor_quality_audio,
                 num_rattle_clips,
                 raven_annotation,
                 cleaned_for_pitt,
                 notes) %>% 
  mutate(source = "xeno_canto")


# Join these into one dataset
bbcu_um <- rbind(fwp_bbcu,umbel_bbcu) %>% mutate(source = "mt_cuckoo_project")

bbcu <- rbind(bbcu_um,xc_dat)

# get a total count
total_bbcu <- sum(bbcu$num_bbcu_5_sec_clips) # 508

# Count of high quality data
total_highq <- total_bbcu - sum(bbcu$num_clips_poor_quality_audio, na.rm = TRUE) # 333 clips

# Count of rattle clips
rattle <- bbcu %>% filter(num_rattle_clips >= 1)
total_rattle <- sum(rattle$num_rattle_clips, na.rm = TRUE) # 64
# total_rattle <- sum(bbcu$num_rattle_clips, na.rm = TRUE) 
# no way to get at high quality rattle clips only 

# Count of cadence_coo clips
total_coo <- total_highq - total_rattle # 269 


# Clean up the data to write it
bbcu_output <- bbcu %>% rename(ran_birdnet = bbcu_bird_net) %>% select(filename, source, ran_birdnet,num_bbcu_5_sec_clips, num_clips_poor_quality_audio,num_rattle_clips)

# write the positive data to a new file
write.csv(bbcu_output, "./Data/Training_Data/Outputs/BBCU_Positive_Training_Files.csv", row.names = FALSE)


####### OLD CODE ########################
# Remove unnecessary files
alldat <- alldat %>% slice(-(511:996))
# convert bbcu_verified into numeric
alldat$bbcu_verified <- as.numeric(alldat$bbcu_verified)

# Make a separate datasheet with just the files with BBCu
dat_bbcu <- alldat %>% filter(bbcu_verified == 1)
# Remove 84-3
dat_bbcu <- dat_bbcu[!grepl("84-3", dat_bbcu$filename), ]


# Wrangle it into the same form as the negative data
dat_pos <- dat_bbcu %>%
  separate(filename, 
           into = c("point_id", "file_name"), 
           sep = "_", 
           remove = FALSE, 
           extra = "merge", 
           fill = "right", 
           convert = TRUE)

# Remove the suffix to certain file names
dat_pos[1,3] <- "20230620_102700"
dat_pos[5,3] <- "20230712_071248" # Why is this one not writing correctly?
dat_pos[6,3] <- "20230713_071338"
dat_pos[7,3] <- "20230712_081832"
dat_pos[8,3] <- "20230712_104615"

##### PICK UP HERE #############################################################################
  
# create new columns to match other negative training data
dat_pos <- dat_pos %>%  
  # specify that these are confusion species 
  mutate(location = "positive_data") %>% 
  separate(file_name,into = c("date", "time"),sep = "_",remove = FALSE) 



dat_pos <- dat_pos %>%
  # Create a month column
  mutate(month = substr(file_name, 5, 6)) %>% 
  # Create a period column
  mutate(period = ifelse(grepl("23|1", time), "nocturnal","diurnal")) %>%
  # Create a new column for aru_model
  ## PRD and CUL is Songmeter
  mutate(aru_model = ifelse(grepl("PRD|CUL", confspp_files$point_id)==TRUE,"SongMeter Micro","AudioMoth"))

# select the columns to match the other training data'
confspp_files_final <- confspp_files %>% select(point_id,file_name,month,period, location, aru_model)