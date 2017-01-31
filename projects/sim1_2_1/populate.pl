#!/usr/bin/env perl
open(RUNS, "/work/halld/home/gxproj3/rp2016-02-runs_events");
while (<RUNS>) {
    chomp;
    @t = split;
    $run = $t[0];
    $n = int($t[1]/25000*0.01 + 0.5);
    print "jproj.pl sim1_2_1 populate $run $n\n";
}
exit;
