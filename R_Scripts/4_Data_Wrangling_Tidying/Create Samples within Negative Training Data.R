#### Create Samples within Negative Training Data ###################

## Purpose: to create a new column with a random sample of the audio file for the negative data

# Created 9/27/2023

# Last modified: 9/27/2023

#### Add file path to the start ######

# What I want: a random 112 s clip from each file 


neg_dat <- read.csv("./Data/Training_Data/Outputs/Cuckoo_Negative_Training_Data_nopath_nosample.csv")

# Establish range of starting seconds of clip
# use 111 if matching the positive data with only high quality clips
# use 121 if matching all positive data, both high quality and low quality clips
start_range <- 1:(1800-122)
# Create empty lists
sample_start <- list()
sample_end <- list()

# pull a random 112 s sample and create a list of the start and end times
for (i in 1:nrow(neg_dat)){
  start <- sample(start_range, size = 1)
  end <- start + 122
  sample_start[i] <- start
  sample_end[i] <- end

}

# Add the new columns to the dataframe
neg_dat$sample_start_s <- sample_start
neg_dat$sample_end_s <- sample_end

# Convert these new columns from a list to a numeric column
neg_dat <- neg_dat %>%
  mutate(
    sample_start_s = as.numeric(unlist(sample_start_s)),
    sample_end_s = as.numeric(unlist(sample_end_s))
  )

# check that this is working correctly
test_neg_dat <- neg_dat %>% mutate(difference = sample_end_s - sample_start_s)

# Sum up the difference column and divide by 5 to see how many total clips
sum(test_neg_dat$difference) /5 

# 1732 total clips with 111 second samples 
# 1888 total clips with 121 second samples
# 1903 total clips with 122 second samples

write.csv(neg_dat,"./Data/Training_Data/Outputs/Cuckoo_Negative_Training_Data_nopath.csv", row.names = FALSE)



#### CODE GRAVEYARD #####
#new_dat <- neg_dat %>% mutate(sample_start = start, sample_end = end)
# 
# start <- sample(start_range, size = 1)
# end <- start + 112
# neg_dat$sample_start[1] <- start