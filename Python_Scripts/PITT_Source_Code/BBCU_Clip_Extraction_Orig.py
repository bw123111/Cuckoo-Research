''' 
This is a script to extract top scoring clips from each site. The output will give you the scripts to run the listening_notebook code on to annotate the clips for cuckoo presence. 
'''


from opensoundscape.audio import Audio
from opensoundscape.helpers import hex_to_time
import pandas as pd
from glob import glob
import subprocess
from os.path import exists
from datetime import date
import numpy as np


'''
to do
1. loop through each csv file of scores
as you do, take note of where each csv file was recorded
create a folder for each of the locations 
- sort the dataframe that has the scores from highest to lowest
- slice off the top 10-15 rows (10 in this case) and keep those
- append the top ones to another csv to save all the top scores
- modify this csv - pull out site name and date 
- within that csv, create the name of the saved clip: directory\\file_name_startime_endtime\\

- loop through this csv, load each of those audio files into memory between the start and end time that match
- save it to the clip name that you have in the csv 
'''

# Create a value for today's date
today = date.today().strftime('%Y-%m-%d')
print(today)

# Establish which dataset you're working on 
dataset = '2022UMBEL'

# Establish the file path for the scores
score_path = 'E:\\2022_UMBEL_Scores\\'
# Establish the file path for where the clips will go
clips_path = 'E:\\2022_UMBEL_Clips\\'
# Establish the file path for the folder with all the audio files
audio_path = 'E:\\2022_UMBEL_Audio\\'
# Establish the file path for the metadata folder
metad_path = 'C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Metadata\\'
# Establish which classes you are annotating (only one in this case)
classes = ['BBCU']

# Read in the csv for the location IDs
loc_file= pd.read_csv(metad_path+'2022_ARUDeployment_Metadata_UMBEL.csv')
# Take the column labeled 'point_ID' and put it into a list [with tolist()] that is sorted in orde [with sorted()], then converted to a set of iterable elements [with set()]
locs_list = sorted(set(loc_file['point_ID'].tolist()))

# Pull out all file paths that match the pattern specified below
# Glob() returns everything that matches a string
scores = glob(score_path+'2022-10-2*_*_scores.csv')
    

# Check whether the folder of clips already exists and if not create it
# Structure for clips files: 'E:\\2022_UMBEL_Clips\\2022-10-21_2022UMBEL_top10persite
if exists(clips_path+today+'_'+dataset+'_top10persite\\')==False:
    print('mkdir',clips_path+today+'_'+dataset+'_top10persite')
    subprocess.check_call('mkdir '+clips_path+today+'_'+dataset+'_top10persite',shell=True)
    # Subprocess gives the terminal whatever string command you give 

