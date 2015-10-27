#!/bin/bash
project=dc_03_2_sim
run=9100
file=1
rundir=/u/scratch/$USER/test.$$
script=`pwd`/$project.csh
mkdir -p $rundir
cd $rundir
$script $project $run $file
exit
