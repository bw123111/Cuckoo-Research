'''
Run Model 2.0 On Test Data

This was created to read in a folder of acoustic data and run Model_2.0 on it. Created from the Mac Copy of this script.

Created: 11/15/2023
Last modified: 12/1/2023
'''

# Import packages ##########################
import opensoundscape
from opensoundscape.ml.cnn import load_model
from opensoundscape import Audio

# Other utilities and packages
import torch
from pathlib import Path
#import pathlib
import numpy as np
import pandas as pd
from glob import glob
import subprocess
import time

start_time = time.time()
print("Starting time:", start_time)



# Establish paths ###########################
# Change this to the path to your files
audio_file_location = "F:\\Cuckoo_Acoustic_Data\\2023\\R6_Test\\Test_R6_SmallFiles"
#Test data: "F:\AudioMothDistance_JennaProject_22-23\AudioMothDistance_Acoustic_Data"

# Establish which collaborator you're working on 
collaborator = "FWPR6"

# Change this to reflect the files you don't want to include when the model is run
files_to_exclude = 'C:/Users/ak201255/Documents/Cuckoo-Research/Data/Acoustic_Data_Quality/2023_FWPR6_IncorrectSizeAcousticFiles.csv'

# Change this to the path to your model file
model_path = "F:\CNN_Classifier_Files\Model_2.0\Model_Files_and_Scripts\models_opso-0.10.1\epoch-10_opso-0-10-1.model"



###### Read in audio files #######################
## This wildcard will work as long as audio_file_location is YYYY_COLLAB_Audio folder
audio_files_list = list(glob(audio_file_location + "/*/*.[wW][aA][vV]"))
audio_files = pd.DataFrame(audio_files_list, columns=["file"])

# Read files to exclude
exclude_data = pd.read_csv(files_to_exclude)
exclude_files = exclude_data['File_Name'].tolist()

# Create a new column 'file_name' in audio_files
audio_files['file_name'] = audio_files['file'].apply(lambda x: Path(x).stem)

# Filter out files based on 'file_name'
audio_files_filtered = audio_files[~audio_files['file_name'].isin(exclude_files)]

# Set 'file' as the index in audio_files_filtered
audio_files_filtered.set_index('file', inplace=True)

# Remove the 'file_name' column from audio_files_filtered
audio_files_filtered.drop('file_name', axis=1, inplace=True)

# Check the final version of audio_files_filtered
print("Filtered Audio Files:")
print(audio_files_filtered)



#### Run the Model #####################################
model = load_model(model_path)

# Spectrogram preprocessing
model.preprocessor.pipeline.load_audio.set(sample_rate=11025)
model.preprocessor.pipeline.bandpass.set(min_f=200, max_f=3500)
model.preprocessor.pipeline.to_spec.set(window_samples=512, overlap_samples=256)
model.preprocessor.pipeline.frequency_mask.bypass = True

scores = model.predict(audio_files_filtered)
print("Shape of scores:", scores.shape)

##########################Edit this: add on the current date to it, change so that it write to the data folder
scores.to_csv(f"predictions_{Path(model_path).stem}-model.csv")


# Calculate the elapsed time
end_time = time.time()
elapsed_time = end_time - start_time
# Print the time it took to run the script
print(f"Script execution time: {elapsed_time:.2f} seconds")




