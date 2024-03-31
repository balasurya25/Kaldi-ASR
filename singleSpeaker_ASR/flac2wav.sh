#!/bin/bash 

mkdir -p newwave/train

for speaker in MC01; do
	mkdir -p newwave/train/$speaker
for((j=1; j<=365; j++)); do
	sourceaudio="/home/balasurya/SSN_TDSC/data/moderate/$speaker/audio/${speaker}${j}.flac"
	destaudio="newwave/train/$speaker/${speaker}${j}.wav"
	ffmpeg -i "$sourceaudio" "$destaudio"
done
cp /home/balasurya/SSN_TDSC/data/moderate/$speaker/label/*.lab newwave/train/$speaker
done

echo "DONE"
