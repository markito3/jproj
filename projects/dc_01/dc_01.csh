#!/bin/csh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
cp -v /home/marki/halld/data_challenge/01/conditions/* .
source setup_jlab.csh
#echo ==environment==
#printenv
cp run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<number_of_events>' 50000 run.ffr
rm -f fort.15
ln -s run.ffr fort.15
bggen
echo ls -l after bggen
ls -l
hdgeant
echo ls -l after hdgeant
ls -l
mcsmear hdgeant.hddm
echo ls -l after mcsmear
ls -l
#echo copy
#cp -v hdgeant_smeared.hddm /volatile/halld/home/marki/proj/bggen/bggen_hdgeant_smeared_${run}_${file}.hddm
hd_root -PPLUGINS=monitoring_hists,danarest -PJANA:BATCH_MODE=1 hdgeant_smeared.hddm
echo ls -l after hd_root
ls -l
echo copy
set rest_dir=/volatile/halld/home/marki/proj/$project/rest
mkdir -p $rest_dir
cp -v dana_rest.hddm $rest_dir/dana_rest_${file}.hddm
set hd_root_dir=/volatile/halld/home/marki/proj/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${file}.root
/home/marki/halld/jproj/scripts/move_log_files.sh $AUGER_ID /w/work/halld/home/marki/proj/${project}
exit
