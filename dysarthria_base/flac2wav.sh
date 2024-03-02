#!/bin/bash 

mkdir -p newwave/train

for speaker in FC01 FC02 FC03 FC04 FC05 MC01 MC02 MC03 MC04 MC05; do
	mkdir -p newwave/train/$speaker
for((j=1; j<=365; j++)); do
	sourceaudio="/home/balasurya/SSN_TDSC/data/control/$speaker/audio/${speaker}_${j}.flac"
	destaudio="newwave/train/$speaker/${speaker}_${j}.wav"
	ffmpeg -i "$sourceaudio" "$destaudio"
done
cp /home/balasurya/SSN_TDSC/data/control/$speaker/label/*.lab newwave/train/$speaker
done


echo "DONE"
