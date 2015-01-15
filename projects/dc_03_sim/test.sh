#!/bin/bash
project=dc_03_sim
run=9100
file=1
rundir=/u/scratch/$USER/test.$$
script=/home/$USER/halld/jproj/projects/$project/$project.csh
mkdir -p $rundir
cd $rundir
$script $project $run $file
exit
