#!/bin/sh
cd /home/gluex/halld/jproj/projects/dc_02
pwd
lockfile=dc_02_driver.lock
if [ -f $lockfile ]
  then
  echo lock file found, exiting
  exit 1
fi
date > $lockfile
export PATH=/home/gluex/halld/jproj/scripts:$PATH
nq=`jobstat -u gluex | grep 900 | grep _20 | grep ' A ' | wc -l`
echo number queued is $nq
if [ $nq -lt 1000 ]
  then
    echo submitting
    jproj.pl dc_02 submit 500 9001
fi
echo looking for disk output
jproj.pl dc_02 update_output /volatile/halld/home/gluex/proj/dc_02/rest
echo doing jput
jproj.pl dc_02 jput /volatile/halld/home/gluex/proj/dc_02/rest /mss/halld/data_challenge/02/rest 0 1000
echo looking for tape files
jproj.pl dc_02 update_silo /mss/halld/data_challenge/02/rest
rm -v $lockfile
exit 0
