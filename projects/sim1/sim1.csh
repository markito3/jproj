#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo -=-start job-=-
date
echo project $project run $run file $file
#
cp -pv /group/halld/www/halldweb/html/gluex_simulations/sim1/conditions/* .
setenv PATH `pwd`:$PATH # put current directory into the path
echo -=-environment-=-
source setup_jlab.csh
printenv
#
# set number of events
#
set number_of_events = 25000
#
# set seed offset
#
@ seed_offset = 0
#
# set flag based on run number
#
@ runno = `echo $run | awk '{print $1 + 0}'`
@ fileno = `echo $file | awk '{print $1 + 0}'`
#
echo -=-run bggen-=-
cp -v run.ffr.template run.ffr
@ seed = $fileno + $seed_offset
gsr.pl '<random_number_seed>' $seed run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' $number_of_events run.ffr
rm -f fort.15
ln -s run.ffr fort.15
echo -=-fort.15-=-
cat fort.15
echo -=-=-=-=-=-=-
set command = bggen
echo command = $command
$command
echo -=-ls -lt after bggen-=-
ls -lt
echo -=-run hdgeant-=-
rm -f control.in
cp -v control.in_9001 control.in
echo -=-control.in-=- 
perl -n -e 'chomp; if (! /^c/ && $_) {print "$_\n";}' < control.in
echo -=-=-=-=-=-=-=-=
set command = hdgeant
echo command = $command
$command
echo -=-ls -lt after hdgeant-=-
ls -lt
echo -=-run mcsmear-=-
set command = "mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1"
set command = "$command hdgeant.hddm"
echo command = $command
$command
echo ls -lt after mcsmear
ls -lt
echo -=-run hd_root-=-
set command = "hd_root -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1"
set command = "${command} -PPLUGINS=danarest,TAGH_online,BCAL_online,"
set command = "${command}FCAL_online,ST_online_tracking,TOF_online,"
set command = "${command}monitoring_hists,BCAL_Eff,p2pi_hists,p3pi_hists,"
set command = "${command}BCAL_inv_mass,trackeff_missing,TAGM_online"
set command = "${command} hdgeant_smeared.hddm"
echo command = $command
$command
echo -=-ls -lt after hd_root-=-
ls -lt
echo -=-copy output files to disk-=-
set smeared_dir=/volatile/halld/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
set rest_dir=/volatile/halld/$project/rest
mkdir -p $rest_dir
cp -v dana_rest.hddm $rest_dir/dana_rest_${run}_${file}.hddm
set hd_root_dir=/volatile/halld/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${run}_${file}.root
echo -=-end run-=-
date
echo -=-exit-=-
exit
