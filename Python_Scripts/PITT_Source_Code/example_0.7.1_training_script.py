from opensoundscape.torch.models.cnn import use_resample_loss,CNN
from opensoundscape.preprocess.preprocessors import SpectrogramPreprocessor
import pandas as pd
from datetime import date

dataset = pd.read_csv('2022-10-06_training_modified.csv').set_index('file')
validation = pd.read_csv('2022-10-06_validation_modified.csv').set_index('file')
overlays = pd.read_csv('2022-10-06_NSWO_Overlays.csv').set_index('file')
today = date.today().strftime('%Y-%m-%d')

preprocessor = SpectrogramPreprocessor(5,overlay_df=overlays)
preprocessor.pipeline.overlay.set(overlay_weight=[0.3,0.7])
preprocessor.pipeline.to_spec.params.window_samples = 1024
preprocessor.pipeline.to_spec.params.overlap_samples = 512
preprocessor.pipeline.bandpass.set(min_f=0,max_f=2000)
model = CNN('resnet18',['NSWO_song','GHOW_adult','BADO_adult'],5.0,single_target=False)
model.preprocessor = preprocessor
use_resample_loss(model)
print("model.single_target:", model.single_target)
print(dataset.columns)
print(validation.columns)

model.train(
    train_df=dataset,
    validation_df=validation,
    save_path=f'./models/{today}', #where to save the trained model
    epochs=100,
    batch_size=512,
    save_interval=100, #save model every 5 epochs (the best model is always saved in addition)
    num_workers=10, #specify 4 if you have 4 CPU processes, eg; 0 means only the root process
)
