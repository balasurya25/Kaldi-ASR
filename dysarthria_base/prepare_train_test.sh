#!/bin/bash

cut -d' ' -f3- wave_text/train.trans > wave_text/train.txt
cut -d' ' -f3- wave_text/test.trans > wave_text/test.txt

#create wav.scp
for speaker in FC01 FC02 FC03 FC04 FC05 MC01 MC02 MC03 MC04 MC05; do
filepath1=newwave/train/$speaker/*.wav
filepath2=newwave/test/$speaker/*.wav
for var in $filepath1; do
	filename1=$(basename "$var")
	filename1="${filename1%.*}"
	printf "$filename1\n" >> wave_text/uttID_train_${speaker}.txt
done
for var in $filepath2; do
	filename2=$(basename "$var")
	filename2="${filename2%.*}"
	printf "$filename2\n" >> wave_text/uttID_test_${speaker}.txt
done

sed "s;${speaker};/home/balasurya/kaldi/egs/normal_base/newwave/train/${speaker}/${speaker};g" wave_text/uttID_train_${speaker}.txt > wave_text/train_wavelist_${speaker}.txt
sed "s;${speaker};/home/balasurya/kaldi/egs/normal_base/newwave/test/${speaker}/${speaker};g" wave_text/uttID_test_${speaker}.txt > wave_text/test_wavelist_${speaker}.txt
done
cat wave_text/uttID_train_*.txt > wave_text/uttID_train
cat wave_text/uttID_test_*.txt > wave_text/uttID_test
sort -o wave_text/uttID_train{,}
sort -o wave_text/uttID_test{,}
cat wave_text/train_wavelist_*.txt > wave_text/train_wavelist
cat wave_text/test_wavelist_*.txt > wave_text/test_wavelist

rm wave_text/train_wavelist_*.txt
rm wave_text/test_wavelist_*.txt
rm wave_text/uttID_train_*.txt
rm wave_text/uttID_test_*.txt

sed -i 's/$/.wav/g' wave_text/train_wavelist
sed -i 's/$/.wav/g' wave_text/test_wavelist

paste wave_text/uttID_train wave_text/train_wavelist > data/train/wav.scp
paste wave_text/uttID_test wave_text/test_wavelist > data/test/wav.scp
sed -i 's/\t/ /g' data/train/wav.scp
sed -i 's/\t/ /g' data/test/wav.scp
 
#create utt2spk
for x in train test; do
#paste wave_text/uttID_$x wave_text/speakerID > data/$x/utt2spk
cat data/$x/wav.scp | awk '{print $1}' > wave_text/utt_$x
cat wave_text/utt_$x | cut -c 1-4 > wave_text/spk_$x
paste wave_text/utt_$x wave_text/spk_$x > data/$x/utt2spk
sed -i 's/\t/ /g' data/$x/utt2spk
done

#create spk2utt
for x in train test 
do
utils/fix_data_dir.sh data/$x
done
 
#create text
for i in train test; do
paste wave_text/uttID_${i} wave_text/${i}.txt > data/${i}/text
sed -i 's/\t/ /g' data/${i}/text
done 
 
#create segments
bash ./local/create_segments.sh
echo "DONE"
