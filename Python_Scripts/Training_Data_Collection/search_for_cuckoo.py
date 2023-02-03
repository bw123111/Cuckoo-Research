# Bella Wengappuly      31 Jan 2023         Cuckoo Research
# This script should allow you to search all files in a folder for 
# the string "Cuckoo". 

# Global code variables at the top of the page allow for folder and 
# search term modification. 
import os

SEARCH_TERM = "Cuckoo"
# for path, all \ must be changed to \\
PATH_TO_FOLDER = "E:\\BirdNET_Classifier_Runs\\2022_FWPR6_Classifier_Runs\\CUL-1"

def searchText(path):
    
    os.chdir(path)
    files = os.listdir()
    #print(files)
    for file_name in files:
        #print(file_name)
        abs_path = os.path.abspath(file_name)
        
        if os.path.isdir(abs_path):
            searchText(abs_path)
            
        if os.path.isfile(abs_path):
             with open(file_name, 'r', encoding='utf-8') as f:
                if SEARCH_TERM in f.read():
                    final_path = os.path.abspath(file_name)
                    print(SEARCH_TERM + " word found in this path " + final_path)
                else:
                    print("No match found in " + abs_path)
    pass

searchText(PATH_TO_FOLDER)
