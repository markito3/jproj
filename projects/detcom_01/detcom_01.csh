#!/bin/csh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
cp -v /home/gluex/halld/detcom/01/conditions/* .
source setup_jlab.csh
echo ==environment==
printenv
echo ==run bggen==
cp -v run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' 30000 run.ffr
rm -f fort.15
ln -s run.ffr fort.15
bggen
echo ==ls -l after bggen==
ls -l
echo ==run hdgeant==
set run4=`echo $run | perl -n -e 'printf "%4d", $_;'`
ln -s control.in_$run4 control.in
hdgeant
echo ==ls -l after hdgeant==
ls -l
echo ==run mcsmear==
mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm
echo ls -l after mcsmear
ls -l
echo ==run hd_ana to make evio output==
hd_ana -PPLUGINS=rawevent -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant_smeared.hddm
echo ==run hd_root==
# set the bfield map
if ( $run == 09101 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_1200A_poisson_20140520
else if ( $run == 09102 ) then
    set bfield_option = -PBFIELD_TYPE=NoField
else
    echo illegal run number in detcom_01.csh, run = $run
    exit 1
endif
# run hd_root
hd_root -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 \
    -PPLUGINS=monitoring_hists,danarest $bfield_option \
    hdgeant_smeared.hddm 
echo ==ls -l after hd_root==
ls -l
echo ==copy hdgeant, smeared, evio, rest and hd_root==
set hdgeant_dir=/volatile/halld/$project/hdgeant
mkdir -p $hdgeant_dir
cp -v hdgeant.hddm $hdgeant_dir/hdgeant_${run}_${file}.hddm
set smeared_dir=/volatile/halld/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
set evio_dir=/volatile/halld/$project/evio
mkdir -p $evio_dir
cp -v rawevent_0${run}.evio $evio_dir/rawevent_${run}_${file}.evio
set rest_dir=/volatile/halld/$project/rest
mkdir -p $rest_dir
cp -v dana_rest.hddm $rest_dir/dana_rest_${run}_${file}.hddm
set hd_root_dir=/volatile/halld/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${run}_${file}.root
echo ==exit==
exit
