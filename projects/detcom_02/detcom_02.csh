#!/bin/csh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo ==start job==
date
echo project $project run $run file $file
#
cp -pv /home/gxproj4/halld/detcom/02/conditions/* .
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
# set flag based on run number
#
@ runno = `echo $run | awk '{print $1 + 0}'`
if ($runno >= 9311 && $runno <= 9316) then
    set em = 1
else if ($runno >= 9301 && $runno <= 9306) then
    set em = 0
else
    echo bad run number found when checking for bggen or em-only
    exit 3
endif
#
if (! $em) then
    echo ==run bggen==
    cp -v run.ffr.template run.ffr
    gsr.pl '<random_number_seed>' $file run.ffr
    gsr.pl '<run_number>' $run run.ffr
    gsr.pl '<number_of_events>' $number_of_events run.ffr
    if ( $runno >= 9301 && $runno <= 9303 ) then
        gsr.pl '<epeak>' 5.4999 run.ffr
    else if ( $runno >= 9304 && $runno <= 9306 ) then
        gsr.pl '<epeak>' 3.4 run.ffr
    else
        echo bad run number found setting coherent/incoherent
	exit 2
    endif
    rm -f fort.15
    ln -s run.ffr fort.15
    set command = bggen
    echo command = $command
    $command
    echo ==ls -lt after bggen==
    ls -lt
endif
echo ==run hdgeant==
set run4=`echo $run | perl -n -e 'printf "%4d", $_;'`
rm -f control.in
cp -v control.in.template control.in
gsr.pl '<number_of_events_max>' $number_of_events_max control.in # TRIG card
if ($em) then
    gsr.pl INFILE cINFILE control.in # comment out INFILE card
    gsr.pl '<run_number>' $run control.in
else
    gsr.pl RUNNO cRUNNO control.in # comment out run number setting
endif
if ($runno >= 9301 && $runno <= 9303 || $runno >= 9311 && $runno <= 9313) then 
    gsr.pl '<coherent_edge>' 5.4999 control.in # coherent running
else if ($runno >= 9304 && $runno <= 9306|| $runno >= 9314 && $runno <= 9316) then 
    gsr.pl '<coherent_edge>' 3.4 control.in # coherent running
else
    echo bad run number determining coherent edge position
    exit 4
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
echo ==run hd_ana to make evio output==
set command = "hd_ana -PPLUGINS=rawevent -PRAWEVENT:NO_PEDESTAL=0  -PRAWEVENT:NO_RANDOM_PEDESTAL=1 -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant_smeared.hddm"
echo command = $command
$command
echo ==ls -lt after hd_ana==
ls -lt
echo ==run hd_root==
# set the bfield map
if ( $runno == 9301 || $runno == 9304 || $runno == 9311 || $runno == 9314 ) then
    set bfield_option = -PBFIELD_TYPE=NoField
else if (  $runno == 9302 || $runno == 9305 || $runno == 9312 || $runno == 9315 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_800A_poisson_20150427
else if ( $runno == 9303 || $runno == 9306 || $runno == 9313 || $runno == 9316 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_1300A_poisson_20150330
else
    echo illegal run number in detcom_02.csh, run = $run
    exit 1
endif
# set plugins list
if ($em) then
    set plugins_option = -PPLUGINS=monitoring_hists,CDC_online,FDC_online,ST_online,TOF_online,FCAL_online,BCAL_online
else
    set plugins_option = -PPLUGINS=monitoring_hists,danarest
endif
set command = "hd_root -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 $plugins_option $bfield_option hdgeant_smeared.hddm" 
echo command = $command
$command
echo ==ls -lt after hd_root==
ls -lt
echo ==copy output files to disk==
#set hdgeant_dir=/volatile/halld/$project/hdgeant
#mkdir -p $hdgeant_dir
#cp -v hdgeant.hddm $hdgeant_dir/hdgeant_${run}_${file}.hddm
set smeared_dir=/volatile/halld/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
if (! $em) then
    set evio_dir=/volatile/halld/$project/evio
    mkdir -p $evio_dir
    cp -v rawevent_0${run}.evio $evio_dir/rawevent_${run}_${file}.evio
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
