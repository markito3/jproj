#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table bggen_cutoff; drop table bggen_cutoffJob"
jproj.pl bggen_cutoff create
jproj.pl bggen_cutoff populate 9401 1
jproj.pl bggen_cutoff populate 9402 1
jproj.pl bggen_cutoff populate 9403 1
jproj.pl bggen_cutoff populate 9404 1
jproj.pl bggen_cutoff populate 9405 1
jproj.pl bggen_cutoff populate 9406 1
jproj.pl bggen_cutoff populate 9407 1
jproj.pl bggen_cutoff populate 9411 1
jproj.pl bggen_cutoff populate 9412 1
jproj.pl bggen_cutoff populate 9413 1
jproj.pl bggen_cutoff populate 9414 1
jproj.pl bggen_cutoff populate 9415 1
jproj.pl bggen_cutoff populate 9416 1
jproj.pl bggen_cutoff populate 9417 1
