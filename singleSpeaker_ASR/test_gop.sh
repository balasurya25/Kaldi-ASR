# /bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

#testing
nj=2
mkdir -p exp/compute_gop_test

./steps/nnet2/align.sh --nj 2 data/test data/lang exp/nnet2 exp/nnet2_test_ali

compute-mfcc-feats --config=conf/mfcc.conf scp:data/test/wav.scp ark:- | copy-feats --compress=true ark:- ark,scp:mfcc_test_feats.ark,mfcc_test_feats.scp

nnet-am-compute --apply-log=false exp/nnet2_test_ali/final.mdl scp:mfcc_test_feats.scp ark,t:exp/compute_gop_test/posterior_infile.ark

cp exp/compute_gop/lookup_table.txt exp/compute_gop_test/
cp exp/compute_gop/show_transitions.txt exp/compute_gop_test/

in_file=exp/compute_gop_test/posterior_infile.ark
cat $in_file | sed -e '1d' | sed -e 's/^[ \t]*//' > exp/compute_gop_test/posterior_test.txt 

for((i=1; i<=$nj; i++)); do
	gzip -d exp/nnet2_test_ali/ali.$i.gz
	show-alignments exp/nnet2/phones.txt exp/nnet2_test_ali/final.mdl ark:exp/nnet2_test_ali/ali.$i > exp/nnet2_test_ali/show_ali_$i.txt
done

cat exp/nnet2_test_ali/show_ali_*.txt > exp/nnet2_test_ali/alignments.txt
awk '$0' exp/nnet2_test_ali/alignments.txt > exp/compute_gop_test/align_infile.txt

mkdir -p exp/compute_gop_test/phones
mkdir -p exp/compute_gop_test/ids
mkdir -p exp/compute_gop_test/segments

for((i=1; i<=50; i++))
do
rs=`expr $i % 2`

if [ "$rs" == 0 ] 
then
cat exp/compute_gop_test/align_infile.txt | head -$i | tail -1 | sed 's/ /\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '/^$/d' | \
 sed '1d' > exp/compute_gop_test/phones/tmp_phones_$i.txt
else
cat exp/compute_gop_test/align_infile.txt | head -$i | tail -1 | sed 's/\[ /\n/g' | sed 's/\ ]//g' | sed 's/ /\n/g' | sed 's/^[ \t]*//;s/[ \t]*$//' | \
	sed '/^$/d' | sed '1d' > exp/compute_gop_test/ids/tmp_t_ids_$i.txt
cat exp/compute_gop_test/align_infile.txt | head -$i | tail -1 | sed 's/\[ /\n/g' | sed 's/\ ]//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '1d' | \
	 awk '{print NF}' > exp/compute_gop_test/segments/tmp_segments_$i.txt
fi
done
