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

# Change this to the path to your files
audio_file_location = "/path/to/my/folder"

# Change this to the path to your model file
model_path = "/path/to/my/model/epoch-X.model"

# Epoch 10 was best.model previously
model = load_model('./model_training_checkpoints_2023-10-13_18:56:42.785065/epoch-10.model')

# May need to change the wildcard pattern below to be sure you get all your files
audio_files_list = list(glob(audio_file_location + "/*/*.WAV"))
audio_files_list = audio_files_list + list(glob(audio_file_location + "/*/*.wav"))
audio_files = pd.DataFrame(audio_files_list, columns="file").set_index("file")

print(audio_files.head())

model = load_model(model_path)

scores = model.predict(audio_files)

scores.to_csv(f"predictions_{Path(model_path).stem}-model.csv")

