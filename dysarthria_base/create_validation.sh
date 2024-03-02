#!/bin/bash

mkdir -p newwave/test

for speaker in FC01 FC02 FC03 FC04 FC05 MC01 MC02 MC03 MC04 MC05; do
mkdir -p newwave/test/$speaker
for var1 in 113 116 118 119 120 121 122 125 145 151 153 158 159 161 166 174 175 176 179 187 188 190 193 194 197 ; do
audiofile="newwave/train/$speaker/${speaker}_${var1}.wav"
labfile="newwave/train/$speaker/${speaker}_${var1}.lab"
mv "$audiofile" newwave/test/$speaker
mv "$labfile" newwave/test/$speaker
done
done

echo "DONE"
