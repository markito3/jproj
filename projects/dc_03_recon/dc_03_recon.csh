#!/bin/csh
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
set run5=`echo $run | perl -n -e 'printf "%05d", $_;'`
set file6=`echo $file | perl -n -e 'printf "%07d", $_;'`
cp -v /group/halld/www/halldweb/html/data_challenge/03/conditions/* .
echo ==setting up environment==
source setup_jlab.csh
echo ==environment==
printenv
echo ==analyze the evio file==
hd_root -PPLUGINS=DAQ,TTab,monitoring_hists,danarest -PJANA:BATCH_MODE=1 hdgeant_smeared_${run5}_${file7}.evio
mkdir -p /volatile/halld/data_challenge/$project/root
cp -pv hd_root.root /volatile/halld/data_challenge/$project/root/hd_root_${run5}_${file7}.root
mkdir -p /volatile/halld/data_challenge/$project/rest
cp -pv dana_rest.hddm /volatile/halld/data_challenge/$project/rest/dana_rest_${run5}_${file7}.hddm
echo ==exit==
exit
