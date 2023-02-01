##################### Header ######################

# This is a script for combining and condensing the metadata into a site information file 
# One idea is to create a google sheets doc for this to keep a living record of the deployment locations
# The idea is to update this every year 


# Design of the datasheets:
# Sheets for each year:
# Point_ID | Site | Point_num | Latitude | Longitude | Deployed 2020 | ARU Detection 2020 | Playback Detection 2020 | Deployed 2021| 

# have a master datasheet of each site and whether they were deployed and collected data in each year




# The data indicates whether or not the monitor was deployed (if not deployed, it wasn't monitored this year, but if it was deployed and didn't collect data, this column will be NA) and whether or not it detected a cuckoo if it was deployed

# Do we want habitat descriptions of this site? Leave this off for now
# How to combine different latitudes across different years?


# Practice plotting/mapping this in R 

# Deliverables for Anna N and Brandi S:
  # The datasheet 
  # Map with the locations color coded to whether the presence was confirmed


# Status 10/20: Read in the data from 2021 and 2022
# GO UPDATE METADATA AND DEPLOYMENT DATA 2020 in DROP BOX

#################### Setup #########################

# Load relevant libraries
library(tidyverse)
library(data.table)
library(janitor)
library(lubridate)
library(here)

# Load in datasheets
#Metadata from 2020
# Filter just the UMBEL data from here
mUMBELFWP_20 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2020_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL_FWP.csv")
mUMBELFWP_20 <- mUMBELFWP_20 %>% clean_names()
# sites along Missouri
Missouri_20 <- mUMBELFWP_20 %>% filter(river_system=="Missouri")
length(Missouri_20$x2020point_id)
length(unique(Missouri_20$site))

# sites along Yellowstone
Yellowstone_20 <- mUMBELFWP_20 %>% filter(river_system=="Yellowstone")
length(Yellowstone_20$x2020point_id)
length(unique(Yellowstone_20$site))

# How many sites are there?
length(unique(mUMBELFWP_20$site))
d1 <- mUMBELFWP_20%>%filter(playback_cuckoo_detected=="1")
d2 <- mUMBELFWP_20%>%filter(aru_cuckoo_detected=="1")
d3 <- mUMBELFWP_20%>%filter(is.na(aru_cuckoo_detected)==TRUE)
# Join it with this for FWP
# below contains the same information as UMBEL FWP datasheet
#mFWP_20 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Metadata\\2020_ARUDeploymentMetadata_FWPSkone.csv")
# Read in FWP deployment data



################### Other #########################

# Read in UMBEL data - all sites had data collected
# The metadata from 2020 may not include deployment locations for UMBEL that didn't have data collected, it does include deployment locations for FWP that didn't have data collected

m_20 <- mUMBELFWP_20 %>% select(point_id,site_name,point,lat,long, data_days, aru_cuckoo_detected, playback_cuckoo_detected) %>% mutate(deployed_2020 ="Y")

# Change data days name to data collected 
m_20 <- m_20 %>% rename(data_collected = data_days)
# Change data collected values that are numbers to Y, everything else to N
m_20_new <- m_20 %>% mutate(data_collected = ifelse(data_collected>0,"Y","N")) 

m_20_new <- m_20_new %>% mutate(data_collected = replace(data_collected,is.na(data_collected)==TRUE, "N"))

# Test whether this does what you think it does
#length(m_20_new$data_collected=="N")
#length(m_20$data_collected==NA|0)
# GOOD TO GO

# Change ARU cuckoo detected NA values to 0
m_20_new <- m_20_new %>% mutate(aru_data_detected = replace(aru_data_detected,is.na(aru_data_detected)==TRUE, "0"))

# Why is it adding extra columns and not changing what I want it to?





