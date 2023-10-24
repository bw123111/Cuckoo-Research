#### Combine Negative Training Data CSVs ###################

## Purpose: to read in all the separate files of negative training data and combine them into one datasheet for exporting into google sheets

# Created 9/26/2023

# Last modified: 9/27/2023

####### Setup ########
source("./R_Scripts/6_Function_Scripts/Combine_CSV_Files_In_Directory.R")

####### CODE ###############

combined_data <- combine_csv_files("./Data/Training_Data/Outputs/Negative_Files_To_Vet/")


# Read in the habitat negatives sheet from the google sheets to include the data location and ARU model

other_dat <- read.csv("./Data/Training_Data/Raw_Data/Raw_Audio_Processed_Habitat_Negatives.csv")

other_dat <- other_dat %>% 
  filter(extracted_files == "Y") %>% 
  select(site,point,landcover_strata,aru_model) %>% 
  unite(point_id,site,point,sep = "-") %>% 
  rename(location = landcover_strata)

# change names to include zeros because excel is dumb
other_dat[3,1] <- "MISO-077"
other_dat[4,1] <- "MISO-065"
other_dat[5,1] <- "MISO-010"
other_dat[6,1] <- "MISO-098"
other_dat[7,1] <- "MISO-015"

# join the other dat to the combined data
negative_files <- left_join(combined_data, other_dat)

write.csv(negative_files,"./Data/Training_Data/Outputs/Cuckoo_Negative_Training_Data.csv", row.names = FALSE)


###### Figuring out how much negative training data I need #####
min <- nrow(negative_files) * 30
seconds <- min * 60 
clips <- seconds/5


pos_clips_noPQ <- 890 + 195 + 375 + 264 #1724
pos_clips_PQ <- 890 + 195 + 375 + 430 #1890

clips - pos_clips_noPQ

# how many files to balance?
sec_tomatch <- 1724 * 5
min_tomatch <- seconds_tomatch / 60
files_tomatch <- min_tomatch / 30

#### CODE #####
# num_hours <- nrow(negative_files) *.5
# num_seconds <- num_hours * (60*60)
# num_clips <- num_seconds/5