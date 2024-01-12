''' 
Clip Extraction Code
This is a script to extract top scoring clips from each site. The output will give you the scripts to run the listening_notebook code on to annotate the clips for cuckoo presence. 

As a note, when I changed between using the D: drive and the E: drive, it gave me a bunch of errors becuase in lines 168 and 180 I had to change the / into a \\.

Copied from script of same name from model 1.0 files 1/11/2024
Last edited 1/12/2024
'''

from opensoundscape.audio import Audio
#from opensoundscape.helpers import hex_to_time
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
- sort by date and time of day (diurnal vs nocturnal)
- slice off the top 1-2 rows (top scoring file per day) and keep those
- append the top ones to another csv to save all the top scores
- modify this csv - pull out site name and date 
- within that csv, create the name of the saved clip: directory\\file_name_startime_endtime\\

- loop through this csv, load each of those audio files into memory between the start and end time that match
- save it to the clip name that you have in the csv 

-adjust this to account for both rattle and coo call - pull both top scoring rattle and top scoring coo from each site each period. (This will balance out the differences in model performance - if we just pull one and if the rattle classifier is overfit it's likely to bias towards the more confident score even if it's wrong)
'''

# Create a value for today's date
#today = date.today().strftime('%Y-%m-%d')
#print(today)

# Establish which dataset you're working on and where the metadata is
year = 'Test' # Format YYYY
collab = 'R6' # Format UMBEL or FWPR#
metad_file = '2023_ARUDeployment_MetadataFull_Cleaned10-24.csv'
# SHOULDN'T HAVE TO EDIT BELOW THIS LINE


# Establish which dataset you're working with 
dataset = f'{year}_{collab}'
print(dataset)

# Establish the file path for the scores
score_path = f'E:\\CNN_Classifier_Files\\Model_2.0\\Model_Scores\\predictions_epoch-10_opso-0-10-1-{year}_{collab}_Audio.csv'
# Establish the file path for where the clips will go
clips_path = f'E:\\Cuckoo_Acoustic_Data\\{year}\\{year}_{collab}_Data\\{year}_{collab}_Clips_2.0\\'
# Establish the file path for the folder with all the audio files
audio_path = f'E:\\Cuckoo_Acoustic_Data\\{year}\\{year}_{collab}_Data\\{year}_{collab}_Audio\\'
# Establish the file path for the metadata folder
metad_path = 'C:/Users/annak/OneDrive/Documents/UM/Research/Coding_Workspace/Cuckoo-Research/Data/Metadata/Outputs/'
# Establish which classes you are annotating (only one (BBCU) originally)
classes = ['cadence_coo','rattle']
# CHANGE LINE 170 AS WELL

# Read in the csv for the location IDs
metadata = pd.read_csv(metad_path+metad_file, encoding= 'unicode_escape')
# Take the column labeled 'point_ID' and put it into a list [with tolist()] that is sorted in orde [with sorted()], then converted to a set of iterable elements [with set()]
locs_list = sorted(set(metadata['point_id'].tolist()))
#print("Printing locs list")
#print(locs_list)

# Pull the scores into a dataframe
sf = pd.read_csv(score_path)
#print("Scores file:")
#print(sf.head())  

# Iterate through each class the in the CNN model 
for cl in classes:
    keep_df = pd.DataFrame()
    print()
    print('Working on '+cl)

    # Check if a folder for the class exists and if not, make one 
    if exists(clips_path+dataset+'_topclip_perperiod\\'+cl)==False:
        subprocess.check_call('mkdir '+clips_path+dataset+'_topclip_perperiod\\'+cl, shell=True)
 
    print("The current scores file is",score_path)
    # make a new column called point_id from the string after the second \\ in the first column in the scores file
    sf['point_id'] = sf['file'].apply(lambda x: x.split('\\')[-2] if isinstance(x, str) else None)
    # Extract the point IDs from the first column in the scores file and create a list of unique ones 
    point_list = list(set(sf['point_id']))
    #point_list = list(set([x.split('\\')[-2] if isinstance(x, str) else None for x in sf['file']]))
    print("List of points:",point_list)


    for point in point_list:
        # Initialize a folder relating the class to the location you're looking at 
        folder = clips_path+dataset+'_topclip_perperiod\\'+cl+'\\'+point
        print("The current folder is")
        print(folder)
     
        # Check if the location from the file is included in the list of locations of the acoustic data, and if not, nothing happens 
        if point not in locs_list:
            # place for future code if the location is not in the list 
            warnings.warn('point ID from scores file not in list from acoustic metadata', UserWarning)
        
        else:
            # Check if the folder already exists, and if not, create the folder
            if exists(folder)==False:
                subprocess.check_call('mkdir '+folder, shell=True)
                # At this point, it's gone through and created a new folder for each site

            # Pull out the values of sf that include location in the file column
            df = sf[sf['point_id'] == point]
            print("Dataframe for this point is:")
            print(df)
           
            # resets the index back to zero but drops the previously used indexes from it
            df = df.reset_index(drop=True)
            
            # Create a dataframe based on each scores CSV file 
            # Pull out the date and the hour for each file and add them to a name 
            # int() converts a string to an integer and returns
            # split() splits a string into a list using a specified separator
            df['date'] = [(d.split('_')[-2]) for d in df['file'].tolist()]
            df['hour'] = [(d.split('_')[-1].split('.')[0]) for d in df['file'].tolist()]
            df['hour'] = df['hour'].astype(int)
            df['time_period'] = np.where((df['hour'] == 70000) | (df['hour'] == 90000), 'diurnal',
                             np.where((df['hour'] == 230000) | (df['hour'] == 10000), 'nocturnal', 'unknown'))
            df['species'] = "BBCU"
            # Order the columns
            df = df[['file','date','hour','time_period','point_id','start_time','end_time','species','cadence_coo','rattle']]
            # check if df has everything you want in it
            #print("Printing df")
            #print(df) 
            #print(df.columns)
            
            # Initialize a counter
            num = 0

            ####### LEFT OFF HERE 1-12 #####################################################
            # make a sub data frame to work with
            sub_df1 = df
# in R: sub_df %>% group_by(date, time_period) %>% arrange()
            # original: sub_df1 = sub_df1.sort_values(by=['cadence_coo'],ascending=False)
            # Pull out the top scoring file from each day and each time period
            ## Do this in a for loop?
            sub_df1 = sub_df1.groupby(['date', 'time_period']).apply(lambda x: x.sort_values(by='cadence_coo'))
            
            # resets the index at the start of the for loop but drops the current value from consideration (double check this)
            sub_df1 = sub_df1.reset_index(drop=True)
            # take the top scoring file
            sub_df1 = sub_df1.iloc[:1]
            #print("Printing sub_df - this one should be sorted")
            print(sub_df1)
'''            
            num += len(sub_df)
            # append the result to dataframe with top scoring clips
            keep_df = pd.concat([keep_df,sub_df])
            
            # decide whether to keep in new data
            if num!=10:
                print(f'{point} does not have top ten files.')

            if len(df)<1:
                print(point+' failed.')
                continue
               
    #print("Printing keep df before and after creating a clip column")
    #keep_df.to_csv(clips_path+'test_keep_df.csv')
    #print(len(keep_df))
    #for i in range(len(keep_df)+1):
    #    print(i)
    # split the part where it creates the smaller clips into print statements to see where its getting hung up
        
    keep_df = keep_df.reset_index(drop=True)
    # create new column named clip that has the name for the clip (w/in master csv) (list comprehension)
    keep_df['clip'] = [clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+keep_df['file'].iat[i].split('\\')[-2]+'\\'+keep_df['date'].iat[i]+'_'+keep_df['hour'].iat[i]+'_'+str(keep_df['start_time'].iat[i])+'s-'+str(keep_df['end_time'].iat[i])+'s.wav' for i in range(len(keep_df))]
    
    #print(keep_df)
    #keep_df['clip'] = [clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+keep_df['file'].iat[i].split('/')[-2]+'\\'+keep_df['file'].iat[i].split('\\')[-1].split('.')[0]+str(keep_df['start_time'].iat[i])+'s-'+str(keep_df['end_time'].iat[i])+'s.wav' 
    #for i in range(len(keep_df))]
    #print(keep_df)
    #keep_df.to_csv(r'E:\Clip_Extraction_Test2.csv')
    
    # loop through master csv
    for i in range(len(keep_df)):
        #specify the specific audiofile to load, specify which clip you want to isolate
        filename = keep_df['file'].iat[i]
        filename = "D:\\" + "\\".join(filename.split("\\")[1:])
        audio = Audio.from_file(filename,offset=keep_df['start_time'].iat[i],duration=5)
        # save the new clip to the clip name you specified previously
        audio.save(keep_df['clip'].iat[i])
    
    # save the csv as well
    keep_df.to_csv(clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+'top10scoring_clips_persite.csv')
    

