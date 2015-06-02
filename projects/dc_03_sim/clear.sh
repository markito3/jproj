#!/bin/sh
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table dc_03_sim, dc_03_simJob"
jproj.pl dc_03_sim create
jproj.pl dc_03_sim populate 9200 10
