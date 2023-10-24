######### Clean New GRTS Data Pre Deployment #################

# This is a script for reading in the new, edited GRTS points and creating separate datasheets of the base points and the final points

# Created: 4/25/2023
# Last updated: 4/25/2023


######## install and load pacakges #########
packages <- c("data.table","tidyverse","janitor")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)


########## Code ##############

# Load in repeat locs
repeats <- read_csv(".\\Data\\Spatial_Data\\Repeat_Monitoring_Points_2023.csv") %>% clean_names()

# MUSSELSHELL
# Load in other points
mush_grts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Musselshell_SurveyPoints_v2_2023 for ArcPro.csv") %>% clean_names()
# take out repeat locs in this dataset
mush_grts <- mush_grts %>% slice(4:234)
# filter out the base points
mush_base <- mush_grts %>% filter(sitesuse_new=="Base")
mush_over <- mush_grts %>% filter(is.na(sitesuse_new))
#nrow(mush_grts)
# filter the musselshell points from the repeat data
mush_repeats <- repeats %>% filter(organization =="FWPR5")

# Export all this data
# write.csv(mush_base,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_FWPR5_BaseGRTS.csv",row.names=FALSE)
# write.csv(mush_over,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_FWPR5_OverSampleGRTS.csv",row.names=FALSE)
# write.csv(mush_repeats,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_FWPR5_Repeats.csv",row.names=FALSE)


# MISSOURI - UMBEL
# Load in other points
misou_grts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri_SurveyPointsUMBEL_v2_2023.csv") %>% clean_names()

# do we have enough?
misou_repeats <- repeats %>% filter(organization=="UMBEL/MTA")
nrow(misou_repeats) # 33
nrow(misou_grts %>% filter(siteuse_new=="Base")) # 40
# Good to go

# filter out the base points
misou_base <- misou_grts %>% filter(siteuse_new=="Base") %>% select(1:10)
misou_over <- misou_grts %>% filter(is.na(siteuse_new)) %>% select(1:10)
#nrow(mush_grts)

# write these to csv files 
# write.csv(misou_base,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_UMBEL_BaseGRTS.csv",row.names=FALSE)
# write.csv(misou_over,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_UMBEL_OverSampleGRTS.csv",row.names=FALSE)
# write.csv(misou_repeats,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_UMBEL_Repeats.csv",row.names=FALSE)


# MISSOURI - R6
# Load in other points
miso6_grts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri_SurveyPointsR6_v2_2023.csv") %>% clean_names()

# do we have enough?
miso6_repeats <- repeats %>% filter(organization=="FWPR6")
nrow(miso6_repeats) # 9
nrow(miso6_grts %>% filter(siteuse_new=="Base")) # 4
# Good to go

# filter out the base points
miso6_base <- miso6_grts %>% filter(siteuse_new=="Base") #%>% select(1:10)
miso6_over <- miso6_grts %>% filter(is.na(siteuse_new)) %>% slice(10:78)
miso6_repeats <- repeats %>% filter(organization=="FWPR6")
nrow(misou_repeats) # 33
#nrow(mush_grts)

# # write these to csv files 
# write.csv(miso6_base,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_R6_BaseGRTS.csv",row.names=FALSE)
# write.csv(miso6_over,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_R6_OverSampleGRTS.csv",row.names=FALSE)
# write.csv(miso6_repeats,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\2023_R6_Repeats.csv",row.names=FALSE)


######## START WITH FWP R7 #################
yell_grts <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Yellowstone_SurveyPoints_v2_2023.csv") %>% clean_names()
yell_repeats <- repeats %>% filter(organization=="FWPR7")
nrow(yell_repeats) # 15
nrow(yell_grts %>% filter(siteuse_new=="Base")) # 34
# Total is 49, good to go
# filter out the base points
yell_base <- yell_grts %>% filter(siteuse_new=="Base") 
yell_over <- yell_grts %>% filter(is.na(siteuse_new))

# write these to csv files 
# write.csv(yell_base,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Yellowstone\\2023_R7_BaseGRTS.csv",row.names=FALSE)
# write.csv(yell_over,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Yellowstone\\2023_R7_OverSampleGRTS.csv",row.names=FALSE)
# write.csv(yell_repeats,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Yellowstone\\2023_R7_Repeats.csv",row.names=FALSE)
# update GIS map and update to ArcGIS online


##### Clean data for Grant #######33

# filter UMBEL locations that have a longitude greater than -108.8571723
to_clean <- read_csv(".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_UMBEL_BaseGRTSandRepeats.csv")

for_grant <- to_clean %>% filter(lon_wgs84 > -108.6863026)
for_grant <- for_grant %>% filter(aru=="Yes")

# export this to a csv
write_csv(for_grant,".\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_UMBELPoints_ForGrant.csv")


########## Changing site names ###########
r6_miso <- read_csv("C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\Coding_Workspace\\Cuckoo-Research\\Data\\Spatial_Data\\GRTS_Points_2023\\GRTS_Points_Edited_Version2\\Missouri River\\2023_R6_BaseGRTSandRepeats.csv")

r6_miso <- r6_miso %>% separate(site_id,into=c("site","point_num"),sep = "-" )

# mutate the site column if it is "Site"
r6_miso %>% ifelse(site == "Site", mutate(site = "MISO"),site)

census_data <- census_data %>% mutate(MonthNum = case_when(
  Month == "January" ~ 1
