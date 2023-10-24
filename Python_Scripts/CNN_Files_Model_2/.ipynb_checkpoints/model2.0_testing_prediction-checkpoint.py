import opensoundscape
from opensoundscape.ml.cnn import load_model
from opensoundscape import Audio

# Other utilities and packages
import torch
#from pathlib import Path
import pathlib
import numpy as np
import pandas as pd
from glob import glob
import subprocess

# Change this to the path to your files
audio_file_location = "F:\\CNN_Classifier_Files\\Model_2.0\\Test_Acoustic_Data_Mini"
# In this location, I copied a couple of files from CUL-1


# Change this to the path to your model file
model_path = "C:\\Users\\ak201255\\Documents\\CNN_Model2.0\\epoch-10.model"

# Chat GPT suggestion: Use Path from pathlib to handle paths
#model_path = Path(model_path)
# Stackoverflow suggesion
# temp = pathlib.PosixPath
# pathlib.PosixPath = pathlib.WindowsPath
# reset on line 45


# This wildcard pattern will work as long as you run it on the 2023_COLLAB_Audio folder
audio_files_list = list(glob(audio_file_location + "\\*\\*.[wW][aA][vV]"))
# make this into a dataframe
audio_files = pd.DataFrame(audio_files_list, columns=["file"]).set_index("file")
print("here is audio_files:")

print(audio_files.head())

model = load_model(model_path)

scores = model.predict(audio_files)

scores.to_csv(f"predictions_{model_path.stem}-model.csv")

#reset earlier setting 
#pathlib.PosixPath = temp

