# extract mfcc features for train and test
./steps/make_mfcc.sh --cmd run.pl --nj 4 --config ./conf/mfcc.conf data/train exp/make_mfcc/train mfcc 
./steps/make_mfcc.sh --cmd run.pl --nj 2 --config ./conf/mfcc.conf data/test exp/make_mfcc/test mfcc 

# compute cepstral mean and variance normalisation for the train and test utterances
./steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train mfcc
./steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test mfcc

# detect voice activity in the speech 
./steps/compute_vad_decision.sh --nj 4 data/train exp/make_vad/train vad
./steps/compute_vad_decision.sh --nj 2 data/test exp/make_vad/test vad
