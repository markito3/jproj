#!/bin/csh
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
cp -v /group/halld/www/halldweb/html/data_challenge/03_2/conditions/* .
echo ==setting up environment==
source setup_jlab.csh
echo ==environment==
printenv
echo ==analyze the evio file==
hd_root -PPLUGINS=DAQ,monitoring_hists,danarest -PJANA:BATCH_MODE=1 hdgeant_smeared_${run}_${file}.evio
mkdir -p /volatile/halld/data_challenge/$project/root
cp -pv hd_root.root /volatile/halld/data_challenge/$project/root/hd_root_${run}_${file}.root
mkdir -p /volatile/halld/data_challenge/$project/rest
cp -pv dana_rest.hddm /volatile/halld/data_challenge/$project/rest/dana_rest_${run}_${file}.hddm
echo ==exit==
exit
