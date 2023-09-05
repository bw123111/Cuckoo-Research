#### Clean Up Jennas Metadata for Testing in Classifier ####

# This is a script for cleaning up Jennas metadata to run it through the classifier to test the speed

# Last updated 9/5/2023

#### Install and load pacakges #####
packages <- c("tidyverse","janitor", "lubridate", "here", "data.table")
source(".\\R_Scripts\\Install_Load_Packages.R")
load_packages(packages)



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
