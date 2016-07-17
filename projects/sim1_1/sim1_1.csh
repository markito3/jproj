#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo -=-start job-=-
date
echo project $project run $run file $file
#
cp -pv /group/halld/www/halldweb/html/gluex_simulations/sim1.1/* .
setenv PATH `pwd`:$PATH # put current directory into the path
echo -=-environment-=-
source setup_jlab.csh
printenv
#
# set number of events
#
set number_of_events = 25000
#
# set flags based on run number
#
set collimator = `rcnd $run collimator_diameter | awk '{print $1}'`
echo collimator = $collimator
if ($collimator == "") then
    echo "no value returned for collimator"
    exit 1
endif
#
echo -=-run bggen-=-
cp -v run.ffr.${collimator}_coll.template run.ffr
set seed = $run$file
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
cp -v control.in_${collimator}_coll control.in
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
echo -=-ls -lt after mcsmear-=-
ls -lt
echo -=-run hd_root-=-
set command = "hd_root -PJANA:BATCH_MODE=1 -PNTHREADS=1 -PPLUGINS=danarest,monitoring_hists,TRIG_online,BCAL_inv_mass,FCAL_invmass,BCAL_Hadronic_Eff,CDC_Efficiency,FCAL_Hadronic_Eff,FDC_Efficiency,SC_Eff,TOF_Eff -PTRKFIT:HYPOTHESES=2,3,8,9,11,12,14 hdgeant_smeared.hddm"
echo command = $command
$command
echo -=-ls -lt after hd_root-=-
ls -lt
#
echo -=-copy output files to disk-=-
#
set smeared_dir=/volatile/halld/gluex_simulations/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
#
set rest_dir=/volatile/halld/gluex_simulations/$project/rest
mkdir -p $rest_dir
cp -v dana_rest.hddm $rest_dir/dana_rest_${run}_${file}.hddm
#
set hd_root_dir=/volatile/halld/gluex_simulations/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${run}_${file}.root
#
set tree_bcal_hadronic_eff_dir=/volatile/halld/gluex_simulations/$project/tree_bcal_hadronic_eff_dir
mkdir -p $tree_bcal_hadronic_eff_dir
cp -v tree_bcal_hadronic_eff.root $tree_bcal_hadronic_eff_dir/tree_bcal_hadronic_eff_${run}_${file}.root
#
set tree_fcal_hadronic_eff_dir=/volatile/halld/gluex_simulations/$project/tree_fcal_hadronic_eff_dir
mkdir -p $tree_fcal_hadronic_eff_dir
cp -v tree_fcal_hadronic_eff.root $tree_fcal_hadronic_eff_dir/tree_fcal_hadronic_eff_${run}_${file}.root
#
set tree_sc_eff_dir=/volatile/halld/gluex_simulations/$project/tree_sc_eff_dir
mkdir -p $tree_sc_eff_dir
cp -v tree_sc_eff.root $tree_sc_eff_dir/tree_sc_eff_${run}_${file}.root
#
set tree_tof_eff_dir=/volatile/halld/gluex_simulations/$project/tree_tof_eff_dir
mkdir -p $tree_tof_eff_dir
cp -v tree_tof_eff.root $tree_tof_eff_dir/tree_tof_eff_${run}_${file}.root
#
echo -=-end run-=-
date
echo -=-exit-=-
exit
