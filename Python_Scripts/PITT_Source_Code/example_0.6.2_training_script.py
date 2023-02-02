from opensoundscape.preprocess.preprocessors import CnnPreprocessor
from opensoundscape.torch.models.cnn import CnnResampleLoss
from opensoundscape.torch.architectures import cnn_architectures
import pandas as pd
import os
from datetime import date, datetime
import time
from glob import glob
import logging
import sys

# Initiate logging
sys.path.append('/jet/home/sammlapp/utils')
import mylogging
sys.path.append('/jet/home/lmc150/Utils')
from save_tensor_sample import SaveTensorSample
# Set some variables.
random_state = 0
# Date
t1 = time.time()
today = date.today().strftime('%Y-%m-%d')
# Paths
p1 = '/ocean/projects/bio200037p/lmc150/SONG10/'
p2 = '/ocean/projects/bio200037p/lmc150/XC_negatives/GHOW_BADO_5s_negatives/'
p3 = '/ocean/projects/bio200037p/lmc150/Overlays/ewpw_night_5s/'
# Training Data
# Positives
BADO_labels = pd.read_csv(f'{p1}data/labels/2022-05-19_BADO_beg_labels.csv')
GHOW_labels = pd.read_csv(f'{p1}data/labels/2022-05-19_GHOW_beg_labels.csv')
pos_labels_df = pd.concat([BADO_labels,GHOW_labels])
pos_labels_df['file'] = [f'{p1}data/clips/{f}' for f in pos_labels_df['file'].tolist()]
pos_labels_df = pos_labels_df.fillna(0)
other_labels_df = pd.read_csv(f'{p1}data/labels/beg_other_class_negs.csv')
other_labels_df['file'] = [f'{p1}data/clips/{f}' for f in other_labels_df['file'].tolist()]
# Overlays
overlay_df1 = pd.read_csv(f'{p3}no_beg_overlays.csv')
overlay_df2 = pd.read_csv(f'{p3}random_overlays.csv')
overlay_df = pd.concat([overlay_df1,overlay_df2])
overlay_df['file'] = [f'{p3}clips/{f}' for f in overlay_df['file'].tolist()]
overlay_df = overlay_df.set_index('file')
# Negatives
xc_negatives_df = pd.read_csv(f'{p2}xeno-canto_400_5s_random.csv')
xc_negatives_df['file'] = [p2+f.split('/')[-1] for f in xc_negatives_df['file'].tolist()]
# Other Variables
annotated_negatives_size = 0.4
validation_size = 0.2
tensor_samples = 25
classes = ['BADO_beg','GHOW_beg']
# Preprocessing
clip_duration = 5
overlay_weight = [0.1,0.5]
bandpass = [0,10000]
window_samples = 1024
overlap_samples = 512
# Model training
label = 'beg_model'
save_path = f'{p1}models/{today}_BADO_GHOW_{label}/'
epochs = 100
batch_size = 64
save_interval = 100
num_workers = int(os.environ['SLURM_NTASKS'])
# Testing
#testing = 'on'
testing = 'off'

if testing=='off':
    log_filename = f"train_{label}_model_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S%Z')}.log"
    mylogging.setup_default_logging(log_filename)

#I did not make the training csvs before loading them into this script.
#I instead took csvs of the different training sources and spliced them together in this script.
#That is what's going on in this next section of code.

# Prepare data
min_pos = 0

# Downsample to make two owl classes even
for cl in classes:

    if min_pos>sum(pos_labels_df[cl].tolist()) or min_pos==0:
        min_pos = int(sum(pos_labels_df[cl].tolist()))

all_pos_df = pd.DataFrame()

# Sequester positives for downsampling
for cl in classes:
    pos_df = pos_labels_df.loc[pos_labels_df[cl]==1]
    pos_df = pos_df.sample(n=min_pos,random_state=random_state)
    all_pos_df = pd.concat([all_pos_df,pos_df])

# Other class will stay 500
anno_negatives_df = pos_labels_df.drop(all_pos_df.index.tolist())
neg_labels_df = pd.concat([xc_negatives_df,anno_negatives_df])

# Set up training and validation sets
validation_df = pd.concat([pos_labels_df.sample(frac=validation_size,random_state=random_state),
    neg_labels_df.sample(frac=validation_size,random_state=random_state),
    other_labels_df.sample(frac=validation_size,random_state=random_state)])
validation_df = validation_df.fillna(0)
validation_df = validation_df.set_index('file')
validation_df.to_csv(f'{p1}data/labels/{today}_{label}_validation.csv')

training_df = pd.concat([pos_labels_df,neg_labels_df,other_labels_df])
training_df = training_df.drop(validation_df.index.tolist())
training_df = training_df.fillna(0)
training_df = training_df.set_index('file')
training_df.to_csv(f'{p1}data/labels/{today}_{label}_training.csv')

# For testing purposes.
if testing=='on':
    training_df = training_df.sample(n=25,random_state=random_state)
    training_df.to_csv(f'{p1}data/labels/{today}_{label}_training_test.csv')
    validation_df = validation_df.sample(n=25,random_state=random_state)
    validation_df.to_csv(f'{p1}data/labels/{today}_{label}_validation_test.csv')
    tensor_samples = 1
    epochs = 0

# Preprocess data
# Training set
training_ds = CnnPreprocessor(training_df,overlay_df=overlay_df)
training_ds.actions.overlay.set(overlay_weight=overlay_weight,overlay_class='different')
training_ds.actions.bandpass.set(min_f=bandpass[0],max_f=bandpass[1])
training_ds.actions.to_spec.set(window_samples=window_samples,overlap_samples=overlap_samples)

# Validation set
validation_ds = CnnPreprocessor(validation_df)
validation_ds.actions.bandpass.set(min_f=bandpass[0],max_f=bandpass[1])
validation_ds.actions.to_spec.set(window_samples=window_samples,overlap_samples=overlap_samples)

# Model architecture
model = CnnResampleLoss(cnn_architectures.resnet18(len(training_df.columns.tolist())),
                     training_df.columns.tolist(),
                     single_target=False) # Train this one as multi-target; may re-evaluate depending on validation data

# Train model
model.train(train_dataset=training_ds,
            valid_dataset=validation_ds,
            save_path=save_path,
            epochs=epochs,
            batch_size=batch_size,
            save_interval=save_interval,
            num_workers=num_workers)

# Save tensor sample
training_ds.actions.color_jitter.off()
training_ds.actions.random_affine.off()
training_ds.actions.time_mask.off()
training_ds.actions.frequency_mask.off()
SaveTensorSample(training_df,
                 training_ds,
                 f'{p1}data/tensor_samples/',
                 training_df.columns.tolist(),
                 extra_label=f'training_{today}_{label}',
                 n=tensor_samples,
                 r=random_state)

# Predict on validation set
validation_ds.augmentation_off()
scores,_,_ = model.predict(
    validation_ds,
    batch_size=batch_size,
    num_workers=num_workers,
    activation_layer=None)
scores.to_csv(f'{p1}results/{today}_{label}_validation_scores.csv')
