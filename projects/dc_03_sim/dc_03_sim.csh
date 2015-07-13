#!/bin/csh
#eval `~marki/bin/delpath.pl /apps/bin`
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
set run5=`echo $run | perl -n -e 'printf "%05d", $_;'`
set run6=`echo $run | perl -n -e 'printf "%06d", $_;'`
set file7=`echo $file | perl -n -e 'printf "%07d", $_;'`
cp -v /group/halld/www/halldweb/html/data_challenge/03/conditions/* .
echo ==setting up environment==
source setup_jlab.csh
echo ==environment==
printenv
echo ==copy logs==
./loop.csh 600 cp job.out /work/halld/data_challenge/03_sim/logs/${PBS_JOBNAME}.${AUGER_ID}.out >& /dev/null &
./loop.csh 600 cp job.err /work/halld/data_challenge/03_sim/logs/${PBS_JOBNAME}.${AUGER_ID}.err >& /dev/null &
echo ==run bggen==
cp -v run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' 5000000 run.ffr
rm -f fort.15
ln -s run.ffr fort.15
bggen
echo ==ls -l after bggen==
ls -l
echo ==run hdgeant==
hdgeant
echo ==ls -l after hdgeant==
ls -l
echo ==run mcsmear==
mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT_FIRST_EVENT=300 \
    -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm
echo ls -l after mcsmear
ls -l
echo ==translate to evio format==
hd_ana -PJANA:BATCH_MODE=1 -PPLUGINS=rawevent hdgeant_smeared.hddm
echo ==copy smeared==
mkdir -p /volatile/halld/data_challenge/$project/smeared
cp -pv rawevent_$run6.evio /volatile/halld/data_challenge/$project/smeared/hdgeant_smeared_${run5}_${file7}.evio
echo ==exit==
exit
echo ==analyze the evio file and copy out the output in this job for now==
hd_root -PPLUGINS=DAQ,TTab,monitoring_hists,danarest -PJANA:BATCH_MODE=1 rawevent_$run5.evio
mkdir -p /volatile/halld/data_challenge/$project/root
cp -pv hd_root.root /volatile/halld/data_challenge/$project/root/hd_root_${run5}_${file7}.root
mkdir -p /volatile/halld/data_challenge/$project/rest
cp -pv dana_rest.hddm /volatile/halld/data_challenge/$project/rest/dana_rest_${run5}_${file7}.hddm
