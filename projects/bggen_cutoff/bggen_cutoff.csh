#!/bin/tcsh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo ==start job==
date
echo project $project run $run file $file
#
cp -pv /group/halld/www/halldweb/html/detcom/02/conditions/* .
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
if ($runno == 9401) then
    set cutoff=2.4
else if ($runno == 9402) then
    set cutoff=2.5
else if ($runno == 9403) then
    set cutoff=2.6
else if ($runno == 9404) then
    set cutoff=2.7
else if ($runno == 9405) then
    set cutoff=2.8
else if ($runno == 9406) then
    set cutoff=2.9
else if ($runno == 9407) then
    set cutoff=3.0
else if ($runno == 9411) then
    set cutoff=2.4
else if ($runno == 9412) then
    set cutoff=2.5
else if ($runno == 9413) then
    set cutoff=2.6
else if ($runno == 9414) then
    set cutoff=2.7
else if ($runno == 9415) then
    set cutoff=2.8
else if ($runno == 9416) then
    set cutoff=2.9
else if ($runno == 9417) then
    set cutoff=3.0
else
    echo bad run number found setting bggen cut-off
    exit 3
endif
#
echo ==prepare run.ffr==
cp -v run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' $number_of_events run.ffr
gsr.pl 2.5 $cutoff run.ffr
if ( $runno >= 9401 && $runno <= 9407 ) then
    gsr.pl '<epeak>' 5.4999 run.ffr
else if ( $runno >= 9411 && $runno <= 9417 ) then
    gsr.pl '<epeak>' 3.0 run.ffr
else
    echo bad run number found setting coherent/incoherent
exit 2
endif
rm -f fort.15
ln -s run.ffr fort.15
echo ====begin run.ffr====
cat run.ffr
echo ====end run.ffr====
echo ==run bggen==
set command = bggen
echo command = $command
$command
echo ==ls -lt after bggen==
set bggen_dir=/volatile/halld/detcom_02/bggen
mkdir -p $bggen_dir
cp -v bggen.hddm $bggen_dir/bggen_${run}_${file}.hddm
exit
