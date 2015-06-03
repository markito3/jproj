#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table bggen_cutoff; drop table bggen_cutoffJob"
jproj.pl bggen_cutoff create
jproj.pl bggen_cutoff populate 9401 1000
jproj.pl bggen_cutoff populate 9402 1000
jproj.pl bggen_cutoff populate 9403 1000
jproj.pl bggen_cutoff populate 9404 1000
jproj.pl bggen_cutoff populate 9405 1000
jproj.pl bggen_cutoff populate 9406 1000
jproj.pl bggen_cutoff populate 9407 1000
