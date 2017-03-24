#!/bin/bash
target=$1
maxjobs=$2
echo target = $target
if [ "X$maxjobs" = X ]
    then
    maxjobs=10000
fi
echo maxjobs = $maxjobs
rm -f watcher.tmp
swif status -workflow sim1_2_1 > watcher.tmp
dispatched=`grep dispatched watcher.tmp | grep -v undispatched | awk '{print $3}'`
echo dispatched = $dispatched
undispatched=`grep undispatched watcher.tmp | awk '{print $3}'`
if [ "X$undispatched" = X ]
    then
    undispatched=0
fi
echo undispatched = $undispatched
pending=`grep auger_pending watcher.tmp | awk '{print $3}'`
if [ "X$pending" = X ]
    then
    pending=0
fi
echo pending = $pending
deficit=$(($target-$dispatched-$undispatched))
echo deficit = $deficit
if [ "$deficit" -gt 0 -a "$pending" -eq 0 ]
    then
    if [ "$deficit" -gt "$maxjobs" ]
	then
	addjobs=$maxjobs
    else
	addjobs=$deficit
    fi
    echo add $addjobs job\(s\)
    jproj.pl sim1_2_1 add $addjobs
else
    echo no need for more
fi
