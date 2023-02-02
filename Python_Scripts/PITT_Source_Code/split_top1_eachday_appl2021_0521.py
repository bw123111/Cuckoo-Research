from opensoundscape.audio import Audio
from opensoundscape.helpers import hex_to_time
import pandas as pd
from glob import glob
import subprocess
from os.path import exists
from datetime import date
import numpy as np

today = date.today().strftime('%Y-%m-%d')
p1 = '/media/kitzeslab/T7/song8/v1.2/'
p2 = '/home/chc419/projects/song8_CAWA/clips/'
dataset = 'appl2021'
classes = ['CAWA_song']
card_file = pd.read_csv(p2+'2021_CentralApps_cardIDs.csv')
cards = sorted(set(card_file['card_ID'].tolist()))
cards = [c.strip() for c in cards]
scores = glob(p1+'scores/2022-09-09_'+dataset+'*.csv')
first_date = 20210521
last_date = 20210530
date_range = np.arange(first_date,last_date+1,1)

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

            for d in date_range:
                sub_df = df.loc[df['date']==d]
                sub_df = sub_df.sort_values(by=[cl],ascending=False)
                sub_df = sub_df.reset_index(drop=True)
                sub_df = sub_df.iloc[:1]
                num += len(sub_df)
                keep_df = pd.concat([keep_df,sub_df])

            if num!=10:
                print(f'{card} does not have all 10 days.')

            if len(df)<1:
                print(card+' failed.')
                continue

    keep_df = keep_df.reset_index(drop=True)
    keep_df['clip'] = [p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+keep_df['file'].iat[i].split('/')[-2]+'/'+keep_df['file'].iat[i].split('/')[-2]+'_'+keep_df['file'].iat[i].split('/')[-1].split('.')[0]+'_'+str(keep_df['start_time'].iat[i])+'s-'+str(keep_df['end_time'].iat[i])+'s.wav' for i in range(len(keep_df))]

    for i in range(len(keep_df)):
        audio = Audio.from_file(keep_df['file'].iat[i],offset=keep_df['start_time'].iat[i],duration=4)
        audio.save(keep_df['clip'].iat[i])

    keep_df.to_csv(p2+today+'_'+dataset+'_top1_10day/'+cl+'/'+today+'_'+dataset+'_'+cl+'_top1_'+str(first_date)+'-'+str(last_date)+'_scores.csv')
