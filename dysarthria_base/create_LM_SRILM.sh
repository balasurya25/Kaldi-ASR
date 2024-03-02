#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi
. parse_options.sh || exit 1;

lmdir=data/local/nist_lm
tmpdir=data/local/lm_tmp
lm_text='data/local/dict/lm_train.text'
lexicon=data/local/dict/lexicon.txt

mkdir -p $lmdir
mkdir -p $tmpdir

# (2) Create the phone bigram LM
if [ -z $SRILM ] ; then
  export SRILM=$KALDI_ROOT/../tools/srilm-1.6.0
fi

export PATH=${PATH}:$SRILM/bin/i686-m64

ngram-count -text $lm_text -order 2 \
  -lm $tmpdir/lm_phone_bg.ilm.gz

cp -r $tmpdir/lm_phone_bg.ilm.gz $lmdir/
mv $lmdir/lm_phone_bg.ilm.gz $lmdir/lm_phone_bg.arpa.gz
cp -r $tmpdir/lm_phone_bg.ilm.gz $lmdir/

echo "LM Preparation Succeeded"

echo "Preparing language models for test"

for lm_suffix in bg; do
  test=data/lang_test_${lm_suffix}
  mkdir -p $test
  cp -r data/lang/* $test
  gunzip -c $lmdir/lm_phone_${lm_suffix}.arpa.gz | \
    egrep -v '<s> <s>|</s> <s>|</s> </s>' | \
    arpa2fst - | fstprint | \
    utils/eps2disambig.pl | utils/s2eps.pl > $test/Gfst.txt
  gunzip -c $lmdir/lm_phone_${lm_suffix}.arpa.gz | \
    egrep -v '<s> <s>|</s> <s>|</s> </s>' | \
   arpa2fst - | fstprint | \
    utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$test/words.txt \
     --osymbols=$test/words.txt  --keep_isymbols=false --keep_osymbols=false | \
    fstrmepsilon | fstarcsort --sort_type=ilabel > $test/G.fst
  fstisstochastic $test/G.fst
  
 # The output is like:
 # 9.14233e-05 -0.259833
 # we do expect the first of these 2 numbers to be close to zero (the second is
 # nonzero because the backoff weights make the states sum to >1).
 # Because of the <s> fiasco for these particular LMs, the first number is not
 # as close to zero as it could be.

 # Everything below is only for diagnostic.
 # Checking that G has no cycles with empty words on them (e.g. <s>, </s>);
 # this might cause determinization failure of CLG.
 # #0 is treated as an empty word.
 
  mkdir -p $tmpdir/g
  awk '{if(NF==1){ printf("0 0 %s %s\n", $1,$1); }} END{print "0 0 #0 #0"; print "0";}' \
    < "$lexicon"  >$tmpdir/g/select_empty.fst.txt
  fstcompile --isymbols=$test/words.txt --osymbols=$test/words.txt $tmpdir/g/select_empty.fst.txt | \
   fstarcsort --sort_type=olabel | fstcompose - $test/G.fst > $tmpdir/g/empty_words.fst
  fstinfo $tmpdir/g/empty_words.fst | grep cyclic | grep -w 'y' && 
    echo "Language model has cycles with empty words" && exit 1
  rm -r $tmpdir/g
done

utils/validate_lang.pl data/lang_test_bg || exit 1

echo "Succeeded in formatting data."
rm -r $tmpdir
