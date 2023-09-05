#### Landowner Species List #####

# this is a script to read in the point count data from playback surveys and create a species list for each site for landowner deliverables

# Created 8/2/2023

# Last updated 8/31/2023

#### Install and load pacakges #####
packages <- c("tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)

#### Code #####


#### Seacross Ranch ####

# read in the point count data
seacross_data <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Playback_Results\\2023\\Raw_Data\\2023_PlaybackSurveyData_Seacross.csv")

LGC <- seacross_data %>% filter(site_id=="LGC") 
LGC_spp <- unique(LGC$species)
SRA <- seacross_data %>% filter(site_id=="SRA")
SRA_spp <- unique(SRA$species)
SRB <- seacross_data %>% filter(site_id=="SRB")
SRB_spp <- unique(SRB$species)





#### Rob Hazelwood Sites ####
playback_dat <- read.csv("./Data/Playback_Results/2023/Raw_Data/2023_PlaybackPtCtSurveyData_UMBEL_8-31.csv")

# Filter out only the sites that are on Rob Hazelwood's land
rh_dat <- playback_dat %>% filter(grepl("203|82", site_id)) %>% 
  select(site_id,species)

# Pull out columns of interest and keep only the unique values, mutate a new column for yes presence
site_spp <- rh_dat  %>% 
  group_by(site_id) %>% 
  summarize(species_code = unique(species)) %>% 
  mutate(spp_present = "Y")

# Pivot this dataset wider
site_table <- site_spp %>% pivot_wider(names_from = site_id, values_from = spp_present) 

# Remove the NOBI names
site_table <- site_table[!(site_table$species_code %in% c("NOBI","UNBI","UNDU"),]

# Create a new row for BBCU and YBCU and have NA for each
# Better practice: test if there are any YBCU or BBCU in the data, if not, create NA for all of them
BBCU_dat <- c("BBCU",NA, NA, NA, NA)
YBCU_dat <- c("YBCU",NA, NA, NA, NA)
site_spp_detections <- rbind(site_table, BBCU_dat,YBCU_dat)

# Sort to make pretty
site_spp_detections <-site_spp_detections %>% arrange(species_code) 

# Write to csv
write.csv(site_spp_detections,"./Data/Playback_Results/2023/Outputs/2023_PlaybackPointCountData_HazewoodSites.csv", row.names = FALSE)




#### Code Graveyard #####

# Need to put the species ID as a column and mutate a new column for each site 
all_spp <- unique(rh_dat$species)

# make this into a dataframe to add columns to it 
all_spp_df <- as.data.frame(all_spp)

# Idea: Split up the sites and create a new column that mutates yes if the species in the dataframe is found in the list of species at each site

all_spp_df <- all_spp_df %>% mutate(Site_83 = ifelse())