######################### 2021 Data############################ fix this code
UMBEL_21 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Metadata\\2021_ARUDeployment_Metadata_UMBEL.csv")
UMBEL_21 <- UMBEL_21  %>% clean_names()
UMBEL_21 <- UMBEL_21 %>% separate(point_id, into = c("site","point"),sep="-")
length(unique(UMBEL_21$site))
UMBEL_21_dep <- UMBEL_21 %>% filter(!obs=="not deployed")

playback_21 <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\2021_ARUDeploymentMetadata_ARUandPlaybackResults_UMBEL.csv")
playback_21 <- playback_21  %>% clean_names()
playback_21_dep <- playback_21 %>% filter(!obs=="not deployed")

UMBEL_21_points <- UMBEL_21$point_id
length(UMBEL_21_points)+length(Skone_22_points)






######################### 2022 Data ############################

# Read in metadata from 2022
UMBEL_22 <- read_csv(".\\Data\\Metadata\\2022_ARUDeployment_Metadata_UMBEL.csv")
FWPR5_22 <- read_csv(".\\Data\\Metadata\\2022_ARUDeployment_Metadata_FWPR5.csv")
FWPR7_22 <- read_csv(".\\Data\\Metadata\\FWPSkone_CuckooSiteMetadata_20-22.csv")
FWPR7_22orig <- read_csv(".\\Data\\Metadata\\FWPSkone_CuckooSiteMetadata_20-22.csv")
FWPR6_22 <- read_csv(".\\Data\\Metadata\\2022_ARUDeployment_Metadata_FWPR6.csv")


# clean up the names 
UMBEL_22 <- UMBEL_22 %>% clean_names()
FWPR7_22 <- FWPR7_22 %>% clean_names()
FWPR6_22 <- FWPR6_22 %>% clean_names()
FWPR5_22 <- FWPR5_22 %>% clean_names()
# With FWPR7 data:
# read in the full version of FWPR7 data
FWPR7_22orig <- FWPR7_22orig %>% clean_names()
# mutate organization name to match
FWPR7_22orig <- FWPR7_22orig %>% mutate(organization = "FWP_R7")
# cut off everything above row 22
FWPR7_22orig <- FWPR7_22orig %>% slice(22:n())
# Select the old version of the point IDs
FWPR7_22orig <- FWPR7_22orig %>% select(point_id_orig,lat, long, organization)
# rename the point IDs so that you can bind them
FWPR7_22orig <- FWPR7_22orig %>% rename(point_id= point_id_orig)

# Add on organization name to R5 data
FWPR5_22 <- FWPR5_22 %>% mutate(organization = "FWP_R5")
FWPR5_22 <- FWPR5_22 %>% rename(lat=latitude,long=longitude)

# Clip off bottom of R6 data
FWPR6_22 <- FWPR6_22 %>% filter(is.na(point_id)==FALSE)
# Add on organization name to R6 data
FWPR6_22 <- FWPR6_22 %>% mutate(organization= "FWP_R6")


# Split R7 into years and select only 2022
FWPR7_22 <- FWPR7_22 %>% separate(date_deployed, into = c("month","day","year"), sep = '/')
FWPR7_22 <- FWPR7_22 %>% filter(year=="2022") 
# Add on organization name
FWPR7_22 <- FWPR7_22 %>% mutate(organization = "FWP_R7")

#R6 and UMBEL are along Missouri 

# Select point_id, lat, long
UMBEL_22 <- UMBEL_22 %>% select(point_id,lat_if_new_or_from_2021,long_if_new_or_from_2021) 
UMBEL_22 <- UMBEL_22 %>% rename(long=long_if_new_or_from_2021,lat=lat_if_new_or_from_2021)
# Add on organization name
UMBEL_22 <- UMBEL_22 %>% mutate(organization = "UMBEL_MTAudubon")


# Select columns of interest from each datasheet to export to ArcGIS
FWPR5_22 <- FWPR5_22 %>% select(point_id,lat,long, organization)
FWPR6_22 <- FWPR6_22 %>% select(point_id,lat,long, organization)
FWPR7_22 <- FWPR7_22 %>% select(point_id,lat,long, organization)
UMBEL_22 <- UMBEL_22 %>% select(point_id,lat,long, organization)



