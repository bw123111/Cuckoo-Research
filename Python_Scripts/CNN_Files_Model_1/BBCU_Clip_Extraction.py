''' 
This is a script to extract top scoring clips from each site. The output will give you the scripts to run the listening_notebook code on to annotate the clips for cuckoo presence. 

As a note, when I changed between using the D: drive and the E: drive, it gave me a bunch of errors becuase in lines 168 and 180 I had to change the / into a \\.
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
dataset = '2022FWPR7'

# Establish the file path for the scores
score_path = 'D:\\2022_FWPR7_Scores\\'
# Establish the file path for where the clips will go
clips_path = 'D:\\2022_FWPR7_Clips\\'
# Establish the file path for the folder with all the audio files
audio_path = 'D:\\2022_FWPR7_Audio\\'
# Establish the file path for the metadata folder
metad_path = 'C:\\Users\\annak\\OneDrive\\Documents\\UM\\Research\\UM Masters Thesis R Work\\Data\\Metadata\\'
# Establish which classes you are annotating (only one in this case)
classes = ['BBCU']
# CHANGE LINE 170 AS WELL

# Read in the csv for the location IDs
loc_file= pd.read_csv(metad_path+'2022_ARUDeployment_Metadata_FWPR7.csv', encoding= 'unicode_escape')
# Take the column labeled 'point_ID' and put it into a list [with tolist()] that is sorted in orde [with sorted()], then converted to a set of iterable elements [with set()]
locs_list = sorted(set(loc_file['point_id'].tolist()))
print("Printing locs list")
print(locs_list)
# Pull out all file paths that match the pattern specified below
# Glob() returns everything that matches a string
scores = glob(score_path+'2023-**-**_***-*_scores.csv')
#Glob pattern matching, not a regular expression https://pubs.opengroup.org/onlinepubs/000095399/utilities/xcu_chap02.html#tag_02_13
print(scores)   

# Check whether the folder of clips already exists and if not create it
# Structure for clips files: 'E:\\2022_UMBEL_Clips\\2022-10-21_2022UMBEL_top10persite
if exists(clips_path+today+'_'+dataset+'_top10persite\\')==False:
    print('mkdir'+clips_path+today+'_'+dataset+'_top10persite')
    subprocess.check_call('mkdir '+clips_path+today+'_'+dataset+'_top10persite',shell=True)
    # Subprocess gives the terminal whatever string command you give 

#keep_df = pd.DataFrame()
#print(keep_df)
    
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
        print("The current scores file is",sf)
        location = sf.split('_')[-2]
        print(location)
        # Initialize a folder relating the class to the location you're looking at 
        folder = clips_path+today+'_'+dataset+'_top10persite\\'+cl+'\\'+location
        print("The current folder is",folder)
        
        # Check if the location from the file is included in the list of locations of the acoustic data, and if not, nothing happens 
        if location not in locs_list:
            # place for future code if the location is not in the list 
            print('location from scores file not in list from acoustic data')
            # None of the locations are in the location files list
        
        else:
            # Check if the folder already exists, and if not, create the folder
            if exists(folder)==False:
                subprocess.check_call('mkdir '+folder, shell=True)
                # At this point, it's gone through and created a new folder for each site

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
            print("CHECK FOR POINT VALUES HERE")
            print(df['point'])
            # assign the species to the current class you're working in 
            df = df.assign(species=cl)
            # old code
            ##df['species'] = [cl]
            ##add location and c1 to df
            ##Create a dataframe that combines all of the previous columns 
            ##df = df[['file','date','hour','point','start_time','end_time','species']]
            
            num = 0
            # check if df has everything you want in it
            #print("Printing df")
            #print(df) 
            
            # make a sub data frame to work with
            sub_df = df
            sub_df = sub_df.sort_values(by=['present'],ascending=False)
            
            # resets the index at the start of the for loop but drops the current value from consideration (double check this)
            sub_df = sub_df.reset_index(drop=True)
            # take the top 10 from each site
            sub_df = sub_df.iloc[:10]
            #print("Printing sub_df - this one should be sorted")
            #print(sub_df)
            
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
    

