#!/bin/csh
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
set run6=`echo $run | perl -n -e 'printf "%06d", $_;'`
set file7=`echo $file | perl -n -e 'printf "%07d", $_;'`
cp -v /group/halld/www/halldweb/html/data_challenge/03_2/conditions/* .
echo ==setting up environment==
source setup_jlab.csh
echo ==environment==
printenv
echo ==copy logs==
./loop.csh 600 cp job.out /work/halld/data_challenge/03_2_sim/logs/${PBS_JOBNAME}.${AUGER_ID}.out >& /dev/null &
./loop.csh 600 cp job.err /work/halld/data_challenge/03_2_sim/logs/${PBS_JOBNAME}.${AUGER_ID}.err >& /dev/null &
echo ==run bggen==
cp -v run.ffr.template run.ffr
gsr.pl '<random_number_seed>' $file run.ffr
gsr.pl '<run_number>' $run run.ffr
gsr.pl '<number_of_events>' 400000 run.ffr
rm -f fort.15
ln -s run.ffr fort.15
bggen
echo ==ls -l after bggen==
ls -l
echo ==run hdgeant==
hdgeant
rm -v bggen.hddm
echo ==ls -l after hdgeant==
ls -l
echo ==run mcsmear==
mcsmear -PJANA:BATCH_MODE=1 -PTHREAD_TIMEOUT_FIRST_EVENT=300 \
    -PTHREAD_TIMEOUT=300 -PNTHREADS=1 hdgeant.hddm
rm -v hdgeant.hddm
echo ==ls -l after mcsmear==
ls -l
echo ==run hd_ana, translate to evio format==
hd_ana -PJANA:BATCH_MODE=1 -PPLUGINS=rawevent hdgeant_smeared.hddm
rm -v hdgeant_smeared.hddm
echo ==ls -l after hd_ana==
ls -l
echo ==copy smeared==
mkdir -p /volatile/halld/data_challenge/$project/smeared
cp -pv rawevent_$run6.evio /volatile/halld/data_challenge/$project/smeared/hdgeant_smeared_${run6}_${file7}.evio
echo ==exit==
exit
