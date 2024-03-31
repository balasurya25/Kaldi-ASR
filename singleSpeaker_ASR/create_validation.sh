#!/bin/bash

mkdir -p newwave/test

for speaker in MC01; do
mkdir -p newwave/test
for var1 in 113 116 118 119 120 121 122 125 145 151 153 158 159 161 166 174 175 176 179 187 188 190 193 194 197 ; do 
audiofile="newwave/train/${speaker}${var1}.wav"
labfile="newwave/train/${speaker}${var1}.lab"
mv "$audiofile" newwave/test
mv "$labfile" newwave/test
done
done

echo "DONE"
