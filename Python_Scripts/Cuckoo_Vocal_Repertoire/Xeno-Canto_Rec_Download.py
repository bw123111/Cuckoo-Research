'''
Xeno-Canto Recording Extraction Clip

Created by Christian Dupree 6/13/2023

'''
#env req.

#Python=3.8
#pip install requests
#pip install tqdm

# NOTE: the default location to download the files is wherever the script is located

import requests
import os
import urllib.request
from tqdm import tqdm  # import tqdm

def download_bird_calls(query):
    BASE_URL = 'https://www.xeno-canto.org/api/2/recordings'
    query = {'query': query}
    response = requests.get(BASE_URL, params=query)
    data = response.json()

    os.makedirs('bird_calls', exist_ok=True)  # create directory if it doesn't exist

    if 'recordings' in data:
        # wrap the loop with tqdm for progress bar
        for i, recording in tqdm(enumerate(data['recordings'], 1), total=len(data['recordings']), desc='Downloading', unit='file'):
            file_url = recording['file']
            file_name = os.path.join('bird_calls', os.path.basename(file_url))  # specify the directory
            urllib.request.urlretrieve(file_url, file_name)

        print(f"\nDownloaded {i} files.")  # print newline for better formatting
    else:
        print("No recordings found.")

if __name__ == "__main__":
    query = input("Enter bird name: ") #Enter bird name here
    download_bird_calls(query)


