


# Function: input is a dataframe of audio files
edit_names <- function(list_of_files){
  
  # First, test if there is the ARU ID in the file name
  if(grepl("([^_]*)_([[:digit:]]{8})_([[:digit:]]{6})\\.(wav|WAV)$",audio_files[1,]) == TRUE){
    print("Data with prefix and extension")
    # separate into name and file extension
    data_new <- list_of_files %>% separate(file_names, into = c("name","file_type"), sep = "\\.(?=[^.]*$)")
    # remove the summary data
    data_new <- data_new[!grepl("Summary|CONFIG", data_new$name), ]
    # split the file name into SD ID, date and time 
    data_new <- data_new %>% separate(name, into = c("sd_id","date","time"), sep = "_")
    print("Removed file extension")
    
    # Next, test if there is a .wav or .WAV added onto the end of the files
  } else if (grepl("\\.WAV|\\.wav$",audio_files[1,]) == TRUE){
    # separate into name and file extension
    data_new <- list_of_files %>% separate(file_names, into = c("name","file_type"), sep = "\\.(?=[^.]*$)")
    # split the file name into date and time 
    data_new <- data_new %>% separate(name, into = c("date","time"), sep = "_")
    print("Removed file extension from name")
    
  } else {
    # split the file name into date and time 
    data_new <- list_of_files %>% separate(file_names, into = c("date","time"), sep = "_")
  }
  
  # add a new column for am or pm files
  data_new <- data_new %>% mutate(period = ifelse(grepl("23|1", time), "nocturnal","diurnal"))
  # add a month column
  data_new$month <- substr(data_new$date, 5, 6)
  
  # pull out the data we want and return it from the function
  data_new %>% select(date, time, month, period)
  return(data_new)
}