# Bind all the 2022 points together
points_22 <- rbind(UMBEL_22, FWPR7_22, FWPR6_22, FWPR5_22)

# check for duplicates with the original 
dup_check22 <- rbind(UMBEL_22, FWPR7_22orig, FWPR6_22, FWPR5_22)
duplicated(dup_check22$point_id)


# Check if there are duplicate points in this dataset


points_22 <- points_22 %>% separate(point_id, into = c("site","point"),sep="-")
length(unique(points_22$site))
# how many sites along the Missouri?
Missouri_22 <- points_22 %>% filter(organization %in% c("UMBEL_MTAudubon","FWP_R6"))
length(unique(Missouri_22$site))
# how many sites along the Yellowstone?
Yellowstone_22 <- points_22 %>% filter(organization %in% c("FWP_R5","FWP_R7"))
length(unique(Yellowstone_22$site))

# Remove points without long lat for gis data
points_22 <- points_22 %>% na.omit
# missing 26 points from UMBEL that don't have long/lat
write.csv(points_22,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Thesis_ArcGIS_Files\\Cuckoo_Montitoring_Locations\\2022_PointsLatLong_12-20.csv")

points_22ALL <- rbind(UMBEL_22, FWPR7_22, FWPR6_22, FWPR5_22)
write.csv(points_22ALL,"C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Thesis_ArcGIS_Files\\Cuckoo_Montitoring_Locations\\2022_ALLPoints.csv")


# Design of the datasheets: IMPORTANT this datasheet that I'm making is only for the top down listening file to read the point IDs from 
# Just kidding, I should just use individual metadata from this year
# Sheets for each year:
# Point_ID | Site | Point_num | Latitude | Longitude |
# Add later: Deployed 2022 | ARU Detection 2022 | Playback Detection 2022 | 

UMBEL_22 %>% select()


# Figure out how many unique site IDs you'll be looking at
UMBEL_22_points <- UMBEL_22$point_id
Skone_22_points <- Skone_22$point_id
Hussey_22_points <- Hussey_22$point_id

length(UMBEL_22_points)+length(Skone_22_points)+length(Hussey_22_points)
# 122 sites total in 2022


# Total points from 2021 (estimated) and 2022
# how many clips to listen to from each site to keep listening time below three hours
123+122
seconds <- (3*60)*60
clips <- seconds/5
# listen to max of 2160 clips
# how many clips per site to listen to
clips/245
#9 files per site
5*245
# 1225 extra seconds to listen to
((seconds+1225)/60)/60
# total of three hours and 20 minutes to listen to them all if you take the top ten files
# top ten files it is FINAL



##############Looking at metadata for the classifier ###############

# How many files to look at for each site
# Spend no more than 3 hrs listening back to the data
# How many days?
num_secs <- 3*60*60

str(UMBEL_21)

num_dates <- function(dataset){
  # Clean up the data
  dataset <- dataset %>% select(dataset$date_deployed,dataset$date_retrieved) %>% na.omit()
  # Make the data into datetime
  dataset <- mutate(as_datetime(datset$date_deployed, dataset$date_retrieved))
  print(datset)
}
num_dates(UMBEL_21)


dataset <- UMBEL_21 %>% select(date_deployed,date_retrieved) %>% na.omit()
# Make the data into datetime
dataset <- dataset %>% mutate(as_date(date_retrieved))
print(datset)
# dates are being weird, just doing it by hand
# Total days in the dataset 
days_total <- 299

length(UMBEL_21$point_id)






########### JENNAS METADATA ########################
# load in jenna's metadata
jenna_dat <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Metadata\\ARU_Testing_Metadata_Jenna.csv")
jenna_orig <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Metadata\\ARU_Testing_Metadata_JennaORIGINAL.csv")
# 1. How to name columns in a way that is easy to read into R

## how to clean up column names in R
jenna_dat <- clean_names(jenna_dat)


# 2. How to create metadata that is useful in R
# Split the site_name column into: site ID, AM/PM, distance

# 3. This allows us to use metadata to learn things about our analysis 
## EX: How long will the classifier take to run on this dat? How many total minutes of data are we working with? 

# check which class the columns of interest are
class(jenna_dat$start_time_of_recording)
class(jenna_dat$end_time_of_recording)

## make a new dataframe to play around with
duration_dat2 <- jenna_dat

## Calculate the interval between the two values
duration_dat2$interval <- jenna_dat$start_time_of_recording %--% jenna_dat$end_time_of_recording

# Create a numeric column for the duration and convert it into minutes
duration_dat2 <- duration_dat2 %>% mutate(duration = as.duration(interval))
duration_dat2 <- duration_dat2 %>% mutate(interval2=as.numeric(duration))
duration_dat2 <- duration_dat2 %>% mutate(minutes_duration=interval2/60)

## Calculate the total number of minutes in all recordings 
total_mins <- sum(na.omit(duration_dat2$minutes_duration))
total_hrs <- total_mins/60
# total of 13 hours of recording 
# make sure this is estimating this correctly
total_recs <- 24 + 24 + 32 + 24
total_recs*18

10^3
396/60

# Testing how long running classifier is going to take:
hrs_rec_FWPAM <- .5*(301+249+249+249+301+281+281+281)
time_to_run <- 6.6/13.01

#1096 hours to run, .508 minutes to run each hour
hrs_rec_FWPAM*time_to_run
556/24

1709.13/60
415.73/60

############################# CODE GRAVEYARD ########################################

# # clean names and filter only UMBEL data
# mUMBEL_20 <- mUMBELFWP_20 %>% clean_names() %>% filter(river_system=="Missouri")
# # clean names on the FWP data
# mFWP_20 <- mFWP_20 %>% clean_names()
# 
# mUMBEL_20 %>% select(point_id,site_name,point,lat,long) %>% mutate(deployed_2020=="Y") %>% 
# 
# # select point id, site, point num, lat, long, mutate deployed 2020 to yes, select ARU detection as ARU detection 2020 and playback detection as playback detection 2020

#duration_dat2 <- jenna_dat %>% difftime(start_time_of_recording,end_time_of_recording, units="secs")


#sum(duration_dat$duration_mins)
## Why is our code breaking?
#durs <- duration_dat %>% select(duration_mins) %>% na.omit()
## Why are there NAs in the data? Are they where they're supposed to be?
#take the sum again:
#sum(durs$duration_mins)/60
#class(durs$duration_mins)


#duration_dat <- jenna_dat %>% mutate(duration = end_time_of_recording-start_time_of_recording )
#duration_dat <- duration_dat %>% mutate(duration_mins = duration/60) 
# not sure why hms gave it a seconds designation, the seconds isn't actually in the data
#duration_dat %>% separate(duration_mins, into=c("duration_mins","extra"), sep=" ")
#duration_dat$duration_mins


#UMBEL_22longlat <- left_join(UMBEL_22,longlat_21,by=c("point_id","lat","long"))
# UMBEL_pts <- UMBEL_22 %>% select(point_id)
# for (i in 1:length(UMBEL_pts)){
#   #print(UMBEL_22[i])
#   point <- UMBEL_22[i]
#   #print(point)
#   #check if this point is in 2021 data
#   if (point %in% longlat_21$point_id){
#     print("TRUE")
#     #nothing is printing true?
#   }
# }
# Get UMBEL data with lat/long data
#longlat_21 <- UMBEL_21 %>% select(point_id, lat,long)
#longlat_21 <- longlat_21 %>% na.omit()
#Left join with UMBEL 22
