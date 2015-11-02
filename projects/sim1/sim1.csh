#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo ==start job==
date
echo project $project run $run file $file
#
cp -pv /group/halld/www/halldweb/html/gluex_simulations/sim1/conditions/* .
setenv PATH `pwd`:$PATH # put current directory into the path
echo ==environment==
source setup_jlab.csh
printenv
#
# set number of events
#
set number_of_events = 30000
set number_of_events_max = 10000000 # will be used for em background only runs
#
# set seed offset
#
@ seed_offset = 0
#
# set flag based on run number
#
@ runno = `echo $run | awk '{print $1 + 0}'`
@ fileno = `echo $file | awk '{print $1 + 0}'`
if ($runno >= 9011 && $runno <= 9020) then
    set em = 1
else if ($runno >= 9001 && $runno <= 9010) then
    set em = 0
else
    echo bad run number found when checking for bggen or em-only
    exit 3
endif
#
if (! $em) then
    echo ==run bggen==
    cp -v run.ffr.template run.ffr
    @ seed = $fileno + $seed_offset
    gsr.pl '<random_number_seed>' $seed run.ffr
    gsr.pl '<run_number>' $run run.ffr
    gsr.pl '<number_of_events>' $number_of_events run.ffr
    rm -f fort.15
    ln -s run.ffr fort.15
    set command = bggen
    echo command = $command
    $command
    echo ==ls -lt after bggen==
    ls -lt
endif
echo ==run hdgeant==
rm -f control.in
cp -v control.in_9001 control.in
gsr.pl '<number_of_events_max>' $number_of_events_max control.in # TRIG card
if ($em) then
    gsr.pl INFILE cINFILE control.in # comment out INFILE card
    gsr.pl '<run_number>' $run control.in
else
    gsr.pl RUNNO cRUNNO control.in # comment out run number setting
endif
set command = hdgeant
echo command = $command
$command
echo ==ls -lt after hdgeant==
ls -lt
echo ==run mcsmear==
set command = "mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm"
echo command = $command
$command
echo ls -lt after mcsmear
ls -lt
echo ==run hd_root==
set command = "hd_root -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 -PPLUGINS=danarest,monitoring_hists hdgeant_smeared.hddm"
echo command = $command
$command
echo ==ls -lt after hd_root==
ls -lt
echo ==copy output files to disk==
set smeared_dir=/volatile/halld/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
if (! $em) then
    set rest_dir=/volatile/halld/$project/rest
    mkdir -p $rest_dir
    cp -v dana_rest.hddm $rest_dir/dana_rest_${run}_${file}.hddm
endif
set hd_root_dir=/volatile/halld/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${run}_${file}.root
echo ==control.in==
perl -n -e 'chomp; if (! /^c/ && $_) {print "$_\n";}' < control.in
if (! $em) then
   echo ==fort.15==
   cat fort.15
endif
echo ==end run==
date
echo ==exit==
exit
