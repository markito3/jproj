#!/bin/csh
eval `~marki/bin/delpath.pl /apps/bin`
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
cp -v /home/gxproj2/halld/data_challenge/03/conditions/* .
echo ==setting up environment==
source setup_jlab.csh
echo ==environment==
printenv
echo ==run bggen==
cp -v run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' 5000 run.ffr
rm -f fort.15
ln -s run.ffr fort.15
bggen
echo ==ls -l after bggen==
ls -l
echo ==run hdgeant==
hdgeant
echo ==ls -l after hdgeant==
ls -l
echo ==run mcsmear==
mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT_FIRST_EVENT=300 \
    -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm
echo ls -l after mcsmear
ls -l
echo ==translate to evio format==
hd_ana -PPLUGINS=rawevent hdgeant_smeared.hddm
echo ==copy smeared==
mkdir -p /volatile/halld/data_challenge/$project/smeared
cp -pv hdgeant_smeared.evio /volatile/halld/data_challenge/$project/smeared/hdgeant_smeared_${run}_${file}.evio
echo ==exit==
exit
