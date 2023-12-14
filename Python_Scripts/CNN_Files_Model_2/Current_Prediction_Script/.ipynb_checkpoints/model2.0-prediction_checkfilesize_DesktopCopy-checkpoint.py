'''
Run Model 2.0 On Data

This was created to read in a folder of acoustic data and run Model_2.0 on it. Created from the Mac Copy of this script.

Created: 11/15/2023
Last modified: 12/5/2023
'''

# Import packages ##########################
import opensoundscape
from opensoundscape.ml.cnn import load_model
from opensoundscape import Audio
# Other utilities and packages
import torch
from pathlib import Path
import numpy as np
import pandas as pd
from glob import glob
import subprocess
import time
import os

#### Establish year and collabroator ####
year = "2023"
collaborator = "FWPR6"

#### Establish paths ###########################
# Change this to the path to your files
## NOTE: This should be a collaborator's folder of audio files from one year on Bioacoustics_Storage (F:)
audio_file_location = f'F:/Cuckoo_Acoustic_Data/{year}/{year}_{collaborator}_Data/{year}_{collaborator}_Audio'
#"F:/Cuckoo_Acoustic_Data/2023/2023_FWPR5_Data/2023_FWPR5_Audio"

# Change this to reflect the files you don't want to include when the model is run
## NOTE: This should be the output from Examine_Acoustic_Data.ipynb that should be stored on Bioacoustics_Storage (F:)
files_to_exclude = f'F:/CNN_Classifier_Files/Model_2.0/Model_Inputs_Data_Quality/{year}_{collaborator}_IncorrectSizeAcousticFiles.csv'

# CHECKPOINT: are audio_file_location and files_to_exclude set to read data for the same collaborator for the same year???????



### Shouldn't need to edit anything below ############################
# Mark starting time
start_time = time.time()
print("Starting time:", start_time)

# Specify the path to your model 
## NOTE: This should be epoch-10_opso-0-10-1.model within the Model_2.0 folder on Bioacoustics_Storage (F:) and shouldn't need changing
model_path = "F:/CNN_Classifier_Files/Model_2.0/Model_Files_and_Scripts/models_opso-0.10.1/epoch-10_opso-0-10-1.model"

# Specify where the scores will be stored
## NOTE: This should be the folder for Model_Scores on Bioacoustics_Storage (F:) and shouldn't need changing
outputs_path = 'F:/CNN_Classifier_Files/Model_2.0/Model_Scores'

#### Read in audio files #######################
## This wildcard will work as long as audio_file_location is YYYY_COLLAB_Audio folder
audio_files_list = list(glob(audio_file_location + "/*/*.[wW][aA][vV]"))
audio_files = pd.DataFrame(audio_files_list, columns=["file"])

# Read files to exclude
exclude_data = pd.read_csv(files_to_exclude)
# Convert all file names to upper case to catch .wav and .WAV
exclude_data['File_Name'] = exclude_data['File_Name'].str.upper()
exclude_files = exclude_data['File_Name'].tolist()
#print("Checking files to exclude...")
#print(exclude_files)

# Create a new column 'file_name' in audio_files
audio_files['file_name'] = audio_files['file'].apply(lambda x: Path(x).name) # used to be .stem
# convert the file_name to filter into upper case to catch .WAV vs .wav
audio_files['file_name'] = audio_files['file_name'].str.upper()

# Filter out files based on 'file_name'
audio_files = audio_files[~audio_files['file_name'].isin(exclude_files)]

# Set 'file' as the index in audio_files_filtered
audio_files.set_index('file', inplace=True)

# Remove the 'file_name' column from audio_files_filtered
audio_files.drop('file_name', axis=1, inplace=True)

# Check the final version of audio_files_filtered
print("Filtered Audio Files:")
print(audio_files)


#### Run the Model #####################################
model = load_model(model_path)

# Spectrogram preprocessing
model.preprocessor.pipeline.load_audio.set(sample_rate=11025)
model.preprocessor.pipeline.bandpass.set(min_f=200, max_f=3500)
model.preprocessor.pipeline.to_spec.set(window_samples=512, overlap_samples=256)
model.preprocessor.pipeline.frequency_mask.bypass = True

scores = model.predict(audio_files)
print("Shape of scores:", scores.shape)

# Specify the path and name for the scores
output_file_path = os.path.join(outputs_path, f"predictions_{os.path.basename(model_path).split('.')[0]}-{os.path.basename(audio_file_location)}.csv")
# Write the scores to a .csv in this location
scores.to_csv(output_file_path)

# Calculate the elapsed time
end_time = time.time()
elapsed_time = (end_time - start_time)/60
# Print the time it took to run the script
print(f"Script execution time: {elapsed_time:.2f} minutes")



# OLD: files_to_exclude ='C:/Users/ak201255/Documents/Cuckoo-Research/Data/Acoustic_Data_Quality/2023_FWPR6_IncorrectSizeAcousticFiles.csv'
# OLD: outputs_path ='C:/Users/ak201255/Documents/Cuckoo-Research/Data/CNN_Outputs'

