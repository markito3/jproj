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
source setup_jlab.csh
#
# set number of events
#
set number_of_events = 1000
#
# set flag based on run number
#
@ runno = `echo $run | awk '{print $1 + 0}'`
if ($runno >= 9311 && $runno <= 9316) then
    set em = 1
else if ($runno >= 9301 && $runno <= 9306)
    set em = 0
else
    echo bad run number found when checking for bggen or em-only
    exit 3
endif
#
#echo ==environment==
#printenv
if (! $em) then
    echo ==run bggen==
    cp -v run.ffr.template run.ffr
    gsr.pl '<random_number_seed>' $file run.ffr
    gsr.pl '<run_number>' $run run.ffr
    gsr.pl '<number_of_events>' $number_of_events run.ffr
    if ( $run >= 09301 && $run <= 09303 )
        gsr.pl '<epeak>' 5.499 run.ffr
    else if ( $run >= 09304 && $run <= 09306 )
        gsr.pl '<epeak>' 3.4 run.ffr
    else
        echo bad run number found setting coherent/incoherent
	exit 2
    endif
    rm -f fort.15
    ln -s run.ffr fort.15
    bggen
    echo ==ls -l after bggen==
    ls -l
endif
echo ==run hdgeant==
set run4=`echo $run | perl -n -e 'printf "%4d", $_;'`
rm -f control.in
cp -v control.in.template control.in
if ($em) gsr.pl '<number_of_events>' $number_of_events control.in
set command = hdgeant
echo command = $command
$command
echo ==ls -l after hdgeant==
ls -l
echo ==run mcsmear==
set command = "mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm"
echo command = $command
$command
echo ls -l after mcsmear
ls -l
echo ==run hd_ana to make evio output==
set command = "hd_ana -PPLUGINS=rawevent -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant_smeared.hddm"
echo command = $command
$command
echo ==run hd_root==
# set the bfield map
if ( $run == 09301 || $run == 09304 || $run == 09311 || $run == 09314 ) then
    set bfield_option = -PBFIELD_TYPE=NoField
else if (  $run == 09302 || $run == 09305 || $run == 09312 || $run == 09315 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_800A_poisson_20150427
else if ( $run == 09303 || $run == 09306 || $run == 09313 || $run == 09316 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_1200A_poisson_20140520
else if ( $run == 09105 ) then
    set bfield_option = -PBFIELD_TYPE=NoField
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
set command = "hd_root -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 \
    $plugins_option $bfield_option \
    hdgeant_smeared.hddm" 
echo command = $command
$command
echo ==ls -l after hd_root==
ls -l
echo ==copy output files to disk==
#set hdgeant_dir=/volatile/halld/$project/hdgeant
#mkdir -p $hdgeant_dir
#cp -v hdgeant.hddm $hdgeant_dir/hdgeant_${run}_${file}.hddm
set smeared_dir=/volatile/halld/$project/smeared
mkdir -p $smeared_dir
cp -v hdgeant_smeared.hddm $smeared_dir/hdgeant_smeared_${run}_${file}.hddm
set evio_dir=/volatile/halld/$project/evio
mkdir -p $evio_dir
cp -v rawevent_0${run}.evio $evio_dir/rawevent_${run}_${file}.evio
if (! $em) then
    set rest_dir=/volatile/halld/$project/rest
    mkdir -p $rest_dir
    cp -v dana_rest.hddm $rest_dir/dana_rest_${run}_${file}.hddm
endif
set hd_root_dir=/volatile/halld/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${run}_${file}.root
echo ==end run==
date
echo ==exit==
exit
