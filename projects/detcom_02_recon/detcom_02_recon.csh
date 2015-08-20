#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
@ runno = `echo $run | awk '{print $1 + 0}'`
echo ==start job==
date
echo project $project run $run file $file
#
cp -pv /group/halld/www/halldweb/html/detcom/02/conditions/* .
setenv PATH `pwd`:$PATH # put current directory into the path
echo ==environment==
source setup_jlab.csh
printenv
if ( $runno == 9301 || $runno == 9304 || $runno == 9311 || $runno == 9314 ) then
    set bfield_option = -PBFIELD_TYPE=NoField
else if (  $runno == 9302 || $runno == 9305 || $runno == 9312 || $runno == 9315 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_800A_poisson_20150427
else if ( $runno == 9303 || $runno == 9306 || $runno == 9313 || $runno == 9316 ) then
    set bfield_option = -PBFIELD_MAP=Magnets/Solenoid/solenoid_1300A_poisson_20150330
else
    echo illegal run number in ${project}.csh, run = $run
    exit 1
endif
set command = "hd_root -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT=300 -PNTHREADS=1 -PPLUGINS=danarest,TAGH_online,BCAL_online,FCAL_online,ST_online_tracking,TOF_online,monitoring_hists,BCAL_Eff,p2pi_hists,p3pi_hists,BCAL_inv_mass,trackeff_missing,TRIG_online $bfield_option hdgeant_smeared_${run}_${file}.hddm"
echo command = $command
$command
echo ==ls -lt after hd_root==
ls -lt
echo ==copy output files to disk==
set rest_dir=/volatile/halld/$project/rest
mkdir -p $rest_dir
cp -v dana_rest.hddm $rest_dir/dana_rest_${run}_${file}.hddm
set hd_root_dir=/volatile/halld/$project/hd_root
mkdir -p $hd_root_dir
cp -v hd_root.root $hd_root_dir/hd_root_${run}_${file}.root
echo ==end run==
date
echo ==exit==
exit
