# Test for script name
from opensoundscape.audio import Audio
from opensoundscape.helpers import hex_to_time
import pandas as pd
from glob import glob
import subprocess
from os.path import exists
from datetime import date
import numpy as np



score_path = 'E:\\2022_UMBEL_Scores\\'
scores = glob(score_path+'2022-10-2*_*_scores.csv')
clips_path = 'E:\\2022_UMBEL_Clips\\'
today = date.today().strftime('%Y-%m-%d')
dataset = '2022UMBEL'
cl ='BBCU'
keep_df = pd.DataFrame()

for sf in scores:
    # Split accepts a string and splits it into a list of characters based on the string in the parenthesis 
    # Putting the negative one and two tell you the second and third to last items in those list 
    #print(sf)
    location = sf.split('_')[-2]
    #print(location)
    # Initialize a folder relating the class to the location you're looking at 
    #folder = clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+location
    #print(folder)
        
    # Read in the .csv scores file for that location
    df = pd.read_csv(sf)
    # resets the index back to zero but drops the previously used indexes from it
    df = df.reset_index(drop=True)

    # Create a dataframe based on each scores CSV file 
    # Pull out the date and the hour for each file and add them to a name 
    # int() converts a string to an integer and returns
    # split() splits a string into a list using a specified separator
    df['date'] = [(d.split('_')[-2]) for d in df['file'].tolist()]
    df['hour'] = [(d.split('_')[-1].split('.')[0]) for d in df['file'].tolist()]
    #df['point'] = [c.split('_')[-3] for c in df['file'].tolist()]
    # below used to be location but I think this is extraneous
    df['point'] = [location for d in df['file'].tolist()]
    #print("CHECK FOR POINT VALUES HERE")
    #print(df['point'])
    # assign the species to the current class you're working in 
    df = df.assign(species=cl)

    sub_df = df
    sub_df = sub_df.sort_values(by=['present'],ascending=False)

    # resets the index at the start of the for loop but drops the current value from consideration (double check this)
    sub_df = sub_df.reset_index(drop=True)
    # take the top 10 from each site
    sub_df = sub_df.iloc[:10]
    #print(sub_df)

    #num += len(sub_df)
    # append the result to dataframe with top scoring clips
    keep_df = pd.concat([keep_df,sub_df])

    keep_df = keep_df.reset_index(drop=True)
    
    print(keep_df)
    for i in range(len(keep_df)):
    # create new column named clip that has the name for the clip (w/in master csv) (list comprehension)
        keep_df['clip'] = [clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+keep_df['file'].iat[i].split('/')[-2]+'\\'+keep_df['date'].iat[i]+'_'+keep_df['hour'].iat[i]+'_'+str(keep_df['start_time'].iat[i])+'s-'+str(keep_df['end_time'].iat[i])+'s.wav'for i in range(len(keep_df))]
        
# ValueError: Length of values (1) does not match length of index (10)
        
#print(keep_df[clip])

# Changes to original code:
# Took out int() in date and hour
# added for i in range(len(keep_df)): before list comprehension
                       