# Check if the data frame has been initialized for the class you're working with
## Do I need this if I only have one class? maybe keep in case I want to add a YBCU annotation to the dataset 
for cl in classes:
    keep_df = pd.DataFrame()
    print()
    print('Working on '+cl)

    if exists(clips_path+today+'_'+dataset+'_top10persite\\'+cl)==False:
        subprocess.check_call('mkdir '+clips_path+today+'_'+dataset+'_top10persite\\'+cl, shell=True)
        
    # for each .csv file in the list of all the scores .csv files
    for sf in scores:
        # Split accepts a string and splits it into a list of characters based on the string in the parenthesis 
        # Putting the negative one and two tell you the second and third to last items in those list 
        print(sf)
        location = sf.split('_')[-2]
        print(location)
        # Initialize a folder relating the class to the location you're looking at 
        folder = clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+location
        print(folder)
        
        # Check if the location from the file is included in the list of locations of the acoustic data, and if not, nothing happens 
        if location not in locs_list:
            # place for future code if the location is not in the list 
            print('location from scores file not in list from acoustic data')
            # None of the locations are in the location files list
        
        else:
            # Check if the folder already exists, and if not, create the folder
            if exists(folder)==False:
                subprocess.check_call('mkdir '+folder, shell=True)

            # Read in the .csv scores file for that location
            df = pd.read_csv(sf)
            # resets the index back to zero but drops the previously used indexes from it
            df = df.reset_index(drop=True)
            
            # At this point, it's gone through and created a new folder for each site 
            
            # Next, we'll be *fill in*
            # Pull out the date and the hour for each file and add them to a name 
        
            # int() converts a string to an integer and returns
            # split() splits a string into a list using a specified separator
            df['date'] = [int(d.split('_')[-2]) for d in df['file'].tolist()]
            df['hour'] = [int(d.split('_')[-1].split('.')[0]) for d in df['file'].tolist()]
            #df['point'] = [c.split('_')[-3] for c in df['file'].tolist()]
            # below used to be location but I think this is extraneous
            df['point'] = [location for d in df['file'].tolist()]
            # assign the species to the current class you're working in 
            df = df.assign(species=cl)
            # old code
            #df['species'] = [cl]
            # add location and c1 to df
            # Create a dataframe that combines all of the previous columns 
            #df = df[['file','date','hour','point','start_time','end_time','species']]
            
            num = 0
            # check if df has everything you want in it
            #print(df)
            '''
            # make a sub data frame to work with
            sub_df = df
            sub_df = sub_df.sort_values(by=['present'],ascending=False)
            # resets the index at the start of the for loop but drops the current value from consideration (double check this)
            sub_df = sub_df.reset_index(drop=True)
            # take the top 10 from each site
            sub_df = sub_df.iloc[:10]
            num += len(sub_df)
            # append the result to dataframe with top scoring clips
            keep_df = pd.concat([keep_df,sub_df])
            '''
            
            # For each day in the date range, pull out top 10 (original code)
            # ISSUE: ITS NOT SEPARATING THEM BY SITE, ITS TAKING THE TOP ALL AROUND___________________
            for l in locs_list:
                # Access the location by the column designating the point ID to create a dataframe
                sub_df = df.loc[df['point']==l]
                # take dataframe of scores (sub_df) and sort them by scores (c1) 
                sub_df = sub_df.sort_values(by=['present'],ascending=False)
                # resets the index at the start of the for loop but drops the current value from consideration (double check this)
                sub_df = sub_df.reset_index(drop=True)
                # take the top 10 from each site
                sub_df = sub_df.iloc[:10]
                num += len(sub_df)
                # append the result to dataframe with top scoring clips
                keep_df = pd.concat([keep_df,sub_df])
            
            '''
            # Old code for the top ten in each site: could nest this within the site values 
            for d in date_range:
                sub_df = df.loc[df['date']==d]
                # take dataframe of scores (sub_df) and sort them by scores (c1) 
                sub_df = sub_df.sort_values(by=[cl],ascending=False)
                sub_df = sub_df.reset_index(drop=True)
                # take the top one (change to 10 or 15 -- 13) from 
                sub_df = sub_df.iloc[:1]
                num += len(sub_df)
                # append the result to dataframe with top scoring clips
                keep_df = pd.concat([keep_df,sub_df])
            '''
            
            # decide whether to keep in new data
            if num!=10:
                print(f'{card} does not have all 10 days.')

            if len(df)<1:
                print(card+' failed.')
                continue
            keep_df.head(10)
            #print(keep_df)
            #exit()
            
''' 
                keep_df = keep_df.reset_index(drop=True)
    # create new column named clip that has the name for the clip (w/in master csv) (list comprehension)
    keep_df['clip'] = [p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+keep_df['file'].iat[i].split('/')[-2]+'/'+keep_df['file'].iat[i].split('/')[-2]+'_'+keep_df['file'].iat[i].split('/')[-1].split('.')[0]+'_'+str(keep_df['start_time'].iat[i])+'s-'+str(keep_df['end_time'].iat[i])+'s.wav' for i in range(len(keep_df))]

    # loop through master csv
    for i in range(len(keep_df)):
        #specify the specific audiofile to load, specify which clip you want to isolate 
        audio = Audio.from_file(keep_df['file'].iat[i],offset=keep_df['start_time'].iat[i],duration=5)
        # save the new clip to the clip name you specified previously
        audio.save(keep_df['clip'].iat[i])
    # save the csv as well
    keep_df.to_csv(p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+today+'_'+dataset+'_'+cl+'_top1_'+str(first_date)+'-'+str(last_date)+'_scores.csv')
'''


        
        
