'''
Run Model 2.0 On Test Data

This was created to read in a folder of acoustic data and run Model_2.0 on it. Created from the Mac Copy of this script.

Created: 11/15/2023
Last modified: 11/15/2023
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

# Establish paths ###########################
# Change this to the path to your files
audio_file_location = "F:\AudioMothDistance_JennaProject_22-23\AudioMothDistance_Acoustic_Data"
#"/Volumes/Bioacoustics_Storage/AudioMothDistance_JennaProject_22-23/AudioMothDistance_Acoustic_Data"
# Starting with just the files from Jenna's project

## FIND A WAY TO MASK THE FILES THAT ARE WITHIN INCOM

# Change this to the path to your model file
model_path = "F:\CNN_Classifier_Files\Model_2.0\Model_Files_and_Scripts\models_opso-0.10.1\epoch-10_opso-0-10-1.model"

start_time = time.time()
print("Starting time:", start_time)

# Read and run the model ######################
# This wildcard pattern will work as long as you run it on the 2023_COLLAB_Audio folder
audio_files_list = list(glob(audio_file_location + "/*/*.[wW][aA][vV]"))
# make this into a dataframe
audio_files = pd.DataFrame(audio_files_list, columns=["file"]).set_index("file")
# testing the issue
print("Number of audio files:", len(audio_files_list))
print("Example audio file:", audio_files_list[0])
audio_files.head(5)
# test displaying audio
Audio.from_file(audio_files_list[0])

model = load_model(model_path)

# Spectrogram preprocessing
model.preprocessor.pipeline.load_audio.set(sample_rate=11025)
model.preprocessor.pipeline.bandpass.set(min_f=200, max_f=3500)
model.preprocessor.pipeline.to_spec.set(window_samples=512, overlap_samples=256)
model.preprocessor.pipeline.frequency_mask.bypass = True

scores = model.predict(audio_files)
print("Shape of scores:", scores.shape)

scores.to_csv(f"predictions_{Path(model_path).stem}-model.csv")


# Calculate the elapsed time
end_time = time.time()
elapsed_time = end_time - start_time

# Print the time it took to run the script
print(f"Script execution time: {elapsed_time:.2f} seconds")
