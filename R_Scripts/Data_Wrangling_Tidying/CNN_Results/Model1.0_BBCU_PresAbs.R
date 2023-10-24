##### Classifier Data Organization #####

### This is a script for taking in the top10clips audio files and sorting them into a presence/absence data for each site in the metadata
### Last Updated 2/2


### Status: Completed for
#___ FWP R5
#_Y_ FWP R6
#___ FWP R7
#___ UMBEL


##### Load in packages #######

library(tidyverse)
library(here)



###### Create functions for processing data ############

detections_to_sites <- function(metadata,cnn_annotations) {
  # summarize the annotations column and create a new column to store the presence absence value
  site_detections <- cnn_annotations %>% group_by(point) %>% filter(!is.na(annotation)) %>% summarize(detections = sum(annotation)) %>% mutate(presence = ifelse(detections>0,1,0))
  site_detections <- site_detections %>% select(point,presence)
  site_detections <- site_detections %>% select(point,presence)
  
  # add the presence values to metadata
  new_df <- left_join(metadat, site_detections, by=c("point_id"="point"))
  new_df <- new_df %>% rename(BBCU_presence=presence)
  new_df <- as.data.frame(new_df)
  return(new_df)
}



##### Run data #############################

## FWPR5
metadat <- read_csv(".\\Data\\Metadata\\2022_ARUDeployment_Metadata_FWPR5.csv")
metadat <- metadat %>% rename(point_id=Point_ID)
cnn_detections <- read_csv(".\\Data\\Classifier_Results\\2022_FWPR5_top10scoring_clips_persite_annotations_v2.csv")
# convert to integer
#class(cnn_detections)
cnn_detections$annotation <- as.integer(cnn_detections$annotation)
#class(cnn_detections$annotation)
# run the function
output <- detections_to_sites(metadat,cnn_detections)
# write to csv
write_csv(output,".\\Data\\Cuckoo_Presence_Absence_ARU\\Model_1.0\\2022_MetadataARUPresence_FWPR5.csv")

## FWPR6
metadat <- read_csv(".\\Data\\Metadata\\2022_ARUDeployment_Metadata_FWPR6.csv")
cnn_detections <- read_csv(".\\Data\\Classifier_Results\\2022_FWPR6_top10scoring_clips_persite_annotations.csv")
# convert to integer
cnn_detections$annotation <- as.integer(cnn_detections$annotation)
# run the function
output <- detections_to_sites(metadat,cnn_detections)
# write to csv
write_csv(output,".\\Data\\Cuckoo_Presence_Absence_ARU\\Model_1.0\\2022_MetadataARUPresence_FWPR6.csv")

## UMBEL
metadat <- read_csv(".\\Data\\Metadata\\2022_ARUDeployment_Metadata_UMBEL.csv")
metadat <- metadat %>% rename(point_id=point_ID)
cnn_detections <- read_csv(".\\Data\\Classifier_Results\\2022_UMBEL_top10scoring_clips_persite_annotations_v2.csv")
# convert to integer
#class(cnn_detections)
cnn_detections$annotation <- as.integer(cnn_detections$annotation)
#class(cnn_detections$annotation)
# run the function
output <- detections_to_sites(metadat,cnn_detections)
# write to csv
write_csv(output,".\\Data\\Cuckoo_Presence_Absence_ARU\\Model_1.0\\2022_MetadataARUPresence_UMBEL.csv")




##### Call functions on data and write to CSV **CHANGE THIS PART OF THE CODE ONLY*** #######

output <- detections_to_sites(metadat,cnn_detections)

write_csv(output,".\\Data\\Cuckoo_Presence_Absence_ARU\\Model_1.0\\2022_MetadataARUPresence_FWPR6.csv")


###### CODE GRAVEYARD ###########  
# # Testing functions
# # summarize the annotations column and create a new column to store the presence absence value
# site_detections <- cnn_annotations %>% group_by(point) %>% filter(!is.na(annotation)) %>% summarize(detections = sum(annotation)) %>% mutate(presence = ifelse(detections>0,1,0))
# site_detections <- site_detections %>% select(point,presence)
# 
# # add the presence values to metadata
# new_df <- left_join(metadat, site_detections, by=c("point_id"="point"))