'''
### ORIGINAL CODE #####
# Establish the file path for where your annotations will go (????????????)
#p1 = '/media/kitzeslab/T7/song8/v1.2/'
# Establish the file path for where your clips are stored
#p2 = '/home/chc419/projects/song8_CAWA/clips/'

# Establish where the scores are (????????????)
# set the parent directory for all of the folder with point files 
dataset = 'appl2021'
# Establish which classes you are annotating (????????????)
classes = ['CAWA_song']
# Read in the csv for the location (card) IDs(separate .csv for each card)
loc_file = pd.read_csv(p2+'2021_CentralApps_cardIDs.csv')
# Take the column labeled 'card_ID' (will be point_ID) for my data and put it into a list that is sorted in order, then converted to a set of iterable elements with set()
locs = sorted(set(loc_file['point_ID'].tolist()))
# Returns a subset of the string - do this to get a list of all the different sites?
locs = [c.strip() for c in locs]
## Skipping above line for now, could add later if I need it
# Pull out all file paths that match the pattern specified below
scores = glob(p1+'scores/2022-09-09_'+dataset+'*_scores.csv')

# Specify the ten day range they're looking at? (won't need this in my code)
#first_date = 20210521
#last_date = 20210530
#date_range = np.arange(first_date,last_date+1,1)

# Check whether the clips have already been extracted
if exists(p2+today+'_'+dataset+'_top1_10day/')==False:
    subprocess.check_call(['mkdir',p2+today+'_'+dataset+'_top1_10day/'])

for cl in classes:
    keep_df = pd.DataFrame()
    print()
    print('Working on '+cl)

    if exists(p2+today+'_'+dataset+'_top1_10day/'+cl)==False:
        subprocess.check_call(['mkdir',p2+today+'_'+dataset+'_top1_10day/'+cl])

    for sf in scores:
        card = sf.split('/')[-1].split('_')[-2]
        folder = p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+card

        if card not in cards:
            pass

        else:

            if exists(folder)==False:
                subprocess.check_call(['mkdir',folder])

            df = pd.read_csv(sf)
            df = df.reset_index(drop=True)

            try:
                df['date'] = [int(d.split('/')[-1].split('_')[0]) for d in df['file'].tolist()]
                df['hour'] = [int(d.split('/')[-1].split('_')[-1].split('.')[0]) for d in df['file'].tolist()]

            except:
                df['date'] = [int(hex_to_time(d.split('/')[-1].split('.')[0]).strftime('%Y%m%d')) for d in df['file'].tolist()]
                df['hour'] = [int(hex_to_time(d.split('/')[-1].split('.')[0]).strftime('%H%M%S')) for d in df['file'].tolist()]

            df['card'] = [c.split('/')[-2] for c in df['file'].tolist()]
            df = df[['file','date','hour','card','start_time','end_time',cl]]
            num = 0
            
            # remove for loop
            # For each day in the date range, pull out 
            for d in date_range:
                sub_df = df.loc[df['date']==d]
                # take dataframe of scores (sub_df) and sort them by scores (c1) 
                sub_df = sub_df.sort_values(by=[cl],ascending=False)
                sub_df = sub_df.reset_index(drop=True)
                # take the top one (change to 10 or 15 -- 13) from 
                sub_df = sub_df.iloc[:1]
                num += len(sub_df)
                # append the result to dataframe with top scoring clips
                keep_df = pd.concat([keep_df,sub_df])

            if num!=10:
                print(f'{card} does not have all 10 days.')

            if len(df)<1:
                print(card+' failed.')
                continue

    keep_df = keep_df.reset_index(drop=True)
    # create new column named clip that has the name for the clip (w/in master csv) (list comprehension)
    keep_df['clip'] = [p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+keep_df['file'].iat[i].split('/')[-2]+'/'+keep_df['file'].iat[i].split('/')[-2]+'_'+keep_df['file'].iat[i].split('/')[-1].split('.')[0]+'_'+str(keep_df['start_time'].iat[i])+'s-'+str(keep_df['end_time'].iat[i])+'s.wav' for i in range(len(keep_df))]

    # loop through master csv
    for i in range(len(keep_df)):
        #specify the specific audiofile to load, specify which clip you want to isolate 
        audio = Audio.from_file(keep_df['file'].iat[i],offset=keep_df['start_time'].iat[i],duration=5)
        # save the new clip to the clip name you specified previously
        audio.save(keep_df['clip'].iat[i])
    # save the csv as well
    keep_df.to_csv(p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+today+'_'+dataset+'_'+cl+'_top1_'+str(first_date)+'-'+str(last_date)+'_scores.csv')
'''