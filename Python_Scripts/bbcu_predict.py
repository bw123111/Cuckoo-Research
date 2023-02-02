# Import statements
from opensoundscape.torch.models.cnn import load_outdated_model
from opensoundscape.preprocess.preprocessors import SpectrogramPreprocessor
from time import time
from datetime import date
import pandas as pd
from glob import glob

# Set up some paths
model_path = 'path\\to\\model\\epoch-350.tar'
locations_path = 'path\\to\\locations' # Use * to indicate separate locations directories
scores_path = 'path\\to\\saved\\scores'

# Load saved model
model = load_outdated_model(model_path,'resnet18',5.0)
model.preprocessor.pipeline.to_img.set(invert=True) # OPSO 0.7.1 has inverted black and white
# Important to specify these preprocessing parameters which were used to train the model
model.preprocessor.pipeline.load_audio.set(sample_rate=2000)
model.preprocessor.pipeline.to_spec.set(window_samples=256, overlap_samples=224)
model.preprocessor.pipeline.bandpass.set(min_f=500, max_f=800)

# Predict on each point
locations = glob(locations_path)

for loc in locations:
    t1 = time.time()
    audio_files = glob(f"{loc}\\*.WAV")
    scores,_,_ = model.predict(audio_files,
                                overlap_fraction=0
                                )
    scores.to_csv(scores_path+date.today().strftime('%Y-%m-%d')+'_'+loc.split('\\')[-1]+'_scores.csv')
    t2 = time.time()
    print(loc.split('\\')[-1]+' completed in '+str(int((t2-t1)/60))+' minutes.')
