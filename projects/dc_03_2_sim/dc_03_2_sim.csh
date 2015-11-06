#!/bin/csh
date
set project=$1
set run=$2
set file=$3
echo processing project = $project, run = $run, file = $file
cp -pv /group/halld/www/halldweb/html/data_challenge/03_2/conditions/* .
echo -=-setting up environment-=-
set command="source setup_jlab.csh"
echo $command
$command
echo -=-environment-=-
printenv
echo -=-run bggen-=-
cp -v run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<run_number>' $run run.ffr
#gsr.pl '<number_of_events>' 400000 run.ffr
gsr.pl '<number_of_events>' 4000 run.ffr
rm -f fort.15
ln -s run.ffr fort.15
bggen
echo -=-ls -lt after bggen-=-
ls -lt
echo -=-run hdgeant-=-
set command=hdgeant
echo $command
$command
rm -v bggen.hddm
echo -=-ls -lt after hdgeant-=-
ls -lt
echo -=-run mcsmear-=-
set command="mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT_FIRST_EVENT=300 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm"
echo $command
$command
echo -=-copy smeared-=-
mkdir -p /volatile/halld/data_challenge/$project/smeared
cp -pv hdgeant_smeared.hddm /volatile/halld/data_challenge/$project/smeared/hdgeant_smeared_${run}_${file}.hddm
rm -v hdgeant.hddm
echo -=-ls -lt after mcsmear-=-
ls -lt
echo -=-run hd_ana, translate to evio format-=-
set command="hd_ana -PJANA:BATCH_MODE=1 -PPLUGINS=rawevent -PRAWEVENT:NO_PEDESTAL=0 -PRAWEVENT:NO_RANDOM_PEDESTAL=1 hdgeant_smeared.hddm"
echo $command
$command
rm -v hdgeant_smeared.hddm
echo -=-ls -lt after hd_ana-=-
ls -lt
echo -=-copy evio-=-
set run6=`echo $run | perl -n -e 'printf "%06d", $_;'` # needed for hd_ana output
cp -pv rawevent_$run6.evio /volatile/halld/data_challenge/$project/smeared/hdgeant_smeared_${run}_${file}.evio
echo -=-exit-=-
date
exit