'''






'''
FROM OLD CODE
# Pull out all file paths that match the pattern specified below
# Glob() returns everything that matches a string
#scores = glob(score_path+'2023-**-**_***-*_scores.csv') # Don't need to have this anymore because the scores are all in one sheet
######## Modify this to match current format of one score output per folder ################################
#Glob pattern matching, not a regular expression https://pubs.opengroup.org/onlinepubs/000095399/utilities/xcu_chap02.html#tag_02_13

# Check whether the folder of clips already exists and if not create it
# Structure for clips files: 'E:\\2022_UMBEL_Clips\\2022-10-21_2022UMBEL_top10persite
if exists(clips_path+today+'_'+dataset+'_topclips\\')==False:
    print('mkdir'+clips_path+today+'_'+dataset+'_topclips')
    subprocess.check_call('mkdir '+clips_path+today+'_'+dataset+'_topclips',shell=True)
    # Subprocess gives the terminal whatever string command you give 

#keep_df = pd.DataFrame()
#print(keep_df)

 #df = sf[sf['file'].apply(lambda x: x.split('\\')[-2] if isinstance(x, str) else None).isin(point_list)]
            # make a new column called point_id
            #df['point_id'] = df['file'].apply(lambda x: x.split('\\')[-2] if isinstance(x, str) else None)

            #print("df is",df['point_id'])

            # PULL OUT THE ROWS IN SF THAT MATCH THE LOCATION to make the dataframe that I'll be interacting with###################
            #df['point'] = [c.split('_')[-3] for c in df['file'].tolist()]
            ####### ADD ON A STRING DIURNAL IF HOUR BETWEEN 070000 and 093000, NOCTURNAL IF HOUR BETWEEN 230000 and 013000 #############################################
            # below used to be location but I think this is extraneous
            #df['point'] = [location for d in df['file'].tolist()]
            #print("CHECK FOR POINT VALUES HERE")
            #print(df['point'])

            # assign the species to the current class you're working in 
            #df = df.assign(species=cl)
            # old code
'''