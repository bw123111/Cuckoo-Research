'''
This is a file for testing out how to measure the overall background noise of a .wav file

Components:
-use dB? how to measure amplitude

Resources:
http://opensoundscape.org/en/latest/api/modules.html#module-opensoundscape.audio

'''
# import Audio and Spectrogram classes from OpenSoundscape
from opensoundscape.audio import Audio
from opensoundscape.spectrogram import Spectrogram
from pathlib import Path
import IPython.display as ipd


# load in an audiofile and create a spectrogram from it
audio_path = 'E:\\2022_UMBEL_Clips\\2022-12-09_2022UMBEL_top10persite\\BBCU\\82-1\\20220620_070000_1385.0s-1390.0s.wav'

audio_1 = Audio.from_file(audio_path)
# create an object for this spectrogram
spectrogram_1 = Spectrogram.from_audio(audio_1)
# plot the spectrogram
spectrogram_1.plot()

'''
# calculate amplitude signal
high_freq_amplitude = spectrogram_1.amplitude()

# plot
from matplotlib import pyplot as plt
plt.plot(spec_trimmed.times,high_freq_amplitude)
plt.xlabel('time (sec)')
plt.ylabel('amplitude')
plt.show()
'''